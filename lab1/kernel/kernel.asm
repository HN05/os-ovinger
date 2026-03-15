
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000c117          	auipc	sp,0xc
    80000004:	8f813103          	ld	sp,-1800(sp) # 8000b8f8 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	1a4000ef          	jal	ra,800001ba <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <r_mhartid>:
#ifndef __ASSEMBLER__

// which hart (core) is this?
static inline uint64
r_mhartid()
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec22                	sd	s0,24(sp)
    80000020:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
    80000026:	fef43423          	sd	a5,-24(s0)
  return x;
    8000002a:	fe843783          	ld	a5,-24(s0)
}
    8000002e:	853e                	mv	a0,a5
    80000030:	6462                	ld	s0,24(sp)
    80000032:	6105                	addi	sp,sp,32
    80000034:	8082                	ret

0000000080000036 <r_mstatus>:
#define MSTATUS_MPP_U (0L << 11)
#define MSTATUS_MIE (1L << 3)    // machine-mode interrupt enable.

static inline uint64
r_mstatus()
{
    80000036:	1101                	addi	sp,sp,-32
    80000038:	ec22                	sd	s0,24(sp)
    8000003a:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000003c:	300027f3          	csrr	a5,mstatus
    80000040:	fef43423          	sd	a5,-24(s0)
  return x;
    80000044:	fe843783          	ld	a5,-24(s0)
}
    80000048:	853e                	mv	a0,a5
    8000004a:	6462                	ld	s0,24(sp)
    8000004c:	6105                	addi	sp,sp,32
    8000004e:	8082                	ret

0000000080000050 <w_mstatus>:

static inline void 
w_mstatus(uint64 x)
{
    80000050:	1101                	addi	sp,sp,-32
    80000052:	ec22                	sd	s0,24(sp)
    80000054:	1000                	addi	s0,sp,32
    80000056:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000005a:	fe843783          	ld	a5,-24(s0)
    8000005e:	30079073          	csrw	mstatus,a5
}
    80000062:	0001                	nop
    80000064:	6462                	ld	s0,24(sp)
    80000066:	6105                	addi	sp,sp,32
    80000068:	8082                	ret

000000008000006a <w_mepc>:
// machine exception program counter, holds the
// instruction address to which a return from
// exception will go.
static inline void 
w_mepc(uint64 x)
{
    8000006a:	1101                	addi	sp,sp,-32
    8000006c:	ec22                	sd	s0,24(sp)
    8000006e:	1000                	addi	s0,sp,32
    80000070:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000074:	fe843783          	ld	a5,-24(s0)
    80000078:	34179073          	csrw	mepc,a5
}
    8000007c:	0001                	nop
    8000007e:	6462                	ld	s0,24(sp)
    80000080:	6105                	addi	sp,sp,32
    80000082:	8082                	ret

0000000080000084 <r_sie>:
#define SIE_SEIE (1L << 9) // external
#define SIE_STIE (1L << 5) // timer
#define SIE_SSIE (1L << 1) // software
static inline uint64
r_sie()
{
    80000084:	1101                	addi	sp,sp,-32
    80000086:	ec22                	sd	s0,24(sp)
    80000088:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000008a:	104027f3          	csrr	a5,sie
    8000008e:	fef43423          	sd	a5,-24(s0)
  return x;
    80000092:	fe843783          	ld	a5,-24(s0)
}
    80000096:	853e                	mv	a0,a5
    80000098:	6462                	ld	s0,24(sp)
    8000009a:	6105                	addi	sp,sp,32
    8000009c:	8082                	ret

000000008000009e <w_sie>:

static inline void 
w_sie(uint64 x)
{
    8000009e:	1101                	addi	sp,sp,-32
    800000a0:	ec22                	sd	s0,24(sp)
    800000a2:	1000                	addi	s0,sp,32
    800000a4:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a8:	fe843783          	ld	a5,-24(s0)
    800000ac:	10479073          	csrw	sie,a5
}
    800000b0:	0001                	nop
    800000b2:	6462                	ld	s0,24(sp)
    800000b4:	6105                	addi	sp,sp,32
    800000b6:	8082                	ret

00000000800000b8 <r_mie>:
#define MIE_MEIE (1L << 11) // external
#define MIE_MTIE (1L << 7)  // timer
#define MIE_MSIE (1L << 3)  // software
static inline uint64
r_mie()
{
    800000b8:	1101                	addi	sp,sp,-32
    800000ba:	ec22                	sd	s0,24(sp)
    800000bc:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    800000be:	304027f3          	csrr	a5,mie
    800000c2:	fef43423          	sd	a5,-24(s0)
  return x;
    800000c6:	fe843783          	ld	a5,-24(s0)
}
    800000ca:	853e                	mv	a0,a5
    800000cc:	6462                	ld	s0,24(sp)
    800000ce:	6105                	addi	sp,sp,32
    800000d0:	8082                	ret

00000000800000d2 <w_mie>:

static inline void 
w_mie(uint64 x)
{
    800000d2:	1101                	addi	sp,sp,-32
    800000d4:	ec22                	sd	s0,24(sp)
    800000d6:	1000                	addi	s0,sp,32
    800000d8:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mie, %0" : : "r" (x));
    800000dc:	fe843783          	ld	a5,-24(s0)
    800000e0:	30479073          	csrw	mie,a5
}
    800000e4:	0001                	nop
    800000e6:	6462                	ld	s0,24(sp)
    800000e8:	6105                	addi	sp,sp,32
    800000ea:	8082                	ret

00000000800000ec <w_medeleg>:
  return x;
}

static inline void 
w_medeleg(uint64 x)
{
    800000ec:	1101                	addi	sp,sp,-32
    800000ee:	ec22                	sd	s0,24(sp)
    800000f0:	1000                	addi	s0,sp,32
    800000f2:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000f6:	fe843783          	ld	a5,-24(s0)
    800000fa:	30279073          	csrw	medeleg,a5
}
    800000fe:	0001                	nop
    80000100:	6462                	ld	s0,24(sp)
    80000102:	6105                	addi	sp,sp,32
    80000104:	8082                	ret

0000000080000106 <w_mideleg>:
  return x;
}

static inline void 
w_mideleg(uint64 x)
{
    80000106:	1101                	addi	sp,sp,-32
    80000108:	ec22                	sd	s0,24(sp)
    8000010a:	1000                	addi	s0,sp,32
    8000010c:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80000110:	fe843783          	ld	a5,-24(s0)
    80000114:	30379073          	csrw	mideleg,a5
}
    80000118:	0001                	nop
    8000011a:	6462                	ld	s0,24(sp)
    8000011c:	6105                	addi	sp,sp,32
    8000011e:	8082                	ret

0000000080000120 <w_mtvec>:
}

// Machine-mode interrupt vector
static inline void 
w_mtvec(uint64 x)
{
    80000120:	1101                	addi	sp,sp,-32
    80000122:	ec22                	sd	s0,24(sp)
    80000124:	1000                	addi	s0,sp,32
    80000126:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000012a:	fe843783          	ld	a5,-24(s0)
    8000012e:	30579073          	csrw	mtvec,a5
}
    80000132:	0001                	nop
    80000134:	6462                	ld	s0,24(sp)
    80000136:	6105                	addi	sp,sp,32
    80000138:	8082                	ret

000000008000013a <w_pmpcfg0>:

// Physical Memory Protection
static inline void
w_pmpcfg0(uint64 x)
{
    8000013a:	1101                	addi	sp,sp,-32
    8000013c:	ec22                	sd	s0,24(sp)
    8000013e:	1000                	addi	s0,sp,32
    80000140:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80000144:	fe843783          	ld	a5,-24(s0)
    80000148:	3a079073          	csrw	pmpcfg0,a5
}
    8000014c:	0001                	nop
    8000014e:	6462                	ld	s0,24(sp)
    80000150:	6105                	addi	sp,sp,32
    80000152:	8082                	ret

0000000080000154 <w_pmpaddr0>:

static inline void
w_pmpaddr0(uint64 x)
{
    80000154:	1101                	addi	sp,sp,-32
    80000156:	ec22                	sd	s0,24(sp)
    80000158:	1000                	addi	s0,sp,32
    8000015a:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    8000015e:	fe843783          	ld	a5,-24(s0)
    80000162:	3b079073          	csrw	pmpaddr0,a5
}
    80000166:	0001                	nop
    80000168:	6462                	ld	s0,24(sp)
    8000016a:	6105                	addi	sp,sp,32
    8000016c:	8082                	ret

000000008000016e <w_satp>:

// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
    8000016e:	1101                	addi	sp,sp,-32
    80000170:	ec22                	sd	s0,24(sp)
    80000172:	1000                	addi	s0,sp,32
    80000174:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw satp, %0" : : "r" (x));
    80000178:	fe843783          	ld	a5,-24(s0)
    8000017c:	18079073          	csrw	satp,a5
}
    80000180:	0001                	nop
    80000182:	6462                	ld	s0,24(sp)
    80000184:	6105                	addi	sp,sp,32
    80000186:	8082                	ret

0000000080000188 <w_mscratch>:
  return x;
}

static inline void 
w_mscratch(uint64 x)
{
    80000188:	1101                	addi	sp,sp,-32
    8000018a:	ec22                	sd	s0,24(sp)
    8000018c:	1000                	addi	s0,sp,32
    8000018e:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000192:	fe843783          	ld	a5,-24(s0)
    80000196:	34079073          	csrw	mscratch,a5
}
    8000019a:	0001                	nop
    8000019c:	6462                	ld	s0,24(sp)
    8000019e:	6105                	addi	sp,sp,32
    800001a0:	8082                	ret

00000000800001a2 <w_tp>:
  return x;
}

static inline void 
w_tp(uint64 x)
{
    800001a2:	1101                	addi	sp,sp,-32
    800001a4:	ec22                	sd	s0,24(sp)
    800001a6:	1000                	addi	s0,sp,32
    800001a8:	fea43423          	sd	a0,-24(s0)
  asm volatile("mv tp, %0" : : "r" (x));
    800001ac:	fe843783          	ld	a5,-24(s0)
    800001b0:	823e                	mv	tp,a5
}
    800001b2:	0001                	nop
    800001b4:	6462                	ld	s0,24(sp)
    800001b6:	6105                	addi	sp,sp,32
    800001b8:	8082                	ret

00000000800001ba <start>:
extern void timervec();

// entry.S jumps here in machine mode on stack0.
void
start()
{
    800001ba:	1101                	addi	sp,sp,-32
    800001bc:	ec06                	sd	ra,24(sp)
    800001be:	e822                	sd	s0,16(sp)
    800001c0:	1000                	addi	s0,sp,32
  // set M Previous Privilege mode to Supervisor, for mret.
  unsigned long x = r_mstatus();
    800001c2:	00000097          	auipc	ra,0x0
    800001c6:	e74080e7          	jalr	-396(ra) # 80000036 <r_mstatus>
    800001ca:	fea43423          	sd	a0,-24(s0)
  x &= ~MSTATUS_MPP_MASK;
    800001ce:	fe843703          	ld	a4,-24(s0)
    800001d2:	77f9                	lui	a5,0xffffe
    800001d4:	7ff78793          	addi	a5,a5,2047 # ffffffffffffe7ff <end+0xffffffff7ffd9a47>
    800001d8:	8ff9                	and	a5,a5,a4
    800001da:	fef43423          	sd	a5,-24(s0)
  x |= MSTATUS_MPP_S;
    800001de:	fe843703          	ld	a4,-24(s0)
    800001e2:	6785                	lui	a5,0x1
    800001e4:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    800001e8:	8fd9                	or	a5,a5,a4
    800001ea:	fef43423          	sd	a5,-24(s0)
  w_mstatus(x);
    800001ee:	fe843503          	ld	a0,-24(s0)
    800001f2:	00000097          	auipc	ra,0x0
    800001f6:	e5e080e7          	jalr	-418(ra) # 80000050 <w_mstatus>

  // set M Exception Program Counter to main, for mret.
  // requires gcc -mcmodel=medany
  w_mepc((uint64)main);
    800001fa:	00001797          	auipc	a5,0x1
    800001fe:	60878793          	addi	a5,a5,1544 # 80001802 <main>
    80000202:	853e                	mv	a0,a5
    80000204:	00000097          	auipc	ra,0x0
    80000208:	e66080e7          	jalr	-410(ra) # 8000006a <w_mepc>

  // disable paging for now.
  w_satp(0);
    8000020c:	4501                	li	a0,0
    8000020e:	00000097          	auipc	ra,0x0
    80000212:	f60080e7          	jalr	-160(ra) # 8000016e <w_satp>

  // delegate all interrupts and exceptions to supervisor mode.
  w_medeleg(0xffff);
    80000216:	67c1                	lui	a5,0x10
    80000218:	fff78513          	addi	a0,a5,-1 # ffff <_entry-0x7fff0001>
    8000021c:	00000097          	auipc	ra,0x0
    80000220:	ed0080e7          	jalr	-304(ra) # 800000ec <w_medeleg>
  w_mideleg(0xffff);
    80000224:	67c1                	lui	a5,0x10
    80000226:	fff78513          	addi	a0,a5,-1 # ffff <_entry-0x7fff0001>
    8000022a:	00000097          	auipc	ra,0x0
    8000022e:	edc080e7          	jalr	-292(ra) # 80000106 <w_mideleg>
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000232:	00000097          	auipc	ra,0x0
    80000236:	e52080e7          	jalr	-430(ra) # 80000084 <r_sie>
    8000023a:	87aa                	mv	a5,a0
    8000023c:	2227e793          	ori	a5,a5,546
    80000240:	853e                	mv	a0,a5
    80000242:	00000097          	auipc	ra,0x0
    80000246:	e5c080e7          	jalr	-420(ra) # 8000009e <w_sie>

  // configure Physical Memory Protection to give supervisor mode
  // access to all of physical memory.
  w_pmpaddr0(0x3fffffffffffffull);
    8000024a:	57fd                	li	a5,-1
    8000024c:	00a7d513          	srli	a0,a5,0xa
    80000250:	00000097          	auipc	ra,0x0
    80000254:	f04080e7          	jalr	-252(ra) # 80000154 <w_pmpaddr0>
  w_pmpcfg0(0xf);
    80000258:	453d                	li	a0,15
    8000025a:	00000097          	auipc	ra,0x0
    8000025e:	ee0080e7          	jalr	-288(ra) # 8000013a <w_pmpcfg0>

  // ask for clock interrupts.
  timerinit();
    80000262:	00000097          	auipc	ra,0x0
    80000266:	032080e7          	jalr	50(ra) # 80000294 <timerinit>

  // keep each CPU's hartid in its tp register, for cpuid().
  int id = r_mhartid();
    8000026a:	00000097          	auipc	ra,0x0
    8000026e:	db2080e7          	jalr	-590(ra) # 8000001c <r_mhartid>
    80000272:	87aa                	mv	a5,a0
    80000274:	fef42223          	sw	a5,-28(s0)
  w_tp(id);
    80000278:	fe442783          	lw	a5,-28(s0)
    8000027c:	853e                	mv	a0,a5
    8000027e:	00000097          	auipc	ra,0x0
    80000282:	f24080e7          	jalr	-220(ra) # 800001a2 <w_tp>

  // switch to supervisor mode and jump to main().
  asm volatile("mret");
    80000286:	30200073          	mret
}
    8000028a:	0001                	nop
    8000028c:	60e2                	ld	ra,24(sp)
    8000028e:	6442                	ld	s0,16(sp)
    80000290:	6105                	addi	sp,sp,32
    80000292:	8082                	ret

0000000080000294 <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    80000294:	1101                	addi	sp,sp,-32
    80000296:	ec06                	sd	ra,24(sp)
    80000298:	e822                	sd	s0,16(sp)
    8000029a:	1000                	addi	s0,sp,32
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    8000029c:	00000097          	auipc	ra,0x0
    800002a0:	d80080e7          	jalr	-640(ra) # 8000001c <r_mhartid>
    800002a4:	87aa                	mv	a5,a0
    800002a6:	fef42623          	sw	a5,-20(s0)

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
    800002aa:	000f47b7          	lui	a5,0xf4
    800002ae:	24078793          	addi	a5,a5,576 # f4240 <_entry-0x7ff0bdc0>
    800002b2:	fef42423          	sw	a5,-24(s0)
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    800002b6:	0200c7b7          	lui	a5,0x200c
    800002ba:	17e1                	addi	a5,a5,-8 # 200bff8 <_entry-0x7dff4008>
    800002bc:	6398                	ld	a4,0(a5)
    800002be:	fe842783          	lw	a5,-24(s0)
    800002c2:	fec42683          	lw	a3,-20(s0)
    800002c6:	0036969b          	slliw	a3,a3,0x3
    800002ca:	2681                	sext.w	a3,a3
    800002cc:	8636                	mv	a2,a3
    800002ce:	020046b7          	lui	a3,0x2004
    800002d2:	96b2                	add	a3,a3,a2
    800002d4:	97ba                	add	a5,a5,a4
    800002d6:	e29c                	sd	a5,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    800002d8:	fec42703          	lw	a4,-20(s0)
    800002dc:	87ba                	mv	a5,a4
    800002de:	078a                	slli	a5,a5,0x2
    800002e0:	97ba                	add	a5,a5,a4
    800002e2:	078e                	slli	a5,a5,0x3
    800002e4:	00013717          	auipc	a4,0x13
    800002e8:	65c70713          	addi	a4,a4,1628 # 80013940 <timer_scratch>
    800002ec:	97ba                	add	a5,a5,a4
    800002ee:	fef43023          	sd	a5,-32(s0)
  scratch[3] = CLINT_MTIMECMP(id);
    800002f2:	fec42783          	lw	a5,-20(s0)
    800002f6:	0037979b          	slliw	a5,a5,0x3
    800002fa:	2781                	sext.w	a5,a5
    800002fc:	873e                	mv	a4,a5
    800002fe:	020047b7          	lui	a5,0x2004
    80000302:	973e                	add	a4,a4,a5
    80000304:	fe043783          	ld	a5,-32(s0)
    80000308:	07e1                	addi	a5,a5,24 # 2004018 <_entry-0x7dffbfe8>
    8000030a:	e398                	sd	a4,0(a5)
  scratch[4] = interval;
    8000030c:	fe043783          	ld	a5,-32(s0)
    80000310:	02078793          	addi	a5,a5,32
    80000314:	fe842703          	lw	a4,-24(s0)
    80000318:	e398                	sd	a4,0(a5)
  w_mscratch((uint64)scratch);
    8000031a:	fe043783          	ld	a5,-32(s0)
    8000031e:	853e                	mv	a0,a5
    80000320:	00000097          	auipc	ra,0x0
    80000324:	e68080e7          	jalr	-408(ra) # 80000188 <w_mscratch>

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);
    80000328:	00009797          	auipc	a5,0x9
    8000032c:	9d878793          	addi	a5,a5,-1576 # 80008d00 <timervec>
    80000330:	853e                	mv	a0,a5
    80000332:	00000097          	auipc	ra,0x0
    80000336:	dee080e7          	jalr	-530(ra) # 80000120 <w_mtvec>

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000033a:	00000097          	auipc	ra,0x0
    8000033e:	cfc080e7          	jalr	-772(ra) # 80000036 <r_mstatus>
    80000342:	87aa                	mv	a5,a0
    80000344:	0087e793          	ori	a5,a5,8
    80000348:	853e                	mv	a0,a5
    8000034a:	00000097          	auipc	ra,0x0
    8000034e:	d06080e7          	jalr	-762(ra) # 80000050 <w_mstatus>

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000352:	00000097          	auipc	ra,0x0
    80000356:	d66080e7          	jalr	-666(ra) # 800000b8 <r_mie>
    8000035a:	87aa                	mv	a5,a0
    8000035c:	0807e793          	ori	a5,a5,128
    80000360:	853e                	mv	a0,a5
    80000362:	00000097          	auipc	ra,0x0
    80000366:	d70080e7          	jalr	-656(ra) # 800000d2 <w_mie>
}
    8000036a:	0001                	nop
    8000036c:	60e2                	ld	ra,24(sp)
    8000036e:	6442                	ld	s0,16(sp)
    80000370:	6105                	addi	sp,sp,32
    80000372:	8082                	ret

0000000080000374 <consputc>:
// called by printf(), and to echo input characters,
// but not from write().
//
void
consputc(int c)
{
    80000374:	1101                	addi	sp,sp,-32
    80000376:	ec06                	sd	ra,24(sp)
    80000378:	e822                	sd	s0,16(sp)
    8000037a:	1000                	addi	s0,sp,32
    8000037c:	87aa                	mv	a5,a0
    8000037e:	fef42623          	sw	a5,-20(s0)
  if(c == BACKSPACE){
    80000382:	fec42783          	lw	a5,-20(s0)
    80000386:	0007871b          	sext.w	a4,a5
    8000038a:	10000793          	li	a5,256
    8000038e:	02f71363          	bne	a4,a5,800003b4 <consputc+0x40>
    // if the user typed backspace, overwrite with a space.
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000392:	4521                	li	a0,8
    80000394:	00001097          	auipc	ra,0x1
    80000398:	ab6080e7          	jalr	-1354(ra) # 80000e4a <uartputc_sync>
    8000039c:	02000513          	li	a0,32
    800003a0:	00001097          	auipc	ra,0x1
    800003a4:	aaa080e7          	jalr	-1366(ra) # 80000e4a <uartputc_sync>
    800003a8:	4521                	li	a0,8
    800003aa:	00001097          	auipc	ra,0x1
    800003ae:	aa0080e7          	jalr	-1376(ra) # 80000e4a <uartputc_sync>
  } else {
    uartputc_sync(c);
  }
}
    800003b2:	a801                	j	800003c2 <consputc+0x4e>
    uartputc_sync(c);
    800003b4:	fec42783          	lw	a5,-20(s0)
    800003b8:	853e                	mv	a0,a5
    800003ba:	00001097          	auipc	ra,0x1
    800003be:	a90080e7          	jalr	-1392(ra) # 80000e4a <uartputc_sync>
}
    800003c2:	0001                	nop
    800003c4:	60e2                	ld	ra,24(sp)
    800003c6:	6442                	ld	s0,16(sp)
    800003c8:	6105                	addi	sp,sp,32
    800003ca:	8082                	ret

00000000800003cc <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800003cc:	7179                	addi	sp,sp,-48
    800003ce:	f406                	sd	ra,40(sp)
    800003d0:	f022                	sd	s0,32(sp)
    800003d2:	1800                	addi	s0,sp,48
    800003d4:	87aa                	mv	a5,a0
    800003d6:	fcb43823          	sd	a1,-48(s0)
    800003da:	8732                	mv	a4,a2
    800003dc:	fcf42e23          	sw	a5,-36(s0)
    800003e0:	87ba                	mv	a5,a4
    800003e2:	fcf42c23          	sw	a5,-40(s0)
  int i;

  for(i = 0; i < n; i++){
    800003e6:	fe042623          	sw	zero,-20(s0)
    800003ea:	a0a1                	j	80000432 <consolewrite+0x66>
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800003ec:	fec42703          	lw	a4,-20(s0)
    800003f0:	fd043783          	ld	a5,-48(s0)
    800003f4:	00f70633          	add	a2,a4,a5
    800003f8:	fdc42703          	lw	a4,-36(s0)
    800003fc:	feb40793          	addi	a5,s0,-21
    80000400:	4685                	li	a3,1
    80000402:	85ba                	mv	a1,a4
    80000404:	853e                	mv	a0,a5
    80000406:	00003097          	auipc	ra,0x3
    8000040a:	29a080e7          	jalr	666(ra) # 800036a0 <either_copyin>
    8000040e:	87aa                	mv	a5,a0
    80000410:	873e                	mv	a4,a5
    80000412:	57fd                	li	a5,-1
    80000414:	02f70963          	beq	a4,a5,80000446 <consolewrite+0x7a>
      break;
    uartputc(c);
    80000418:	feb44783          	lbu	a5,-21(s0)
    8000041c:	2781                	sext.w	a5,a5
    8000041e:	853e                	mv	a0,a5
    80000420:	00001097          	auipc	ra,0x1
    80000424:	96c080e7          	jalr	-1684(ra) # 80000d8c <uartputc>
  for(i = 0; i < n; i++){
    80000428:	fec42783          	lw	a5,-20(s0)
    8000042c:	2785                	addiw	a5,a5,1
    8000042e:	fef42623          	sw	a5,-20(s0)
    80000432:	fec42783          	lw	a5,-20(s0)
    80000436:	873e                	mv	a4,a5
    80000438:	fd842783          	lw	a5,-40(s0)
    8000043c:	2701                	sext.w	a4,a4
    8000043e:	2781                	sext.w	a5,a5
    80000440:	faf746e3          	blt	a4,a5,800003ec <consolewrite+0x20>
    80000444:	a011                	j	80000448 <consolewrite+0x7c>
      break;
    80000446:	0001                	nop
  }

  return i;
    80000448:	fec42783          	lw	a5,-20(s0)
}
    8000044c:	853e                	mv	a0,a5
    8000044e:	70a2                	ld	ra,40(sp)
    80000450:	7402                	ld	s0,32(sp)
    80000452:	6145                	addi	sp,sp,48
    80000454:	8082                	ret

0000000080000456 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000456:	7179                	addi	sp,sp,-48
    80000458:	f406                	sd	ra,40(sp)
    8000045a:	f022                	sd	s0,32(sp)
    8000045c:	1800                	addi	s0,sp,48
    8000045e:	87aa                	mv	a5,a0
    80000460:	fcb43823          	sd	a1,-48(s0)
    80000464:	8732                	mv	a4,a2
    80000466:	fcf42e23          	sw	a5,-36(s0)
    8000046a:	87ba                	mv	a5,a4
    8000046c:	fcf42c23          	sw	a5,-40(s0)
  uint target;
  int c;
  char cbuf;

  target = n;
    80000470:	fd842783          	lw	a5,-40(s0)
    80000474:	fef42623          	sw	a5,-20(s0)
  acquire(&cons.lock);
    80000478:	00013517          	auipc	a0,0x13
    8000047c:	60850513          	addi	a0,a0,1544 # 80013a80 <cons>
    80000480:	00001097          	auipc	ra,0x1
    80000484:	df8080e7          	jalr	-520(ra) # 80001278 <acquire>
  while(n > 0){
    80000488:	a23d                	j	800005b6 <consoleread+0x160>
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
      if(killed(myproc())){
    8000048a:	00002097          	auipc	ra,0x2
    8000048e:	3b6080e7          	jalr	950(ra) # 80002840 <myproc>
    80000492:	87aa                	mv	a5,a0
    80000494:	853e                	mv	a0,a5
    80000496:	00003097          	auipc	ra,0x3
    8000049a:	156080e7          	jalr	342(ra) # 800035ec <killed>
    8000049e:	87aa                	mv	a5,a0
    800004a0:	cb99                	beqz	a5,800004b6 <consoleread+0x60>
        release(&cons.lock);
    800004a2:	00013517          	auipc	a0,0x13
    800004a6:	5de50513          	addi	a0,a0,1502 # 80013a80 <cons>
    800004aa:	00001097          	auipc	ra,0x1
    800004ae:	e32080e7          	jalr	-462(ra) # 800012dc <release>
        return -1;
    800004b2:	57fd                	li	a5,-1
    800004b4:	aa25                	j	800005ec <consoleread+0x196>
      }
      sleep(&cons.r, &cons.lock);
    800004b6:	00013597          	auipc	a1,0x13
    800004ba:	5ca58593          	addi	a1,a1,1482 # 80013a80 <cons>
    800004be:	00013517          	auipc	a0,0x13
    800004c2:	65a50513          	addi	a0,a0,1626 # 80013b18 <cons+0x98>
    800004c6:	00003097          	auipc	ra,0x3
    800004ca:	f3c080e7          	jalr	-196(ra) # 80003402 <sleep>
    while(cons.r == cons.w){
    800004ce:	00013797          	auipc	a5,0x13
    800004d2:	5b278793          	addi	a5,a5,1458 # 80013a80 <cons>
    800004d6:	0987a703          	lw	a4,152(a5)
    800004da:	00013797          	auipc	a5,0x13
    800004de:	5a678793          	addi	a5,a5,1446 # 80013a80 <cons>
    800004e2:	09c7a783          	lw	a5,156(a5)
    800004e6:	faf702e3          	beq	a4,a5,8000048a <consoleread+0x34>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800004ea:	00013797          	auipc	a5,0x13
    800004ee:	59678793          	addi	a5,a5,1430 # 80013a80 <cons>
    800004f2:	0987a783          	lw	a5,152(a5)
    800004f6:	2781                	sext.w	a5,a5
    800004f8:	0017871b          	addiw	a4,a5,1
    800004fc:	0007069b          	sext.w	a3,a4
    80000500:	00013717          	auipc	a4,0x13
    80000504:	58070713          	addi	a4,a4,1408 # 80013a80 <cons>
    80000508:	08d72c23          	sw	a3,152(a4)
    8000050c:	07f7f793          	andi	a5,a5,127
    80000510:	2781                	sext.w	a5,a5
    80000512:	00013717          	auipc	a4,0x13
    80000516:	56e70713          	addi	a4,a4,1390 # 80013a80 <cons>
    8000051a:	1782                	slli	a5,a5,0x20
    8000051c:	9381                	srli	a5,a5,0x20
    8000051e:	97ba                	add	a5,a5,a4
    80000520:	0187c783          	lbu	a5,24(a5)
    80000524:	fef42423          	sw	a5,-24(s0)

    if(c == C('D')){  // end-of-file
    80000528:	fe842783          	lw	a5,-24(s0)
    8000052c:	0007871b          	sext.w	a4,a5
    80000530:	4791                	li	a5,4
    80000532:	02f71963          	bne	a4,a5,80000564 <consoleread+0x10e>
      if(n < target){
    80000536:	fd842703          	lw	a4,-40(s0)
    8000053a:	fec42783          	lw	a5,-20(s0)
    8000053e:	2781                	sext.w	a5,a5
    80000540:	08f77163          	bgeu	a4,a5,800005c2 <consoleread+0x16c>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        cons.r--;
    80000544:	00013797          	auipc	a5,0x13
    80000548:	53c78793          	addi	a5,a5,1340 # 80013a80 <cons>
    8000054c:	0987a783          	lw	a5,152(a5)
    80000550:	37fd                	addiw	a5,a5,-1
    80000552:	0007871b          	sext.w	a4,a5
    80000556:	00013797          	auipc	a5,0x13
    8000055a:	52a78793          	addi	a5,a5,1322 # 80013a80 <cons>
    8000055e:	08e7ac23          	sw	a4,152(a5)
      }
      break;
    80000562:	a085                	j	800005c2 <consoleread+0x16c>
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000564:	fe842783          	lw	a5,-24(s0)
    80000568:	0ff7f793          	zext.b	a5,a5
    8000056c:	fef403a3          	sb	a5,-25(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000570:	fe740713          	addi	a4,s0,-25
    80000574:	fdc42783          	lw	a5,-36(s0)
    80000578:	4685                	li	a3,1
    8000057a:	863a                	mv	a2,a4
    8000057c:	fd043583          	ld	a1,-48(s0)
    80000580:	853e                	mv	a0,a5
    80000582:	00003097          	auipc	ra,0x3
    80000586:	0aa080e7          	jalr	170(ra) # 8000362c <either_copyout>
    8000058a:	87aa                	mv	a5,a0
    8000058c:	873e                	mv	a4,a5
    8000058e:	57fd                	li	a5,-1
    80000590:	02f70b63          	beq	a4,a5,800005c6 <consoleread+0x170>
      break;

    dst++;
    80000594:	fd043783          	ld	a5,-48(s0)
    80000598:	0785                	addi	a5,a5,1
    8000059a:	fcf43823          	sd	a5,-48(s0)
    --n;
    8000059e:	fd842783          	lw	a5,-40(s0)
    800005a2:	37fd                	addiw	a5,a5,-1
    800005a4:	fcf42c23          	sw	a5,-40(s0)

    if(c == '\n'){
    800005a8:	fe842783          	lw	a5,-24(s0)
    800005ac:	0007871b          	sext.w	a4,a5
    800005b0:	47a9                	li	a5,10
    800005b2:	00f70c63          	beq	a4,a5,800005ca <consoleread+0x174>
  while(n > 0){
    800005b6:	fd842783          	lw	a5,-40(s0)
    800005ba:	2781                	sext.w	a5,a5
    800005bc:	f0f049e3          	bgtz	a5,800004ce <consoleread+0x78>
    800005c0:	a031                	j	800005cc <consoleread+0x176>
      break;
    800005c2:	0001                	nop
    800005c4:	a021                	j	800005cc <consoleread+0x176>
      break;
    800005c6:	0001                	nop
    800005c8:	a011                	j	800005cc <consoleread+0x176>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    800005ca:	0001                	nop
    }
  }
  release(&cons.lock);
    800005cc:	00013517          	auipc	a0,0x13
    800005d0:	4b450513          	addi	a0,a0,1204 # 80013a80 <cons>
    800005d4:	00001097          	auipc	ra,0x1
    800005d8:	d08080e7          	jalr	-760(ra) # 800012dc <release>

  return target - n;
    800005dc:	fd842783          	lw	a5,-40(s0)
    800005e0:	fec42703          	lw	a4,-20(s0)
    800005e4:	40f707bb          	subw	a5,a4,a5
    800005e8:	2781                	sext.w	a5,a5
    800005ea:	2781                	sext.w	a5,a5
}
    800005ec:	853e                	mv	a0,a5
    800005ee:	70a2                	ld	ra,40(sp)
    800005f0:	7402                	ld	s0,32(sp)
    800005f2:	6145                	addi	sp,sp,48
    800005f4:	8082                	ret

00000000800005f6 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800005f6:	1101                	addi	sp,sp,-32
    800005f8:	ec06                	sd	ra,24(sp)
    800005fa:	e822                	sd	s0,16(sp)
    800005fc:	1000                	addi	s0,sp,32
    800005fe:	87aa                	mv	a5,a0
    80000600:	fef42623          	sw	a5,-20(s0)
  acquire(&cons.lock);
    80000604:	00013517          	auipc	a0,0x13
    80000608:	47c50513          	addi	a0,a0,1148 # 80013a80 <cons>
    8000060c:	00001097          	auipc	ra,0x1
    80000610:	c6c080e7          	jalr	-916(ra) # 80001278 <acquire>

  switch(c){
    80000614:	fec42783          	lw	a5,-20(s0)
    80000618:	0007871b          	sext.w	a4,a5
    8000061c:	07f00793          	li	a5,127
    80000620:	0cf70763          	beq	a4,a5,800006ee <consoleintr+0xf8>
    80000624:	fec42783          	lw	a5,-20(s0)
    80000628:	0007871b          	sext.w	a4,a5
    8000062c:	07f00793          	li	a5,127
    80000630:	10e7c363          	blt	a5,a4,80000736 <consoleintr+0x140>
    80000634:	fec42783          	lw	a5,-20(s0)
    80000638:	0007871b          	sext.w	a4,a5
    8000063c:	47d5                	li	a5,21
    8000063e:	06f70163          	beq	a4,a5,800006a0 <consoleintr+0xaa>
    80000642:	fec42783          	lw	a5,-20(s0)
    80000646:	0007871b          	sext.w	a4,a5
    8000064a:	47d5                	li	a5,21
    8000064c:	0ee7c563          	blt	a5,a4,80000736 <consoleintr+0x140>
    80000650:	fec42783          	lw	a5,-20(s0)
    80000654:	0007871b          	sext.w	a4,a5
    80000658:	47a1                	li	a5,8
    8000065a:	08f70a63          	beq	a4,a5,800006ee <consoleintr+0xf8>
    8000065e:	fec42783          	lw	a5,-20(s0)
    80000662:	0007871b          	sext.w	a4,a5
    80000666:	47c1                	li	a5,16
    80000668:	0cf71763          	bne	a4,a5,80000736 <consoleintr+0x140>
  case C('P'):  // Print process list.
    procdump();
    8000066c:	00003097          	auipc	ra,0x3
    80000670:	0a8080e7          	jalr	168(ra) # 80003714 <procdump>
    break;
    80000674:	aad9                	j	8000084a <consoleintr+0x254>
  case C('U'):  // Kill line.
    while(cons.e != cons.w &&
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
      cons.e--;
    80000676:	00013797          	auipc	a5,0x13
    8000067a:	40a78793          	addi	a5,a5,1034 # 80013a80 <cons>
    8000067e:	0a07a783          	lw	a5,160(a5)
    80000682:	37fd                	addiw	a5,a5,-1
    80000684:	0007871b          	sext.w	a4,a5
    80000688:	00013797          	auipc	a5,0x13
    8000068c:	3f878793          	addi	a5,a5,1016 # 80013a80 <cons>
    80000690:	0ae7a023          	sw	a4,160(a5)
      consputc(BACKSPACE);
    80000694:	10000513          	li	a0,256
    80000698:	00000097          	auipc	ra,0x0
    8000069c:	cdc080e7          	jalr	-804(ra) # 80000374 <consputc>
    while(cons.e != cons.w &&
    800006a0:	00013797          	auipc	a5,0x13
    800006a4:	3e078793          	addi	a5,a5,992 # 80013a80 <cons>
    800006a8:	0a07a703          	lw	a4,160(a5)
    800006ac:	00013797          	auipc	a5,0x13
    800006b0:	3d478793          	addi	a5,a5,980 # 80013a80 <cons>
    800006b4:	09c7a783          	lw	a5,156(a5)
    800006b8:	18f70463          	beq	a4,a5,80000840 <consoleintr+0x24a>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800006bc:	00013797          	auipc	a5,0x13
    800006c0:	3c478793          	addi	a5,a5,964 # 80013a80 <cons>
    800006c4:	0a07a783          	lw	a5,160(a5)
    800006c8:	37fd                	addiw	a5,a5,-1
    800006ca:	2781                	sext.w	a5,a5
    800006cc:	07f7f793          	andi	a5,a5,127
    800006d0:	2781                	sext.w	a5,a5
    800006d2:	00013717          	auipc	a4,0x13
    800006d6:	3ae70713          	addi	a4,a4,942 # 80013a80 <cons>
    800006da:	1782                	slli	a5,a5,0x20
    800006dc:	9381                	srli	a5,a5,0x20
    800006de:	97ba                	add	a5,a5,a4
    800006e0:	0187c783          	lbu	a5,24(a5)
    while(cons.e != cons.w &&
    800006e4:	873e                	mv	a4,a5
    800006e6:	47a9                	li	a5,10
    800006e8:	f8f717e3          	bne	a4,a5,80000676 <consoleintr+0x80>
    }
    break;
    800006ec:	aa91                	j	80000840 <consoleintr+0x24a>
  case C('H'): // Backspace
  case '\x7f': // Delete key
    if(cons.e != cons.w){
    800006ee:	00013797          	auipc	a5,0x13
    800006f2:	39278793          	addi	a5,a5,914 # 80013a80 <cons>
    800006f6:	0a07a703          	lw	a4,160(a5)
    800006fa:	00013797          	auipc	a5,0x13
    800006fe:	38678793          	addi	a5,a5,902 # 80013a80 <cons>
    80000702:	09c7a783          	lw	a5,156(a5)
    80000706:	12f70f63          	beq	a4,a5,80000844 <consoleintr+0x24e>
      cons.e--;
    8000070a:	00013797          	auipc	a5,0x13
    8000070e:	37678793          	addi	a5,a5,886 # 80013a80 <cons>
    80000712:	0a07a783          	lw	a5,160(a5)
    80000716:	37fd                	addiw	a5,a5,-1
    80000718:	0007871b          	sext.w	a4,a5
    8000071c:	00013797          	auipc	a5,0x13
    80000720:	36478793          	addi	a5,a5,868 # 80013a80 <cons>
    80000724:	0ae7a023          	sw	a4,160(a5)
      consputc(BACKSPACE);
    80000728:	10000513          	li	a0,256
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	c48080e7          	jalr	-952(ra) # 80000374 <consputc>
    }
    break;
    80000734:	aa01                	j	80000844 <consoleintr+0x24e>
  default:
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000736:	fec42783          	lw	a5,-20(s0)
    8000073a:	2781                	sext.w	a5,a5
    8000073c:	10078663          	beqz	a5,80000848 <consoleintr+0x252>
    80000740:	00013797          	auipc	a5,0x13
    80000744:	34078793          	addi	a5,a5,832 # 80013a80 <cons>
    80000748:	0a07a703          	lw	a4,160(a5)
    8000074c:	00013797          	auipc	a5,0x13
    80000750:	33478793          	addi	a5,a5,820 # 80013a80 <cons>
    80000754:	0987a783          	lw	a5,152(a5)
    80000758:	40f707bb          	subw	a5,a4,a5
    8000075c:	2781                	sext.w	a5,a5
    8000075e:	873e                	mv	a4,a5
    80000760:	07f00793          	li	a5,127
    80000764:	0ee7e263          	bltu	a5,a4,80000848 <consoleintr+0x252>
      c = (c == '\r') ? '\n' : c;
    80000768:	fec42783          	lw	a5,-20(s0)
    8000076c:	0007871b          	sext.w	a4,a5
    80000770:	47b5                	li	a5,13
    80000772:	00f70563          	beq	a4,a5,8000077c <consoleintr+0x186>
    80000776:	fec42783          	lw	a5,-20(s0)
    8000077a:	a011                	j	8000077e <consoleintr+0x188>
    8000077c:	47a9                	li	a5,10
    8000077e:	fef42623          	sw	a5,-20(s0)

      // echo back to the user.
      consputc(c);
    80000782:	fec42783          	lw	a5,-20(s0)
    80000786:	853e                	mv	a0,a5
    80000788:	00000097          	auipc	ra,0x0
    8000078c:	bec080e7          	jalr	-1044(ra) # 80000374 <consputc>

      // store for consumption by consoleread().
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000790:	00013797          	auipc	a5,0x13
    80000794:	2f078793          	addi	a5,a5,752 # 80013a80 <cons>
    80000798:	0a07a783          	lw	a5,160(a5)
    8000079c:	2781                	sext.w	a5,a5
    8000079e:	0017871b          	addiw	a4,a5,1
    800007a2:	0007069b          	sext.w	a3,a4
    800007a6:	00013717          	auipc	a4,0x13
    800007aa:	2da70713          	addi	a4,a4,730 # 80013a80 <cons>
    800007ae:	0ad72023          	sw	a3,160(a4)
    800007b2:	07f7f793          	andi	a5,a5,127
    800007b6:	2781                	sext.w	a5,a5
    800007b8:	fec42703          	lw	a4,-20(s0)
    800007bc:	0ff77713          	zext.b	a4,a4
    800007c0:	00013697          	auipc	a3,0x13
    800007c4:	2c068693          	addi	a3,a3,704 # 80013a80 <cons>
    800007c8:	1782                	slli	a5,a5,0x20
    800007ca:	9381                	srli	a5,a5,0x20
    800007cc:	97b6                	add	a5,a5,a3
    800007ce:	00e78c23          	sb	a4,24(a5)

      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    800007d2:	fec42783          	lw	a5,-20(s0)
    800007d6:	0007871b          	sext.w	a4,a5
    800007da:	47a9                	li	a5,10
    800007dc:	02f70d63          	beq	a4,a5,80000816 <consoleintr+0x220>
    800007e0:	fec42783          	lw	a5,-20(s0)
    800007e4:	0007871b          	sext.w	a4,a5
    800007e8:	4791                	li	a5,4
    800007ea:	02f70663          	beq	a4,a5,80000816 <consoleintr+0x220>
    800007ee:	00013797          	auipc	a5,0x13
    800007f2:	29278793          	addi	a5,a5,658 # 80013a80 <cons>
    800007f6:	0a07a703          	lw	a4,160(a5)
    800007fa:	00013797          	auipc	a5,0x13
    800007fe:	28678793          	addi	a5,a5,646 # 80013a80 <cons>
    80000802:	0987a783          	lw	a5,152(a5)
    80000806:	40f707bb          	subw	a5,a4,a5
    8000080a:	2781                	sext.w	a5,a5
    8000080c:	873e                	mv	a4,a5
    8000080e:	08000793          	li	a5,128
    80000812:	02f71b63          	bne	a4,a5,80000848 <consoleintr+0x252>
        // wake up consoleread() if a whole line (or end-of-file)
        // has arrived.
        cons.w = cons.e;
    80000816:	00013797          	auipc	a5,0x13
    8000081a:	26a78793          	addi	a5,a5,618 # 80013a80 <cons>
    8000081e:	0a07a703          	lw	a4,160(a5)
    80000822:	00013797          	auipc	a5,0x13
    80000826:	25e78793          	addi	a5,a5,606 # 80013a80 <cons>
    8000082a:	08e7ae23          	sw	a4,156(a5)
        wakeup(&cons.r);
    8000082e:	00013517          	auipc	a0,0x13
    80000832:	2ea50513          	addi	a0,a0,746 # 80013b18 <cons+0x98>
    80000836:	00003097          	auipc	ra,0x3
    8000083a:	c48080e7          	jalr	-952(ra) # 8000347e <wakeup>
      }
    }
    break;
    8000083e:	a029                	j	80000848 <consoleintr+0x252>
    break;
    80000840:	0001                	nop
    80000842:	a021                	j	8000084a <consoleintr+0x254>
    break;
    80000844:	0001                	nop
    80000846:	a011                	j	8000084a <consoleintr+0x254>
    break;
    80000848:	0001                	nop
  }
  
  release(&cons.lock);
    8000084a:	00013517          	auipc	a0,0x13
    8000084e:	23650513          	addi	a0,a0,566 # 80013a80 <cons>
    80000852:	00001097          	auipc	ra,0x1
    80000856:	a8a080e7          	jalr	-1398(ra) # 800012dc <release>
}
    8000085a:	0001                	nop
    8000085c:	60e2                	ld	ra,24(sp)
    8000085e:	6442                	ld	s0,16(sp)
    80000860:	6105                	addi	sp,sp,32
    80000862:	8082                	ret

0000000080000864 <consoleinit>:

void
consoleinit(void)
{
    80000864:	1141                	addi	sp,sp,-16
    80000866:	e406                	sd	ra,8(sp)
    80000868:	e022                	sd	s0,0(sp)
    8000086a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000086c:	0000a597          	auipc	a1,0xa
    80000870:	79458593          	addi	a1,a1,1940 # 8000b000 <etext>
    80000874:	00013517          	auipc	a0,0x13
    80000878:	20c50513          	addi	a0,a0,524 # 80013a80 <cons>
    8000087c:	00001097          	auipc	ra,0x1
    80000880:	9cc080e7          	jalr	-1588(ra) # 80001248 <initlock>

  uartinit();
    80000884:	00000097          	auipc	ra,0x0
    80000888:	48e080e7          	jalr	1166(ra) # 80000d12 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000088c:	00023797          	auipc	a5,0x23
    80000890:	39478793          	addi	a5,a5,916 # 80023c20 <devsw>
    80000894:	00000717          	auipc	a4,0x0
    80000898:	bc270713          	addi	a4,a4,-1086 # 80000456 <consoleread>
    8000089c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000089e:	00023797          	auipc	a5,0x23
    800008a2:	38278793          	addi	a5,a5,898 # 80023c20 <devsw>
    800008a6:	00000717          	auipc	a4,0x0
    800008aa:	b2670713          	addi	a4,a4,-1242 # 800003cc <consolewrite>
    800008ae:	ef98                	sd	a4,24(a5)
}
    800008b0:	0001                	nop
    800008b2:	60a2                	ld	ra,8(sp)
    800008b4:	6402                	ld	s0,0(sp)
    800008b6:	0141                	addi	sp,sp,16
    800008b8:	8082                	ret

00000000800008ba <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800008ba:	7139                	addi	sp,sp,-64
    800008bc:	fc06                	sd	ra,56(sp)
    800008be:	f822                	sd	s0,48(sp)
    800008c0:	0080                	addi	s0,sp,64
    800008c2:	87aa                	mv	a5,a0
    800008c4:	86ae                	mv	a3,a1
    800008c6:	8732                	mv	a4,a2
    800008c8:	fcf42623          	sw	a5,-52(s0)
    800008cc:	87b6                	mv	a5,a3
    800008ce:	fcf42423          	sw	a5,-56(s0)
    800008d2:	87ba                	mv	a5,a4
    800008d4:	fcf42223          	sw	a5,-60(s0)
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800008d8:	fc442783          	lw	a5,-60(s0)
    800008dc:	2781                	sext.w	a5,a5
    800008de:	c78d                	beqz	a5,80000908 <printint+0x4e>
    800008e0:	fcc42783          	lw	a5,-52(s0)
    800008e4:	01f7d79b          	srliw	a5,a5,0x1f
    800008e8:	0ff7f793          	zext.b	a5,a5
    800008ec:	fcf42223          	sw	a5,-60(s0)
    800008f0:	fc442783          	lw	a5,-60(s0)
    800008f4:	2781                	sext.w	a5,a5
    800008f6:	cb89                	beqz	a5,80000908 <printint+0x4e>
    x = -xx;
    800008f8:	fcc42783          	lw	a5,-52(s0)
    800008fc:	40f007bb          	negw	a5,a5
    80000900:	2781                	sext.w	a5,a5
    80000902:	fef42423          	sw	a5,-24(s0)
    80000906:	a029                	j	80000910 <printint+0x56>
  else
    x = xx;
    80000908:	fcc42783          	lw	a5,-52(s0)
    8000090c:	fef42423          	sw	a5,-24(s0)

  i = 0;
    80000910:	fe042623          	sw	zero,-20(s0)
  do {
    buf[i++] = digits[x % base];
    80000914:	fc842783          	lw	a5,-56(s0)
    80000918:	fe842703          	lw	a4,-24(s0)
    8000091c:	02f777bb          	remuw	a5,a4,a5
    80000920:	0007861b          	sext.w	a2,a5
    80000924:	fec42783          	lw	a5,-20(s0)
    80000928:	0017871b          	addiw	a4,a5,1
    8000092c:	fee42623          	sw	a4,-20(s0)
    80000930:	0000b697          	auipc	a3,0xb
    80000934:	e7068693          	addi	a3,a3,-400 # 8000b7a0 <digits>
    80000938:	02061713          	slli	a4,a2,0x20
    8000093c:	9301                	srli	a4,a4,0x20
    8000093e:	9736                	add	a4,a4,a3
    80000940:	00074703          	lbu	a4,0(a4)
    80000944:	17c1                	addi	a5,a5,-16
    80000946:	97a2                	add	a5,a5,s0
    80000948:	fee78423          	sb	a4,-24(a5)
  } while((x /= base) != 0);
    8000094c:	fc842783          	lw	a5,-56(s0)
    80000950:	fe842703          	lw	a4,-24(s0)
    80000954:	02f757bb          	divuw	a5,a4,a5
    80000958:	fef42423          	sw	a5,-24(s0)
    8000095c:	fe842783          	lw	a5,-24(s0)
    80000960:	2781                	sext.w	a5,a5
    80000962:	fbcd                	bnez	a5,80000914 <printint+0x5a>

  if(sign)
    80000964:	fc442783          	lw	a5,-60(s0)
    80000968:	2781                	sext.w	a5,a5
    8000096a:	cb95                	beqz	a5,8000099e <printint+0xe4>
    buf[i++] = '-';
    8000096c:	fec42783          	lw	a5,-20(s0)
    80000970:	0017871b          	addiw	a4,a5,1
    80000974:	fee42623          	sw	a4,-20(s0)
    80000978:	17c1                	addi	a5,a5,-16
    8000097a:	97a2                	add	a5,a5,s0
    8000097c:	02d00713          	li	a4,45
    80000980:	fee78423          	sb	a4,-24(a5)

  while(--i >= 0)
    80000984:	a829                	j	8000099e <printint+0xe4>
    consputc(buf[i]);
    80000986:	fec42783          	lw	a5,-20(s0)
    8000098a:	17c1                	addi	a5,a5,-16
    8000098c:	97a2                	add	a5,a5,s0
    8000098e:	fe87c783          	lbu	a5,-24(a5)
    80000992:	2781                	sext.w	a5,a5
    80000994:	853e                	mv	a0,a5
    80000996:	00000097          	auipc	ra,0x0
    8000099a:	9de080e7          	jalr	-1570(ra) # 80000374 <consputc>
  while(--i >= 0)
    8000099e:	fec42783          	lw	a5,-20(s0)
    800009a2:	37fd                	addiw	a5,a5,-1
    800009a4:	fef42623          	sw	a5,-20(s0)
    800009a8:	fec42783          	lw	a5,-20(s0)
    800009ac:	2781                	sext.w	a5,a5
    800009ae:	fc07dce3          	bgez	a5,80000986 <printint+0xcc>
}
    800009b2:	0001                	nop
    800009b4:	0001                	nop
    800009b6:	70e2                	ld	ra,56(sp)
    800009b8:	7442                	ld	s0,48(sp)
    800009ba:	6121                	addi	sp,sp,64
    800009bc:	8082                	ret

00000000800009be <printptr>:

static void
printptr(uint64 x)
{
    800009be:	7179                	addi	sp,sp,-48
    800009c0:	f406                	sd	ra,40(sp)
    800009c2:	f022                	sd	s0,32(sp)
    800009c4:	1800                	addi	s0,sp,48
    800009c6:	fca43c23          	sd	a0,-40(s0)
  int i;
  consputc('0');
    800009ca:	03000513          	li	a0,48
    800009ce:	00000097          	auipc	ra,0x0
    800009d2:	9a6080e7          	jalr	-1626(ra) # 80000374 <consputc>
  consputc('x');
    800009d6:	07800513          	li	a0,120
    800009da:	00000097          	auipc	ra,0x0
    800009de:	99a080e7          	jalr	-1638(ra) # 80000374 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800009e2:	fe042623          	sw	zero,-20(s0)
    800009e6:	a81d                	j	80000a1c <printptr+0x5e>
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800009e8:	fd843783          	ld	a5,-40(s0)
    800009ec:	93f1                	srli	a5,a5,0x3c
    800009ee:	0000b717          	auipc	a4,0xb
    800009f2:	db270713          	addi	a4,a4,-590 # 8000b7a0 <digits>
    800009f6:	97ba                	add	a5,a5,a4
    800009f8:	0007c783          	lbu	a5,0(a5)
    800009fc:	2781                	sext.w	a5,a5
    800009fe:	853e                	mv	a0,a5
    80000a00:	00000097          	auipc	ra,0x0
    80000a04:	974080e7          	jalr	-1676(ra) # 80000374 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000a08:	fec42783          	lw	a5,-20(s0)
    80000a0c:	2785                	addiw	a5,a5,1
    80000a0e:	fef42623          	sw	a5,-20(s0)
    80000a12:	fd843783          	ld	a5,-40(s0)
    80000a16:	0792                	slli	a5,a5,0x4
    80000a18:	fcf43c23          	sd	a5,-40(s0)
    80000a1c:	fec42783          	lw	a5,-20(s0)
    80000a20:	873e                	mv	a4,a5
    80000a22:	47bd                	li	a5,15
    80000a24:	fce7f2e3          	bgeu	a5,a4,800009e8 <printptr+0x2a>
}
    80000a28:	0001                	nop
    80000a2a:	0001                	nop
    80000a2c:	70a2                	ld	ra,40(sp)
    80000a2e:	7402                	ld	s0,32(sp)
    80000a30:	6145                	addi	sp,sp,48
    80000a32:	8082                	ret

0000000080000a34 <printf>:

// Print to the console. only understands %d, %x, %p, %s.
void
printf(char *fmt, ...)
{
    80000a34:	7119                	addi	sp,sp,-128
    80000a36:	fc06                	sd	ra,56(sp)
    80000a38:	f822                	sd	s0,48(sp)
    80000a3a:	0080                	addi	s0,sp,64
    80000a3c:	fca43423          	sd	a0,-56(s0)
    80000a40:	e40c                	sd	a1,8(s0)
    80000a42:	e810                	sd	a2,16(s0)
    80000a44:	ec14                	sd	a3,24(s0)
    80000a46:	f018                	sd	a4,32(s0)
    80000a48:	f41c                	sd	a5,40(s0)
    80000a4a:	03043823          	sd	a6,48(s0)
    80000a4e:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, c, locking;
  char *s;

  locking = pr.locking;
    80000a52:	00013797          	auipc	a5,0x13
    80000a56:	0d678793          	addi	a5,a5,214 # 80013b28 <pr>
    80000a5a:	4f9c                	lw	a5,24(a5)
    80000a5c:	fcf42e23          	sw	a5,-36(s0)
  if(locking)
    80000a60:	fdc42783          	lw	a5,-36(s0)
    80000a64:	2781                	sext.w	a5,a5
    80000a66:	cb89                	beqz	a5,80000a78 <printf+0x44>
    acquire(&pr.lock);
    80000a68:	00013517          	auipc	a0,0x13
    80000a6c:	0c050513          	addi	a0,a0,192 # 80013b28 <pr>
    80000a70:	00001097          	auipc	ra,0x1
    80000a74:	808080e7          	jalr	-2040(ra) # 80001278 <acquire>

  if (fmt == 0)
    80000a78:	fc843783          	ld	a5,-56(s0)
    80000a7c:	eb89                	bnez	a5,80000a8e <printf+0x5a>
    panic("null fmt");
    80000a7e:	0000a517          	auipc	a0,0xa
    80000a82:	58a50513          	addi	a0,a0,1418 # 8000b008 <etext+0x8>
    80000a86:	00000097          	auipc	ra,0x0
    80000a8a:	204080e7          	jalr	516(ra) # 80000c8a <panic>

  va_start(ap, fmt);
    80000a8e:	04040793          	addi	a5,s0,64
    80000a92:	fcf43023          	sd	a5,-64(s0)
    80000a96:	fc043783          	ld	a5,-64(s0)
    80000a9a:	fc878793          	addi	a5,a5,-56
    80000a9e:	fcf43823          	sd	a5,-48(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000aa2:	fe042623          	sw	zero,-20(s0)
    80000aa6:	a24d                	j	80000c48 <printf+0x214>
    if(c != '%'){
    80000aa8:	fd842783          	lw	a5,-40(s0)
    80000aac:	0007871b          	sext.w	a4,a5
    80000ab0:	02500793          	li	a5,37
    80000ab4:	00f70a63          	beq	a4,a5,80000ac8 <printf+0x94>
      consputc(c);
    80000ab8:	fd842783          	lw	a5,-40(s0)
    80000abc:	853e                	mv	a0,a5
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	8b6080e7          	jalr	-1866(ra) # 80000374 <consputc>
      continue;
    80000ac6:	aaa5                	j	80000c3e <printf+0x20a>
    }
    c = fmt[++i] & 0xff;
    80000ac8:	fec42783          	lw	a5,-20(s0)
    80000acc:	2785                	addiw	a5,a5,1
    80000ace:	fef42623          	sw	a5,-20(s0)
    80000ad2:	fec42783          	lw	a5,-20(s0)
    80000ad6:	fc843703          	ld	a4,-56(s0)
    80000ada:	97ba                	add	a5,a5,a4
    80000adc:	0007c783          	lbu	a5,0(a5)
    80000ae0:	fcf42c23          	sw	a5,-40(s0)
    if(c == 0)
    80000ae4:	fd842783          	lw	a5,-40(s0)
    80000ae8:	2781                	sext.w	a5,a5
    80000aea:	16078e63          	beqz	a5,80000c66 <printf+0x232>
      break;
    switch(c){
    80000aee:	fd842783          	lw	a5,-40(s0)
    80000af2:	0007871b          	sext.w	a4,a5
    80000af6:	07800793          	li	a5,120
    80000afa:	08f70963          	beq	a4,a5,80000b8c <printf+0x158>
    80000afe:	fd842783          	lw	a5,-40(s0)
    80000b02:	0007871b          	sext.w	a4,a5
    80000b06:	07800793          	li	a5,120
    80000b0a:	10e7cc63          	blt	a5,a4,80000c22 <printf+0x1ee>
    80000b0e:	fd842783          	lw	a5,-40(s0)
    80000b12:	0007871b          	sext.w	a4,a5
    80000b16:	07300793          	li	a5,115
    80000b1a:	0af70563          	beq	a4,a5,80000bc4 <printf+0x190>
    80000b1e:	fd842783          	lw	a5,-40(s0)
    80000b22:	0007871b          	sext.w	a4,a5
    80000b26:	07300793          	li	a5,115
    80000b2a:	0ee7cc63          	blt	a5,a4,80000c22 <printf+0x1ee>
    80000b2e:	fd842783          	lw	a5,-40(s0)
    80000b32:	0007871b          	sext.w	a4,a5
    80000b36:	07000793          	li	a5,112
    80000b3a:	06f70863          	beq	a4,a5,80000baa <printf+0x176>
    80000b3e:	fd842783          	lw	a5,-40(s0)
    80000b42:	0007871b          	sext.w	a4,a5
    80000b46:	07000793          	li	a5,112
    80000b4a:	0ce7cc63          	blt	a5,a4,80000c22 <printf+0x1ee>
    80000b4e:	fd842783          	lw	a5,-40(s0)
    80000b52:	0007871b          	sext.w	a4,a5
    80000b56:	02500793          	li	a5,37
    80000b5a:	0af70d63          	beq	a4,a5,80000c14 <printf+0x1e0>
    80000b5e:	fd842783          	lw	a5,-40(s0)
    80000b62:	0007871b          	sext.w	a4,a5
    80000b66:	06400793          	li	a5,100
    80000b6a:	0af71c63          	bne	a4,a5,80000c22 <printf+0x1ee>
    case 'd':
      printint(va_arg(ap, int), 10, 1);
    80000b6e:	fd043783          	ld	a5,-48(s0)
    80000b72:	00878713          	addi	a4,a5,8
    80000b76:	fce43823          	sd	a4,-48(s0)
    80000b7a:	439c                	lw	a5,0(a5)
    80000b7c:	4605                	li	a2,1
    80000b7e:	45a9                	li	a1,10
    80000b80:	853e                	mv	a0,a5
    80000b82:	00000097          	auipc	ra,0x0
    80000b86:	d38080e7          	jalr	-712(ra) # 800008ba <printint>
      break;
    80000b8a:	a855                	j	80000c3e <printf+0x20a>
    case 'x':
      printint(va_arg(ap, int), 16, 1);
    80000b8c:	fd043783          	ld	a5,-48(s0)
    80000b90:	00878713          	addi	a4,a5,8
    80000b94:	fce43823          	sd	a4,-48(s0)
    80000b98:	439c                	lw	a5,0(a5)
    80000b9a:	4605                	li	a2,1
    80000b9c:	45c1                	li	a1,16
    80000b9e:	853e                	mv	a0,a5
    80000ba0:	00000097          	auipc	ra,0x0
    80000ba4:	d1a080e7          	jalr	-742(ra) # 800008ba <printint>
      break;
    80000ba8:	a859                	j	80000c3e <printf+0x20a>
    case 'p':
      printptr(va_arg(ap, uint64));
    80000baa:	fd043783          	ld	a5,-48(s0)
    80000bae:	00878713          	addi	a4,a5,8
    80000bb2:	fce43823          	sd	a4,-48(s0)
    80000bb6:	639c                	ld	a5,0(a5)
    80000bb8:	853e                	mv	a0,a5
    80000bba:	00000097          	auipc	ra,0x0
    80000bbe:	e04080e7          	jalr	-508(ra) # 800009be <printptr>
      break;
    80000bc2:	a8b5                	j	80000c3e <printf+0x20a>
    case 's':
      if((s = va_arg(ap, char*)) == 0)
    80000bc4:	fd043783          	ld	a5,-48(s0)
    80000bc8:	00878713          	addi	a4,a5,8
    80000bcc:	fce43823          	sd	a4,-48(s0)
    80000bd0:	639c                	ld	a5,0(a5)
    80000bd2:	fef43023          	sd	a5,-32(s0)
    80000bd6:	fe043783          	ld	a5,-32(s0)
    80000bda:	e79d                	bnez	a5,80000c08 <printf+0x1d4>
        s = "(null)";
    80000bdc:	0000a797          	auipc	a5,0xa
    80000be0:	43c78793          	addi	a5,a5,1084 # 8000b018 <etext+0x18>
    80000be4:	fef43023          	sd	a5,-32(s0)
      for(; *s; s++)
    80000be8:	a005                	j	80000c08 <printf+0x1d4>
        consputc(*s);
    80000bea:	fe043783          	ld	a5,-32(s0)
    80000bee:	0007c783          	lbu	a5,0(a5)
    80000bf2:	2781                	sext.w	a5,a5
    80000bf4:	853e                	mv	a0,a5
    80000bf6:	fffff097          	auipc	ra,0xfffff
    80000bfa:	77e080e7          	jalr	1918(ra) # 80000374 <consputc>
      for(; *s; s++)
    80000bfe:	fe043783          	ld	a5,-32(s0)
    80000c02:	0785                	addi	a5,a5,1
    80000c04:	fef43023          	sd	a5,-32(s0)
    80000c08:	fe043783          	ld	a5,-32(s0)
    80000c0c:	0007c783          	lbu	a5,0(a5)
    80000c10:	ffe9                	bnez	a5,80000bea <printf+0x1b6>
      break;
    80000c12:	a035                	j	80000c3e <printf+0x20a>
    case '%':
      consputc('%');
    80000c14:	02500513          	li	a0,37
    80000c18:	fffff097          	auipc	ra,0xfffff
    80000c1c:	75c080e7          	jalr	1884(ra) # 80000374 <consputc>
      break;
    80000c20:	a839                	j	80000c3e <printf+0x20a>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000c22:	02500513          	li	a0,37
    80000c26:	fffff097          	auipc	ra,0xfffff
    80000c2a:	74e080e7          	jalr	1870(ra) # 80000374 <consputc>
      consputc(c);
    80000c2e:	fd842783          	lw	a5,-40(s0)
    80000c32:	853e                	mv	a0,a5
    80000c34:	fffff097          	auipc	ra,0xfffff
    80000c38:	740080e7          	jalr	1856(ra) # 80000374 <consputc>
      break;
    80000c3c:	0001                	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000c3e:	fec42783          	lw	a5,-20(s0)
    80000c42:	2785                	addiw	a5,a5,1
    80000c44:	fef42623          	sw	a5,-20(s0)
    80000c48:	fec42783          	lw	a5,-20(s0)
    80000c4c:	fc843703          	ld	a4,-56(s0)
    80000c50:	97ba                	add	a5,a5,a4
    80000c52:	0007c783          	lbu	a5,0(a5)
    80000c56:	fcf42c23          	sw	a5,-40(s0)
    80000c5a:	fd842783          	lw	a5,-40(s0)
    80000c5e:	2781                	sext.w	a5,a5
    80000c60:	e40794e3          	bnez	a5,80000aa8 <printf+0x74>
    80000c64:	a011                	j	80000c68 <printf+0x234>
      break;
    80000c66:	0001                	nop
    }
  }
  va_end(ap);

  if(locking)
    80000c68:	fdc42783          	lw	a5,-36(s0)
    80000c6c:	2781                	sext.w	a5,a5
    80000c6e:	cb89                	beqz	a5,80000c80 <printf+0x24c>
    release(&pr.lock);
    80000c70:	00013517          	auipc	a0,0x13
    80000c74:	eb850513          	addi	a0,a0,-328 # 80013b28 <pr>
    80000c78:	00000097          	auipc	ra,0x0
    80000c7c:	664080e7          	jalr	1636(ra) # 800012dc <release>
}
    80000c80:	0001                	nop
    80000c82:	70e2                	ld	ra,56(sp)
    80000c84:	7442                	ld	s0,48(sp)
    80000c86:	6109                	addi	sp,sp,128
    80000c88:	8082                	ret

0000000080000c8a <panic>:

void
panic(char *s)
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	1000                	addi	s0,sp,32
    80000c92:	fea43423          	sd	a0,-24(s0)
  pr.locking = 0;
    80000c96:	00013797          	auipc	a5,0x13
    80000c9a:	e9278793          	addi	a5,a5,-366 # 80013b28 <pr>
    80000c9e:	0007ac23          	sw	zero,24(a5)
  printf("panic: ");
    80000ca2:	0000a517          	auipc	a0,0xa
    80000ca6:	37e50513          	addi	a0,a0,894 # 8000b020 <etext+0x20>
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	d8a080e7          	jalr	-630(ra) # 80000a34 <printf>
  printf(s);
    80000cb2:	fe843503          	ld	a0,-24(s0)
    80000cb6:	00000097          	auipc	ra,0x0
    80000cba:	d7e080e7          	jalr	-642(ra) # 80000a34 <printf>
  printf("\n");
    80000cbe:	0000a517          	auipc	a0,0xa
    80000cc2:	36a50513          	addi	a0,a0,874 # 8000b028 <etext+0x28>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	d6e080e7          	jalr	-658(ra) # 80000a34 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000cce:	0000b797          	auipc	a5,0xb
    80000cd2:	c4278793          	addi	a5,a5,-958 # 8000b910 <panicked>
    80000cd6:	4705                	li	a4,1
    80000cd8:	c398                	sw	a4,0(a5)
  for(;;)
    80000cda:	a001                	j	80000cda <panic+0x50>

0000000080000cdc <printfinit>:
    ;
}

void
printfinit(void)
{
    80000cdc:	1141                	addi	sp,sp,-16
    80000cde:	e406                	sd	ra,8(sp)
    80000ce0:	e022                	sd	s0,0(sp)
    80000ce2:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000ce4:	0000a597          	auipc	a1,0xa
    80000ce8:	34c58593          	addi	a1,a1,844 # 8000b030 <etext+0x30>
    80000cec:	00013517          	auipc	a0,0x13
    80000cf0:	e3c50513          	addi	a0,a0,-452 # 80013b28 <pr>
    80000cf4:	00000097          	auipc	ra,0x0
    80000cf8:	554080e7          	jalr	1364(ra) # 80001248 <initlock>
  pr.locking = 1;
    80000cfc:	00013797          	auipc	a5,0x13
    80000d00:	e2c78793          	addi	a5,a5,-468 # 80013b28 <pr>
    80000d04:	4705                	li	a4,1
    80000d06:	cf98                	sw	a4,24(a5)
}
    80000d08:	0001                	nop
    80000d0a:	60a2                	ld	ra,8(sp)
    80000d0c:	6402                	ld	s0,0(sp)
    80000d0e:	0141                	addi	sp,sp,16
    80000d10:	8082                	ret

0000000080000d12 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000d12:	1141                	addi	sp,sp,-16
    80000d14:	e406                	sd	ra,8(sp)
    80000d16:	e022                	sd	s0,0(sp)
    80000d18:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000d1a:	100007b7          	lui	a5,0x10000
    80000d1e:	0785                	addi	a5,a5,1 # 10000001 <_entry-0x6fffffff>
    80000d20:	00078023          	sb	zero,0(a5)

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000d24:	100007b7          	lui	a5,0x10000
    80000d28:	078d                	addi	a5,a5,3 # 10000003 <_entry-0x6ffffffd>
    80000d2a:	f8000713          	li	a4,-128
    80000d2e:	00e78023          	sb	a4,0(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000d32:	100007b7          	lui	a5,0x10000
    80000d36:	470d                	li	a4,3
    80000d38:	00e78023          	sb	a4,0(a5) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000d3c:	100007b7          	lui	a5,0x10000
    80000d40:	0785                	addi	a5,a5,1 # 10000001 <_entry-0x6fffffff>
    80000d42:	00078023          	sb	zero,0(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000d46:	100007b7          	lui	a5,0x10000
    80000d4a:	078d                	addi	a5,a5,3 # 10000003 <_entry-0x6ffffffd>
    80000d4c:	470d                	li	a4,3
    80000d4e:	00e78023          	sb	a4,0(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000d52:	100007b7          	lui	a5,0x10000
    80000d56:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000d58:	471d                	li	a4,7
    80000d5a:	00e78023          	sb	a4,0(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000d5e:	100007b7          	lui	a5,0x10000
    80000d62:	0785                	addi	a5,a5,1 # 10000001 <_entry-0x6fffffff>
    80000d64:	470d                	li	a4,3
    80000d66:	00e78023          	sb	a4,0(a5)

  initlock(&uart_tx_lock, "uart");
    80000d6a:	0000a597          	auipc	a1,0xa
    80000d6e:	2ce58593          	addi	a1,a1,718 # 8000b038 <etext+0x38>
    80000d72:	00013517          	auipc	a0,0x13
    80000d76:	dd650513          	addi	a0,a0,-554 # 80013b48 <uart_tx_lock>
    80000d7a:	00000097          	auipc	ra,0x0
    80000d7e:	4ce080e7          	jalr	1230(ra) # 80001248 <initlock>
}
    80000d82:	0001                	nop
    80000d84:	60a2                	ld	ra,8(sp)
    80000d86:	6402                	ld	s0,0(sp)
    80000d88:	0141                	addi	sp,sp,16
    80000d8a:	8082                	ret

0000000080000d8c <uartputc>:
// because it may block, it can't be called
// from interrupts; it's only suitable for use
// by write().
void
uartputc(int c)
{
    80000d8c:	1101                	addi	sp,sp,-32
    80000d8e:	ec06                	sd	ra,24(sp)
    80000d90:	e822                	sd	s0,16(sp)
    80000d92:	1000                	addi	s0,sp,32
    80000d94:	87aa                	mv	a5,a0
    80000d96:	fef42623          	sw	a5,-20(s0)
  acquire(&uart_tx_lock);
    80000d9a:	00013517          	auipc	a0,0x13
    80000d9e:	dae50513          	addi	a0,a0,-594 # 80013b48 <uart_tx_lock>
    80000da2:	00000097          	auipc	ra,0x0
    80000da6:	4d6080e7          	jalr	1238(ra) # 80001278 <acquire>

  if(panicked){
    80000daa:	0000b797          	auipc	a5,0xb
    80000dae:	b6678793          	addi	a5,a5,-1178 # 8000b910 <panicked>
    80000db2:	439c                	lw	a5,0(a5)
    80000db4:	2781                	sext.w	a5,a5
    80000db6:	cf91                	beqz	a5,80000dd2 <uartputc+0x46>
    for(;;)
    80000db8:	a001                	j	80000db8 <uartputc+0x2c>
      ;
  }
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    // buffer is full.
    // wait for uartstart() to open up space in the buffer.
    sleep(&uart_tx_r, &uart_tx_lock);
    80000dba:	00013597          	auipc	a1,0x13
    80000dbe:	d8e58593          	addi	a1,a1,-626 # 80013b48 <uart_tx_lock>
    80000dc2:	0000b517          	auipc	a0,0xb
    80000dc6:	b5e50513          	addi	a0,a0,-1186 # 8000b920 <uart_tx_r>
    80000dca:	00002097          	auipc	ra,0x2
    80000dce:	638080e7          	jalr	1592(ra) # 80003402 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000dd2:	0000b797          	auipc	a5,0xb
    80000dd6:	b4e78793          	addi	a5,a5,-1202 # 8000b920 <uart_tx_r>
    80000dda:	639c                	ld	a5,0(a5)
    80000ddc:	02078713          	addi	a4,a5,32
    80000de0:	0000b797          	auipc	a5,0xb
    80000de4:	b3878793          	addi	a5,a5,-1224 # 8000b918 <uart_tx_w>
    80000de8:	639c                	ld	a5,0(a5)
    80000dea:	fcf708e3          	beq	a4,a5,80000dba <uartputc+0x2e>
  }
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000dee:	0000b797          	auipc	a5,0xb
    80000df2:	b2a78793          	addi	a5,a5,-1238 # 8000b918 <uart_tx_w>
    80000df6:	639c                	ld	a5,0(a5)
    80000df8:	8bfd                	andi	a5,a5,31
    80000dfa:	fec42703          	lw	a4,-20(s0)
    80000dfe:	0ff77713          	zext.b	a4,a4
    80000e02:	00013697          	auipc	a3,0x13
    80000e06:	d5e68693          	addi	a3,a3,-674 # 80013b60 <uart_tx_buf>
    80000e0a:	97b6                	add	a5,a5,a3
    80000e0c:	00e78023          	sb	a4,0(a5)
  uart_tx_w += 1;
    80000e10:	0000b797          	auipc	a5,0xb
    80000e14:	b0878793          	addi	a5,a5,-1272 # 8000b918 <uart_tx_w>
    80000e18:	639c                	ld	a5,0(a5)
    80000e1a:	00178713          	addi	a4,a5,1
    80000e1e:	0000b797          	auipc	a5,0xb
    80000e22:	afa78793          	addi	a5,a5,-1286 # 8000b918 <uart_tx_w>
    80000e26:	e398                	sd	a4,0(a5)
  uartstart();
    80000e28:	00000097          	auipc	ra,0x0
    80000e2c:	084080e7          	jalr	132(ra) # 80000eac <uartstart>
  release(&uart_tx_lock);
    80000e30:	00013517          	auipc	a0,0x13
    80000e34:	d1850513          	addi	a0,a0,-744 # 80013b48 <uart_tx_lock>
    80000e38:	00000097          	auipc	ra,0x0
    80000e3c:	4a4080e7          	jalr	1188(ra) # 800012dc <release>
}
    80000e40:	0001                	nop
    80000e42:	60e2                	ld	ra,24(sp)
    80000e44:	6442                	ld	s0,16(sp)
    80000e46:	6105                	addi	sp,sp,32
    80000e48:	8082                	ret

0000000080000e4a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000e4a:	1101                	addi	sp,sp,-32
    80000e4c:	ec06                	sd	ra,24(sp)
    80000e4e:	e822                	sd	s0,16(sp)
    80000e50:	1000                	addi	s0,sp,32
    80000e52:	87aa                	mv	a5,a0
    80000e54:	fef42623          	sw	a5,-20(s0)
  push_off();
    80000e58:	00000097          	auipc	ra,0x0
    80000e5c:	51e080e7          	jalr	1310(ra) # 80001376 <push_off>

  if(panicked){
    80000e60:	0000b797          	auipc	a5,0xb
    80000e64:	ab078793          	addi	a5,a5,-1360 # 8000b910 <panicked>
    80000e68:	439c                	lw	a5,0(a5)
    80000e6a:	2781                	sext.w	a5,a5
    80000e6c:	c391                	beqz	a5,80000e70 <uartputc_sync+0x26>
    for(;;)
    80000e6e:	a001                	j	80000e6e <uartputc_sync+0x24>
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000e70:	0001                	nop
    80000e72:	100007b7          	lui	a5,0x10000
    80000e76:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000e78:	0007c783          	lbu	a5,0(a5)
    80000e7c:	0ff7f793          	zext.b	a5,a5
    80000e80:	2781                	sext.w	a5,a5
    80000e82:	0207f793          	andi	a5,a5,32
    80000e86:	2781                	sext.w	a5,a5
    80000e88:	d7ed                	beqz	a5,80000e72 <uartputc_sync+0x28>
    ;
  WriteReg(THR, c);
    80000e8a:	100007b7          	lui	a5,0x10000
    80000e8e:	fec42703          	lw	a4,-20(s0)
    80000e92:	0ff77713          	zext.b	a4,a4
    80000e96:	00e78023          	sb	a4,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000e9a:	00000097          	auipc	ra,0x0
    80000e9e:	534080e7          	jalr	1332(ra) # 800013ce <pop_off>
}
    80000ea2:	0001                	nop
    80000ea4:	60e2                	ld	ra,24(sp)
    80000ea6:	6442                	ld	s0,16(sp)
    80000ea8:	6105                	addi	sp,sp,32
    80000eaa:	8082                	ret

0000000080000eac <uartstart>:
// in the transmit buffer, send it.
// caller must hold uart_tx_lock.
// called from both the top- and bottom-half.
void
uartstart()
{
    80000eac:	1101                	addi	sp,sp,-32
    80000eae:	ec06                	sd	ra,24(sp)
    80000eb0:	e822                	sd	s0,16(sp)
    80000eb2:	1000                	addi	s0,sp,32
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000eb4:	0000b797          	auipc	a5,0xb
    80000eb8:	a6478793          	addi	a5,a5,-1436 # 8000b918 <uart_tx_w>
    80000ebc:	6398                	ld	a4,0(a5)
    80000ebe:	0000b797          	auipc	a5,0xb
    80000ec2:	a6278793          	addi	a5,a5,-1438 # 8000b920 <uart_tx_r>
    80000ec6:	639c                	ld	a5,0(a5)
    80000ec8:	06f70a63          	beq	a4,a5,80000f3c <uartstart+0x90>
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000ecc:	100007b7          	lui	a5,0x10000
    80000ed0:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000ed2:	0007c783          	lbu	a5,0(a5)
    80000ed6:	0ff7f793          	zext.b	a5,a5
    80000eda:	2781                	sext.w	a5,a5
    80000edc:	0207f793          	andi	a5,a5,32
    80000ee0:	2781                	sext.w	a5,a5
    80000ee2:	cfb9                	beqz	a5,80000f40 <uartstart+0x94>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000ee4:	0000b797          	auipc	a5,0xb
    80000ee8:	a3c78793          	addi	a5,a5,-1476 # 8000b920 <uart_tx_r>
    80000eec:	639c                	ld	a5,0(a5)
    80000eee:	8bfd                	andi	a5,a5,31
    80000ef0:	00013717          	auipc	a4,0x13
    80000ef4:	c7070713          	addi	a4,a4,-912 # 80013b60 <uart_tx_buf>
    80000ef8:	97ba                	add	a5,a5,a4
    80000efa:	0007c783          	lbu	a5,0(a5)
    80000efe:	fef42623          	sw	a5,-20(s0)
    uart_tx_r += 1;
    80000f02:	0000b797          	auipc	a5,0xb
    80000f06:	a1e78793          	addi	a5,a5,-1506 # 8000b920 <uart_tx_r>
    80000f0a:	639c                	ld	a5,0(a5)
    80000f0c:	00178713          	addi	a4,a5,1
    80000f10:	0000b797          	auipc	a5,0xb
    80000f14:	a1078793          	addi	a5,a5,-1520 # 8000b920 <uart_tx_r>
    80000f18:	e398                	sd	a4,0(a5)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000f1a:	0000b517          	auipc	a0,0xb
    80000f1e:	a0650513          	addi	a0,a0,-1530 # 8000b920 <uart_tx_r>
    80000f22:	00002097          	auipc	ra,0x2
    80000f26:	55c080e7          	jalr	1372(ra) # 8000347e <wakeup>
    
    WriteReg(THR, c);
    80000f2a:	100007b7          	lui	a5,0x10000
    80000f2e:	fec42703          	lw	a4,-20(s0)
    80000f32:	0ff77713          	zext.b	a4,a4
    80000f36:	00e78023          	sb	a4,0(a5) # 10000000 <_entry-0x70000000>
  while(1){
    80000f3a:	bfad                	j	80000eb4 <uartstart+0x8>
      return;
    80000f3c:	0001                	nop
    80000f3e:	a011                	j	80000f42 <uartstart+0x96>
      return;
    80000f40:	0001                	nop
  }
}
    80000f42:	60e2                	ld	ra,24(sp)
    80000f44:	6442                	ld	s0,16(sp)
    80000f46:	6105                	addi	sp,sp,32
    80000f48:	8082                	ret

0000000080000f4a <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000f4a:	1141                	addi	sp,sp,-16
    80000f4c:	e422                	sd	s0,8(sp)
    80000f4e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000f50:	100007b7          	lui	a5,0x10000
    80000f54:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000f56:	0007c783          	lbu	a5,0(a5)
    80000f5a:	0ff7f793          	zext.b	a5,a5
    80000f5e:	2781                	sext.w	a5,a5
    80000f60:	8b85                	andi	a5,a5,1
    80000f62:	2781                	sext.w	a5,a5
    80000f64:	cb89                	beqz	a5,80000f76 <uartgetc+0x2c>
    // input data is ready.
    return ReadReg(RHR);
    80000f66:	100007b7          	lui	a5,0x10000
    80000f6a:	0007c783          	lbu	a5,0(a5) # 10000000 <_entry-0x70000000>
    80000f6e:	0ff7f793          	zext.b	a5,a5
    80000f72:	2781                	sext.w	a5,a5
    80000f74:	a011                	j	80000f78 <uartgetc+0x2e>
  } else {
    return -1;
    80000f76:	57fd                	li	a5,-1
  }
}
    80000f78:	853e                	mv	a0,a5
    80000f7a:	6422                	ld	s0,8(sp)
    80000f7c:	0141                	addi	sp,sp,16
    80000f7e:	8082                	ret

0000000080000f80 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000f80:	1101                	addi	sp,sp,-32
    80000f82:	ec06                	sd	ra,24(sp)
    80000f84:	e822                	sd	s0,16(sp)
    80000f86:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    80000f88:	00000097          	auipc	ra,0x0
    80000f8c:	fc2080e7          	jalr	-62(ra) # 80000f4a <uartgetc>
    80000f90:	87aa                	mv	a5,a0
    80000f92:	fef42623          	sw	a5,-20(s0)
    if(c == -1)
    80000f96:	fec42783          	lw	a5,-20(s0)
    80000f9a:	0007871b          	sext.w	a4,a5
    80000f9e:	57fd                	li	a5,-1
    80000fa0:	00f70a63          	beq	a4,a5,80000fb4 <uartintr+0x34>
      break;
    consoleintr(c);
    80000fa4:	fec42783          	lw	a5,-20(s0)
    80000fa8:	853e                	mv	a0,a5
    80000faa:	fffff097          	auipc	ra,0xfffff
    80000fae:	64c080e7          	jalr	1612(ra) # 800005f6 <consoleintr>
  while(1){
    80000fb2:	bfd9                	j	80000f88 <uartintr+0x8>
      break;
    80000fb4:	0001                	nop
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000fb6:	00013517          	auipc	a0,0x13
    80000fba:	b9250513          	addi	a0,a0,-1134 # 80013b48 <uart_tx_lock>
    80000fbe:	00000097          	auipc	ra,0x0
    80000fc2:	2ba080e7          	jalr	698(ra) # 80001278 <acquire>
  uartstart();
    80000fc6:	00000097          	auipc	ra,0x0
    80000fca:	ee6080e7          	jalr	-282(ra) # 80000eac <uartstart>
  release(&uart_tx_lock);
    80000fce:	00013517          	auipc	a0,0x13
    80000fd2:	b7a50513          	addi	a0,a0,-1158 # 80013b48 <uart_tx_lock>
    80000fd6:	00000097          	auipc	ra,0x0
    80000fda:	306080e7          	jalr	774(ra) # 800012dc <release>
}
    80000fde:	0001                	nop
    80000fe0:	60e2                	ld	ra,24(sp)
    80000fe2:	6442                	ld	s0,16(sp)
    80000fe4:	6105                	addi	sp,sp,32
    80000fe6:	8082                	ret

0000000080000fe8 <kinit>:
  struct run *freelist;
} kmem;

void
kinit()
{
    80000fe8:	1141                	addi	sp,sp,-16
    80000fea:	e406                	sd	ra,8(sp)
    80000fec:	e022                	sd	s0,0(sp)
    80000fee:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ff0:	0000a597          	auipc	a1,0xa
    80000ff4:	05058593          	addi	a1,a1,80 # 8000b040 <etext+0x40>
    80000ff8:	00013517          	auipc	a0,0x13
    80000ffc:	b8850513          	addi	a0,a0,-1144 # 80013b80 <kmem>
    80001000:	00000097          	auipc	ra,0x0
    80001004:	248080e7          	jalr	584(ra) # 80001248 <initlock>
  freerange(end, (void*)PHYSTOP);
    80001008:	47c5                	li	a5,17
    8000100a:	01b79593          	slli	a1,a5,0x1b
    8000100e:	00024517          	auipc	a0,0x24
    80001012:	daa50513          	addi	a0,a0,-598 # 80024db8 <end>
    80001016:	00000097          	auipc	ra,0x0
    8000101a:	012080e7          	jalr	18(ra) # 80001028 <freerange>
}
    8000101e:	0001                	nop
    80001020:	60a2                	ld	ra,8(sp)
    80001022:	6402                	ld	s0,0(sp)
    80001024:	0141                	addi	sp,sp,16
    80001026:	8082                	ret

0000000080001028 <freerange>:

void
freerange(void *pa_start, void *pa_end)
{
    80001028:	7179                	addi	sp,sp,-48
    8000102a:	f406                	sd	ra,40(sp)
    8000102c:	f022                	sd	s0,32(sp)
    8000102e:	1800                	addi	s0,sp,48
    80001030:	fca43c23          	sd	a0,-40(s0)
    80001034:	fcb43823          	sd	a1,-48(s0)
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
    80001038:	fd843703          	ld	a4,-40(s0)
    8000103c:	6785                	lui	a5,0x1
    8000103e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001040:	973e                	add	a4,a4,a5
    80001042:	77fd                	lui	a5,0xfffff
    80001044:	8ff9                	and	a5,a5,a4
    80001046:	fef43423          	sd	a5,-24(s0)
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    8000104a:	a829                	j	80001064 <freerange+0x3c>
    kfree(p);
    8000104c:	fe843503          	ld	a0,-24(s0)
    80001050:	00000097          	auipc	ra,0x0
    80001054:	030080e7          	jalr	48(ra) # 80001080 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80001058:	fe843703          	ld	a4,-24(s0)
    8000105c:	6785                	lui	a5,0x1
    8000105e:	97ba                	add	a5,a5,a4
    80001060:	fef43423          	sd	a5,-24(s0)
    80001064:	fe843703          	ld	a4,-24(s0)
    80001068:	6785                	lui	a5,0x1
    8000106a:	97ba                	add	a5,a5,a4
    8000106c:	fd043703          	ld	a4,-48(s0)
    80001070:	fcf77ee3          	bgeu	a4,a5,8000104c <freerange+0x24>
}
    80001074:	0001                	nop
    80001076:	0001                	nop
    80001078:	70a2                	ld	ra,40(sp)
    8000107a:	7402                	ld	s0,32(sp)
    8000107c:	6145                	addi	sp,sp,48
    8000107e:	8082                	ret

0000000080001080 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80001080:	7179                	addi	sp,sp,-48
    80001082:	f406                	sd	ra,40(sp)
    80001084:	f022                	sd	s0,32(sp)
    80001086:	1800                	addi	s0,sp,48
    80001088:	fca43c23          	sd	a0,-40(s0)
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    8000108c:	fd843703          	ld	a4,-40(s0)
    80001090:	6785                	lui	a5,0x1
    80001092:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001094:	8ff9                	and	a5,a5,a4
    80001096:	ef99                	bnez	a5,800010b4 <kfree+0x34>
    80001098:	fd843703          	ld	a4,-40(s0)
    8000109c:	00024797          	auipc	a5,0x24
    800010a0:	d1c78793          	addi	a5,a5,-740 # 80024db8 <end>
    800010a4:	00f76863          	bltu	a4,a5,800010b4 <kfree+0x34>
    800010a8:	fd843703          	ld	a4,-40(s0)
    800010ac:	47c5                	li	a5,17
    800010ae:	07ee                	slli	a5,a5,0x1b
    800010b0:	00f76a63          	bltu	a4,a5,800010c4 <kfree+0x44>
    panic("kfree");
    800010b4:	0000a517          	auipc	a0,0xa
    800010b8:	f9450513          	addi	a0,a0,-108 # 8000b048 <etext+0x48>
    800010bc:	00000097          	auipc	ra,0x0
    800010c0:	bce080e7          	jalr	-1074(ra) # 80000c8a <panic>

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    800010c4:	6605                	lui	a2,0x1
    800010c6:	4585                	li	a1,1
    800010c8:	fd843503          	ld	a0,-40(s0)
    800010cc:	00000097          	auipc	ra,0x0
    800010d0:	380080e7          	jalr	896(ra) # 8000144c <memset>

  r = (struct run*)pa;
    800010d4:	fd843783          	ld	a5,-40(s0)
    800010d8:	fef43423          	sd	a5,-24(s0)

  acquire(&kmem.lock);
    800010dc:	00013517          	auipc	a0,0x13
    800010e0:	aa450513          	addi	a0,a0,-1372 # 80013b80 <kmem>
    800010e4:	00000097          	auipc	ra,0x0
    800010e8:	194080e7          	jalr	404(ra) # 80001278 <acquire>
  r->next = kmem.freelist;
    800010ec:	00013797          	auipc	a5,0x13
    800010f0:	a9478793          	addi	a5,a5,-1388 # 80013b80 <kmem>
    800010f4:	6f98                	ld	a4,24(a5)
    800010f6:	fe843783          	ld	a5,-24(s0)
    800010fa:	e398                	sd	a4,0(a5)
  kmem.freelist = r;
    800010fc:	00013797          	auipc	a5,0x13
    80001100:	a8478793          	addi	a5,a5,-1404 # 80013b80 <kmem>
    80001104:	fe843703          	ld	a4,-24(s0)
    80001108:	ef98                	sd	a4,24(a5)
  release(&kmem.lock);
    8000110a:	00013517          	auipc	a0,0x13
    8000110e:	a7650513          	addi	a0,a0,-1418 # 80013b80 <kmem>
    80001112:	00000097          	auipc	ra,0x0
    80001116:	1ca080e7          	jalr	458(ra) # 800012dc <release>
}
    8000111a:	0001                	nop
    8000111c:	70a2                	ld	ra,40(sp)
    8000111e:	7402                	ld	s0,32(sp)
    80001120:	6145                	addi	sp,sp,48
    80001122:	8082                	ret

0000000080001124 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80001124:	1101                	addi	sp,sp,-32
    80001126:	ec06                	sd	ra,24(sp)
    80001128:	e822                	sd	s0,16(sp)
    8000112a:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    8000112c:	00013517          	auipc	a0,0x13
    80001130:	a5450513          	addi	a0,a0,-1452 # 80013b80 <kmem>
    80001134:	00000097          	auipc	ra,0x0
    80001138:	144080e7          	jalr	324(ra) # 80001278 <acquire>
  r = kmem.freelist;
    8000113c:	00013797          	auipc	a5,0x13
    80001140:	a4478793          	addi	a5,a5,-1468 # 80013b80 <kmem>
    80001144:	6f9c                	ld	a5,24(a5)
    80001146:	fef43423          	sd	a5,-24(s0)
  if(r)
    8000114a:	fe843783          	ld	a5,-24(s0)
    8000114e:	cb89                	beqz	a5,80001160 <kalloc+0x3c>
    kmem.freelist = r->next;
    80001150:	fe843783          	ld	a5,-24(s0)
    80001154:	6398                	ld	a4,0(a5)
    80001156:	00013797          	auipc	a5,0x13
    8000115a:	a2a78793          	addi	a5,a5,-1494 # 80013b80 <kmem>
    8000115e:	ef98                	sd	a4,24(a5)
  release(&kmem.lock);
    80001160:	00013517          	auipc	a0,0x13
    80001164:	a2050513          	addi	a0,a0,-1504 # 80013b80 <kmem>
    80001168:	00000097          	auipc	ra,0x0
    8000116c:	174080e7          	jalr	372(ra) # 800012dc <release>

  if(r)
    80001170:	fe843783          	ld	a5,-24(s0)
    80001174:	cb89                	beqz	a5,80001186 <kalloc+0x62>
    memset((char*)r, 5, PGSIZE); // fill with junk
    80001176:	6605                	lui	a2,0x1
    80001178:	4595                	li	a1,5
    8000117a:	fe843503          	ld	a0,-24(s0)
    8000117e:	00000097          	auipc	ra,0x0
    80001182:	2ce080e7          	jalr	718(ra) # 8000144c <memset>
  return (void*)r;
    80001186:	fe843783          	ld	a5,-24(s0)
}
    8000118a:	853e                	mv	a0,a5
    8000118c:	60e2                	ld	ra,24(sp)
    8000118e:	6442                	ld	s0,16(sp)
    80001190:	6105                	addi	sp,sp,32
    80001192:	8082                	ret

0000000080001194 <r_sstatus>:
{
    80001194:	1101                	addi	sp,sp,-32
    80001196:	ec22                	sd	s0,24(sp)
    80001198:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000119a:	100027f3          	csrr	a5,sstatus
    8000119e:	fef43423          	sd	a5,-24(s0)
  return x;
    800011a2:	fe843783          	ld	a5,-24(s0)
}
    800011a6:	853e                	mv	a0,a5
    800011a8:	6462                	ld	s0,24(sp)
    800011aa:	6105                	addi	sp,sp,32
    800011ac:	8082                	ret

00000000800011ae <w_sstatus>:
{
    800011ae:	1101                	addi	sp,sp,-32
    800011b0:	ec22                	sd	s0,24(sp)
    800011b2:	1000                	addi	s0,sp,32
    800011b4:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800011b8:	fe843783          	ld	a5,-24(s0)
    800011bc:	10079073          	csrw	sstatus,a5
}
    800011c0:	0001                	nop
    800011c2:	6462                	ld	s0,24(sp)
    800011c4:	6105                	addi	sp,sp,32
    800011c6:	8082                	ret

00000000800011c8 <intr_on>:
{
    800011c8:	1141                	addi	sp,sp,-16
    800011ca:	e406                	sd	ra,8(sp)
    800011cc:	e022                	sd	s0,0(sp)
    800011ce:	0800                	addi	s0,sp,16
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800011d0:	00000097          	auipc	ra,0x0
    800011d4:	fc4080e7          	jalr	-60(ra) # 80001194 <r_sstatus>
    800011d8:	87aa                	mv	a5,a0
    800011da:	0027e793          	ori	a5,a5,2
    800011de:	853e                	mv	a0,a5
    800011e0:	00000097          	auipc	ra,0x0
    800011e4:	fce080e7          	jalr	-50(ra) # 800011ae <w_sstatus>
}
    800011e8:	0001                	nop
    800011ea:	60a2                	ld	ra,8(sp)
    800011ec:	6402                	ld	s0,0(sp)
    800011ee:	0141                	addi	sp,sp,16
    800011f0:	8082                	ret

00000000800011f2 <intr_off>:
{
    800011f2:	1141                	addi	sp,sp,-16
    800011f4:	e406                	sd	ra,8(sp)
    800011f6:	e022                	sd	s0,0(sp)
    800011f8:	0800                	addi	s0,sp,16
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800011fa:	00000097          	auipc	ra,0x0
    800011fe:	f9a080e7          	jalr	-102(ra) # 80001194 <r_sstatus>
    80001202:	87aa                	mv	a5,a0
    80001204:	9bf5                	andi	a5,a5,-3
    80001206:	853e                	mv	a0,a5
    80001208:	00000097          	auipc	ra,0x0
    8000120c:	fa6080e7          	jalr	-90(ra) # 800011ae <w_sstatus>
}
    80001210:	0001                	nop
    80001212:	60a2                	ld	ra,8(sp)
    80001214:	6402                	ld	s0,0(sp)
    80001216:	0141                	addi	sp,sp,16
    80001218:	8082                	ret

000000008000121a <intr_get>:
{
    8000121a:	1101                	addi	sp,sp,-32
    8000121c:	ec06                	sd	ra,24(sp)
    8000121e:	e822                	sd	s0,16(sp)
    80001220:	1000                	addi	s0,sp,32
  uint64 x = r_sstatus();
    80001222:	00000097          	auipc	ra,0x0
    80001226:	f72080e7          	jalr	-142(ra) # 80001194 <r_sstatus>
    8000122a:	fea43423          	sd	a0,-24(s0)
  return (x & SSTATUS_SIE) != 0;
    8000122e:	fe843783          	ld	a5,-24(s0)
    80001232:	8b89                	andi	a5,a5,2
    80001234:	00f037b3          	snez	a5,a5
    80001238:	0ff7f793          	zext.b	a5,a5
    8000123c:	2781                	sext.w	a5,a5
}
    8000123e:	853e                	mv	a0,a5
    80001240:	60e2                	ld	ra,24(sp)
    80001242:	6442                	ld	s0,16(sp)
    80001244:	6105                	addi	sp,sp,32
    80001246:	8082                	ret

0000000080001248 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80001248:	1101                	addi	sp,sp,-32
    8000124a:	ec22                	sd	s0,24(sp)
    8000124c:	1000                	addi	s0,sp,32
    8000124e:	fea43423          	sd	a0,-24(s0)
    80001252:	feb43023          	sd	a1,-32(s0)
  lk->name = name;
    80001256:	fe843783          	ld	a5,-24(s0)
    8000125a:	fe043703          	ld	a4,-32(s0)
    8000125e:	e798                	sd	a4,8(a5)
  lk->locked = 0;
    80001260:	fe843783          	ld	a5,-24(s0)
    80001264:	0007a023          	sw	zero,0(a5)
  lk->cpu = 0;
    80001268:	fe843783          	ld	a5,-24(s0)
    8000126c:	0007b823          	sd	zero,16(a5)
}
    80001270:	0001                	nop
    80001272:	6462                	ld	s0,24(sp)
    80001274:	6105                	addi	sp,sp,32
    80001276:	8082                	ret

0000000080001278 <acquire>:

// Acquire the lock.
// Loops (spins) until the lock is acquired.
void
acquire(struct spinlock *lk)
{
    80001278:	1101                	addi	sp,sp,-32
    8000127a:	ec06                	sd	ra,24(sp)
    8000127c:	e822                	sd	s0,16(sp)
    8000127e:	1000                	addi	s0,sp,32
    80001280:	fea43423          	sd	a0,-24(s0)
  push_off(); // disable interrupts to avoid deadlock.
    80001284:	00000097          	auipc	ra,0x0
    80001288:	0f2080e7          	jalr	242(ra) # 80001376 <push_off>
  if(holding(lk))
    8000128c:	fe843503          	ld	a0,-24(s0)
    80001290:	00000097          	auipc	ra,0x0
    80001294:	0a2080e7          	jalr	162(ra) # 80001332 <holding>
    80001298:	87aa                	mv	a5,a0
    8000129a:	cb89                	beqz	a5,800012ac <acquire+0x34>
    panic("acquire");
    8000129c:	0000a517          	auipc	a0,0xa
    800012a0:	db450513          	addi	a0,a0,-588 # 8000b050 <etext+0x50>
    800012a4:	00000097          	auipc	ra,0x0
    800012a8:	9e6080e7          	jalr	-1562(ra) # 80000c8a <panic>

  // On RISC-V, sync_lock_test_and_set turns into an atomic swap:
  //   a5 = 1
  //   s1 = &lk->locked
  //   amoswap.w.aq a5, a5, (s1)
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800012ac:	0001                	nop
    800012ae:	fe843783          	ld	a5,-24(s0)
    800012b2:	4705                	li	a4,1
    800012b4:	0ce7a72f          	amoswap.w.aq	a4,a4,(a5)
    800012b8:	0007079b          	sext.w	a5,a4
    800012bc:	fbed                	bnez	a5,800012ae <acquire+0x36>

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen strictly after the lock is acquired.
  // On RISC-V, this emits a fence instruction.
  __sync_synchronize();
    800012be:	0ff0000f          	fence

  // Record info about lock acquisition for holding() and debugging.
  lk->cpu = mycpu();
    800012c2:	00001097          	auipc	ra,0x1
    800012c6:	544080e7          	jalr	1348(ra) # 80002806 <mycpu>
    800012ca:	872a                	mv	a4,a0
    800012cc:	fe843783          	ld	a5,-24(s0)
    800012d0:	eb98                	sd	a4,16(a5)
}
    800012d2:	0001                	nop
    800012d4:	60e2                	ld	ra,24(sp)
    800012d6:	6442                	ld	s0,16(sp)
    800012d8:	6105                	addi	sp,sp,32
    800012da:	8082                	ret

00000000800012dc <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
    800012dc:	1101                	addi	sp,sp,-32
    800012de:	ec06                	sd	ra,24(sp)
    800012e0:	e822                	sd	s0,16(sp)
    800012e2:	1000                	addi	s0,sp,32
    800012e4:	fea43423          	sd	a0,-24(s0)
  if(!holding(lk))
    800012e8:	fe843503          	ld	a0,-24(s0)
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	046080e7          	jalr	70(ra) # 80001332 <holding>
    800012f4:	87aa                	mv	a5,a0
    800012f6:	eb89                	bnez	a5,80001308 <release+0x2c>
    panic("release");
    800012f8:	0000a517          	auipc	a0,0xa
    800012fc:	d6050513          	addi	a0,a0,-672 # 8000b058 <etext+0x58>
    80001300:	00000097          	auipc	ra,0x0
    80001304:	98a080e7          	jalr	-1654(ra) # 80000c8a <panic>

  lk->cpu = 0;
    80001308:	fe843783          	ld	a5,-24(s0)
    8000130c:	0007b823          	sd	zero,16(a5)
  // past this point, to ensure that all the stores in the critical
  // section are visible to other CPUs before the lock is released,
  // and that loads in the critical section occur strictly before
  // the lock is released.
  // On RISC-V, this emits a fence instruction.
  __sync_synchronize();
    80001310:	0ff0000f          	fence
  // implies that an assignment might be implemented with
  // multiple store instructions.
  // On RISC-V, sync_lock_release turns into an atomic swap:
  //   s1 = &lk->locked
  //   amoswap.w zero, zero, (s1)
  __sync_lock_release(&lk->locked);
    80001314:	fe843783          	ld	a5,-24(s0)
    80001318:	0f50000f          	fence	iorw,ow
    8000131c:	0807a02f          	amoswap.w	zero,zero,(a5)

  pop_off();
    80001320:	00000097          	auipc	ra,0x0
    80001324:	0ae080e7          	jalr	174(ra) # 800013ce <pop_off>
}
    80001328:	0001                	nop
    8000132a:	60e2                	ld	ra,24(sp)
    8000132c:	6442                	ld	s0,16(sp)
    8000132e:	6105                	addi	sp,sp,32
    80001330:	8082                	ret

0000000080001332 <holding>:

// Check whether this cpu is holding the lock.
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
    80001332:	7139                	addi	sp,sp,-64
    80001334:	fc06                	sd	ra,56(sp)
    80001336:	f822                	sd	s0,48(sp)
    80001338:	f426                	sd	s1,40(sp)
    8000133a:	0080                	addi	s0,sp,64
    8000133c:	fca43423          	sd	a0,-56(s0)
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80001340:	fc843783          	ld	a5,-56(s0)
    80001344:	439c                	lw	a5,0(a5)
    80001346:	cf89                	beqz	a5,80001360 <holding+0x2e>
    80001348:	fc843783          	ld	a5,-56(s0)
    8000134c:	6b84                	ld	s1,16(a5)
    8000134e:	00001097          	auipc	ra,0x1
    80001352:	4b8080e7          	jalr	1208(ra) # 80002806 <mycpu>
    80001356:	87aa                	mv	a5,a0
    80001358:	00f49463          	bne	s1,a5,80001360 <holding+0x2e>
    8000135c:	4785                	li	a5,1
    8000135e:	a011                	j	80001362 <holding+0x30>
    80001360:	4781                	li	a5,0
    80001362:	fcf42e23          	sw	a5,-36(s0)
  return r;
    80001366:	fdc42783          	lw	a5,-36(s0)
}
    8000136a:	853e                	mv	a0,a5
    8000136c:	70e2                	ld	ra,56(sp)
    8000136e:	7442                	ld	s0,48(sp)
    80001370:	74a2                	ld	s1,40(sp)
    80001372:	6121                	addi	sp,sp,64
    80001374:	8082                	ret

0000000080001376 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80001376:	1101                	addi	sp,sp,-32
    80001378:	ec06                	sd	ra,24(sp)
    8000137a:	e822                	sd	s0,16(sp)
    8000137c:	1000                	addi	s0,sp,32
  int old = intr_get();
    8000137e:	00000097          	auipc	ra,0x0
    80001382:	e9c080e7          	jalr	-356(ra) # 8000121a <intr_get>
    80001386:	87aa                	mv	a5,a0
    80001388:	fef42623          	sw	a5,-20(s0)

  intr_off();
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	e66080e7          	jalr	-410(ra) # 800011f2 <intr_off>
  if(mycpu()->noff == 0)
    80001394:	00001097          	auipc	ra,0x1
    80001398:	472080e7          	jalr	1138(ra) # 80002806 <mycpu>
    8000139c:	87aa                	mv	a5,a0
    8000139e:	5fbc                	lw	a5,120(a5)
    800013a0:	eb89                	bnez	a5,800013b2 <push_off+0x3c>
    mycpu()->intena = old;
    800013a2:	00001097          	auipc	ra,0x1
    800013a6:	464080e7          	jalr	1124(ra) # 80002806 <mycpu>
    800013aa:	872a                	mv	a4,a0
    800013ac:	fec42783          	lw	a5,-20(s0)
    800013b0:	df7c                	sw	a5,124(a4)
  mycpu()->noff += 1;
    800013b2:	00001097          	auipc	ra,0x1
    800013b6:	454080e7          	jalr	1108(ra) # 80002806 <mycpu>
    800013ba:	87aa                	mv	a5,a0
    800013bc:	5fb8                	lw	a4,120(a5)
    800013be:	2705                	addiw	a4,a4,1
    800013c0:	2701                	sext.w	a4,a4
    800013c2:	dfb8                	sw	a4,120(a5)
}
    800013c4:	0001                	nop
    800013c6:	60e2                	ld	ra,24(sp)
    800013c8:	6442                	ld	s0,16(sp)
    800013ca:	6105                	addi	sp,sp,32
    800013cc:	8082                	ret

00000000800013ce <pop_off>:

void
pop_off(void)
{
    800013ce:	1101                	addi	sp,sp,-32
    800013d0:	ec06                	sd	ra,24(sp)
    800013d2:	e822                	sd	s0,16(sp)
    800013d4:	1000                	addi	s0,sp,32
  struct cpu *c = mycpu();
    800013d6:	00001097          	auipc	ra,0x1
    800013da:	430080e7          	jalr	1072(ra) # 80002806 <mycpu>
    800013de:	fea43423          	sd	a0,-24(s0)
  if(intr_get())
    800013e2:	00000097          	auipc	ra,0x0
    800013e6:	e38080e7          	jalr	-456(ra) # 8000121a <intr_get>
    800013ea:	87aa                	mv	a5,a0
    800013ec:	cb89                	beqz	a5,800013fe <pop_off+0x30>
    panic("pop_off - interruptible");
    800013ee:	0000a517          	auipc	a0,0xa
    800013f2:	c7250513          	addi	a0,a0,-910 # 8000b060 <etext+0x60>
    800013f6:	00000097          	auipc	ra,0x0
    800013fa:	894080e7          	jalr	-1900(ra) # 80000c8a <panic>
  if(c->noff < 1)
    800013fe:	fe843783          	ld	a5,-24(s0)
    80001402:	5fbc                	lw	a5,120(a5)
    80001404:	00f04a63          	bgtz	a5,80001418 <pop_off+0x4a>
    panic("pop_off");
    80001408:	0000a517          	auipc	a0,0xa
    8000140c:	c7050513          	addi	a0,a0,-912 # 8000b078 <etext+0x78>
    80001410:	00000097          	auipc	ra,0x0
    80001414:	87a080e7          	jalr	-1926(ra) # 80000c8a <panic>
  c->noff -= 1;
    80001418:	fe843783          	ld	a5,-24(s0)
    8000141c:	5fbc                	lw	a5,120(a5)
    8000141e:	37fd                	addiw	a5,a5,-1
    80001420:	0007871b          	sext.w	a4,a5
    80001424:	fe843783          	ld	a5,-24(s0)
    80001428:	dfb8                	sw	a4,120(a5)
  if(c->noff == 0 && c->intena)
    8000142a:	fe843783          	ld	a5,-24(s0)
    8000142e:	5fbc                	lw	a5,120(a5)
    80001430:	eb89                	bnez	a5,80001442 <pop_off+0x74>
    80001432:	fe843783          	ld	a5,-24(s0)
    80001436:	5ffc                	lw	a5,124(a5)
    80001438:	c789                	beqz	a5,80001442 <pop_off+0x74>
    intr_on();
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	d8e080e7          	jalr	-626(ra) # 800011c8 <intr_on>
}
    80001442:	0001                	nop
    80001444:	60e2                	ld	ra,24(sp)
    80001446:	6442                	ld	s0,16(sp)
    80001448:	6105                	addi	sp,sp,32
    8000144a:	8082                	ret

000000008000144c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000144c:	7179                	addi	sp,sp,-48
    8000144e:	f422                	sd	s0,40(sp)
    80001450:	1800                	addi	s0,sp,48
    80001452:	fca43c23          	sd	a0,-40(s0)
    80001456:	87ae                	mv	a5,a1
    80001458:	8732                	mv	a4,a2
    8000145a:	fcf42a23          	sw	a5,-44(s0)
    8000145e:	87ba                	mv	a5,a4
    80001460:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
    80001464:	fd843783          	ld	a5,-40(s0)
    80001468:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
    8000146c:	fe042623          	sw	zero,-20(s0)
    80001470:	a00d                	j	80001492 <memset+0x46>
    cdst[i] = c;
    80001472:	fec42783          	lw	a5,-20(s0)
    80001476:	fe043703          	ld	a4,-32(s0)
    8000147a:	97ba                	add	a5,a5,a4
    8000147c:	fd442703          	lw	a4,-44(s0)
    80001480:	0ff77713          	zext.b	a4,a4
    80001484:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
    80001488:	fec42783          	lw	a5,-20(s0)
    8000148c:	2785                	addiw	a5,a5,1
    8000148e:	fef42623          	sw	a5,-20(s0)
    80001492:	fec42703          	lw	a4,-20(s0)
    80001496:	fd042783          	lw	a5,-48(s0)
    8000149a:	2781                	sext.w	a5,a5
    8000149c:	fcf76be3          	bltu	a4,a5,80001472 <memset+0x26>
  }
  return dst;
    800014a0:	fd843783          	ld	a5,-40(s0)
}
    800014a4:	853e                	mv	a0,a5
    800014a6:	7422                	ld	s0,40(sp)
    800014a8:	6145                	addi	sp,sp,48
    800014aa:	8082                	ret

00000000800014ac <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800014ac:	7139                	addi	sp,sp,-64
    800014ae:	fc22                	sd	s0,56(sp)
    800014b0:	0080                	addi	s0,sp,64
    800014b2:	fca43c23          	sd	a0,-40(s0)
    800014b6:	fcb43823          	sd	a1,-48(s0)
    800014ba:	87b2                	mv	a5,a2
    800014bc:	fcf42623          	sw	a5,-52(s0)
  const uchar *s1, *s2;

  s1 = v1;
    800014c0:	fd843783          	ld	a5,-40(s0)
    800014c4:	fef43423          	sd	a5,-24(s0)
  s2 = v2;
    800014c8:	fd043783          	ld	a5,-48(s0)
    800014cc:	fef43023          	sd	a5,-32(s0)
  while(n-- > 0){
    800014d0:	a0a1                	j	80001518 <memcmp+0x6c>
    if(*s1 != *s2)
    800014d2:	fe843783          	ld	a5,-24(s0)
    800014d6:	0007c703          	lbu	a4,0(a5)
    800014da:	fe043783          	ld	a5,-32(s0)
    800014de:	0007c783          	lbu	a5,0(a5)
    800014e2:	02f70163          	beq	a4,a5,80001504 <memcmp+0x58>
      return *s1 - *s2;
    800014e6:	fe843783          	ld	a5,-24(s0)
    800014ea:	0007c783          	lbu	a5,0(a5)
    800014ee:	0007871b          	sext.w	a4,a5
    800014f2:	fe043783          	ld	a5,-32(s0)
    800014f6:	0007c783          	lbu	a5,0(a5)
    800014fa:	2781                	sext.w	a5,a5
    800014fc:	40f707bb          	subw	a5,a4,a5
    80001500:	2781                	sext.w	a5,a5
    80001502:	a01d                	j	80001528 <memcmp+0x7c>
    s1++, s2++;
    80001504:	fe843783          	ld	a5,-24(s0)
    80001508:	0785                	addi	a5,a5,1
    8000150a:	fef43423          	sd	a5,-24(s0)
    8000150e:	fe043783          	ld	a5,-32(s0)
    80001512:	0785                	addi	a5,a5,1
    80001514:	fef43023          	sd	a5,-32(s0)
  while(n-- > 0){
    80001518:	fcc42783          	lw	a5,-52(s0)
    8000151c:	fff7871b          	addiw	a4,a5,-1
    80001520:	fce42623          	sw	a4,-52(s0)
    80001524:	f7dd                	bnez	a5,800014d2 <memcmp+0x26>
  }

  return 0;
    80001526:	4781                	li	a5,0
}
    80001528:	853e                	mv	a0,a5
    8000152a:	7462                	ld	s0,56(sp)
    8000152c:	6121                	addi	sp,sp,64
    8000152e:	8082                	ret

0000000080001530 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80001530:	7139                	addi	sp,sp,-64
    80001532:	fc22                	sd	s0,56(sp)
    80001534:	0080                	addi	s0,sp,64
    80001536:	fca43c23          	sd	a0,-40(s0)
    8000153a:	fcb43823          	sd	a1,-48(s0)
    8000153e:	87b2                	mv	a5,a2
    80001540:	fcf42623          	sw	a5,-52(s0)
  const char *s;
  char *d;

  if(n == 0)
    80001544:	fcc42783          	lw	a5,-52(s0)
    80001548:	2781                	sext.w	a5,a5
    8000154a:	e781                	bnez	a5,80001552 <memmove+0x22>
    return dst;
    8000154c:	fd843783          	ld	a5,-40(s0)
    80001550:	a855                	j	80001604 <memmove+0xd4>
  
  s = src;
    80001552:	fd043783          	ld	a5,-48(s0)
    80001556:	fef43423          	sd	a5,-24(s0)
  d = dst;
    8000155a:	fd843783          	ld	a5,-40(s0)
    8000155e:	fef43023          	sd	a5,-32(s0)
  if(s < d && s + n > d){
    80001562:	fe843703          	ld	a4,-24(s0)
    80001566:	fe043783          	ld	a5,-32(s0)
    8000156a:	08f77463          	bgeu	a4,a5,800015f2 <memmove+0xc2>
    8000156e:	fcc46783          	lwu	a5,-52(s0)
    80001572:	fe843703          	ld	a4,-24(s0)
    80001576:	97ba                	add	a5,a5,a4
    80001578:	fe043703          	ld	a4,-32(s0)
    8000157c:	06f77b63          	bgeu	a4,a5,800015f2 <memmove+0xc2>
    s += n;
    80001580:	fcc46783          	lwu	a5,-52(s0)
    80001584:	fe843703          	ld	a4,-24(s0)
    80001588:	97ba                	add	a5,a5,a4
    8000158a:	fef43423          	sd	a5,-24(s0)
    d += n;
    8000158e:	fcc46783          	lwu	a5,-52(s0)
    80001592:	fe043703          	ld	a4,-32(s0)
    80001596:	97ba                	add	a5,a5,a4
    80001598:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
    8000159c:	a01d                	j	800015c2 <memmove+0x92>
      *--d = *--s;
    8000159e:	fe843783          	ld	a5,-24(s0)
    800015a2:	17fd                	addi	a5,a5,-1
    800015a4:	fef43423          	sd	a5,-24(s0)
    800015a8:	fe043783          	ld	a5,-32(s0)
    800015ac:	17fd                	addi	a5,a5,-1
    800015ae:	fef43023          	sd	a5,-32(s0)
    800015b2:	fe843783          	ld	a5,-24(s0)
    800015b6:	0007c703          	lbu	a4,0(a5)
    800015ba:	fe043783          	ld	a5,-32(s0)
    800015be:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    800015c2:	fcc42783          	lw	a5,-52(s0)
    800015c6:	fff7871b          	addiw	a4,a5,-1
    800015ca:	fce42623          	sw	a4,-52(s0)
    800015ce:	fbe1                	bnez	a5,8000159e <memmove+0x6e>
  if(s < d && s + n > d){
    800015d0:	a805                	j	80001600 <memmove+0xd0>
  } else
    while(n-- > 0)
      *d++ = *s++;
    800015d2:	fe843703          	ld	a4,-24(s0)
    800015d6:	00170793          	addi	a5,a4,1
    800015da:	fef43423          	sd	a5,-24(s0)
    800015de:	fe043783          	ld	a5,-32(s0)
    800015e2:	00178693          	addi	a3,a5,1
    800015e6:	fed43023          	sd	a3,-32(s0)
    800015ea:	00074703          	lbu	a4,0(a4)
    800015ee:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    800015f2:	fcc42783          	lw	a5,-52(s0)
    800015f6:	fff7871b          	addiw	a4,a5,-1
    800015fa:	fce42623          	sw	a4,-52(s0)
    800015fe:	fbf1                	bnez	a5,800015d2 <memmove+0xa2>

  return dst;
    80001600:	fd843783          	ld	a5,-40(s0)
}
    80001604:	853e                	mv	a0,a5
    80001606:	7462                	ld	s0,56(sp)
    80001608:	6121                	addi	sp,sp,64
    8000160a:	8082                	ret

000000008000160c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000160c:	7179                	addi	sp,sp,-48
    8000160e:	f406                	sd	ra,40(sp)
    80001610:	f022                	sd	s0,32(sp)
    80001612:	1800                	addi	s0,sp,48
    80001614:	fea43423          	sd	a0,-24(s0)
    80001618:	feb43023          	sd	a1,-32(s0)
    8000161c:	87b2                	mv	a5,a2
    8000161e:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
    80001622:	fdc42783          	lw	a5,-36(s0)
    80001626:	863e                	mv	a2,a5
    80001628:	fe043583          	ld	a1,-32(s0)
    8000162c:	fe843503          	ld	a0,-24(s0)
    80001630:	00000097          	auipc	ra,0x0
    80001634:	f00080e7          	jalr	-256(ra) # 80001530 <memmove>
    80001638:	87aa                	mv	a5,a0
}
    8000163a:	853e                	mv	a0,a5
    8000163c:	70a2                	ld	ra,40(sp)
    8000163e:	7402                	ld	s0,32(sp)
    80001640:	6145                	addi	sp,sp,48
    80001642:	8082                	ret

0000000080001644 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80001644:	7179                	addi	sp,sp,-48
    80001646:	f422                	sd	s0,40(sp)
    80001648:	1800                	addi	s0,sp,48
    8000164a:	fea43423          	sd	a0,-24(s0)
    8000164e:	feb43023          	sd	a1,-32(s0)
    80001652:	87b2                	mv	a5,a2
    80001654:	fcf42e23          	sw	a5,-36(s0)
  while(n > 0 && *p && *p == *q)
    80001658:	a005                	j	80001678 <strncmp+0x34>
    n--, p++, q++;
    8000165a:	fdc42783          	lw	a5,-36(s0)
    8000165e:	37fd                	addiw	a5,a5,-1
    80001660:	fcf42e23          	sw	a5,-36(s0)
    80001664:	fe843783          	ld	a5,-24(s0)
    80001668:	0785                	addi	a5,a5,1
    8000166a:	fef43423          	sd	a5,-24(s0)
    8000166e:	fe043783          	ld	a5,-32(s0)
    80001672:	0785                	addi	a5,a5,1
    80001674:	fef43023          	sd	a5,-32(s0)
  while(n > 0 && *p && *p == *q)
    80001678:	fdc42783          	lw	a5,-36(s0)
    8000167c:	2781                	sext.w	a5,a5
    8000167e:	c385                	beqz	a5,8000169e <strncmp+0x5a>
    80001680:	fe843783          	ld	a5,-24(s0)
    80001684:	0007c783          	lbu	a5,0(a5)
    80001688:	cb99                	beqz	a5,8000169e <strncmp+0x5a>
    8000168a:	fe843783          	ld	a5,-24(s0)
    8000168e:	0007c703          	lbu	a4,0(a5)
    80001692:	fe043783          	ld	a5,-32(s0)
    80001696:	0007c783          	lbu	a5,0(a5)
    8000169a:	fcf700e3          	beq	a4,a5,8000165a <strncmp+0x16>
  if(n == 0)
    8000169e:	fdc42783          	lw	a5,-36(s0)
    800016a2:	2781                	sext.w	a5,a5
    800016a4:	e399                	bnez	a5,800016aa <strncmp+0x66>
    return 0;
    800016a6:	4781                	li	a5,0
    800016a8:	a839                	j	800016c6 <strncmp+0x82>
  return (uchar)*p - (uchar)*q;
    800016aa:	fe843783          	ld	a5,-24(s0)
    800016ae:	0007c783          	lbu	a5,0(a5)
    800016b2:	0007871b          	sext.w	a4,a5
    800016b6:	fe043783          	ld	a5,-32(s0)
    800016ba:	0007c783          	lbu	a5,0(a5)
    800016be:	2781                	sext.w	a5,a5
    800016c0:	40f707bb          	subw	a5,a4,a5
    800016c4:	2781                	sext.w	a5,a5
}
    800016c6:	853e                	mv	a0,a5
    800016c8:	7422                	ld	s0,40(sp)
    800016ca:	6145                	addi	sp,sp,48
    800016cc:	8082                	ret

00000000800016ce <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800016ce:	7139                	addi	sp,sp,-64
    800016d0:	fc22                	sd	s0,56(sp)
    800016d2:	0080                	addi	s0,sp,64
    800016d4:	fca43c23          	sd	a0,-40(s0)
    800016d8:	fcb43823          	sd	a1,-48(s0)
    800016dc:	87b2                	mv	a5,a2
    800016de:	fcf42623          	sw	a5,-52(s0)
  char *os;

  os = s;
    800016e2:	fd843783          	ld	a5,-40(s0)
    800016e6:	fef43423          	sd	a5,-24(s0)
  while(n-- > 0 && (*s++ = *t++) != 0)
    800016ea:	0001                	nop
    800016ec:	fcc42783          	lw	a5,-52(s0)
    800016f0:	fff7871b          	addiw	a4,a5,-1
    800016f4:	fce42623          	sw	a4,-52(s0)
    800016f8:	02f05e63          	blez	a5,80001734 <strncpy+0x66>
    800016fc:	fd043703          	ld	a4,-48(s0)
    80001700:	00170793          	addi	a5,a4,1
    80001704:	fcf43823          	sd	a5,-48(s0)
    80001708:	fd843783          	ld	a5,-40(s0)
    8000170c:	00178693          	addi	a3,a5,1
    80001710:	fcd43c23          	sd	a3,-40(s0)
    80001714:	00074703          	lbu	a4,0(a4)
    80001718:	00e78023          	sb	a4,0(a5)
    8000171c:	0007c783          	lbu	a5,0(a5)
    80001720:	f7f1                	bnez	a5,800016ec <strncpy+0x1e>
    ;
  while(n-- > 0)
    80001722:	a809                	j	80001734 <strncpy+0x66>
    *s++ = 0;
    80001724:	fd843783          	ld	a5,-40(s0)
    80001728:	00178713          	addi	a4,a5,1
    8000172c:	fce43c23          	sd	a4,-40(s0)
    80001730:	00078023          	sb	zero,0(a5)
  while(n-- > 0)
    80001734:	fcc42783          	lw	a5,-52(s0)
    80001738:	fff7871b          	addiw	a4,a5,-1
    8000173c:	fce42623          	sw	a4,-52(s0)
    80001740:	fef042e3          	bgtz	a5,80001724 <strncpy+0x56>
  return os;
    80001744:	fe843783          	ld	a5,-24(s0)
}
    80001748:	853e                	mv	a0,a5
    8000174a:	7462                	ld	s0,56(sp)
    8000174c:	6121                	addi	sp,sp,64
    8000174e:	8082                	ret

0000000080001750 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80001750:	7139                	addi	sp,sp,-64
    80001752:	fc22                	sd	s0,56(sp)
    80001754:	0080                	addi	s0,sp,64
    80001756:	fca43c23          	sd	a0,-40(s0)
    8000175a:	fcb43823          	sd	a1,-48(s0)
    8000175e:	87b2                	mv	a5,a2
    80001760:	fcf42623          	sw	a5,-52(s0)
  char *os;

  os = s;
    80001764:	fd843783          	ld	a5,-40(s0)
    80001768:	fef43423          	sd	a5,-24(s0)
  if(n <= 0)
    8000176c:	fcc42783          	lw	a5,-52(s0)
    80001770:	2781                	sext.w	a5,a5
    80001772:	00f04563          	bgtz	a5,8000177c <safestrcpy+0x2c>
    return os;
    80001776:	fe843783          	ld	a5,-24(s0)
    8000177a:	a0a9                	j	800017c4 <safestrcpy+0x74>
  while(--n > 0 && (*s++ = *t++) != 0)
    8000177c:	0001                	nop
    8000177e:	fcc42783          	lw	a5,-52(s0)
    80001782:	37fd                	addiw	a5,a5,-1
    80001784:	fcf42623          	sw	a5,-52(s0)
    80001788:	fcc42783          	lw	a5,-52(s0)
    8000178c:	2781                	sext.w	a5,a5
    8000178e:	02f05563          	blez	a5,800017b8 <safestrcpy+0x68>
    80001792:	fd043703          	ld	a4,-48(s0)
    80001796:	00170793          	addi	a5,a4,1
    8000179a:	fcf43823          	sd	a5,-48(s0)
    8000179e:	fd843783          	ld	a5,-40(s0)
    800017a2:	00178693          	addi	a3,a5,1
    800017a6:	fcd43c23          	sd	a3,-40(s0)
    800017aa:	00074703          	lbu	a4,0(a4)
    800017ae:	00e78023          	sb	a4,0(a5)
    800017b2:	0007c783          	lbu	a5,0(a5)
    800017b6:	f7e1                	bnez	a5,8000177e <safestrcpy+0x2e>
    ;
  *s = 0;
    800017b8:	fd843783          	ld	a5,-40(s0)
    800017bc:	00078023          	sb	zero,0(a5)
  return os;
    800017c0:	fe843783          	ld	a5,-24(s0)
}
    800017c4:	853e                	mv	a0,a5
    800017c6:	7462                	ld	s0,56(sp)
    800017c8:	6121                	addi	sp,sp,64
    800017ca:	8082                	ret

00000000800017cc <strlen>:

int
strlen(const char *s)
{
    800017cc:	7179                	addi	sp,sp,-48
    800017ce:	f422                	sd	s0,40(sp)
    800017d0:	1800                	addi	s0,sp,48
    800017d2:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
    800017d6:	fe042623          	sw	zero,-20(s0)
    800017da:	a031                	j	800017e6 <strlen+0x1a>
    800017dc:	fec42783          	lw	a5,-20(s0)
    800017e0:	2785                	addiw	a5,a5,1
    800017e2:	fef42623          	sw	a5,-20(s0)
    800017e6:	fec42783          	lw	a5,-20(s0)
    800017ea:	fd843703          	ld	a4,-40(s0)
    800017ee:	97ba                	add	a5,a5,a4
    800017f0:	0007c783          	lbu	a5,0(a5)
    800017f4:	f7e5                	bnez	a5,800017dc <strlen+0x10>
    ;
  return n;
    800017f6:	fec42783          	lw	a5,-20(s0)
}
    800017fa:	853e                	mv	a0,a5
    800017fc:	7422                	ld	s0,40(sp)
    800017fe:	6145                	addi	sp,sp,48
    80001800:	8082                	ret

0000000080001802 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80001802:	1141                	addi	sp,sp,-16
    80001804:	e406                	sd	ra,8(sp)
    80001806:	e022                	sd	s0,0(sp)
    80001808:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000180a:	00001097          	auipc	ra,0x1
    8000180e:	fd8080e7          	jalr	-40(ra) # 800027e2 <cpuid>
    80001812:	87aa                	mv	a5,a0
    80001814:	efd5                	bnez	a5,800018d0 <main+0xce>
    consoleinit();
    80001816:	fffff097          	auipc	ra,0xfffff
    8000181a:	04e080e7          	jalr	78(ra) # 80000864 <consoleinit>
    printfinit();
    8000181e:	fffff097          	auipc	ra,0xfffff
    80001822:	4be080e7          	jalr	1214(ra) # 80000cdc <printfinit>
    printf("\n");
    80001826:	0000a517          	auipc	a0,0xa
    8000182a:	85a50513          	addi	a0,a0,-1958 # 8000b080 <etext+0x80>
    8000182e:	fffff097          	auipc	ra,0xfffff
    80001832:	206080e7          	jalr	518(ra) # 80000a34 <printf>
    printf("xv6 kernel is booting\n");
    80001836:	0000a517          	auipc	a0,0xa
    8000183a:	85250513          	addi	a0,a0,-1966 # 8000b088 <etext+0x88>
    8000183e:	fffff097          	auipc	ra,0xfffff
    80001842:	1f6080e7          	jalr	502(ra) # 80000a34 <printf>
    printf("\n");
    80001846:	0000a517          	auipc	a0,0xa
    8000184a:	83a50513          	addi	a0,a0,-1990 # 8000b080 <etext+0x80>
    8000184e:	fffff097          	auipc	ra,0xfffff
    80001852:	1e6080e7          	jalr	486(ra) # 80000a34 <printf>
    kinit();         // physical page allocator
    80001856:	fffff097          	auipc	ra,0xfffff
    8000185a:	792080e7          	jalr	1938(ra) # 80000fe8 <kinit>
    kvminit();       // create kernel page table
    8000185e:	00000097          	auipc	ra,0x0
    80001862:	1f4080e7          	jalr	500(ra) # 80001a52 <kvminit>
    kvminithart();   // turn on paging
    80001866:	00000097          	auipc	ra,0x0
    8000186a:	212080e7          	jalr	530(ra) # 80001a78 <kvminithart>
    procinit();      // process table
    8000186e:	00001097          	auipc	ra,0x1
    80001872:	ea6080e7          	jalr	-346(ra) # 80002714 <procinit>
    trapinit();      // trap vectors
    80001876:	00002097          	auipc	ra,0x2
    8000187a:	56c080e7          	jalr	1388(ra) # 80003de2 <trapinit>
    trapinithart();  // install kernel trap vector
    8000187e:	00002097          	auipc	ra,0x2
    80001882:	58e080e7          	jalr	1422(ra) # 80003e0c <trapinithart>
    plicinit();      // set up interrupt controller
    80001886:	00007097          	auipc	ra,0x7
    8000188a:	4a4080e7          	jalr	1188(ra) # 80008d2a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000188e:	00007097          	auipc	ra,0x7
    80001892:	4c0080e7          	jalr	1216(ra) # 80008d4e <plicinithart>
    binit();         // buffer cache
    80001896:	00003097          	auipc	ra,0x3
    8000189a:	020080e7          	jalr	32(ra) # 800048b6 <binit>
    iinit();         // inode table
    8000189e:	00004097          	auipc	ra,0x4
    800018a2:	856080e7          	jalr	-1962(ra) # 800050f4 <iinit>
    fileinit();      // file table
    800018a6:	00005097          	auipc	ra,0x5
    800018aa:	238080e7          	jalr	568(ra) # 80006ade <fileinit>
    virtio_disk_init(); // emulated hard disk
    800018ae:	00007097          	auipc	ra,0x7
    800018b2:	574080e7          	jalr	1396(ra) # 80008e22 <virtio_disk_init>
    userinit();      // first user process
    800018b6:	00001097          	auipc	ra,0x1
    800018ba:	30a080e7          	jalr	778(ra) # 80002bc0 <userinit>
    __sync_synchronize();
    800018be:	0ff0000f          	fence
    started = 1;
    800018c2:	00012797          	auipc	a5,0x12
    800018c6:	2de78793          	addi	a5,a5,734 # 80013ba0 <started>
    800018ca:	4705                	li	a4,1
    800018cc:	c398                	sw	a4,0(a5)
    800018ce:	a0a9                	j	80001918 <main+0x116>
  } else {
    while(started == 0)
    800018d0:	0001                	nop
    800018d2:	00012797          	auipc	a5,0x12
    800018d6:	2ce78793          	addi	a5,a5,718 # 80013ba0 <started>
    800018da:	439c                	lw	a5,0(a5)
    800018dc:	2781                	sext.w	a5,a5
    800018de:	dbf5                	beqz	a5,800018d2 <main+0xd0>
      ;
    __sync_synchronize();
    800018e0:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    800018e4:	00001097          	auipc	ra,0x1
    800018e8:	efe080e7          	jalr	-258(ra) # 800027e2 <cpuid>
    800018ec:	87aa                	mv	a5,a0
    800018ee:	85be                	mv	a1,a5
    800018f0:	00009517          	auipc	a0,0x9
    800018f4:	7b050513          	addi	a0,a0,1968 # 8000b0a0 <etext+0xa0>
    800018f8:	fffff097          	auipc	ra,0xfffff
    800018fc:	13c080e7          	jalr	316(ra) # 80000a34 <printf>
    kvminithart();    // turn on paging
    80001900:	00000097          	auipc	ra,0x0
    80001904:	178080e7          	jalr	376(ra) # 80001a78 <kvminithart>
    trapinithart();   // install kernel trap vector
    80001908:	00002097          	auipc	ra,0x2
    8000190c:	504080e7          	jalr	1284(ra) # 80003e0c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001910:	00007097          	auipc	ra,0x7
    80001914:	43e080e7          	jalr	1086(ra) # 80008d4e <plicinithart>
  }

  scheduler();        
    80001918:	00002097          	auipc	ra,0x2
    8000191c:	8be080e7          	jalr	-1858(ra) # 800031d6 <scheduler>

0000000080001920 <w_satp>:
{
    80001920:	1101                	addi	sp,sp,-32
    80001922:	ec22                	sd	s0,24(sp)
    80001924:	1000                	addi	s0,sp,32
    80001926:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw satp, %0" : : "r" (x));
    8000192a:	fe843783          	ld	a5,-24(s0)
    8000192e:	18079073          	csrw	satp,a5
}
    80001932:	0001                	nop
    80001934:	6462                	ld	s0,24(sp)
    80001936:	6105                	addi	sp,sp,32
    80001938:	8082                	ret

000000008000193a <sfence_vma>:
}

// flush the TLB.
static inline void
sfence_vma()
{
    8000193a:	1141                	addi	sp,sp,-16
    8000193c:	e422                	sd	s0,8(sp)
    8000193e:	0800                	addi	s0,sp,16
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001940:	12000073          	sfence.vma
}
    80001944:	0001                	nop
    80001946:	6422                	ld	s0,8(sp)
    80001948:	0141                	addi	sp,sp,16
    8000194a:	8082                	ret

000000008000194c <kvmmake>:
extern char trampoline[]; // trampoline.S

// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
    8000194c:	1101                	addi	sp,sp,-32
    8000194e:	ec06                	sd	ra,24(sp)
    80001950:	e822                	sd	s0,16(sp)
    80001952:	1000                	addi	s0,sp,32
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
    80001954:	fffff097          	auipc	ra,0xfffff
    80001958:	7d0080e7          	jalr	2000(ra) # 80001124 <kalloc>
    8000195c:	fea43423          	sd	a0,-24(s0)
  memset(kpgtbl, 0, PGSIZE);
    80001960:	6605                	lui	a2,0x1
    80001962:	4581                	li	a1,0
    80001964:	fe843503          	ld	a0,-24(s0)
    80001968:	00000097          	auipc	ra,0x0
    8000196c:	ae4080e7          	jalr	-1308(ra) # 8000144c <memset>

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001970:	4719                	li	a4,6
    80001972:	6685                	lui	a3,0x1
    80001974:	10000637          	lui	a2,0x10000
    80001978:	100005b7          	lui	a1,0x10000
    8000197c:	fe843503          	ld	a0,-24(s0)
    80001980:	00000097          	auipc	ra,0x0
    80001984:	2a2080e7          	jalr	674(ra) # 80001c22 <kvmmap>

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001988:	4719                	li	a4,6
    8000198a:	6685                	lui	a3,0x1
    8000198c:	10001637          	lui	a2,0x10001
    80001990:	100015b7          	lui	a1,0x10001
    80001994:	fe843503          	ld	a0,-24(s0)
    80001998:	00000097          	auipc	ra,0x0
    8000199c:	28a080e7          	jalr	650(ra) # 80001c22 <kvmmap>

  // PLIC
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800019a0:	4719                	li	a4,6
    800019a2:	004006b7          	lui	a3,0x400
    800019a6:	0c000637          	lui	a2,0xc000
    800019aa:	0c0005b7          	lui	a1,0xc000
    800019ae:	fe843503          	ld	a0,-24(s0)
    800019b2:	00000097          	auipc	ra,0x0
    800019b6:	270080e7          	jalr	624(ra) # 80001c22 <kvmmap>

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800019ba:	00009717          	auipc	a4,0x9
    800019be:	64670713          	addi	a4,a4,1606 # 8000b000 <etext>
    800019c2:	800007b7          	lui	a5,0x80000
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	4729                	li	a4,10
    800019ca:	86be                	mv	a3,a5
    800019cc:	4785                	li	a5,1
    800019ce:	01f79613          	slli	a2,a5,0x1f
    800019d2:	4785                	li	a5,1
    800019d4:	01f79593          	slli	a1,a5,0x1f
    800019d8:	fe843503          	ld	a0,-24(s0)
    800019dc:	00000097          	auipc	ra,0x0
    800019e0:	246080e7          	jalr	582(ra) # 80001c22 <kvmmap>

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800019e4:	00009597          	auipc	a1,0x9
    800019e8:	61c58593          	addi	a1,a1,1564 # 8000b000 <etext>
    800019ec:	00009617          	auipc	a2,0x9
    800019f0:	61460613          	addi	a2,a2,1556 # 8000b000 <etext>
    800019f4:	00009797          	auipc	a5,0x9
    800019f8:	60c78793          	addi	a5,a5,1548 # 8000b000 <etext>
    800019fc:	4745                	li	a4,17
    800019fe:	076e                	slli	a4,a4,0x1b
    80001a00:	40f707b3          	sub	a5,a4,a5
    80001a04:	4719                	li	a4,6
    80001a06:	86be                	mv	a3,a5
    80001a08:	fe843503          	ld	a0,-24(s0)
    80001a0c:	00000097          	auipc	ra,0x0
    80001a10:	216080e7          	jalr	534(ra) # 80001c22 <kvmmap>

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001a14:	00008797          	auipc	a5,0x8
    80001a18:	5ec78793          	addi	a5,a5,1516 # 8000a000 <_trampoline>
    80001a1c:	4729                	li	a4,10
    80001a1e:	6685                	lui	a3,0x1
    80001a20:	863e                	mv	a2,a5
    80001a22:	040007b7          	lui	a5,0x4000
    80001a26:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001a28:	00c79593          	slli	a1,a5,0xc
    80001a2c:	fe843503          	ld	a0,-24(s0)
    80001a30:	00000097          	auipc	ra,0x0
    80001a34:	1f2080e7          	jalr	498(ra) # 80001c22 <kvmmap>

  // allocate and map a kernel stack for each process.
  proc_mapstacks(kpgtbl);
    80001a38:	fe843503          	ld	a0,-24(s0)
    80001a3c:	00001097          	auipc	ra,0x1
    80001a40:	c1c080e7          	jalr	-996(ra) # 80002658 <proc_mapstacks>
  
  return kpgtbl;
    80001a44:	fe843783          	ld	a5,-24(s0)
}
    80001a48:	853e                	mv	a0,a5
    80001a4a:	60e2                	ld	ra,24(sp)
    80001a4c:	6442                	ld	s0,16(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <kvminit>:

// Initialize the one kernel_pagetable
void
kvminit(void)
{
    80001a52:	1141                	addi	sp,sp,-16
    80001a54:	e406                	sd	ra,8(sp)
    80001a56:	e022                	sd	s0,0(sp)
    80001a58:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001a5a:	00000097          	auipc	ra,0x0
    80001a5e:	ef2080e7          	jalr	-270(ra) # 8000194c <kvmmake>
    80001a62:	872a                	mv	a4,a0
    80001a64:	0000a797          	auipc	a5,0xa
    80001a68:	ec478793          	addi	a5,a5,-316 # 8000b928 <kernel_pagetable>
    80001a6c:	e398                	sd	a4,0(a5)
}
    80001a6e:	0001                	nop
    80001a70:	60a2                	ld	ra,8(sp)
    80001a72:	6402                	ld	s0,0(sp)
    80001a74:	0141                	addi	sp,sp,16
    80001a76:	8082                	ret

0000000080001a78 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80001a78:	1141                	addi	sp,sp,-16
    80001a7a:	e406                	sd	ra,8(sp)
    80001a7c:	e022                	sd	s0,0(sp)
    80001a7e:	0800                	addi	s0,sp,16
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();
    80001a80:	00000097          	auipc	ra,0x0
    80001a84:	eba080e7          	jalr	-326(ra) # 8000193a <sfence_vma>

  w_satp(MAKE_SATP(kernel_pagetable));
    80001a88:	0000a797          	auipc	a5,0xa
    80001a8c:	ea078793          	addi	a5,a5,-352 # 8000b928 <kernel_pagetable>
    80001a90:	639c                	ld	a5,0(a5)
    80001a92:	00c7d713          	srli	a4,a5,0xc
    80001a96:	57fd                	li	a5,-1
    80001a98:	17fe                	slli	a5,a5,0x3f
    80001a9a:	8fd9                	or	a5,a5,a4
    80001a9c:	853e                	mv	a0,a5
    80001a9e:	00000097          	auipc	ra,0x0
    80001aa2:	e82080e7          	jalr	-382(ra) # 80001920 <w_satp>

  // flush stale entries from the TLB.
  sfence_vma();
    80001aa6:	00000097          	auipc	ra,0x0
    80001aaa:	e94080e7          	jalr	-364(ra) # 8000193a <sfence_vma>
}
    80001aae:	0001                	nop
    80001ab0:	60a2                	ld	ra,8(sp)
    80001ab2:	6402                	ld	s0,0(sp)
    80001ab4:	0141                	addi	sp,sp,16
    80001ab6:	8082                	ret

0000000080001ab8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001ab8:	7139                	addi	sp,sp,-64
    80001aba:	fc06                	sd	ra,56(sp)
    80001abc:	f822                	sd	s0,48(sp)
    80001abe:	0080                	addi	s0,sp,64
    80001ac0:	fca43c23          	sd	a0,-40(s0)
    80001ac4:	fcb43823          	sd	a1,-48(s0)
    80001ac8:	87b2                	mv	a5,a2
    80001aca:	fcf42623          	sw	a5,-52(s0)
  if(va >= MAXVA)
    80001ace:	fd043703          	ld	a4,-48(s0)
    80001ad2:	57fd                	li	a5,-1
    80001ad4:	83e9                	srli	a5,a5,0x1a
    80001ad6:	00e7fa63          	bgeu	a5,a4,80001aea <walk+0x32>
    panic("walk");
    80001ada:	00009517          	auipc	a0,0x9
    80001ade:	5de50513          	addi	a0,a0,1502 # 8000b0b8 <etext+0xb8>
    80001ae2:	fffff097          	auipc	ra,0xfffff
    80001ae6:	1a8080e7          	jalr	424(ra) # 80000c8a <panic>

  for(int level = 2; level > 0; level--) {
    80001aea:	4789                	li	a5,2
    80001aec:	fef42623          	sw	a5,-20(s0)
    80001af0:	a851                	j	80001b84 <walk+0xcc>
    pte_t *pte = &pagetable[PX(level, va)];
    80001af2:	fec42783          	lw	a5,-20(s0)
    80001af6:	873e                	mv	a4,a5
    80001af8:	87ba                	mv	a5,a4
    80001afa:	0037979b          	slliw	a5,a5,0x3
    80001afe:	9fb9                	addw	a5,a5,a4
    80001b00:	2781                	sext.w	a5,a5
    80001b02:	27b1                	addiw	a5,a5,12
    80001b04:	2781                	sext.w	a5,a5
    80001b06:	873e                	mv	a4,a5
    80001b08:	fd043783          	ld	a5,-48(s0)
    80001b0c:	00e7d7b3          	srl	a5,a5,a4
    80001b10:	1ff7f793          	andi	a5,a5,511
    80001b14:	078e                	slli	a5,a5,0x3
    80001b16:	fd843703          	ld	a4,-40(s0)
    80001b1a:	97ba                	add	a5,a5,a4
    80001b1c:	fef43023          	sd	a5,-32(s0)
    if(*pte & PTE_V) {
    80001b20:	fe043783          	ld	a5,-32(s0)
    80001b24:	639c                	ld	a5,0(a5)
    80001b26:	8b85                	andi	a5,a5,1
    80001b28:	cb89                	beqz	a5,80001b3a <walk+0x82>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001b2a:	fe043783          	ld	a5,-32(s0)
    80001b2e:	639c                	ld	a5,0(a5)
    80001b30:	83a9                	srli	a5,a5,0xa
    80001b32:	07b2                	slli	a5,a5,0xc
    80001b34:	fcf43c23          	sd	a5,-40(s0)
    80001b38:	a089                	j	80001b7a <walk+0xc2>
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001b3a:	fcc42783          	lw	a5,-52(s0)
    80001b3e:	2781                	sext.w	a5,a5
    80001b40:	cb91                	beqz	a5,80001b54 <walk+0x9c>
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	5e2080e7          	jalr	1506(ra) # 80001124 <kalloc>
    80001b4a:	fca43c23          	sd	a0,-40(s0)
    80001b4e:	fd843783          	ld	a5,-40(s0)
    80001b52:	e399                	bnez	a5,80001b58 <walk+0xa0>
        return 0;
    80001b54:	4781                	li	a5,0
    80001b56:	a0a9                	j	80001ba0 <walk+0xe8>
      memset(pagetable, 0, PGSIZE);
    80001b58:	6605                	lui	a2,0x1
    80001b5a:	4581                	li	a1,0
    80001b5c:	fd843503          	ld	a0,-40(s0)
    80001b60:	00000097          	auipc	ra,0x0
    80001b64:	8ec080e7          	jalr	-1812(ra) # 8000144c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001b68:	fd843783          	ld	a5,-40(s0)
    80001b6c:	83b1                	srli	a5,a5,0xc
    80001b6e:	07aa                	slli	a5,a5,0xa
    80001b70:	0017e713          	ori	a4,a5,1
    80001b74:	fe043783          	ld	a5,-32(s0)
    80001b78:	e398                	sd	a4,0(a5)
  for(int level = 2; level > 0; level--) {
    80001b7a:	fec42783          	lw	a5,-20(s0)
    80001b7e:	37fd                	addiw	a5,a5,-1
    80001b80:	fef42623          	sw	a5,-20(s0)
    80001b84:	fec42783          	lw	a5,-20(s0)
    80001b88:	2781                	sext.w	a5,a5
    80001b8a:	f6f044e3          	bgtz	a5,80001af2 <walk+0x3a>
    }
  }
  return &pagetable[PX(0, va)];
    80001b8e:	fd043783          	ld	a5,-48(s0)
    80001b92:	83b1                	srli	a5,a5,0xc
    80001b94:	1ff7f793          	andi	a5,a5,511
    80001b98:	078e                	slli	a5,a5,0x3
    80001b9a:	fd843703          	ld	a4,-40(s0)
    80001b9e:	97ba                	add	a5,a5,a4
}
    80001ba0:	853e                	mv	a0,a5
    80001ba2:	70e2                	ld	ra,56(sp)
    80001ba4:	7442                	ld	s0,48(sp)
    80001ba6:	6121                	addi	sp,sp,64
    80001ba8:	8082                	ret

0000000080001baa <walkaddr>:
// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
    80001baa:	7179                	addi	sp,sp,-48
    80001bac:	f406                	sd	ra,40(sp)
    80001bae:	f022                	sd	s0,32(sp)
    80001bb0:	1800                	addi	s0,sp,48
    80001bb2:	fca43c23          	sd	a0,-40(s0)
    80001bb6:	fcb43823          	sd	a1,-48(s0)
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001bba:	fd043703          	ld	a4,-48(s0)
    80001bbe:	57fd                	li	a5,-1
    80001bc0:	83e9                	srli	a5,a5,0x1a
    80001bc2:	00e7f463          	bgeu	a5,a4,80001bca <walkaddr+0x20>
    return 0;
    80001bc6:	4781                	li	a5,0
    80001bc8:	a881                	j	80001c18 <walkaddr+0x6e>

  pte = walk(pagetable, va, 0);
    80001bca:	4601                	li	a2,0
    80001bcc:	fd043583          	ld	a1,-48(s0)
    80001bd0:	fd843503          	ld	a0,-40(s0)
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	ee4080e7          	jalr	-284(ra) # 80001ab8 <walk>
    80001bdc:	fea43423          	sd	a0,-24(s0)
  if(pte == 0)
    80001be0:	fe843783          	ld	a5,-24(s0)
    80001be4:	e399                	bnez	a5,80001bea <walkaddr+0x40>
    return 0;
    80001be6:	4781                	li	a5,0
    80001be8:	a805                	j	80001c18 <walkaddr+0x6e>
  if((*pte & PTE_V) == 0)
    80001bea:	fe843783          	ld	a5,-24(s0)
    80001bee:	639c                	ld	a5,0(a5)
    80001bf0:	8b85                	andi	a5,a5,1
    80001bf2:	e399                	bnez	a5,80001bf8 <walkaddr+0x4e>
    return 0;
    80001bf4:	4781                	li	a5,0
    80001bf6:	a00d                	j	80001c18 <walkaddr+0x6e>
  if((*pte & PTE_U) == 0)
    80001bf8:	fe843783          	ld	a5,-24(s0)
    80001bfc:	639c                	ld	a5,0(a5)
    80001bfe:	8bc1                	andi	a5,a5,16
    80001c00:	e399                	bnez	a5,80001c06 <walkaddr+0x5c>
    return 0;
    80001c02:	4781                	li	a5,0
    80001c04:	a811                	j	80001c18 <walkaddr+0x6e>
  pa = PTE2PA(*pte);
    80001c06:	fe843783          	ld	a5,-24(s0)
    80001c0a:	639c                	ld	a5,0(a5)
    80001c0c:	83a9                	srli	a5,a5,0xa
    80001c0e:	07b2                	slli	a5,a5,0xc
    80001c10:	fef43023          	sd	a5,-32(s0)
  return pa;
    80001c14:	fe043783          	ld	a5,-32(s0)
}
    80001c18:	853e                	mv	a0,a5
    80001c1a:	70a2                	ld	ra,40(sp)
    80001c1c:	7402                	ld	s0,32(sp)
    80001c1e:	6145                	addi	sp,sp,48
    80001c20:	8082                	ret

0000000080001c22 <kvmmap>:
// add a mapping to the kernel page table.
// only used when booting.
// does not flush TLB or enable paging.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
    80001c22:	7139                	addi	sp,sp,-64
    80001c24:	fc06                	sd	ra,56(sp)
    80001c26:	f822                	sd	s0,48(sp)
    80001c28:	0080                	addi	s0,sp,64
    80001c2a:	fea43423          	sd	a0,-24(s0)
    80001c2e:	feb43023          	sd	a1,-32(s0)
    80001c32:	fcc43c23          	sd	a2,-40(s0)
    80001c36:	fcd43823          	sd	a3,-48(s0)
    80001c3a:	87ba                	mv	a5,a4
    80001c3c:	fcf42623          	sw	a5,-52(s0)
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001c40:	fcc42783          	lw	a5,-52(s0)
    80001c44:	873e                	mv	a4,a5
    80001c46:	fd843683          	ld	a3,-40(s0)
    80001c4a:	fd043603          	ld	a2,-48(s0)
    80001c4e:	fe043583          	ld	a1,-32(s0)
    80001c52:	fe843503          	ld	a0,-24(s0)
    80001c56:	00000097          	auipc	ra,0x0
    80001c5a:	026080e7          	jalr	38(ra) # 80001c7c <mappages>
    80001c5e:	87aa                	mv	a5,a0
    80001c60:	cb89                	beqz	a5,80001c72 <kvmmap+0x50>
    panic("kvmmap");
    80001c62:	00009517          	auipc	a0,0x9
    80001c66:	45e50513          	addi	a0,a0,1118 # 8000b0c0 <etext+0xc0>
    80001c6a:	fffff097          	auipc	ra,0xfffff
    80001c6e:	020080e7          	jalr	32(ra) # 80000c8a <panic>
}
    80001c72:	0001                	nop
    80001c74:	70e2                	ld	ra,56(sp)
    80001c76:	7442                	ld	s0,48(sp)
    80001c78:	6121                	addi	sp,sp,64
    80001c7a:	8082                	ret

0000000080001c7c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001c7c:	711d                	addi	sp,sp,-96
    80001c7e:	ec86                	sd	ra,88(sp)
    80001c80:	e8a2                	sd	s0,80(sp)
    80001c82:	1080                	addi	s0,sp,96
    80001c84:	fca43423          	sd	a0,-56(s0)
    80001c88:	fcb43023          	sd	a1,-64(s0)
    80001c8c:	fac43c23          	sd	a2,-72(s0)
    80001c90:	fad43823          	sd	a3,-80(s0)
    80001c94:	87ba                	mv	a5,a4
    80001c96:	faf42623          	sw	a5,-84(s0)
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80001c9a:	fb843783          	ld	a5,-72(s0)
    80001c9e:	eb89                	bnez	a5,80001cb0 <mappages+0x34>
    panic("mappages: size");
    80001ca0:	00009517          	auipc	a0,0x9
    80001ca4:	42850513          	addi	a0,a0,1064 # 8000b0c8 <etext+0xc8>
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	fe2080e7          	jalr	-30(ra) # 80000c8a <panic>
  
  a = PGROUNDDOWN(va);
    80001cb0:	fc043703          	ld	a4,-64(s0)
    80001cb4:	77fd                	lui	a5,0xfffff
    80001cb6:	8ff9                	and	a5,a5,a4
    80001cb8:	fef43423          	sd	a5,-24(s0)
  last = PGROUNDDOWN(va + size - 1);
    80001cbc:	fc043703          	ld	a4,-64(s0)
    80001cc0:	fb843783          	ld	a5,-72(s0)
    80001cc4:	97ba                	add	a5,a5,a4
    80001cc6:	fff78713          	addi	a4,a5,-1 # ffffffffffffefff <end+0xffffffff7ffda247>
    80001cca:	77fd                	lui	a5,0xfffff
    80001ccc:	8ff9                	and	a5,a5,a4
    80001cce:	fef43023          	sd	a5,-32(s0)
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    80001cd2:	4605                	li	a2,1
    80001cd4:	fe843583          	ld	a1,-24(s0)
    80001cd8:	fc843503          	ld	a0,-56(s0)
    80001cdc:	00000097          	auipc	ra,0x0
    80001ce0:	ddc080e7          	jalr	-548(ra) # 80001ab8 <walk>
    80001ce4:	fca43c23          	sd	a0,-40(s0)
    80001ce8:	fd843783          	ld	a5,-40(s0)
    80001cec:	e399                	bnez	a5,80001cf2 <mappages+0x76>
      return -1;
    80001cee:	57fd                	li	a5,-1
    80001cf0:	a085                	j	80001d50 <mappages+0xd4>
    if(*pte & PTE_V)
    80001cf2:	fd843783          	ld	a5,-40(s0)
    80001cf6:	639c                	ld	a5,0(a5)
    80001cf8:	8b85                	andi	a5,a5,1
    80001cfa:	cb89                	beqz	a5,80001d0c <mappages+0x90>
      panic("mappages: remap");
    80001cfc:	00009517          	auipc	a0,0x9
    80001d00:	3dc50513          	addi	a0,a0,988 # 8000b0d8 <etext+0xd8>
    80001d04:	fffff097          	auipc	ra,0xfffff
    80001d08:	f86080e7          	jalr	-122(ra) # 80000c8a <panic>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001d0c:	fb043783          	ld	a5,-80(s0)
    80001d10:	83b1                	srli	a5,a5,0xc
    80001d12:	00a79713          	slli	a4,a5,0xa
    80001d16:	fac42783          	lw	a5,-84(s0)
    80001d1a:	8fd9                	or	a5,a5,a4
    80001d1c:	0017e713          	ori	a4,a5,1
    80001d20:	fd843783          	ld	a5,-40(s0)
    80001d24:	e398                	sd	a4,0(a5)
    if(a == last)
    80001d26:	fe843703          	ld	a4,-24(s0)
    80001d2a:	fe043783          	ld	a5,-32(s0)
    80001d2e:	00f70f63          	beq	a4,a5,80001d4c <mappages+0xd0>
      break;
    a += PGSIZE;
    80001d32:	fe843703          	ld	a4,-24(s0)
    80001d36:	6785                	lui	a5,0x1
    80001d38:	97ba                	add	a5,a5,a4
    80001d3a:	fef43423          	sd	a5,-24(s0)
    pa += PGSIZE;
    80001d3e:	fb043703          	ld	a4,-80(s0)
    80001d42:	6785                	lui	a5,0x1
    80001d44:	97ba                	add	a5,a5,a4
    80001d46:	faf43823          	sd	a5,-80(s0)
    if((pte = walk(pagetable, a, 1)) == 0)
    80001d4a:	b761                	j	80001cd2 <mappages+0x56>
      break;
    80001d4c:	0001                	nop
  }
  return 0;
    80001d4e:	4781                	li	a5,0
}
    80001d50:	853e                	mv	a0,a5
    80001d52:	60e6                	ld	ra,88(sp)
    80001d54:	6446                	ld	s0,80(sp)
    80001d56:	6125                	addi	sp,sp,96
    80001d58:	8082                	ret

0000000080001d5a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001d5a:	715d                	addi	sp,sp,-80
    80001d5c:	e486                	sd	ra,72(sp)
    80001d5e:	e0a2                	sd	s0,64(sp)
    80001d60:	0880                	addi	s0,sp,80
    80001d62:	fca43423          	sd	a0,-56(s0)
    80001d66:	fcb43023          	sd	a1,-64(s0)
    80001d6a:	fac43c23          	sd	a2,-72(s0)
    80001d6e:	87b6                	mv	a5,a3
    80001d70:	faf42a23          	sw	a5,-76(s0)
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001d74:	fc043703          	ld	a4,-64(s0)
    80001d78:	6785                	lui	a5,0x1
    80001d7a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001d7c:	8ff9                	and	a5,a5,a4
    80001d7e:	cb89                	beqz	a5,80001d90 <uvmunmap+0x36>
    panic("uvmunmap: not aligned");
    80001d80:	00009517          	auipc	a0,0x9
    80001d84:	36850513          	addi	a0,a0,872 # 8000b0e8 <etext+0xe8>
    80001d88:	fffff097          	auipc	ra,0xfffff
    80001d8c:	f02080e7          	jalr	-254(ra) # 80000c8a <panic>

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001d90:	fc043783          	ld	a5,-64(s0)
    80001d94:	fef43423          	sd	a5,-24(s0)
    80001d98:	a045                	j	80001e38 <uvmunmap+0xde>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001d9a:	4601                	li	a2,0
    80001d9c:	fe843583          	ld	a1,-24(s0)
    80001da0:	fc843503          	ld	a0,-56(s0)
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	d14080e7          	jalr	-748(ra) # 80001ab8 <walk>
    80001dac:	fea43023          	sd	a0,-32(s0)
    80001db0:	fe043783          	ld	a5,-32(s0)
    80001db4:	eb89                	bnez	a5,80001dc6 <uvmunmap+0x6c>
      panic("uvmunmap: walk");
    80001db6:	00009517          	auipc	a0,0x9
    80001dba:	34a50513          	addi	a0,a0,842 # 8000b100 <etext+0x100>
    80001dbe:	fffff097          	auipc	ra,0xfffff
    80001dc2:	ecc080e7          	jalr	-308(ra) # 80000c8a <panic>
    if((*pte & PTE_V) == 0)
    80001dc6:	fe043783          	ld	a5,-32(s0)
    80001dca:	639c                	ld	a5,0(a5)
    80001dcc:	8b85                	andi	a5,a5,1
    80001dce:	eb89                	bnez	a5,80001de0 <uvmunmap+0x86>
      panic("uvmunmap: not mapped");
    80001dd0:	00009517          	auipc	a0,0x9
    80001dd4:	34050513          	addi	a0,a0,832 # 8000b110 <etext+0x110>
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	eb2080e7          	jalr	-334(ra) # 80000c8a <panic>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001de0:	fe043783          	ld	a5,-32(s0)
    80001de4:	639c                	ld	a5,0(a5)
    80001de6:	3ff7f713          	andi	a4,a5,1023
    80001dea:	4785                	li	a5,1
    80001dec:	00f71a63          	bne	a4,a5,80001e00 <uvmunmap+0xa6>
      panic("uvmunmap: not a leaf");
    80001df0:	00009517          	auipc	a0,0x9
    80001df4:	33850513          	addi	a0,a0,824 # 8000b128 <etext+0x128>
    80001df8:	fffff097          	auipc	ra,0xfffff
    80001dfc:	e92080e7          	jalr	-366(ra) # 80000c8a <panic>
    if(do_free){
    80001e00:	fb442783          	lw	a5,-76(s0)
    80001e04:	2781                	sext.w	a5,a5
    80001e06:	cf99                	beqz	a5,80001e24 <uvmunmap+0xca>
      uint64 pa = PTE2PA(*pte);
    80001e08:	fe043783          	ld	a5,-32(s0)
    80001e0c:	639c                	ld	a5,0(a5)
    80001e0e:	83a9                	srli	a5,a5,0xa
    80001e10:	07b2                	slli	a5,a5,0xc
    80001e12:	fcf43c23          	sd	a5,-40(s0)
      kfree((void*)pa);
    80001e16:	fd843783          	ld	a5,-40(s0)
    80001e1a:	853e                	mv	a0,a5
    80001e1c:	fffff097          	auipc	ra,0xfffff
    80001e20:	264080e7          	jalr	612(ra) # 80001080 <kfree>
    }
    *pte = 0;
    80001e24:	fe043783          	ld	a5,-32(s0)
    80001e28:	0007b023          	sd	zero,0(a5)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001e2c:	fe843703          	ld	a4,-24(s0)
    80001e30:	6785                	lui	a5,0x1
    80001e32:	97ba                	add	a5,a5,a4
    80001e34:	fef43423          	sd	a5,-24(s0)
    80001e38:	fb843783          	ld	a5,-72(s0)
    80001e3c:	00c79713          	slli	a4,a5,0xc
    80001e40:	fc043783          	ld	a5,-64(s0)
    80001e44:	97ba                	add	a5,a5,a4
    80001e46:	fe843703          	ld	a4,-24(s0)
    80001e4a:	f4f768e3          	bltu	a4,a5,80001d9a <uvmunmap+0x40>
  }
}
    80001e4e:	0001                	nop
    80001e50:	0001                	nop
    80001e52:	60a6                	ld	ra,72(sp)
    80001e54:	6406                	ld	s0,64(sp)
    80001e56:	6161                	addi	sp,sp,80
    80001e58:	8082                	ret

0000000080001e5a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001e5a:	1101                	addi	sp,sp,-32
    80001e5c:	ec06                	sd	ra,24(sp)
    80001e5e:	e822                	sd	s0,16(sp)
    80001e60:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	2c2080e7          	jalr	706(ra) # 80001124 <kalloc>
    80001e6a:	fea43423          	sd	a0,-24(s0)
  if(pagetable == 0)
    80001e6e:	fe843783          	ld	a5,-24(s0)
    80001e72:	e399                	bnez	a5,80001e78 <uvmcreate+0x1e>
    return 0;
    80001e74:	4781                	li	a5,0
    80001e76:	a819                	j	80001e8c <uvmcreate+0x32>
  memset(pagetable, 0, PGSIZE);
    80001e78:	6605                	lui	a2,0x1
    80001e7a:	4581                	li	a1,0
    80001e7c:	fe843503          	ld	a0,-24(s0)
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	5cc080e7          	jalr	1484(ra) # 8000144c <memset>
  return pagetable;
    80001e88:	fe843783          	ld	a5,-24(s0)
}
    80001e8c:	853e                	mv	a0,a5
    80001e8e:	60e2                	ld	ra,24(sp)
    80001e90:	6442                	ld	s0,16(sp)
    80001e92:	6105                	addi	sp,sp,32
    80001e94:	8082                	ret

0000000080001e96 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001e96:	7139                	addi	sp,sp,-64
    80001e98:	fc06                	sd	ra,56(sp)
    80001e9a:	f822                	sd	s0,48(sp)
    80001e9c:	0080                	addi	s0,sp,64
    80001e9e:	fca43c23          	sd	a0,-40(s0)
    80001ea2:	fcb43823          	sd	a1,-48(s0)
    80001ea6:	87b2                	mv	a5,a2
    80001ea8:	fcf42623          	sw	a5,-52(s0)
  char *mem;

  if(sz >= PGSIZE)
    80001eac:	fcc42783          	lw	a5,-52(s0)
    80001eb0:	0007871b          	sext.w	a4,a5
    80001eb4:	6785                	lui	a5,0x1
    80001eb6:	00f76a63          	bltu	a4,a5,80001eca <uvmfirst+0x34>
    panic("uvmfirst: more than a page");
    80001eba:	00009517          	auipc	a0,0x9
    80001ebe:	28650513          	addi	a0,a0,646 # 8000b140 <etext+0x140>
    80001ec2:	fffff097          	auipc	ra,0xfffff
    80001ec6:	dc8080e7          	jalr	-568(ra) # 80000c8a <panic>
  mem = kalloc();
    80001eca:	fffff097          	auipc	ra,0xfffff
    80001ece:	25a080e7          	jalr	602(ra) # 80001124 <kalloc>
    80001ed2:	fea43423          	sd	a0,-24(s0)
  memset(mem, 0, PGSIZE);
    80001ed6:	6605                	lui	a2,0x1
    80001ed8:	4581                	li	a1,0
    80001eda:	fe843503          	ld	a0,-24(s0)
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	56e080e7          	jalr	1390(ra) # 8000144c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001ee6:	fe843783          	ld	a5,-24(s0)
    80001eea:	4779                	li	a4,30
    80001eec:	86be                	mv	a3,a5
    80001eee:	6605                	lui	a2,0x1
    80001ef0:	4581                	li	a1,0
    80001ef2:	fd843503          	ld	a0,-40(s0)
    80001ef6:	00000097          	auipc	ra,0x0
    80001efa:	d86080e7          	jalr	-634(ra) # 80001c7c <mappages>
  memmove(mem, src, sz);
    80001efe:	fcc42783          	lw	a5,-52(s0)
    80001f02:	863e                	mv	a2,a5
    80001f04:	fd043583          	ld	a1,-48(s0)
    80001f08:	fe843503          	ld	a0,-24(s0)
    80001f0c:	fffff097          	auipc	ra,0xfffff
    80001f10:	624080e7          	jalr	1572(ra) # 80001530 <memmove>
}
    80001f14:	0001                	nop
    80001f16:	70e2                	ld	ra,56(sp)
    80001f18:	7442                	ld	s0,48(sp)
    80001f1a:	6121                	addi	sp,sp,64
    80001f1c:	8082                	ret

0000000080001f1e <uvmalloc>:

// Allocate PTEs and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
uint64
uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz, int xperm)
{
    80001f1e:	7139                	addi	sp,sp,-64
    80001f20:	fc06                	sd	ra,56(sp)
    80001f22:	f822                	sd	s0,48(sp)
    80001f24:	0080                	addi	s0,sp,64
    80001f26:	fca43c23          	sd	a0,-40(s0)
    80001f2a:	fcb43823          	sd	a1,-48(s0)
    80001f2e:	fcc43423          	sd	a2,-56(s0)
    80001f32:	87b6                	mv	a5,a3
    80001f34:	fcf42223          	sw	a5,-60(s0)
  char *mem;
  uint64 a;

  if(newsz < oldsz)
    80001f38:	fc843703          	ld	a4,-56(s0)
    80001f3c:	fd043783          	ld	a5,-48(s0)
    80001f40:	00f77563          	bgeu	a4,a5,80001f4a <uvmalloc+0x2c>
    return oldsz;
    80001f44:	fd043783          	ld	a5,-48(s0)
    80001f48:	a87d                	j	80002006 <uvmalloc+0xe8>

  oldsz = PGROUNDUP(oldsz);
    80001f4a:	fd043703          	ld	a4,-48(s0)
    80001f4e:	6785                	lui	a5,0x1
    80001f50:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001f52:	973e                	add	a4,a4,a5
    80001f54:	77fd                	lui	a5,0xfffff
    80001f56:	8ff9                	and	a5,a5,a4
    80001f58:	fcf43823          	sd	a5,-48(s0)
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001f5c:	fd043783          	ld	a5,-48(s0)
    80001f60:	fef43423          	sd	a5,-24(s0)
    80001f64:	a849                	j	80001ff6 <uvmalloc+0xd8>
    mem = kalloc();
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	1be080e7          	jalr	446(ra) # 80001124 <kalloc>
    80001f6e:	fea43023          	sd	a0,-32(s0)
    if(mem == 0){
    80001f72:	fe043783          	ld	a5,-32(s0)
    80001f76:	ef89                	bnez	a5,80001f90 <uvmalloc+0x72>
      uvmdealloc(pagetable, a, oldsz);
    80001f78:	fd043603          	ld	a2,-48(s0)
    80001f7c:	fe843583          	ld	a1,-24(s0)
    80001f80:	fd843503          	ld	a0,-40(s0)
    80001f84:	00000097          	auipc	ra,0x0
    80001f88:	08c080e7          	jalr	140(ra) # 80002010 <uvmdealloc>
      return 0;
    80001f8c:	4781                	li	a5,0
    80001f8e:	a8a5                	j	80002006 <uvmalloc+0xe8>
    }
    memset(mem, 0, PGSIZE);
    80001f90:	6605                	lui	a2,0x1
    80001f92:	4581                	li	a1,0
    80001f94:	fe043503          	ld	a0,-32(s0)
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	4b4080e7          	jalr	1204(ra) # 8000144c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001fa0:	fe043783          	ld	a5,-32(s0)
    80001fa4:	fc442703          	lw	a4,-60(s0)
    80001fa8:	01276713          	ori	a4,a4,18
    80001fac:	2701                	sext.w	a4,a4
    80001fae:	86be                	mv	a3,a5
    80001fb0:	6605                	lui	a2,0x1
    80001fb2:	fe843583          	ld	a1,-24(s0)
    80001fb6:	fd843503          	ld	a0,-40(s0)
    80001fba:	00000097          	auipc	ra,0x0
    80001fbe:	cc2080e7          	jalr	-830(ra) # 80001c7c <mappages>
    80001fc2:	87aa                	mv	a5,a0
    80001fc4:	c39d                	beqz	a5,80001fea <uvmalloc+0xcc>
      kfree(mem);
    80001fc6:	fe043503          	ld	a0,-32(s0)
    80001fca:	fffff097          	auipc	ra,0xfffff
    80001fce:	0b6080e7          	jalr	182(ra) # 80001080 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001fd2:	fd043603          	ld	a2,-48(s0)
    80001fd6:	fe843583          	ld	a1,-24(s0)
    80001fda:	fd843503          	ld	a0,-40(s0)
    80001fde:	00000097          	auipc	ra,0x0
    80001fe2:	032080e7          	jalr	50(ra) # 80002010 <uvmdealloc>
      return 0;
    80001fe6:	4781                	li	a5,0
    80001fe8:	a839                	j	80002006 <uvmalloc+0xe8>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001fea:	fe843703          	ld	a4,-24(s0)
    80001fee:	6785                	lui	a5,0x1
    80001ff0:	97ba                	add	a5,a5,a4
    80001ff2:	fef43423          	sd	a5,-24(s0)
    80001ff6:	fe843703          	ld	a4,-24(s0)
    80001ffa:	fc843783          	ld	a5,-56(s0)
    80001ffe:	f6f764e3          	bltu	a4,a5,80001f66 <uvmalloc+0x48>
    }
  }
  return newsz;
    80002002:	fc843783          	ld	a5,-56(s0)
}
    80002006:	853e                	mv	a0,a5
    80002008:	70e2                	ld	ra,56(sp)
    8000200a:	7442                	ld	s0,48(sp)
    8000200c:	6121                	addi	sp,sp,64
    8000200e:	8082                	ret

0000000080002010 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80002010:	7139                	addi	sp,sp,-64
    80002012:	fc06                	sd	ra,56(sp)
    80002014:	f822                	sd	s0,48(sp)
    80002016:	0080                	addi	s0,sp,64
    80002018:	fca43c23          	sd	a0,-40(s0)
    8000201c:	fcb43823          	sd	a1,-48(s0)
    80002020:	fcc43423          	sd	a2,-56(s0)
  if(newsz >= oldsz)
    80002024:	fc843703          	ld	a4,-56(s0)
    80002028:	fd043783          	ld	a5,-48(s0)
    8000202c:	00f76563          	bltu	a4,a5,80002036 <uvmdealloc+0x26>
    return oldsz;
    80002030:	fd043783          	ld	a5,-48(s0)
    80002034:	a885                	j	800020a4 <uvmdealloc+0x94>

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80002036:	fc843703          	ld	a4,-56(s0)
    8000203a:	6785                	lui	a5,0x1
    8000203c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000203e:	973e                	add	a4,a4,a5
    80002040:	77fd                	lui	a5,0xfffff
    80002042:	8f7d                	and	a4,a4,a5
    80002044:	fd043683          	ld	a3,-48(s0)
    80002048:	6785                	lui	a5,0x1
    8000204a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000204c:	96be                	add	a3,a3,a5
    8000204e:	77fd                	lui	a5,0xfffff
    80002050:	8ff5                	and	a5,a5,a3
    80002052:	04f77763          	bgeu	a4,a5,800020a0 <uvmdealloc+0x90>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80002056:	fd043703          	ld	a4,-48(s0)
    8000205a:	6785                	lui	a5,0x1
    8000205c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000205e:	973e                	add	a4,a4,a5
    80002060:	77fd                	lui	a5,0xfffff
    80002062:	8f7d                	and	a4,a4,a5
    80002064:	fc843683          	ld	a3,-56(s0)
    80002068:	6785                	lui	a5,0x1
    8000206a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000206c:	96be                	add	a3,a3,a5
    8000206e:	77fd                	lui	a5,0xfffff
    80002070:	8ff5                	and	a5,a5,a3
    80002072:	40f707b3          	sub	a5,a4,a5
    80002076:	83b1                	srli	a5,a5,0xc
    80002078:	fef42623          	sw	a5,-20(s0)
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000207c:	fc843703          	ld	a4,-56(s0)
    80002080:	6785                	lui	a5,0x1
    80002082:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002084:	973e                	add	a4,a4,a5
    80002086:	77fd                	lui	a5,0xfffff
    80002088:	8ff9                	and	a5,a5,a4
    8000208a:	fec42703          	lw	a4,-20(s0)
    8000208e:	4685                	li	a3,1
    80002090:	863a                	mv	a2,a4
    80002092:	85be                	mv	a1,a5
    80002094:	fd843503          	ld	a0,-40(s0)
    80002098:	00000097          	auipc	ra,0x0
    8000209c:	cc2080e7          	jalr	-830(ra) # 80001d5a <uvmunmap>
  }

  return newsz;
    800020a0:	fc843783          	ld	a5,-56(s0)
}
    800020a4:	853e                	mv	a0,a5
    800020a6:	70e2                	ld	ra,56(sp)
    800020a8:	7442                	ld	s0,48(sp)
    800020aa:	6121                	addi	sp,sp,64
    800020ac:	8082                	ret

00000000800020ae <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800020ae:	7139                	addi	sp,sp,-64
    800020b0:	fc06                	sd	ra,56(sp)
    800020b2:	f822                	sd	s0,48(sp)
    800020b4:	0080                	addi	s0,sp,64
    800020b6:	fca43423          	sd	a0,-56(s0)
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800020ba:	fe042623          	sw	zero,-20(s0)
    800020be:	a88d                	j	80002130 <freewalk+0x82>
    pte_t pte = pagetable[i];
    800020c0:	fec42783          	lw	a5,-20(s0)
    800020c4:	078e                	slli	a5,a5,0x3
    800020c6:	fc843703          	ld	a4,-56(s0)
    800020ca:	97ba                	add	a5,a5,a4
    800020cc:	639c                	ld	a5,0(a5)
    800020ce:	fef43023          	sd	a5,-32(s0)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800020d2:	fe043783          	ld	a5,-32(s0)
    800020d6:	8b85                	andi	a5,a5,1
    800020d8:	cb9d                	beqz	a5,8000210e <freewalk+0x60>
    800020da:	fe043783          	ld	a5,-32(s0)
    800020de:	8bb9                	andi	a5,a5,14
    800020e0:	e79d                	bnez	a5,8000210e <freewalk+0x60>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800020e2:	fe043783          	ld	a5,-32(s0)
    800020e6:	83a9                	srli	a5,a5,0xa
    800020e8:	07b2                	slli	a5,a5,0xc
    800020ea:	fcf43c23          	sd	a5,-40(s0)
      freewalk((pagetable_t)child);
    800020ee:	fd843783          	ld	a5,-40(s0)
    800020f2:	853e                	mv	a0,a5
    800020f4:	00000097          	auipc	ra,0x0
    800020f8:	fba080e7          	jalr	-70(ra) # 800020ae <freewalk>
      pagetable[i] = 0;
    800020fc:	fec42783          	lw	a5,-20(s0)
    80002100:	078e                	slli	a5,a5,0x3
    80002102:	fc843703          	ld	a4,-56(s0)
    80002106:	97ba                	add	a5,a5,a4
    80002108:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffda248>
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000210c:	a829                	j	80002126 <freewalk+0x78>
    } else if(pte & PTE_V){
    8000210e:	fe043783          	ld	a5,-32(s0)
    80002112:	8b85                	andi	a5,a5,1
    80002114:	cb89                	beqz	a5,80002126 <freewalk+0x78>
      panic("freewalk: leaf");
    80002116:	00009517          	auipc	a0,0x9
    8000211a:	04a50513          	addi	a0,a0,74 # 8000b160 <etext+0x160>
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	b6c080e7          	jalr	-1172(ra) # 80000c8a <panic>
  for(int i = 0; i < 512; i++){
    80002126:	fec42783          	lw	a5,-20(s0)
    8000212a:	2785                	addiw	a5,a5,1
    8000212c:	fef42623          	sw	a5,-20(s0)
    80002130:	fec42783          	lw	a5,-20(s0)
    80002134:	0007871b          	sext.w	a4,a5
    80002138:	1ff00793          	li	a5,511
    8000213c:	f8e7d2e3          	bge	a5,a4,800020c0 <freewalk+0x12>
    }
  }
  kfree((void*)pagetable);
    80002140:	fc843503          	ld	a0,-56(s0)
    80002144:	fffff097          	auipc	ra,0xfffff
    80002148:	f3c080e7          	jalr	-196(ra) # 80001080 <kfree>
}
    8000214c:	0001                	nop
    8000214e:	70e2                	ld	ra,56(sp)
    80002150:	7442                	ld	s0,48(sp)
    80002152:	6121                	addi	sp,sp,64
    80002154:	8082                	ret

0000000080002156 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80002156:	1101                	addi	sp,sp,-32
    80002158:	ec06                	sd	ra,24(sp)
    8000215a:	e822                	sd	s0,16(sp)
    8000215c:	1000                	addi	s0,sp,32
    8000215e:	fea43423          	sd	a0,-24(s0)
    80002162:	feb43023          	sd	a1,-32(s0)
  if(sz > 0)
    80002166:	fe043783          	ld	a5,-32(s0)
    8000216a:	c385                	beqz	a5,8000218a <uvmfree+0x34>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000216c:	fe043703          	ld	a4,-32(s0)
    80002170:	6785                	lui	a5,0x1
    80002172:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80002174:	97ba                	add	a5,a5,a4
    80002176:	83b1                	srli	a5,a5,0xc
    80002178:	4685                	li	a3,1
    8000217a:	863e                	mv	a2,a5
    8000217c:	4581                	li	a1,0
    8000217e:	fe843503          	ld	a0,-24(s0)
    80002182:	00000097          	auipc	ra,0x0
    80002186:	bd8080e7          	jalr	-1064(ra) # 80001d5a <uvmunmap>
  freewalk(pagetable);
    8000218a:	fe843503          	ld	a0,-24(s0)
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	f20080e7          	jalr	-224(ra) # 800020ae <freewalk>
}
    80002196:	0001                	nop
    80002198:	60e2                	ld	ra,24(sp)
    8000219a:	6442                	ld	s0,16(sp)
    8000219c:	6105                	addi	sp,sp,32
    8000219e:	8082                	ret

00000000800021a0 <uvmcopy>:
// physical memory.
// returns 0 on success, -1 on failure.
// frees any allocated pages on failure.
int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
    800021a0:	711d                	addi	sp,sp,-96
    800021a2:	ec86                	sd	ra,88(sp)
    800021a4:	e8a2                	sd	s0,80(sp)
    800021a6:	1080                	addi	s0,sp,96
    800021a8:	faa43c23          	sd	a0,-72(s0)
    800021ac:	fab43823          	sd	a1,-80(s0)
    800021b0:	fac43423          	sd	a2,-88(s0)
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800021b4:	fe043423          	sd	zero,-24(s0)
    800021b8:	a0d9                	j	8000227e <uvmcopy+0xde>
    if((pte = walk(old, i, 0)) == 0)
    800021ba:	4601                	li	a2,0
    800021bc:	fe843583          	ld	a1,-24(s0)
    800021c0:	fb843503          	ld	a0,-72(s0)
    800021c4:	00000097          	auipc	ra,0x0
    800021c8:	8f4080e7          	jalr	-1804(ra) # 80001ab8 <walk>
    800021cc:	fea43023          	sd	a0,-32(s0)
    800021d0:	fe043783          	ld	a5,-32(s0)
    800021d4:	eb89                	bnez	a5,800021e6 <uvmcopy+0x46>
      panic("uvmcopy: pte should exist");
    800021d6:	00009517          	auipc	a0,0x9
    800021da:	f9a50513          	addi	a0,a0,-102 # 8000b170 <etext+0x170>
    800021de:	fffff097          	auipc	ra,0xfffff
    800021e2:	aac080e7          	jalr	-1364(ra) # 80000c8a <panic>
    if((*pte & PTE_V) == 0)
    800021e6:	fe043783          	ld	a5,-32(s0)
    800021ea:	639c                	ld	a5,0(a5)
    800021ec:	8b85                	andi	a5,a5,1
    800021ee:	eb89                	bnez	a5,80002200 <uvmcopy+0x60>
      panic("uvmcopy: page not present");
    800021f0:	00009517          	auipc	a0,0x9
    800021f4:	fa050513          	addi	a0,a0,-96 # 8000b190 <etext+0x190>
    800021f8:	fffff097          	auipc	ra,0xfffff
    800021fc:	a92080e7          	jalr	-1390(ra) # 80000c8a <panic>
    pa = PTE2PA(*pte);
    80002200:	fe043783          	ld	a5,-32(s0)
    80002204:	639c                	ld	a5,0(a5)
    80002206:	83a9                	srli	a5,a5,0xa
    80002208:	07b2                	slli	a5,a5,0xc
    8000220a:	fcf43c23          	sd	a5,-40(s0)
    flags = PTE_FLAGS(*pte);
    8000220e:	fe043783          	ld	a5,-32(s0)
    80002212:	639c                	ld	a5,0(a5)
    80002214:	2781                	sext.w	a5,a5
    80002216:	3ff7f793          	andi	a5,a5,1023
    8000221a:	fcf42a23          	sw	a5,-44(s0)
    if((mem = kalloc()) == 0)
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	f06080e7          	jalr	-250(ra) # 80001124 <kalloc>
    80002226:	fca43423          	sd	a0,-56(s0)
    8000222a:	fc843783          	ld	a5,-56(s0)
    8000222e:	c3a5                	beqz	a5,8000228e <uvmcopy+0xee>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80002230:	fd843783          	ld	a5,-40(s0)
    80002234:	6605                	lui	a2,0x1
    80002236:	85be                	mv	a1,a5
    80002238:	fc843503          	ld	a0,-56(s0)
    8000223c:	fffff097          	auipc	ra,0xfffff
    80002240:	2f4080e7          	jalr	756(ra) # 80001530 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80002244:	fc843783          	ld	a5,-56(s0)
    80002248:	fd442703          	lw	a4,-44(s0)
    8000224c:	86be                	mv	a3,a5
    8000224e:	6605                	lui	a2,0x1
    80002250:	fe843583          	ld	a1,-24(s0)
    80002254:	fb043503          	ld	a0,-80(s0)
    80002258:	00000097          	auipc	ra,0x0
    8000225c:	a24080e7          	jalr	-1500(ra) # 80001c7c <mappages>
    80002260:	87aa                	mv	a5,a0
    80002262:	cb81                	beqz	a5,80002272 <uvmcopy+0xd2>
      kfree(mem);
    80002264:	fc843503          	ld	a0,-56(s0)
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	e18080e7          	jalr	-488(ra) # 80001080 <kfree>
      goto err;
    80002270:	a005                	j	80002290 <uvmcopy+0xf0>
  for(i = 0; i < sz; i += PGSIZE){
    80002272:	fe843703          	ld	a4,-24(s0)
    80002276:	6785                	lui	a5,0x1
    80002278:	97ba                	add	a5,a5,a4
    8000227a:	fef43423          	sd	a5,-24(s0)
    8000227e:	fe843703          	ld	a4,-24(s0)
    80002282:	fa843783          	ld	a5,-88(s0)
    80002286:	f2f76ae3          	bltu	a4,a5,800021ba <uvmcopy+0x1a>
    }
  }
  return 0;
    8000228a:	4781                	li	a5,0
    8000228c:	a839                	j	800022aa <uvmcopy+0x10a>
      goto err;
    8000228e:	0001                	nop

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80002290:	fe843783          	ld	a5,-24(s0)
    80002294:	83b1                	srli	a5,a5,0xc
    80002296:	4685                	li	a3,1
    80002298:	863e                	mv	a2,a5
    8000229a:	4581                	li	a1,0
    8000229c:	fb043503          	ld	a0,-80(s0)
    800022a0:	00000097          	auipc	ra,0x0
    800022a4:	aba080e7          	jalr	-1350(ra) # 80001d5a <uvmunmap>
  return -1;
    800022a8:	57fd                	li	a5,-1
}
    800022aa:	853e                	mv	a0,a5
    800022ac:	60e6                	ld	ra,88(sp)
    800022ae:	6446                	ld	s0,80(sp)
    800022b0:	6125                	addi	sp,sp,96
    800022b2:	8082                	ret

00000000800022b4 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800022b4:	7179                	addi	sp,sp,-48
    800022b6:	f406                	sd	ra,40(sp)
    800022b8:	f022                	sd	s0,32(sp)
    800022ba:	1800                	addi	s0,sp,48
    800022bc:	fca43c23          	sd	a0,-40(s0)
    800022c0:	fcb43823          	sd	a1,-48(s0)
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800022c4:	4601                	li	a2,0
    800022c6:	fd043583          	ld	a1,-48(s0)
    800022ca:	fd843503          	ld	a0,-40(s0)
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	7ea080e7          	jalr	2026(ra) # 80001ab8 <walk>
    800022d6:	fea43423          	sd	a0,-24(s0)
  if(pte == 0)
    800022da:	fe843783          	ld	a5,-24(s0)
    800022de:	eb89                	bnez	a5,800022f0 <uvmclear+0x3c>
    panic("uvmclear");
    800022e0:	00009517          	auipc	a0,0x9
    800022e4:	ed050513          	addi	a0,a0,-304 # 8000b1b0 <etext+0x1b0>
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	9a2080e7          	jalr	-1630(ra) # 80000c8a <panic>
  *pte &= ~PTE_U;
    800022f0:	fe843783          	ld	a5,-24(s0)
    800022f4:	639c                	ld	a5,0(a5)
    800022f6:	fef7f713          	andi	a4,a5,-17
    800022fa:	fe843783          	ld	a5,-24(s0)
    800022fe:	e398                	sd	a4,0(a5)
}
    80002300:	0001                	nop
    80002302:	70a2                	ld	ra,40(sp)
    80002304:	7402                	ld	s0,32(sp)
    80002306:	6145                	addi	sp,sp,48
    80002308:	8082                	ret

000000008000230a <copyout>:
// Copy from kernel to user.
// Copy len bytes from src to virtual address dstva in a given page table.
// Return 0 on success, -1 on error.
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
    8000230a:	715d                	addi	sp,sp,-80
    8000230c:	e486                	sd	ra,72(sp)
    8000230e:	e0a2                	sd	s0,64(sp)
    80002310:	0880                	addi	s0,sp,80
    80002312:	fca43423          	sd	a0,-56(s0)
    80002316:	fcb43023          	sd	a1,-64(s0)
    8000231a:	fac43c23          	sd	a2,-72(s0)
    8000231e:	fad43823          	sd	a3,-80(s0)
  uint64 n, va0, pa0;

  while(len > 0){
    80002322:	a055                	j	800023c6 <copyout+0xbc>
    va0 = PGROUNDDOWN(dstva);
    80002324:	fc043703          	ld	a4,-64(s0)
    80002328:	77fd                	lui	a5,0xfffff
    8000232a:	8ff9                	and	a5,a5,a4
    8000232c:	fef43023          	sd	a5,-32(s0)
    pa0 = walkaddr(pagetable, va0);
    80002330:	fe043583          	ld	a1,-32(s0)
    80002334:	fc843503          	ld	a0,-56(s0)
    80002338:	00000097          	auipc	ra,0x0
    8000233c:	872080e7          	jalr	-1934(ra) # 80001baa <walkaddr>
    80002340:	fca43c23          	sd	a0,-40(s0)
    if(pa0 == 0)
    80002344:	fd843783          	ld	a5,-40(s0)
    80002348:	e399                	bnez	a5,8000234e <copyout+0x44>
      return -1;
    8000234a:	57fd                	li	a5,-1
    8000234c:	a049                	j	800023ce <copyout+0xc4>
    n = PGSIZE - (dstva - va0);
    8000234e:	fe043703          	ld	a4,-32(s0)
    80002352:	fc043783          	ld	a5,-64(s0)
    80002356:	8f1d                	sub	a4,a4,a5
    80002358:	6785                	lui	a5,0x1
    8000235a:	97ba                	add	a5,a5,a4
    8000235c:	fef43423          	sd	a5,-24(s0)
    if(n > len)
    80002360:	fe843703          	ld	a4,-24(s0)
    80002364:	fb043783          	ld	a5,-80(s0)
    80002368:	00e7f663          	bgeu	a5,a4,80002374 <copyout+0x6a>
      n = len;
    8000236c:	fb043783          	ld	a5,-80(s0)
    80002370:	fef43423          	sd	a5,-24(s0)
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80002374:	fc043703          	ld	a4,-64(s0)
    80002378:	fe043783          	ld	a5,-32(s0)
    8000237c:	8f1d                	sub	a4,a4,a5
    8000237e:	fd843783          	ld	a5,-40(s0)
    80002382:	97ba                	add	a5,a5,a4
    80002384:	873e                	mv	a4,a5
    80002386:	fe843783          	ld	a5,-24(s0)
    8000238a:	2781                	sext.w	a5,a5
    8000238c:	863e                	mv	a2,a5
    8000238e:	fb843583          	ld	a1,-72(s0)
    80002392:	853a                	mv	a0,a4
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	19c080e7          	jalr	412(ra) # 80001530 <memmove>

    len -= n;
    8000239c:	fb043703          	ld	a4,-80(s0)
    800023a0:	fe843783          	ld	a5,-24(s0)
    800023a4:	40f707b3          	sub	a5,a4,a5
    800023a8:	faf43823          	sd	a5,-80(s0)
    src += n;
    800023ac:	fb843703          	ld	a4,-72(s0)
    800023b0:	fe843783          	ld	a5,-24(s0)
    800023b4:	97ba                	add	a5,a5,a4
    800023b6:	faf43c23          	sd	a5,-72(s0)
    dstva = va0 + PGSIZE;
    800023ba:	fe043703          	ld	a4,-32(s0)
    800023be:	6785                	lui	a5,0x1
    800023c0:	97ba                	add	a5,a5,a4
    800023c2:	fcf43023          	sd	a5,-64(s0)
  while(len > 0){
    800023c6:	fb043783          	ld	a5,-80(s0)
    800023ca:	ffa9                	bnez	a5,80002324 <copyout+0x1a>
  }
  return 0;
    800023cc:	4781                	li	a5,0
}
    800023ce:	853e                	mv	a0,a5
    800023d0:	60a6                	ld	ra,72(sp)
    800023d2:	6406                	ld	s0,64(sp)
    800023d4:	6161                	addi	sp,sp,80
    800023d6:	8082                	ret

00000000800023d8 <copyin>:
// Copy from user to kernel.
// Copy len bytes to dst from virtual address srcva in a given page table.
// Return 0 on success, -1 on error.
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
    800023d8:	715d                	addi	sp,sp,-80
    800023da:	e486                	sd	ra,72(sp)
    800023dc:	e0a2                	sd	s0,64(sp)
    800023de:	0880                	addi	s0,sp,80
    800023e0:	fca43423          	sd	a0,-56(s0)
    800023e4:	fcb43023          	sd	a1,-64(s0)
    800023e8:	fac43c23          	sd	a2,-72(s0)
    800023ec:	fad43823          	sd	a3,-80(s0)
  uint64 n, va0, pa0;

  while(len > 0){
    800023f0:	a055                	j	80002494 <copyin+0xbc>
    va0 = PGROUNDDOWN(srcva);
    800023f2:	fb843703          	ld	a4,-72(s0)
    800023f6:	77fd                	lui	a5,0xfffff
    800023f8:	8ff9                	and	a5,a5,a4
    800023fa:	fef43023          	sd	a5,-32(s0)
    pa0 = walkaddr(pagetable, va0);
    800023fe:	fe043583          	ld	a1,-32(s0)
    80002402:	fc843503          	ld	a0,-56(s0)
    80002406:	fffff097          	auipc	ra,0xfffff
    8000240a:	7a4080e7          	jalr	1956(ra) # 80001baa <walkaddr>
    8000240e:	fca43c23          	sd	a0,-40(s0)
    if(pa0 == 0)
    80002412:	fd843783          	ld	a5,-40(s0)
    80002416:	e399                	bnez	a5,8000241c <copyin+0x44>
      return -1;
    80002418:	57fd                	li	a5,-1
    8000241a:	a049                	j	8000249c <copyin+0xc4>
    n = PGSIZE - (srcva - va0);
    8000241c:	fe043703          	ld	a4,-32(s0)
    80002420:	fb843783          	ld	a5,-72(s0)
    80002424:	8f1d                	sub	a4,a4,a5
    80002426:	6785                	lui	a5,0x1
    80002428:	97ba                	add	a5,a5,a4
    8000242a:	fef43423          	sd	a5,-24(s0)
    if(n > len)
    8000242e:	fe843703          	ld	a4,-24(s0)
    80002432:	fb043783          	ld	a5,-80(s0)
    80002436:	00e7f663          	bgeu	a5,a4,80002442 <copyin+0x6a>
      n = len;
    8000243a:	fb043783          	ld	a5,-80(s0)
    8000243e:	fef43423          	sd	a5,-24(s0)
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80002442:	fb843703          	ld	a4,-72(s0)
    80002446:	fe043783          	ld	a5,-32(s0)
    8000244a:	8f1d                	sub	a4,a4,a5
    8000244c:	fd843783          	ld	a5,-40(s0)
    80002450:	97ba                	add	a5,a5,a4
    80002452:	873e                	mv	a4,a5
    80002454:	fe843783          	ld	a5,-24(s0)
    80002458:	2781                	sext.w	a5,a5
    8000245a:	863e                	mv	a2,a5
    8000245c:	85ba                	mv	a1,a4
    8000245e:	fc043503          	ld	a0,-64(s0)
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	0ce080e7          	jalr	206(ra) # 80001530 <memmove>

    len -= n;
    8000246a:	fb043703          	ld	a4,-80(s0)
    8000246e:	fe843783          	ld	a5,-24(s0)
    80002472:	40f707b3          	sub	a5,a4,a5
    80002476:	faf43823          	sd	a5,-80(s0)
    dst += n;
    8000247a:	fc043703          	ld	a4,-64(s0)
    8000247e:	fe843783          	ld	a5,-24(s0)
    80002482:	97ba                	add	a5,a5,a4
    80002484:	fcf43023          	sd	a5,-64(s0)
    srcva = va0 + PGSIZE;
    80002488:	fe043703          	ld	a4,-32(s0)
    8000248c:	6785                	lui	a5,0x1
    8000248e:	97ba                	add	a5,a5,a4
    80002490:	faf43c23          	sd	a5,-72(s0)
  while(len > 0){
    80002494:	fb043783          	ld	a5,-80(s0)
    80002498:	ffa9                	bnez	a5,800023f2 <copyin+0x1a>
  }
  return 0;
    8000249a:	4781                	li	a5,0
}
    8000249c:	853e                	mv	a0,a5
    8000249e:	60a6                	ld	ra,72(sp)
    800024a0:	6406                	ld	s0,64(sp)
    800024a2:	6161                	addi	sp,sp,80
    800024a4:	8082                	ret

00000000800024a6 <copyinstr>:
// Copy bytes to dst from virtual address srcva in a given page table,
// until a '\0', or max.
// Return 0 on success, -1 on error.
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
    800024a6:	711d                	addi	sp,sp,-96
    800024a8:	ec86                	sd	ra,88(sp)
    800024aa:	e8a2                	sd	s0,80(sp)
    800024ac:	1080                	addi	s0,sp,96
    800024ae:	faa43c23          	sd	a0,-72(s0)
    800024b2:	fab43823          	sd	a1,-80(s0)
    800024b6:	fac43423          	sd	a2,-88(s0)
    800024ba:	fad43023          	sd	a3,-96(s0)
  uint64 n, va0, pa0;
  int got_null = 0;
    800024be:	fe042223          	sw	zero,-28(s0)

  while(got_null == 0 && max > 0){
    800024c2:	a0f1                	j	8000258e <copyinstr+0xe8>
    va0 = PGROUNDDOWN(srcva);
    800024c4:	fa843703          	ld	a4,-88(s0)
    800024c8:	77fd                	lui	a5,0xfffff
    800024ca:	8ff9                	and	a5,a5,a4
    800024cc:	fcf43823          	sd	a5,-48(s0)
    pa0 = walkaddr(pagetable, va0);
    800024d0:	fd043583          	ld	a1,-48(s0)
    800024d4:	fb843503          	ld	a0,-72(s0)
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	6d2080e7          	jalr	1746(ra) # 80001baa <walkaddr>
    800024e0:	fca43423          	sd	a0,-56(s0)
    if(pa0 == 0)
    800024e4:	fc843783          	ld	a5,-56(s0)
    800024e8:	e399                	bnez	a5,800024ee <copyinstr+0x48>
      return -1;
    800024ea:	57fd                	li	a5,-1
    800024ec:	a87d                	j	800025aa <copyinstr+0x104>
    n = PGSIZE - (srcva - va0);
    800024ee:	fd043703          	ld	a4,-48(s0)
    800024f2:	fa843783          	ld	a5,-88(s0)
    800024f6:	8f1d                	sub	a4,a4,a5
    800024f8:	6785                	lui	a5,0x1
    800024fa:	97ba                	add	a5,a5,a4
    800024fc:	fef43423          	sd	a5,-24(s0)
    if(n > max)
    80002500:	fe843703          	ld	a4,-24(s0)
    80002504:	fa043783          	ld	a5,-96(s0)
    80002508:	00e7f663          	bgeu	a5,a4,80002514 <copyinstr+0x6e>
      n = max;
    8000250c:	fa043783          	ld	a5,-96(s0)
    80002510:	fef43423          	sd	a5,-24(s0)

    char *p = (char *) (pa0 + (srcva - va0));
    80002514:	fa843703          	ld	a4,-88(s0)
    80002518:	fd043783          	ld	a5,-48(s0)
    8000251c:	8f1d                	sub	a4,a4,a5
    8000251e:	fc843783          	ld	a5,-56(s0)
    80002522:	97ba                	add	a5,a5,a4
    80002524:	fcf43c23          	sd	a5,-40(s0)
    while(n > 0){
    80002528:	a891                	j	8000257c <copyinstr+0xd6>
      if(*p == '\0'){
    8000252a:	fd843783          	ld	a5,-40(s0)
    8000252e:	0007c783          	lbu	a5,0(a5) # 1000 <_entry-0x7ffff000>
    80002532:	eb89                	bnez	a5,80002544 <copyinstr+0x9e>
        *dst = '\0';
    80002534:	fb043783          	ld	a5,-80(s0)
    80002538:	00078023          	sb	zero,0(a5)
        got_null = 1;
    8000253c:	4785                	li	a5,1
    8000253e:	fef42223          	sw	a5,-28(s0)
        break;
    80002542:	a081                	j	80002582 <copyinstr+0xdc>
      } else {
        *dst = *p;
    80002544:	fd843783          	ld	a5,-40(s0)
    80002548:	0007c703          	lbu	a4,0(a5)
    8000254c:	fb043783          	ld	a5,-80(s0)
    80002550:	00e78023          	sb	a4,0(a5)
      }
      --n;
    80002554:	fe843783          	ld	a5,-24(s0)
    80002558:	17fd                	addi	a5,a5,-1
    8000255a:	fef43423          	sd	a5,-24(s0)
      --max;
    8000255e:	fa043783          	ld	a5,-96(s0)
    80002562:	17fd                	addi	a5,a5,-1
    80002564:	faf43023          	sd	a5,-96(s0)
      p++;
    80002568:	fd843783          	ld	a5,-40(s0)
    8000256c:	0785                	addi	a5,a5,1
    8000256e:	fcf43c23          	sd	a5,-40(s0)
      dst++;
    80002572:	fb043783          	ld	a5,-80(s0)
    80002576:	0785                	addi	a5,a5,1
    80002578:	faf43823          	sd	a5,-80(s0)
    while(n > 0){
    8000257c:	fe843783          	ld	a5,-24(s0)
    80002580:	f7cd                	bnez	a5,8000252a <copyinstr+0x84>
    }

    srcva = va0 + PGSIZE;
    80002582:	fd043703          	ld	a4,-48(s0)
    80002586:	6785                	lui	a5,0x1
    80002588:	97ba                	add	a5,a5,a4
    8000258a:	faf43423          	sd	a5,-88(s0)
  while(got_null == 0 && max > 0){
    8000258e:	fe442783          	lw	a5,-28(s0)
    80002592:	2781                	sext.w	a5,a5
    80002594:	e781                	bnez	a5,8000259c <copyinstr+0xf6>
    80002596:	fa043783          	ld	a5,-96(s0)
    8000259a:	f78d                	bnez	a5,800024c4 <copyinstr+0x1e>
  }
  if(got_null){
    8000259c:	fe442783          	lw	a5,-28(s0)
    800025a0:	2781                	sext.w	a5,a5
    800025a2:	c399                	beqz	a5,800025a8 <copyinstr+0x102>
    return 0;
    800025a4:	4781                	li	a5,0
    800025a6:	a011                	j	800025aa <copyinstr+0x104>
  } else {
    return -1;
    800025a8:	57fd                	li	a5,-1
  }
}
    800025aa:	853e                	mv	a0,a5
    800025ac:	60e6                	ld	ra,88(sp)
    800025ae:	6446                	ld	s0,80(sp)
    800025b0:	6125                	addi	sp,sp,96
    800025b2:	8082                	ret

00000000800025b4 <r_sstatus>:
{
    800025b4:	1101                	addi	sp,sp,-32
    800025b6:	ec22                	sd	s0,24(sp)
    800025b8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025ba:	100027f3          	csrr	a5,sstatus
    800025be:	fef43423          	sd	a5,-24(s0)
  return x;
    800025c2:	fe843783          	ld	a5,-24(s0)
}
    800025c6:	853e                	mv	a0,a5
    800025c8:	6462                	ld	s0,24(sp)
    800025ca:	6105                	addi	sp,sp,32
    800025cc:	8082                	ret

00000000800025ce <w_sstatus>:
{
    800025ce:	1101                	addi	sp,sp,-32
    800025d0:	ec22                	sd	s0,24(sp)
    800025d2:	1000                	addi	s0,sp,32
    800025d4:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800025d8:	fe843783          	ld	a5,-24(s0)
    800025dc:	10079073          	csrw	sstatus,a5
}
    800025e0:	0001                	nop
    800025e2:	6462                	ld	s0,24(sp)
    800025e4:	6105                	addi	sp,sp,32
    800025e6:	8082                	ret

00000000800025e8 <intr_on>:
{
    800025e8:	1141                	addi	sp,sp,-16
    800025ea:	e406                	sd	ra,8(sp)
    800025ec:	e022                	sd	s0,0(sp)
    800025ee:	0800                	addi	s0,sp,16
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800025f0:	00000097          	auipc	ra,0x0
    800025f4:	fc4080e7          	jalr	-60(ra) # 800025b4 <r_sstatus>
    800025f8:	87aa                	mv	a5,a0
    800025fa:	0027e793          	ori	a5,a5,2
    800025fe:	853e                	mv	a0,a5
    80002600:	00000097          	auipc	ra,0x0
    80002604:	fce080e7          	jalr	-50(ra) # 800025ce <w_sstatus>
}
    80002608:	0001                	nop
    8000260a:	60a2                	ld	ra,8(sp)
    8000260c:	6402                	ld	s0,0(sp)
    8000260e:	0141                	addi	sp,sp,16
    80002610:	8082                	ret

0000000080002612 <intr_get>:
{
    80002612:	1101                	addi	sp,sp,-32
    80002614:	ec06                	sd	ra,24(sp)
    80002616:	e822                	sd	s0,16(sp)
    80002618:	1000                	addi	s0,sp,32
  uint64 x = r_sstatus();
    8000261a:	00000097          	auipc	ra,0x0
    8000261e:	f9a080e7          	jalr	-102(ra) # 800025b4 <r_sstatus>
    80002622:	fea43423          	sd	a0,-24(s0)
  return (x & SSTATUS_SIE) != 0;
    80002626:	fe843783          	ld	a5,-24(s0)
    8000262a:	8b89                	andi	a5,a5,2
    8000262c:	00f037b3          	snez	a5,a5
    80002630:	0ff7f793          	zext.b	a5,a5
    80002634:	2781                	sext.w	a5,a5
}
    80002636:	853e                	mv	a0,a5
    80002638:	60e2                	ld	ra,24(sp)
    8000263a:	6442                	ld	s0,16(sp)
    8000263c:	6105                	addi	sp,sp,32
    8000263e:	8082                	ret

0000000080002640 <r_tp>:
{
    80002640:	1101                	addi	sp,sp,-32
    80002642:	ec22                	sd	s0,24(sp)
    80002644:	1000                	addi	s0,sp,32
  asm volatile("mv %0, tp" : "=r" (x) );
    80002646:	8792                	mv	a5,tp
    80002648:	fef43423          	sd	a5,-24(s0)
  return x;
    8000264c:	fe843783          	ld	a5,-24(s0)
}
    80002650:	853e                	mv	a0,a5
    80002652:	6462                	ld	s0,24(sp)
    80002654:	6105                	addi	sp,sp,32
    80002656:	8082                	ret

0000000080002658 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80002658:	7139                	addi	sp,sp,-64
    8000265a:	fc06                	sd	ra,56(sp)
    8000265c:	f822                	sd	s0,48(sp)
    8000265e:	0080                	addi	s0,sp,64
    80002660:	fca43423          	sd	a0,-56(s0)
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80002664:	00012797          	auipc	a5,0x12
    80002668:	94478793          	addi	a5,a5,-1724 # 80013fa8 <proc>
    8000266c:	fef43423          	sd	a5,-24(s0)
    80002670:	a061                	j	800026f8 <proc_mapstacks+0xa0>
    char *pa = kalloc();
    80002672:	fffff097          	auipc	ra,0xfffff
    80002676:	ab2080e7          	jalr	-1358(ra) # 80001124 <kalloc>
    8000267a:	fea43023          	sd	a0,-32(s0)
    if(pa == 0)
    8000267e:	fe043783          	ld	a5,-32(s0)
    80002682:	eb89                	bnez	a5,80002694 <proc_mapstacks+0x3c>
      panic("kalloc");
    80002684:	00009517          	auipc	a0,0x9
    80002688:	b3c50513          	addi	a0,a0,-1220 # 8000b1c0 <etext+0x1c0>
    8000268c:	ffffe097          	auipc	ra,0xffffe
    80002690:	5fe080e7          	jalr	1534(ra) # 80000c8a <panic>
    uint64 va = KSTACK((int) (p - proc));
    80002694:	fe843703          	ld	a4,-24(s0)
    80002698:	00012797          	auipc	a5,0x12
    8000269c:	91078793          	addi	a5,a5,-1776 # 80013fa8 <proc>
    800026a0:	40f707b3          	sub	a5,a4,a5
    800026a4:	4037d713          	srai	a4,a5,0x3
    800026a8:	00009797          	auipc	a5,0x9
    800026ac:	c3078793          	addi	a5,a5,-976 # 8000b2d8 <etext+0x2d8>
    800026b0:	639c                	ld	a5,0(a5)
    800026b2:	02f707b3          	mul	a5,a4,a5
    800026b6:	2781                	sext.w	a5,a5
    800026b8:	2785                	addiw	a5,a5,1
    800026ba:	2781                	sext.w	a5,a5
    800026bc:	00d7979b          	slliw	a5,a5,0xd
    800026c0:	2781                	sext.w	a5,a5
    800026c2:	873e                	mv	a4,a5
    800026c4:	040007b7          	lui	a5,0x4000
    800026c8:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026ca:	07b2                	slli	a5,a5,0xc
    800026cc:	8f99                	sub	a5,a5,a4
    800026ce:	fcf43c23          	sd	a5,-40(s0)
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800026d2:	fe043783          	ld	a5,-32(s0)
    800026d6:	4719                	li	a4,6
    800026d8:	6685                	lui	a3,0x1
    800026da:	863e                	mv	a2,a5
    800026dc:	fd843583          	ld	a1,-40(s0)
    800026e0:	fc843503          	ld	a0,-56(s0)
    800026e4:	fffff097          	auipc	ra,0xfffff
    800026e8:	53e080e7          	jalr	1342(ra) # 80001c22 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800026ec:	fe843783          	ld	a5,-24(s0)
    800026f0:	16878793          	addi	a5,a5,360
    800026f4:	fef43423          	sd	a5,-24(s0)
    800026f8:	fe843703          	ld	a4,-24(s0)
    800026fc:	00017797          	auipc	a5,0x17
    80002700:	2ac78793          	addi	a5,a5,684 # 800199a8 <pid_lock>
    80002704:	f6f767e3          	bltu	a4,a5,80002672 <proc_mapstacks+0x1a>
  }
}
    80002708:	0001                	nop
    8000270a:	0001                	nop
    8000270c:	70e2                	ld	ra,56(sp)
    8000270e:	7442                	ld	s0,48(sp)
    80002710:	6121                	addi	sp,sp,64
    80002712:	8082                	ret

0000000080002714 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80002714:	1101                	addi	sp,sp,-32
    80002716:	ec06                	sd	ra,24(sp)
    80002718:	e822                	sd	s0,16(sp)
    8000271a:	1000                	addi	s0,sp,32
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000271c:	00009597          	auipc	a1,0x9
    80002720:	aac58593          	addi	a1,a1,-1364 # 8000b1c8 <etext+0x1c8>
    80002724:	00017517          	auipc	a0,0x17
    80002728:	28450513          	addi	a0,a0,644 # 800199a8 <pid_lock>
    8000272c:	fffff097          	auipc	ra,0xfffff
    80002730:	b1c080e7          	jalr	-1252(ra) # 80001248 <initlock>
  initlock(&wait_lock, "wait_lock");
    80002734:	00009597          	auipc	a1,0x9
    80002738:	a9c58593          	addi	a1,a1,-1380 # 8000b1d0 <etext+0x1d0>
    8000273c:	00017517          	auipc	a0,0x17
    80002740:	28450513          	addi	a0,a0,644 # 800199c0 <wait_lock>
    80002744:	fffff097          	auipc	ra,0xfffff
    80002748:	b04080e7          	jalr	-1276(ra) # 80001248 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000274c:	00012797          	auipc	a5,0x12
    80002750:	85c78793          	addi	a5,a5,-1956 # 80013fa8 <proc>
    80002754:	fef43423          	sd	a5,-24(s0)
    80002758:	a0bd                	j	800027c6 <procinit+0xb2>
      initlock(&p->lock, "proc");
    8000275a:	fe843783          	ld	a5,-24(s0)
    8000275e:	00009597          	auipc	a1,0x9
    80002762:	a8258593          	addi	a1,a1,-1406 # 8000b1e0 <etext+0x1e0>
    80002766:	853e                	mv	a0,a5
    80002768:	fffff097          	auipc	ra,0xfffff
    8000276c:	ae0080e7          	jalr	-1312(ra) # 80001248 <initlock>
      p->state = UNUSED;
    80002770:	fe843783          	ld	a5,-24(s0)
    80002774:	0007ac23          	sw	zero,24(a5)
      p->kstack = KSTACK((int) (p - proc));
    80002778:	fe843703          	ld	a4,-24(s0)
    8000277c:	00012797          	auipc	a5,0x12
    80002780:	82c78793          	addi	a5,a5,-2004 # 80013fa8 <proc>
    80002784:	40f707b3          	sub	a5,a4,a5
    80002788:	4037d713          	srai	a4,a5,0x3
    8000278c:	00009797          	auipc	a5,0x9
    80002790:	b4c78793          	addi	a5,a5,-1204 # 8000b2d8 <etext+0x2d8>
    80002794:	639c                	ld	a5,0(a5)
    80002796:	02f707b3          	mul	a5,a4,a5
    8000279a:	2781                	sext.w	a5,a5
    8000279c:	2785                	addiw	a5,a5,1
    8000279e:	2781                	sext.w	a5,a5
    800027a0:	00d7979b          	slliw	a5,a5,0xd
    800027a4:	2781                	sext.w	a5,a5
    800027a6:	873e                	mv	a4,a5
    800027a8:	040007b7          	lui	a5,0x4000
    800027ac:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027ae:	07b2                	slli	a5,a5,0xc
    800027b0:	8f99                	sub	a5,a5,a4
    800027b2:	873e                	mv	a4,a5
    800027b4:	fe843783          	ld	a5,-24(s0)
    800027b8:	e3b8                	sd	a4,64(a5)
  for(p = proc; p < &proc[NPROC]; p++) {
    800027ba:	fe843783          	ld	a5,-24(s0)
    800027be:	16878793          	addi	a5,a5,360
    800027c2:	fef43423          	sd	a5,-24(s0)
    800027c6:	fe843703          	ld	a4,-24(s0)
    800027ca:	00017797          	auipc	a5,0x17
    800027ce:	1de78793          	addi	a5,a5,478 # 800199a8 <pid_lock>
    800027d2:	f8f764e3          	bltu	a4,a5,8000275a <procinit+0x46>
  }
}
    800027d6:	0001                	nop
    800027d8:	0001                	nop
    800027da:	60e2                	ld	ra,24(sp)
    800027dc:	6442                	ld	s0,16(sp)
    800027de:	6105                	addi	sp,sp,32
    800027e0:	8082                	ret

00000000800027e2 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800027e2:	1101                	addi	sp,sp,-32
    800027e4:	ec06                	sd	ra,24(sp)
    800027e6:	e822                	sd	s0,16(sp)
    800027e8:	1000                	addi	s0,sp,32
  int id = r_tp();
    800027ea:	00000097          	auipc	ra,0x0
    800027ee:	e56080e7          	jalr	-426(ra) # 80002640 <r_tp>
    800027f2:	87aa                	mv	a5,a0
    800027f4:	fef42623          	sw	a5,-20(s0)
  return id;
    800027f8:	fec42783          	lw	a5,-20(s0)
}
    800027fc:	853e                	mv	a0,a5
    800027fe:	60e2                	ld	ra,24(sp)
    80002800:	6442                	ld	s0,16(sp)
    80002802:	6105                	addi	sp,sp,32
    80002804:	8082                	ret

0000000080002806 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80002806:	1101                	addi	sp,sp,-32
    80002808:	ec06                	sd	ra,24(sp)
    8000280a:	e822                	sd	s0,16(sp)
    8000280c:	1000                	addi	s0,sp,32
  int id = cpuid();
    8000280e:	00000097          	auipc	ra,0x0
    80002812:	fd4080e7          	jalr	-44(ra) # 800027e2 <cpuid>
    80002816:	87aa                	mv	a5,a0
    80002818:	fef42623          	sw	a5,-20(s0)
  struct cpu *c = &cpus[id];
    8000281c:	fec42783          	lw	a5,-20(s0)
    80002820:	00779713          	slli	a4,a5,0x7
    80002824:	00011797          	auipc	a5,0x11
    80002828:	38478793          	addi	a5,a5,900 # 80013ba8 <cpus>
    8000282c:	97ba                	add	a5,a5,a4
    8000282e:	fef43023          	sd	a5,-32(s0)
  return c;
    80002832:	fe043783          	ld	a5,-32(s0)
}
    80002836:	853e                	mv	a0,a5
    80002838:	60e2                	ld	ra,24(sp)
    8000283a:	6442                	ld	s0,16(sp)
    8000283c:	6105                	addi	sp,sp,32
    8000283e:	8082                	ret

0000000080002840 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80002840:	1101                	addi	sp,sp,-32
    80002842:	ec06                	sd	ra,24(sp)
    80002844:	e822                	sd	s0,16(sp)
    80002846:	1000                	addi	s0,sp,32
  push_off();
    80002848:	fffff097          	auipc	ra,0xfffff
    8000284c:	b2e080e7          	jalr	-1234(ra) # 80001376 <push_off>
  struct cpu *c = mycpu();
    80002850:	00000097          	auipc	ra,0x0
    80002854:	fb6080e7          	jalr	-74(ra) # 80002806 <mycpu>
    80002858:	fea43423          	sd	a0,-24(s0)
  struct proc *p = c->proc;
    8000285c:	fe843783          	ld	a5,-24(s0)
    80002860:	639c                	ld	a5,0(a5)
    80002862:	fef43023          	sd	a5,-32(s0)
  pop_off();
    80002866:	fffff097          	auipc	ra,0xfffff
    8000286a:	b68080e7          	jalr	-1176(ra) # 800013ce <pop_off>
  return p;
    8000286e:	fe043783          	ld	a5,-32(s0)
}
    80002872:	853e                	mv	a0,a5
    80002874:	60e2                	ld	ra,24(sp)
    80002876:	6442                	ld	s0,16(sp)
    80002878:	6105                	addi	sp,sp,32
    8000287a:	8082                	ret

000000008000287c <allocpid>:

int
allocpid()
{
    8000287c:	1101                	addi	sp,sp,-32
    8000287e:	ec06                	sd	ra,24(sp)
    80002880:	e822                	sd	s0,16(sp)
    80002882:	1000                	addi	s0,sp,32
  int pid;
  
  acquire(&pid_lock);
    80002884:	00017517          	auipc	a0,0x17
    80002888:	12450513          	addi	a0,a0,292 # 800199a8 <pid_lock>
    8000288c:	fffff097          	auipc	ra,0xfffff
    80002890:	9ec080e7          	jalr	-1556(ra) # 80001278 <acquire>
  pid = nextpid;
    80002894:	00009797          	auipc	a5,0x9
    80002898:	efc78793          	addi	a5,a5,-260 # 8000b790 <nextpid>
    8000289c:	439c                	lw	a5,0(a5)
    8000289e:	fef42623          	sw	a5,-20(s0)
  nextpid = nextpid + 1;
    800028a2:	00009797          	auipc	a5,0x9
    800028a6:	eee78793          	addi	a5,a5,-274 # 8000b790 <nextpid>
    800028aa:	439c                	lw	a5,0(a5)
    800028ac:	2785                	addiw	a5,a5,1
    800028ae:	0007871b          	sext.w	a4,a5
    800028b2:	00009797          	auipc	a5,0x9
    800028b6:	ede78793          	addi	a5,a5,-290 # 8000b790 <nextpid>
    800028ba:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800028bc:	00017517          	auipc	a0,0x17
    800028c0:	0ec50513          	addi	a0,a0,236 # 800199a8 <pid_lock>
    800028c4:	fffff097          	auipc	ra,0xfffff
    800028c8:	a18080e7          	jalr	-1512(ra) # 800012dc <release>

  return pid;
    800028cc:	fec42783          	lw	a5,-20(s0)
}
    800028d0:	853e                	mv	a0,a5
    800028d2:	60e2                	ld	ra,24(sp)
    800028d4:	6442                	ld	s0,16(sp)
    800028d6:	6105                	addi	sp,sp,32
    800028d8:	8082                	ret

00000000800028da <allocproc>:
// If found, initialize state required to run in the kernel,
// and return with p->lock held.
// If there are no free procs, or a memory allocation fails, return 0.
static struct proc*
allocproc(void)
{
    800028da:	1101                	addi	sp,sp,-32
    800028dc:	ec06                	sd	ra,24(sp)
    800028de:	e822                	sd	s0,16(sp)
    800028e0:	1000                	addi	s0,sp,32
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800028e2:	00011797          	auipc	a5,0x11
    800028e6:	6c678793          	addi	a5,a5,1734 # 80013fa8 <proc>
    800028ea:	fef43423          	sd	a5,-24(s0)
    800028ee:	a80d                	j	80002920 <allocproc+0x46>
    acquire(&p->lock);
    800028f0:	fe843783          	ld	a5,-24(s0)
    800028f4:	853e                	mv	a0,a5
    800028f6:	fffff097          	auipc	ra,0xfffff
    800028fa:	982080e7          	jalr	-1662(ra) # 80001278 <acquire>
    if(p->state == UNUSED) {
    800028fe:	fe843783          	ld	a5,-24(s0)
    80002902:	4f9c                	lw	a5,24(a5)
    80002904:	cb85                	beqz	a5,80002934 <allocproc+0x5a>
      goto found;
    } else {
      release(&p->lock);
    80002906:	fe843783          	ld	a5,-24(s0)
    8000290a:	853e                	mv	a0,a5
    8000290c:	fffff097          	auipc	ra,0xfffff
    80002910:	9d0080e7          	jalr	-1584(ra) # 800012dc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002914:	fe843783          	ld	a5,-24(s0)
    80002918:	16878793          	addi	a5,a5,360
    8000291c:	fef43423          	sd	a5,-24(s0)
    80002920:	fe843703          	ld	a4,-24(s0)
    80002924:	00017797          	auipc	a5,0x17
    80002928:	08478793          	addi	a5,a5,132 # 800199a8 <pid_lock>
    8000292c:	fcf762e3          	bltu	a4,a5,800028f0 <allocproc+0x16>
    }
  }
  return 0;
    80002930:	4781                	li	a5,0
    80002932:	a0e1                	j	800029fa <allocproc+0x120>
      goto found;
    80002934:	0001                	nop

found:
  p->pid = allocpid();
    80002936:	00000097          	auipc	ra,0x0
    8000293a:	f46080e7          	jalr	-186(ra) # 8000287c <allocpid>
    8000293e:	87aa                	mv	a5,a0
    80002940:	873e                	mv	a4,a5
    80002942:	fe843783          	ld	a5,-24(s0)
    80002946:	db98                	sw	a4,48(a5)
  p->state = USED;
    80002948:	fe843783          	ld	a5,-24(s0)
    8000294c:	4705                	li	a4,1
    8000294e:	cf98                	sw	a4,24(a5)

  // Allocate a trapframe page.
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80002950:	ffffe097          	auipc	ra,0xffffe
    80002954:	7d4080e7          	jalr	2004(ra) # 80001124 <kalloc>
    80002958:	872a                	mv	a4,a0
    8000295a:	fe843783          	ld	a5,-24(s0)
    8000295e:	efb8                	sd	a4,88(a5)
    80002960:	fe843783          	ld	a5,-24(s0)
    80002964:	6fbc                	ld	a5,88(a5)
    80002966:	e385                	bnez	a5,80002986 <allocproc+0xac>
    freeproc(p);
    80002968:	fe843503          	ld	a0,-24(s0)
    8000296c:	00000097          	auipc	ra,0x0
    80002970:	098080e7          	jalr	152(ra) # 80002a04 <freeproc>
    release(&p->lock);
    80002974:	fe843783          	ld	a5,-24(s0)
    80002978:	853e                	mv	a0,a5
    8000297a:	fffff097          	auipc	ra,0xfffff
    8000297e:	962080e7          	jalr	-1694(ra) # 800012dc <release>
    return 0;
    80002982:	4781                	li	a5,0
    80002984:	a89d                	j	800029fa <allocproc+0x120>
  }

  // An empty user page table.
  p->pagetable = proc_pagetable(p);
    80002986:	fe843503          	ld	a0,-24(s0)
    8000298a:	00000097          	auipc	ra,0x0
    8000298e:	118080e7          	jalr	280(ra) # 80002aa2 <proc_pagetable>
    80002992:	872a                	mv	a4,a0
    80002994:	fe843783          	ld	a5,-24(s0)
    80002998:	ebb8                	sd	a4,80(a5)
  if(p->pagetable == 0){
    8000299a:	fe843783          	ld	a5,-24(s0)
    8000299e:	6bbc                	ld	a5,80(a5)
    800029a0:	e385                	bnez	a5,800029c0 <allocproc+0xe6>
    freeproc(p);
    800029a2:	fe843503          	ld	a0,-24(s0)
    800029a6:	00000097          	auipc	ra,0x0
    800029aa:	05e080e7          	jalr	94(ra) # 80002a04 <freeproc>
    release(&p->lock);
    800029ae:	fe843783          	ld	a5,-24(s0)
    800029b2:	853e                	mv	a0,a5
    800029b4:	fffff097          	auipc	ra,0xfffff
    800029b8:	928080e7          	jalr	-1752(ra) # 800012dc <release>
    return 0;
    800029bc:	4781                	li	a5,0
    800029be:	a835                	j	800029fa <allocproc+0x120>
  }

  // Set up new context to start executing at forkret,
  // which returns to user space.
  memset(&p->context, 0, sizeof(p->context));
    800029c0:	fe843783          	ld	a5,-24(s0)
    800029c4:	06078793          	addi	a5,a5,96
    800029c8:	07000613          	li	a2,112
    800029cc:	4581                	li	a1,0
    800029ce:	853e                	mv	a0,a5
    800029d0:	fffff097          	auipc	ra,0xfffff
    800029d4:	a7c080e7          	jalr	-1412(ra) # 8000144c <memset>
  p->context.ra = (uint64)forkret;
    800029d8:	00001717          	auipc	a4,0x1
    800029dc:	9da70713          	addi	a4,a4,-1574 # 800033b2 <forkret>
    800029e0:	fe843783          	ld	a5,-24(s0)
    800029e4:	f3b8                	sd	a4,96(a5)
  p->context.sp = p->kstack + PGSIZE;
    800029e6:	fe843783          	ld	a5,-24(s0)
    800029ea:	63b8                	ld	a4,64(a5)
    800029ec:	6785                	lui	a5,0x1
    800029ee:	973e                	add	a4,a4,a5
    800029f0:	fe843783          	ld	a5,-24(s0)
    800029f4:	f7b8                	sd	a4,104(a5)

  return p;
    800029f6:	fe843783          	ld	a5,-24(s0)
}
    800029fa:	853e                	mv	a0,a5
    800029fc:	60e2                	ld	ra,24(sp)
    800029fe:	6442                	ld	s0,16(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret

0000000080002a04 <freeproc>:
// free a proc structure and the data hanging from it,
// including user pages.
// p->lock must be held.
static void
freeproc(struct proc *p)
{
    80002a04:	1101                	addi	sp,sp,-32
    80002a06:	ec06                	sd	ra,24(sp)
    80002a08:	e822                	sd	s0,16(sp)
    80002a0a:	1000                	addi	s0,sp,32
    80002a0c:	fea43423          	sd	a0,-24(s0)
  if(p->trapframe)
    80002a10:	fe843783          	ld	a5,-24(s0)
    80002a14:	6fbc                	ld	a5,88(a5)
    80002a16:	cb89                	beqz	a5,80002a28 <freeproc+0x24>
    kfree((void*)p->trapframe);
    80002a18:	fe843783          	ld	a5,-24(s0)
    80002a1c:	6fbc                	ld	a5,88(a5)
    80002a1e:	853e                	mv	a0,a5
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	660080e7          	jalr	1632(ra) # 80001080 <kfree>
  p->trapframe = 0;
    80002a28:	fe843783          	ld	a5,-24(s0)
    80002a2c:	0407bc23          	sd	zero,88(a5) # 1058 <_entry-0x7fffefa8>
  if(p->pagetable)
    80002a30:	fe843783          	ld	a5,-24(s0)
    80002a34:	6bbc                	ld	a5,80(a5)
    80002a36:	cf89                	beqz	a5,80002a50 <freeproc+0x4c>
    proc_freepagetable(p->pagetable, p->sz);
    80002a38:	fe843783          	ld	a5,-24(s0)
    80002a3c:	6bb8                	ld	a4,80(a5)
    80002a3e:	fe843783          	ld	a5,-24(s0)
    80002a42:	67bc                	ld	a5,72(a5)
    80002a44:	85be                	mv	a1,a5
    80002a46:	853a                	mv	a0,a4
    80002a48:	00000097          	auipc	ra,0x0
    80002a4c:	11a080e7          	jalr	282(ra) # 80002b62 <proc_freepagetable>
  p->pagetable = 0;
    80002a50:	fe843783          	ld	a5,-24(s0)
    80002a54:	0407b823          	sd	zero,80(a5)
  p->sz = 0;
    80002a58:	fe843783          	ld	a5,-24(s0)
    80002a5c:	0407b423          	sd	zero,72(a5)
  p->pid = 0;
    80002a60:	fe843783          	ld	a5,-24(s0)
    80002a64:	0207a823          	sw	zero,48(a5)
  p->parent = 0;
    80002a68:	fe843783          	ld	a5,-24(s0)
    80002a6c:	0207bc23          	sd	zero,56(a5)
  p->name[0] = 0;
    80002a70:	fe843783          	ld	a5,-24(s0)
    80002a74:	14078c23          	sb	zero,344(a5)
  p->chan = 0;
    80002a78:	fe843783          	ld	a5,-24(s0)
    80002a7c:	0207b023          	sd	zero,32(a5)
  p->killed = 0;
    80002a80:	fe843783          	ld	a5,-24(s0)
    80002a84:	0207a423          	sw	zero,40(a5)
  p->xstate = 0;
    80002a88:	fe843783          	ld	a5,-24(s0)
    80002a8c:	0207a623          	sw	zero,44(a5)
  p->state = UNUSED;
    80002a90:	fe843783          	ld	a5,-24(s0)
    80002a94:	0007ac23          	sw	zero,24(a5)
}
    80002a98:	0001                	nop
    80002a9a:	60e2                	ld	ra,24(sp)
    80002a9c:	6442                	ld	s0,16(sp)
    80002a9e:	6105                	addi	sp,sp,32
    80002aa0:	8082                	ret

0000000080002aa2 <proc_pagetable>:

// Create a user page table for a given process, with no user memory,
// but with trampoline and trapframe pages.
pagetable_t
proc_pagetable(struct proc *p)
{
    80002aa2:	7179                	addi	sp,sp,-48
    80002aa4:	f406                	sd	ra,40(sp)
    80002aa6:	f022                	sd	s0,32(sp)
    80002aa8:	1800                	addi	s0,sp,48
    80002aaa:	fca43c23          	sd	a0,-40(s0)
  pagetable_t pagetable;

  // An empty page table.
  pagetable = uvmcreate();
    80002aae:	fffff097          	auipc	ra,0xfffff
    80002ab2:	3ac080e7          	jalr	940(ra) # 80001e5a <uvmcreate>
    80002ab6:	fea43423          	sd	a0,-24(s0)
  if(pagetable == 0)
    80002aba:	fe843783          	ld	a5,-24(s0)
    80002abe:	e399                	bnez	a5,80002ac4 <proc_pagetable+0x22>
    return 0;
    80002ac0:	4781                	li	a5,0
    80002ac2:	a859                	j	80002b58 <proc_pagetable+0xb6>

  // map the trampoline code (for system call return)
  // at the highest user virtual address.
  // only the supervisor uses it, on the way
  // to/from user space, so not PTE_U.
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80002ac4:	00007797          	auipc	a5,0x7
    80002ac8:	53c78793          	addi	a5,a5,1340 # 8000a000 <_trampoline>
    80002acc:	4729                	li	a4,10
    80002ace:	86be                	mv	a3,a5
    80002ad0:	6605                	lui	a2,0x1
    80002ad2:	040007b7          	lui	a5,0x4000
    80002ad6:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002ad8:	00c79593          	slli	a1,a5,0xc
    80002adc:	fe843503          	ld	a0,-24(s0)
    80002ae0:	fffff097          	auipc	ra,0xfffff
    80002ae4:	19c080e7          	jalr	412(ra) # 80001c7c <mappages>
    80002ae8:	87aa                	mv	a5,a0
    80002aea:	0007db63          	bgez	a5,80002b00 <proc_pagetable+0x5e>
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pagetable, 0);
    80002aee:	4581                	li	a1,0
    80002af0:	fe843503          	ld	a0,-24(s0)
    80002af4:	fffff097          	auipc	ra,0xfffff
    80002af8:	662080e7          	jalr	1634(ra) # 80002156 <uvmfree>
    return 0;
    80002afc:	4781                	li	a5,0
    80002afe:	a8a9                	j	80002b58 <proc_pagetable+0xb6>
  }

  // map the trapframe page just below the trampoline page, for
  // trampoline.S.
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    80002b00:	fd843783          	ld	a5,-40(s0)
    80002b04:	6fbc                	ld	a5,88(a5)
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80002b06:	4719                	li	a4,6
    80002b08:	86be                	mv	a3,a5
    80002b0a:	6605                	lui	a2,0x1
    80002b0c:	020007b7          	lui	a5,0x2000
    80002b10:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002b12:	00d79593          	slli	a1,a5,0xd
    80002b16:	fe843503          	ld	a0,-24(s0)
    80002b1a:	fffff097          	auipc	ra,0xfffff
    80002b1e:	162080e7          	jalr	354(ra) # 80001c7c <mappages>
    80002b22:	87aa                	mv	a5,a0
    80002b24:	0207d863          	bgez	a5,80002b54 <proc_pagetable+0xb2>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002b28:	4681                	li	a3,0
    80002b2a:	4605                	li	a2,1
    80002b2c:	040007b7          	lui	a5,0x4000
    80002b30:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b32:	00c79593          	slli	a1,a5,0xc
    80002b36:	fe843503          	ld	a0,-24(s0)
    80002b3a:	fffff097          	auipc	ra,0xfffff
    80002b3e:	220080e7          	jalr	544(ra) # 80001d5a <uvmunmap>
    uvmfree(pagetable, 0);
    80002b42:	4581                	li	a1,0
    80002b44:	fe843503          	ld	a0,-24(s0)
    80002b48:	fffff097          	auipc	ra,0xfffff
    80002b4c:	60e080e7          	jalr	1550(ra) # 80002156 <uvmfree>
    return 0;
    80002b50:	4781                	li	a5,0
    80002b52:	a019                	j	80002b58 <proc_pagetable+0xb6>
  }

  return pagetable;
    80002b54:	fe843783          	ld	a5,-24(s0)
}
    80002b58:	853e                	mv	a0,a5
    80002b5a:	70a2                	ld	ra,40(sp)
    80002b5c:	7402                	ld	s0,32(sp)
    80002b5e:	6145                	addi	sp,sp,48
    80002b60:	8082                	ret

0000000080002b62 <proc_freepagetable>:

// Free a process's page table, and free the
// physical memory it refers to.
void
proc_freepagetable(pagetable_t pagetable, uint64 sz)
{
    80002b62:	1101                	addi	sp,sp,-32
    80002b64:	ec06                	sd	ra,24(sp)
    80002b66:	e822                	sd	s0,16(sp)
    80002b68:	1000                	addi	s0,sp,32
    80002b6a:	fea43423          	sd	a0,-24(s0)
    80002b6e:	feb43023          	sd	a1,-32(s0)
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80002b72:	4681                	li	a3,0
    80002b74:	4605                	li	a2,1
    80002b76:	040007b7          	lui	a5,0x4000
    80002b7a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b7c:	00c79593          	slli	a1,a5,0xc
    80002b80:	fe843503          	ld	a0,-24(s0)
    80002b84:	fffff097          	auipc	ra,0xfffff
    80002b88:	1d6080e7          	jalr	470(ra) # 80001d5a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80002b8c:	4681                	li	a3,0
    80002b8e:	4605                	li	a2,1
    80002b90:	020007b7          	lui	a5,0x2000
    80002b94:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002b96:	00d79593          	slli	a1,a5,0xd
    80002b9a:	fe843503          	ld	a0,-24(s0)
    80002b9e:	fffff097          	auipc	ra,0xfffff
    80002ba2:	1bc080e7          	jalr	444(ra) # 80001d5a <uvmunmap>
  uvmfree(pagetable, sz);
    80002ba6:	fe043583          	ld	a1,-32(s0)
    80002baa:	fe843503          	ld	a0,-24(s0)
    80002bae:	fffff097          	auipc	ra,0xfffff
    80002bb2:	5a8080e7          	jalr	1448(ra) # 80002156 <uvmfree>
}
    80002bb6:	0001                	nop
    80002bb8:	60e2                	ld	ra,24(sp)
    80002bba:	6442                	ld	s0,16(sp)
    80002bbc:	6105                	addi	sp,sp,32
    80002bbe:	8082                	ret

0000000080002bc0 <userinit>:
};

// Set up first user process.
void
userinit(void)
{
    80002bc0:	1101                	addi	sp,sp,-32
    80002bc2:	ec06                	sd	ra,24(sp)
    80002bc4:	e822                	sd	s0,16(sp)
    80002bc6:	1000                	addi	s0,sp,32
  struct proc *p;

  p = allocproc();
    80002bc8:	00000097          	auipc	ra,0x0
    80002bcc:	d12080e7          	jalr	-750(ra) # 800028da <allocproc>
    80002bd0:	fea43423          	sd	a0,-24(s0)
  initproc = p;
    80002bd4:	00009797          	auipc	a5,0x9
    80002bd8:	d5c78793          	addi	a5,a5,-676 # 8000b930 <initproc>
    80002bdc:	fe843703          	ld	a4,-24(s0)
    80002be0:	e398                	sd	a4,0(a5)
  
  // allocate one user page and copy initcode's instructions
  // and data into it.
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80002be2:	fe843783          	ld	a5,-24(s0)
    80002be6:	6bbc                	ld	a5,80(a5)
    80002be8:	03400613          	li	a2,52
    80002bec:	00009597          	auipc	a1,0x9
    80002bf0:	bcc58593          	addi	a1,a1,-1076 # 8000b7b8 <initcode>
    80002bf4:	853e                	mv	a0,a5
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	2a0080e7          	jalr	672(ra) # 80001e96 <uvmfirst>
  p->sz = PGSIZE;
    80002bfe:	fe843783          	ld	a5,-24(s0)
    80002c02:	6705                	lui	a4,0x1
    80002c04:	e7b8                	sd	a4,72(a5)

  // prepare for the very first "return" from kernel to user.
  p->trapframe->epc = 0;      // user program counter
    80002c06:	fe843783          	ld	a5,-24(s0)
    80002c0a:	6fbc                	ld	a5,88(a5)
    80002c0c:	0007bc23          	sd	zero,24(a5)
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80002c10:	fe843783          	ld	a5,-24(s0)
    80002c14:	6fbc                	ld	a5,88(a5)
    80002c16:	6705                	lui	a4,0x1
    80002c18:	fb98                	sd	a4,48(a5)

  safestrcpy(p->name, "initcode", sizeof(p->name));
    80002c1a:	fe843783          	ld	a5,-24(s0)
    80002c1e:	15878793          	addi	a5,a5,344
    80002c22:	4641                	li	a2,16
    80002c24:	00008597          	auipc	a1,0x8
    80002c28:	5c458593          	addi	a1,a1,1476 # 8000b1e8 <etext+0x1e8>
    80002c2c:	853e                	mv	a0,a5
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	b22080e7          	jalr	-1246(ra) # 80001750 <safestrcpy>
  p->cwd = namei("/");
    80002c36:	00008517          	auipc	a0,0x8
    80002c3a:	5c250513          	addi	a0,a0,1474 # 8000b1f8 <etext+0x1f8>
    80002c3e:	00003097          	auipc	ra,0x3
    80002c42:	5b6080e7          	jalr	1462(ra) # 800061f4 <namei>
    80002c46:	872a                	mv	a4,a0
    80002c48:	fe843783          	ld	a5,-24(s0)
    80002c4c:	14e7b823          	sd	a4,336(a5)

  p->state = RUNNABLE;
    80002c50:	fe843783          	ld	a5,-24(s0)
    80002c54:	470d                	li	a4,3
    80002c56:	cf98                	sw	a4,24(a5)

  release(&p->lock);
    80002c58:	fe843783          	ld	a5,-24(s0)
    80002c5c:	853e                	mv	a0,a5
    80002c5e:	ffffe097          	auipc	ra,0xffffe
    80002c62:	67e080e7          	jalr	1662(ra) # 800012dc <release>
}
    80002c66:	0001                	nop
    80002c68:	60e2                	ld	ra,24(sp)
    80002c6a:	6442                	ld	s0,16(sp)
    80002c6c:	6105                	addi	sp,sp,32
    80002c6e:	8082                	ret

0000000080002c70 <growproc>:

// Grow or shrink user memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
    80002c70:	7179                	addi	sp,sp,-48
    80002c72:	f406                	sd	ra,40(sp)
    80002c74:	f022                	sd	s0,32(sp)
    80002c76:	1800                	addi	s0,sp,48
    80002c78:	87aa                	mv	a5,a0
    80002c7a:	fcf42e23          	sw	a5,-36(s0)
  uint64 sz;
  struct proc *p = myproc();
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	bc2080e7          	jalr	-1086(ra) # 80002840 <myproc>
    80002c86:	fea43023          	sd	a0,-32(s0)

  sz = p->sz;
    80002c8a:	fe043783          	ld	a5,-32(s0)
    80002c8e:	67bc                	ld	a5,72(a5)
    80002c90:	fef43423          	sd	a5,-24(s0)
  if(n > 0){
    80002c94:	fdc42783          	lw	a5,-36(s0)
    80002c98:	2781                	sext.w	a5,a5
    80002c9a:	02f05963          	blez	a5,80002ccc <growproc+0x5c>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80002c9e:	fe043783          	ld	a5,-32(s0)
    80002ca2:	6ba8                	ld	a0,80(a5)
    80002ca4:	fdc42703          	lw	a4,-36(s0)
    80002ca8:	fe843783          	ld	a5,-24(s0)
    80002cac:	97ba                	add	a5,a5,a4
    80002cae:	4691                	li	a3,4
    80002cb0:	863e                	mv	a2,a5
    80002cb2:	fe843583          	ld	a1,-24(s0)
    80002cb6:	fffff097          	auipc	ra,0xfffff
    80002cba:	268080e7          	jalr	616(ra) # 80001f1e <uvmalloc>
    80002cbe:	fea43423          	sd	a0,-24(s0)
    80002cc2:	fe843783          	ld	a5,-24(s0)
    80002cc6:	eb95                	bnez	a5,80002cfa <growproc+0x8a>
      return -1;
    80002cc8:	57fd                	li	a5,-1
    80002cca:	a835                	j	80002d06 <growproc+0x96>
    }
  } else if(n < 0){
    80002ccc:	fdc42783          	lw	a5,-36(s0)
    80002cd0:	2781                	sext.w	a5,a5
    80002cd2:	0207d463          	bgez	a5,80002cfa <growproc+0x8a>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002cd6:	fe043783          	ld	a5,-32(s0)
    80002cda:	6bb4                	ld	a3,80(a5)
    80002cdc:	fdc42703          	lw	a4,-36(s0)
    80002ce0:	fe843783          	ld	a5,-24(s0)
    80002ce4:	97ba                	add	a5,a5,a4
    80002ce6:	863e                	mv	a2,a5
    80002ce8:	fe843583          	ld	a1,-24(s0)
    80002cec:	8536                	mv	a0,a3
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	322080e7          	jalr	802(ra) # 80002010 <uvmdealloc>
    80002cf6:	fea43423          	sd	a0,-24(s0)
  }
  p->sz = sz;
    80002cfa:	fe043783          	ld	a5,-32(s0)
    80002cfe:	fe843703          	ld	a4,-24(s0)
    80002d02:	e7b8                	sd	a4,72(a5)
  return 0;
    80002d04:	4781                	li	a5,0
}
    80002d06:	853e                	mv	a0,a5
    80002d08:	70a2                	ld	ra,40(sp)
    80002d0a:	7402                	ld	s0,32(sp)
    80002d0c:	6145                	addi	sp,sp,48
    80002d0e:	8082                	ret

0000000080002d10 <fork>:

// Create a new process, copying the parent.
// Sets up child kernel stack to return as if from fork() system call.
int
fork(void)
{
    80002d10:	7179                	addi	sp,sp,-48
    80002d12:	f406                	sd	ra,40(sp)
    80002d14:	f022                	sd	s0,32(sp)
    80002d16:	1800                	addi	s0,sp,48
  int i, pid;
  struct proc *np;
  struct proc *p = myproc();
    80002d18:	00000097          	auipc	ra,0x0
    80002d1c:	b28080e7          	jalr	-1240(ra) # 80002840 <myproc>
    80002d20:	fea43023          	sd	a0,-32(s0)

  // Allocate process.
  if((np = allocproc()) == 0){
    80002d24:	00000097          	auipc	ra,0x0
    80002d28:	bb6080e7          	jalr	-1098(ra) # 800028da <allocproc>
    80002d2c:	fca43c23          	sd	a0,-40(s0)
    80002d30:	fd843783          	ld	a5,-40(s0)
    80002d34:	e399                	bnez	a5,80002d3a <fork+0x2a>
    return -1;
    80002d36:	57fd                	li	a5,-1
    80002d38:	aab5                	j	80002eb4 <fork+0x1a4>
  }

  // Copy user memory from parent to child.
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002d3a:	fe043783          	ld	a5,-32(s0)
    80002d3e:	6bb8                	ld	a4,80(a5)
    80002d40:	fd843783          	ld	a5,-40(s0)
    80002d44:	6bb4                	ld	a3,80(a5)
    80002d46:	fe043783          	ld	a5,-32(s0)
    80002d4a:	67bc                	ld	a5,72(a5)
    80002d4c:	863e                	mv	a2,a5
    80002d4e:	85b6                	mv	a1,a3
    80002d50:	853a                	mv	a0,a4
    80002d52:	fffff097          	auipc	ra,0xfffff
    80002d56:	44e080e7          	jalr	1102(ra) # 800021a0 <uvmcopy>
    80002d5a:	87aa                	mv	a5,a0
    80002d5c:	0207d163          	bgez	a5,80002d7e <fork+0x6e>
    freeproc(np);
    80002d60:	fd843503          	ld	a0,-40(s0)
    80002d64:	00000097          	auipc	ra,0x0
    80002d68:	ca0080e7          	jalr	-864(ra) # 80002a04 <freeproc>
    release(&np->lock);
    80002d6c:	fd843783          	ld	a5,-40(s0)
    80002d70:	853e                	mv	a0,a5
    80002d72:	ffffe097          	auipc	ra,0xffffe
    80002d76:	56a080e7          	jalr	1386(ra) # 800012dc <release>
    return -1;
    80002d7a:	57fd                	li	a5,-1
    80002d7c:	aa25                	j	80002eb4 <fork+0x1a4>
  }
  np->sz = p->sz;
    80002d7e:	fe043783          	ld	a5,-32(s0)
    80002d82:	67b8                	ld	a4,72(a5)
    80002d84:	fd843783          	ld	a5,-40(s0)
    80002d88:	e7b8                	sd	a4,72(a5)

  // copy saved user registers.
  *(np->trapframe) = *(p->trapframe);
    80002d8a:	fe043783          	ld	a5,-32(s0)
    80002d8e:	6fb8                	ld	a4,88(a5)
    80002d90:	fd843783          	ld	a5,-40(s0)
    80002d94:	6fbc                	ld	a5,88(a5)
    80002d96:	86be                	mv	a3,a5
    80002d98:	12000793          	li	a5,288
    80002d9c:	863e                	mv	a2,a5
    80002d9e:	85ba                	mv	a1,a4
    80002da0:	8536                	mv	a0,a3
    80002da2:	fffff097          	auipc	ra,0xfffff
    80002da6:	86a080e7          	jalr	-1942(ra) # 8000160c <memcpy>

  // Cause fork to return 0 in the child.
  np->trapframe->a0 = 0;
    80002daa:	fd843783          	ld	a5,-40(s0)
    80002dae:	6fbc                	ld	a5,88(a5)
    80002db0:	0607b823          	sd	zero,112(a5)

  // increment reference counts on open file descriptors.
  for(i = 0; i < NOFILE; i++)
    80002db4:	fe042623          	sw	zero,-20(s0)
    80002db8:	a0a9                	j	80002e02 <fork+0xf2>
    if(p->ofile[i])
    80002dba:	fe043703          	ld	a4,-32(s0)
    80002dbe:	fec42783          	lw	a5,-20(s0)
    80002dc2:	07e9                	addi	a5,a5,26
    80002dc4:	078e                	slli	a5,a5,0x3
    80002dc6:	97ba                	add	a5,a5,a4
    80002dc8:	639c                	ld	a5,0(a5)
    80002dca:	c79d                	beqz	a5,80002df8 <fork+0xe8>
      np->ofile[i] = filedup(p->ofile[i]);
    80002dcc:	fe043703          	ld	a4,-32(s0)
    80002dd0:	fec42783          	lw	a5,-20(s0)
    80002dd4:	07e9                	addi	a5,a5,26
    80002dd6:	078e                	slli	a5,a5,0x3
    80002dd8:	97ba                	add	a5,a5,a4
    80002dda:	639c                	ld	a5,0(a5)
    80002ddc:	853e                	mv	a0,a5
    80002dde:	00004097          	auipc	ra,0x4
    80002de2:	dae080e7          	jalr	-594(ra) # 80006b8c <filedup>
    80002de6:	86aa                	mv	a3,a0
    80002de8:	fd843703          	ld	a4,-40(s0)
    80002dec:	fec42783          	lw	a5,-20(s0)
    80002df0:	07e9                	addi	a5,a5,26
    80002df2:	078e                	slli	a5,a5,0x3
    80002df4:	97ba                	add	a5,a5,a4
    80002df6:	e394                	sd	a3,0(a5)
  for(i = 0; i < NOFILE; i++)
    80002df8:	fec42783          	lw	a5,-20(s0)
    80002dfc:	2785                	addiw	a5,a5,1
    80002dfe:	fef42623          	sw	a5,-20(s0)
    80002e02:	fec42783          	lw	a5,-20(s0)
    80002e06:	0007871b          	sext.w	a4,a5
    80002e0a:	47bd                	li	a5,15
    80002e0c:	fae7d7e3          	bge	a5,a4,80002dba <fork+0xaa>
  np->cwd = idup(p->cwd);
    80002e10:	fe043783          	ld	a5,-32(s0)
    80002e14:	1507b783          	ld	a5,336(a5)
    80002e18:	853e                	mv	a0,a5
    80002e1a:	00002097          	auipc	ra,0x2
    80002e1e:	65a080e7          	jalr	1626(ra) # 80005474 <idup>
    80002e22:	872a                	mv	a4,a0
    80002e24:	fd843783          	ld	a5,-40(s0)
    80002e28:	14e7b823          	sd	a4,336(a5)

  safestrcpy(np->name, p->name, sizeof(p->name));
    80002e2c:	fd843783          	ld	a5,-40(s0)
    80002e30:	15878713          	addi	a4,a5,344
    80002e34:	fe043783          	ld	a5,-32(s0)
    80002e38:	15878793          	addi	a5,a5,344
    80002e3c:	4641                	li	a2,16
    80002e3e:	85be                	mv	a1,a5
    80002e40:	853a                	mv	a0,a4
    80002e42:	fffff097          	auipc	ra,0xfffff
    80002e46:	90e080e7          	jalr	-1778(ra) # 80001750 <safestrcpy>

  pid = np->pid;
    80002e4a:	fd843783          	ld	a5,-40(s0)
    80002e4e:	5b9c                	lw	a5,48(a5)
    80002e50:	fcf42a23          	sw	a5,-44(s0)

  release(&np->lock);
    80002e54:	fd843783          	ld	a5,-40(s0)
    80002e58:	853e                	mv	a0,a5
    80002e5a:	ffffe097          	auipc	ra,0xffffe
    80002e5e:	482080e7          	jalr	1154(ra) # 800012dc <release>

  acquire(&wait_lock);
    80002e62:	00017517          	auipc	a0,0x17
    80002e66:	b5e50513          	addi	a0,a0,-1186 # 800199c0 <wait_lock>
    80002e6a:	ffffe097          	auipc	ra,0xffffe
    80002e6e:	40e080e7          	jalr	1038(ra) # 80001278 <acquire>
  np->parent = p;
    80002e72:	fd843783          	ld	a5,-40(s0)
    80002e76:	fe043703          	ld	a4,-32(s0)
    80002e7a:	ff98                	sd	a4,56(a5)
  release(&wait_lock);
    80002e7c:	00017517          	auipc	a0,0x17
    80002e80:	b4450513          	addi	a0,a0,-1212 # 800199c0 <wait_lock>
    80002e84:	ffffe097          	auipc	ra,0xffffe
    80002e88:	458080e7          	jalr	1112(ra) # 800012dc <release>

  acquire(&np->lock);
    80002e8c:	fd843783          	ld	a5,-40(s0)
    80002e90:	853e                	mv	a0,a5
    80002e92:	ffffe097          	auipc	ra,0xffffe
    80002e96:	3e6080e7          	jalr	998(ra) # 80001278 <acquire>
  np->state = RUNNABLE;
    80002e9a:	fd843783          	ld	a5,-40(s0)
    80002e9e:	470d                	li	a4,3
    80002ea0:	cf98                	sw	a4,24(a5)
  release(&np->lock);
    80002ea2:	fd843783          	ld	a5,-40(s0)
    80002ea6:	853e                	mv	a0,a5
    80002ea8:	ffffe097          	auipc	ra,0xffffe
    80002eac:	434080e7          	jalr	1076(ra) # 800012dc <release>

  return pid;
    80002eb0:	fd442783          	lw	a5,-44(s0)
}
    80002eb4:	853e                	mv	a0,a5
    80002eb6:	70a2                	ld	ra,40(sp)
    80002eb8:	7402                	ld	s0,32(sp)
    80002eba:	6145                	addi	sp,sp,48
    80002ebc:	8082                	ret

0000000080002ebe <reparent>:

// Pass p's abandoned children to init.
// Caller must hold wait_lock.
void
reparent(struct proc *p)
{
    80002ebe:	7179                	addi	sp,sp,-48
    80002ec0:	f406                	sd	ra,40(sp)
    80002ec2:	f022                	sd	s0,32(sp)
    80002ec4:	1800                	addi	s0,sp,48
    80002ec6:	fca43c23          	sd	a0,-40(s0)
  struct proc *pp;

  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002eca:	00011797          	auipc	a5,0x11
    80002ece:	0de78793          	addi	a5,a5,222 # 80013fa8 <proc>
    80002ed2:	fef43423          	sd	a5,-24(s0)
    80002ed6:	a081                	j	80002f16 <reparent+0x58>
    if(pp->parent == p){
    80002ed8:	fe843783          	ld	a5,-24(s0)
    80002edc:	7f9c                	ld	a5,56(a5)
    80002ede:	fd843703          	ld	a4,-40(s0)
    80002ee2:	02f71463          	bne	a4,a5,80002f0a <reparent+0x4c>
      pp->parent = initproc;
    80002ee6:	00009797          	auipc	a5,0x9
    80002eea:	a4a78793          	addi	a5,a5,-1462 # 8000b930 <initproc>
    80002eee:	6398                	ld	a4,0(a5)
    80002ef0:	fe843783          	ld	a5,-24(s0)
    80002ef4:	ff98                	sd	a4,56(a5)
      wakeup(initproc);
    80002ef6:	00009797          	auipc	a5,0x9
    80002efa:	a3a78793          	addi	a5,a5,-1478 # 8000b930 <initproc>
    80002efe:	639c                	ld	a5,0(a5)
    80002f00:	853e                	mv	a0,a5
    80002f02:	00000097          	auipc	ra,0x0
    80002f06:	57c080e7          	jalr	1404(ra) # 8000347e <wakeup>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002f0a:	fe843783          	ld	a5,-24(s0)
    80002f0e:	16878793          	addi	a5,a5,360
    80002f12:	fef43423          	sd	a5,-24(s0)
    80002f16:	fe843703          	ld	a4,-24(s0)
    80002f1a:	00017797          	auipc	a5,0x17
    80002f1e:	a8e78793          	addi	a5,a5,-1394 # 800199a8 <pid_lock>
    80002f22:	faf76be3          	bltu	a4,a5,80002ed8 <reparent+0x1a>
    }
  }
}
    80002f26:	0001                	nop
    80002f28:	0001                	nop
    80002f2a:	70a2                	ld	ra,40(sp)
    80002f2c:	7402                	ld	s0,32(sp)
    80002f2e:	6145                	addi	sp,sp,48
    80002f30:	8082                	ret

0000000080002f32 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait().
void
exit(int status)
{
    80002f32:	7139                	addi	sp,sp,-64
    80002f34:	fc06                	sd	ra,56(sp)
    80002f36:	f822                	sd	s0,48(sp)
    80002f38:	0080                	addi	s0,sp,64
    80002f3a:	87aa                	mv	a5,a0
    80002f3c:	fcf42623          	sw	a5,-52(s0)
  struct proc *p = myproc();
    80002f40:	00000097          	auipc	ra,0x0
    80002f44:	900080e7          	jalr	-1792(ra) # 80002840 <myproc>
    80002f48:	fea43023          	sd	a0,-32(s0)

  if(p == initproc)
    80002f4c:	00009797          	auipc	a5,0x9
    80002f50:	9e478793          	addi	a5,a5,-1564 # 8000b930 <initproc>
    80002f54:	639c                	ld	a5,0(a5)
    80002f56:	fe043703          	ld	a4,-32(s0)
    80002f5a:	00f71a63          	bne	a4,a5,80002f6e <exit+0x3c>
    panic("init exiting");
    80002f5e:	00008517          	auipc	a0,0x8
    80002f62:	2a250513          	addi	a0,a0,674 # 8000b200 <etext+0x200>
    80002f66:	ffffe097          	auipc	ra,0xffffe
    80002f6a:	d24080e7          	jalr	-732(ra) # 80000c8a <panic>

  // Close all open files.
  for(int fd = 0; fd < NOFILE; fd++){
    80002f6e:	fe042623          	sw	zero,-20(s0)
    80002f72:	a881                	j	80002fc2 <exit+0x90>
    if(p->ofile[fd]){
    80002f74:	fe043703          	ld	a4,-32(s0)
    80002f78:	fec42783          	lw	a5,-20(s0)
    80002f7c:	07e9                	addi	a5,a5,26
    80002f7e:	078e                	slli	a5,a5,0x3
    80002f80:	97ba                	add	a5,a5,a4
    80002f82:	639c                	ld	a5,0(a5)
    80002f84:	cb95                	beqz	a5,80002fb8 <exit+0x86>
      struct file *f = p->ofile[fd];
    80002f86:	fe043703          	ld	a4,-32(s0)
    80002f8a:	fec42783          	lw	a5,-20(s0)
    80002f8e:	07e9                	addi	a5,a5,26
    80002f90:	078e                	slli	a5,a5,0x3
    80002f92:	97ba                	add	a5,a5,a4
    80002f94:	639c                	ld	a5,0(a5)
    80002f96:	fcf43c23          	sd	a5,-40(s0)
      fileclose(f);
    80002f9a:	fd843503          	ld	a0,-40(s0)
    80002f9e:	00004097          	auipc	ra,0x4
    80002fa2:	c54080e7          	jalr	-940(ra) # 80006bf2 <fileclose>
      p->ofile[fd] = 0;
    80002fa6:	fe043703          	ld	a4,-32(s0)
    80002faa:	fec42783          	lw	a5,-20(s0)
    80002fae:	07e9                	addi	a5,a5,26
    80002fb0:	078e                	slli	a5,a5,0x3
    80002fb2:	97ba                	add	a5,a5,a4
    80002fb4:	0007b023          	sd	zero,0(a5)
  for(int fd = 0; fd < NOFILE; fd++){
    80002fb8:	fec42783          	lw	a5,-20(s0)
    80002fbc:	2785                	addiw	a5,a5,1
    80002fbe:	fef42623          	sw	a5,-20(s0)
    80002fc2:	fec42783          	lw	a5,-20(s0)
    80002fc6:	0007871b          	sext.w	a4,a5
    80002fca:	47bd                	li	a5,15
    80002fcc:	fae7d4e3          	bge	a5,a4,80002f74 <exit+0x42>
    }
  }

  begin_op();
    80002fd0:	00003097          	auipc	ra,0x3
    80002fd4:	588080e7          	jalr	1416(ra) # 80006558 <begin_op>
  iput(p->cwd);
    80002fd8:	fe043783          	ld	a5,-32(s0)
    80002fdc:	1507b783          	ld	a5,336(a5)
    80002fe0:	853e                	mv	a0,a5
    80002fe2:	00002097          	auipc	ra,0x2
    80002fe6:	66c080e7          	jalr	1644(ra) # 8000564e <iput>
  end_op();
    80002fea:	00003097          	auipc	ra,0x3
    80002fee:	630080e7          	jalr	1584(ra) # 8000661a <end_op>
  p->cwd = 0;
    80002ff2:	fe043783          	ld	a5,-32(s0)
    80002ff6:	1407b823          	sd	zero,336(a5)

  acquire(&wait_lock);
    80002ffa:	00017517          	auipc	a0,0x17
    80002ffe:	9c650513          	addi	a0,a0,-1594 # 800199c0 <wait_lock>
    80003002:	ffffe097          	auipc	ra,0xffffe
    80003006:	276080e7          	jalr	630(ra) # 80001278 <acquire>

  // Give any children to init.
  reparent(p);
    8000300a:	fe043503          	ld	a0,-32(s0)
    8000300e:	00000097          	auipc	ra,0x0
    80003012:	eb0080e7          	jalr	-336(ra) # 80002ebe <reparent>

  // Parent might be sleeping in wait().
  wakeup(p->parent);
    80003016:	fe043783          	ld	a5,-32(s0)
    8000301a:	7f9c                	ld	a5,56(a5)
    8000301c:	853e                	mv	a0,a5
    8000301e:	00000097          	auipc	ra,0x0
    80003022:	460080e7          	jalr	1120(ra) # 8000347e <wakeup>
  
  acquire(&p->lock);
    80003026:	fe043783          	ld	a5,-32(s0)
    8000302a:	853e                	mv	a0,a5
    8000302c:	ffffe097          	auipc	ra,0xffffe
    80003030:	24c080e7          	jalr	588(ra) # 80001278 <acquire>

  p->xstate = status;
    80003034:	fe043783          	ld	a5,-32(s0)
    80003038:	fcc42703          	lw	a4,-52(s0)
    8000303c:	d7d8                	sw	a4,44(a5)
  p->state = ZOMBIE;
    8000303e:	fe043783          	ld	a5,-32(s0)
    80003042:	4715                	li	a4,5
    80003044:	cf98                	sw	a4,24(a5)

  release(&wait_lock);
    80003046:	00017517          	auipc	a0,0x17
    8000304a:	97a50513          	addi	a0,a0,-1670 # 800199c0 <wait_lock>
    8000304e:	ffffe097          	auipc	ra,0xffffe
    80003052:	28e080e7          	jalr	654(ra) # 800012dc <release>

  // Jump into the scheduler, never to return.
  sched();
    80003056:	00000097          	auipc	ra,0x0
    8000305a:	230080e7          	jalr	560(ra) # 80003286 <sched>
  panic("zombie exit");
    8000305e:	00008517          	auipc	a0,0x8
    80003062:	1b250513          	addi	a0,a0,434 # 8000b210 <etext+0x210>
    80003066:	ffffe097          	auipc	ra,0xffffe
    8000306a:	c24080e7          	jalr	-988(ra) # 80000c8a <panic>

000000008000306e <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(uint64 addr)
{
    8000306e:	7139                	addi	sp,sp,-64
    80003070:	fc06                	sd	ra,56(sp)
    80003072:	f822                	sd	s0,48(sp)
    80003074:	0080                	addi	s0,sp,64
    80003076:	fca43423          	sd	a0,-56(s0)
  struct proc *pp;
  int havekids, pid;
  struct proc *p = myproc();
    8000307a:	fffff097          	auipc	ra,0xfffff
    8000307e:	7c6080e7          	jalr	1990(ra) # 80002840 <myproc>
    80003082:	fca43c23          	sd	a0,-40(s0)

  acquire(&wait_lock);
    80003086:	00017517          	auipc	a0,0x17
    8000308a:	93a50513          	addi	a0,a0,-1734 # 800199c0 <wait_lock>
    8000308e:	ffffe097          	auipc	ra,0xffffe
    80003092:	1ea080e7          	jalr	490(ra) # 80001278 <acquire>

  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    80003096:	fe042223          	sw	zero,-28(s0)
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000309a:	00011797          	auipc	a5,0x11
    8000309e:	f0e78793          	addi	a5,a5,-242 # 80013fa8 <proc>
    800030a2:	fef43423          	sd	a5,-24(s0)
    800030a6:	a8d1                	j	8000317a <wait+0x10c>
      if(pp->parent == p){
    800030a8:	fe843783          	ld	a5,-24(s0)
    800030ac:	7f9c                	ld	a5,56(a5)
    800030ae:	fd843703          	ld	a4,-40(s0)
    800030b2:	0af71e63          	bne	a4,a5,8000316e <wait+0x100>
        // make sure the child isn't still in exit() or swtch().
        acquire(&pp->lock);
    800030b6:	fe843783          	ld	a5,-24(s0)
    800030ba:	853e                	mv	a0,a5
    800030bc:	ffffe097          	auipc	ra,0xffffe
    800030c0:	1bc080e7          	jalr	444(ra) # 80001278 <acquire>

        havekids = 1;
    800030c4:	4785                	li	a5,1
    800030c6:	fef42223          	sw	a5,-28(s0)
        if(pp->state == ZOMBIE){
    800030ca:	fe843783          	ld	a5,-24(s0)
    800030ce:	4f9c                	lw	a5,24(a5)
    800030d0:	873e                	mv	a4,a5
    800030d2:	4795                	li	a5,5
    800030d4:	08f71663          	bne	a4,a5,80003160 <wait+0xf2>
          // Found one.
          pid = pp->pid;
    800030d8:	fe843783          	ld	a5,-24(s0)
    800030dc:	5b9c                	lw	a5,48(a5)
    800030de:	fcf42a23          	sw	a5,-44(s0)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800030e2:	fc843783          	ld	a5,-56(s0)
    800030e6:	c7a9                	beqz	a5,80003130 <wait+0xc2>
    800030e8:	fd843783          	ld	a5,-40(s0)
    800030ec:	6bb8                	ld	a4,80(a5)
    800030ee:	fe843783          	ld	a5,-24(s0)
    800030f2:	02c78793          	addi	a5,a5,44
    800030f6:	4691                	li	a3,4
    800030f8:	863e                	mv	a2,a5
    800030fa:	fc843583          	ld	a1,-56(s0)
    800030fe:	853a                	mv	a0,a4
    80003100:	fffff097          	auipc	ra,0xfffff
    80003104:	20a080e7          	jalr	522(ra) # 8000230a <copyout>
    80003108:	87aa                	mv	a5,a0
    8000310a:	0207d363          	bgez	a5,80003130 <wait+0xc2>
                                  sizeof(pp->xstate)) < 0) {
            release(&pp->lock);
    8000310e:	fe843783          	ld	a5,-24(s0)
    80003112:	853e                	mv	a0,a5
    80003114:	ffffe097          	auipc	ra,0xffffe
    80003118:	1c8080e7          	jalr	456(ra) # 800012dc <release>
            release(&wait_lock);
    8000311c:	00017517          	auipc	a0,0x17
    80003120:	8a450513          	addi	a0,a0,-1884 # 800199c0 <wait_lock>
    80003124:	ffffe097          	auipc	ra,0xffffe
    80003128:	1b8080e7          	jalr	440(ra) # 800012dc <release>
            return -1;
    8000312c:	57fd                	li	a5,-1
    8000312e:	a879                	j	800031cc <wait+0x15e>
          }
          freeproc(pp);
    80003130:	fe843503          	ld	a0,-24(s0)
    80003134:	00000097          	auipc	ra,0x0
    80003138:	8d0080e7          	jalr	-1840(ra) # 80002a04 <freeproc>
          release(&pp->lock);
    8000313c:	fe843783          	ld	a5,-24(s0)
    80003140:	853e                	mv	a0,a5
    80003142:	ffffe097          	auipc	ra,0xffffe
    80003146:	19a080e7          	jalr	410(ra) # 800012dc <release>
          release(&wait_lock);
    8000314a:	00017517          	auipc	a0,0x17
    8000314e:	87650513          	addi	a0,a0,-1930 # 800199c0 <wait_lock>
    80003152:	ffffe097          	auipc	ra,0xffffe
    80003156:	18a080e7          	jalr	394(ra) # 800012dc <release>
          return pid;
    8000315a:	fd442783          	lw	a5,-44(s0)
    8000315e:	a0bd                	j	800031cc <wait+0x15e>
        }
        release(&pp->lock);
    80003160:	fe843783          	ld	a5,-24(s0)
    80003164:	853e                	mv	a0,a5
    80003166:	ffffe097          	auipc	ra,0xffffe
    8000316a:	176080e7          	jalr	374(ra) # 800012dc <release>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000316e:	fe843783          	ld	a5,-24(s0)
    80003172:	16878793          	addi	a5,a5,360
    80003176:	fef43423          	sd	a5,-24(s0)
    8000317a:	fe843703          	ld	a4,-24(s0)
    8000317e:	00017797          	auipc	a5,0x17
    80003182:	82a78793          	addi	a5,a5,-2006 # 800199a8 <pid_lock>
    80003186:	f2f761e3          	bltu	a4,a5,800030a8 <wait+0x3a>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || killed(p)){
    8000318a:	fe442783          	lw	a5,-28(s0)
    8000318e:	2781                	sext.w	a5,a5
    80003190:	cb89                	beqz	a5,800031a2 <wait+0x134>
    80003192:	fd843503          	ld	a0,-40(s0)
    80003196:	00000097          	auipc	ra,0x0
    8000319a:	456080e7          	jalr	1110(ra) # 800035ec <killed>
    8000319e:	87aa                	mv	a5,a0
    800031a0:	cb99                	beqz	a5,800031b6 <wait+0x148>
      release(&wait_lock);
    800031a2:	00017517          	auipc	a0,0x17
    800031a6:	81e50513          	addi	a0,a0,-2018 # 800199c0 <wait_lock>
    800031aa:	ffffe097          	auipc	ra,0xffffe
    800031ae:	132080e7          	jalr	306(ra) # 800012dc <release>
      return -1;
    800031b2:	57fd                	li	a5,-1
    800031b4:	a821                	j	800031cc <wait+0x15e>
    }
    
    // Wait for a child to exit.
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800031b6:	00017597          	auipc	a1,0x17
    800031ba:	80a58593          	addi	a1,a1,-2038 # 800199c0 <wait_lock>
    800031be:	fd843503          	ld	a0,-40(s0)
    800031c2:	00000097          	auipc	ra,0x0
    800031c6:	240080e7          	jalr	576(ra) # 80003402 <sleep>
    havekids = 0;
    800031ca:	b5f1                	j	80003096 <wait+0x28>
  }
}
    800031cc:	853e                	mv	a0,a5
    800031ce:	70e2                	ld	ra,56(sp)
    800031d0:	7442                	ld	s0,48(sp)
    800031d2:	6121                	addi	sp,sp,64
    800031d4:	8082                	ret

00000000800031d6 <scheduler>:
//  - swtch to start running that process.
//  - eventually that process transfers control
//    via swtch back to the scheduler.
void
scheduler(void)
{
    800031d6:	1101                	addi	sp,sp,-32
    800031d8:	ec06                	sd	ra,24(sp)
    800031da:	e822                	sd	s0,16(sp)
    800031dc:	1000                	addi	s0,sp,32
  struct proc *p;
  struct cpu *c = mycpu();
    800031de:	fffff097          	auipc	ra,0xfffff
    800031e2:	628080e7          	jalr	1576(ra) # 80002806 <mycpu>
    800031e6:	fea43023          	sd	a0,-32(s0)
  
  c->proc = 0;
    800031ea:	fe043783          	ld	a5,-32(s0)
    800031ee:	0007b023          	sd	zero,0(a5)
  for(;;){
    // Avoid deadlock by ensuring that devices can interrupt.
    intr_on();
    800031f2:	fffff097          	auipc	ra,0xfffff
    800031f6:	3f6080e7          	jalr	1014(ra) # 800025e8 <intr_on>

    for(p = proc; p < &proc[NPROC]; p++) {
    800031fa:	00011797          	auipc	a5,0x11
    800031fe:	dae78793          	addi	a5,a5,-594 # 80013fa8 <proc>
    80003202:	fef43423          	sd	a5,-24(s0)
    80003206:	a0bd                	j	80003274 <scheduler+0x9e>
      acquire(&p->lock);
    80003208:	fe843783          	ld	a5,-24(s0)
    8000320c:	853e                	mv	a0,a5
    8000320e:	ffffe097          	auipc	ra,0xffffe
    80003212:	06a080e7          	jalr	106(ra) # 80001278 <acquire>
      if(p->state == RUNNABLE) {
    80003216:	fe843783          	ld	a5,-24(s0)
    8000321a:	4f9c                	lw	a5,24(a5)
    8000321c:	873e                	mv	a4,a5
    8000321e:	478d                	li	a5,3
    80003220:	02f71d63          	bne	a4,a5,8000325a <scheduler+0x84>
        // Switch to chosen process.  It is the process's job
        // to release its lock and then reacquire it
        // before jumping back to us.
        p->state = RUNNING;
    80003224:	fe843783          	ld	a5,-24(s0)
    80003228:	4711                	li	a4,4
    8000322a:	cf98                	sw	a4,24(a5)
        c->proc = p;
    8000322c:	fe043783          	ld	a5,-32(s0)
    80003230:	fe843703          	ld	a4,-24(s0)
    80003234:	e398                	sd	a4,0(a5)
        swtch(&c->context, &p->context);
    80003236:	fe043783          	ld	a5,-32(s0)
    8000323a:	00878713          	addi	a4,a5,8
    8000323e:	fe843783          	ld	a5,-24(s0)
    80003242:	06078793          	addi	a5,a5,96
    80003246:	85be                	mv	a1,a5
    80003248:	853a                	mv	a0,a4
    8000324a:	00001097          	auipc	ra,0x1
    8000324e:	992080e7          	jalr	-1646(ra) # 80003bdc <swtch>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        c->proc = 0;
    80003252:	fe043783          	ld	a5,-32(s0)
    80003256:	0007b023          	sd	zero,0(a5)
      }
      release(&p->lock);
    8000325a:	fe843783          	ld	a5,-24(s0)
    8000325e:	853e                	mv	a0,a5
    80003260:	ffffe097          	auipc	ra,0xffffe
    80003264:	07c080e7          	jalr	124(ra) # 800012dc <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80003268:	fe843783          	ld	a5,-24(s0)
    8000326c:	16878793          	addi	a5,a5,360
    80003270:	fef43423          	sd	a5,-24(s0)
    80003274:	fe843703          	ld	a4,-24(s0)
    80003278:	00016797          	auipc	a5,0x16
    8000327c:	73078793          	addi	a5,a5,1840 # 800199a8 <pid_lock>
    80003280:	f8f764e3          	bltu	a4,a5,80003208 <scheduler+0x32>
    intr_on();
    80003284:	b7bd                	j	800031f2 <scheduler+0x1c>

0000000080003286 <sched>:
// be proc->intena and proc->noff, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
    80003286:	7179                	addi	sp,sp,-48
    80003288:	f406                	sd	ra,40(sp)
    8000328a:	f022                	sd	s0,32(sp)
    8000328c:	ec26                	sd	s1,24(sp)
    8000328e:	1800                	addi	s0,sp,48
  int intena;
  struct proc *p = myproc();
    80003290:	fffff097          	auipc	ra,0xfffff
    80003294:	5b0080e7          	jalr	1456(ra) # 80002840 <myproc>
    80003298:	fca43c23          	sd	a0,-40(s0)

  if(!holding(&p->lock))
    8000329c:	fd843783          	ld	a5,-40(s0)
    800032a0:	853e                	mv	a0,a5
    800032a2:	ffffe097          	auipc	ra,0xffffe
    800032a6:	090080e7          	jalr	144(ra) # 80001332 <holding>
    800032aa:	87aa                	mv	a5,a0
    800032ac:	eb89                	bnez	a5,800032be <sched+0x38>
    panic("sched p->lock");
    800032ae:	00008517          	auipc	a0,0x8
    800032b2:	f7250513          	addi	a0,a0,-142 # 8000b220 <etext+0x220>
    800032b6:	ffffe097          	auipc	ra,0xffffe
    800032ba:	9d4080e7          	jalr	-1580(ra) # 80000c8a <panic>
  if(mycpu()->noff != 1)
    800032be:	fffff097          	auipc	ra,0xfffff
    800032c2:	548080e7          	jalr	1352(ra) # 80002806 <mycpu>
    800032c6:	87aa                	mv	a5,a0
    800032c8:	5fbc                	lw	a5,120(a5)
    800032ca:	873e                	mv	a4,a5
    800032cc:	4785                	li	a5,1
    800032ce:	00f70a63          	beq	a4,a5,800032e2 <sched+0x5c>
    panic("sched locks");
    800032d2:	00008517          	auipc	a0,0x8
    800032d6:	f5e50513          	addi	a0,a0,-162 # 8000b230 <etext+0x230>
    800032da:	ffffe097          	auipc	ra,0xffffe
    800032de:	9b0080e7          	jalr	-1616(ra) # 80000c8a <panic>
  if(p->state == RUNNING)
    800032e2:	fd843783          	ld	a5,-40(s0)
    800032e6:	4f9c                	lw	a5,24(a5)
    800032e8:	873e                	mv	a4,a5
    800032ea:	4791                	li	a5,4
    800032ec:	00f71a63          	bne	a4,a5,80003300 <sched+0x7a>
    panic("sched running");
    800032f0:	00008517          	auipc	a0,0x8
    800032f4:	f5050513          	addi	a0,a0,-176 # 8000b240 <etext+0x240>
    800032f8:	ffffe097          	auipc	ra,0xffffe
    800032fc:	992080e7          	jalr	-1646(ra) # 80000c8a <panic>
  if(intr_get())
    80003300:	fffff097          	auipc	ra,0xfffff
    80003304:	312080e7          	jalr	786(ra) # 80002612 <intr_get>
    80003308:	87aa                	mv	a5,a0
    8000330a:	cb89                	beqz	a5,8000331c <sched+0x96>
    panic("sched interruptible");
    8000330c:	00008517          	auipc	a0,0x8
    80003310:	f4450513          	addi	a0,a0,-188 # 8000b250 <etext+0x250>
    80003314:	ffffe097          	auipc	ra,0xffffe
    80003318:	976080e7          	jalr	-1674(ra) # 80000c8a <panic>

  intena = mycpu()->intena;
    8000331c:	fffff097          	auipc	ra,0xfffff
    80003320:	4ea080e7          	jalr	1258(ra) # 80002806 <mycpu>
    80003324:	87aa                	mv	a5,a0
    80003326:	5ffc                	lw	a5,124(a5)
    80003328:	fcf42a23          	sw	a5,-44(s0)
  swtch(&p->context, &mycpu()->context);
    8000332c:	fd843783          	ld	a5,-40(s0)
    80003330:	06078493          	addi	s1,a5,96
    80003334:	fffff097          	auipc	ra,0xfffff
    80003338:	4d2080e7          	jalr	1234(ra) # 80002806 <mycpu>
    8000333c:	87aa                	mv	a5,a0
    8000333e:	07a1                	addi	a5,a5,8
    80003340:	85be                	mv	a1,a5
    80003342:	8526                	mv	a0,s1
    80003344:	00001097          	auipc	ra,0x1
    80003348:	898080e7          	jalr	-1896(ra) # 80003bdc <swtch>
  mycpu()->intena = intena;
    8000334c:	fffff097          	auipc	ra,0xfffff
    80003350:	4ba080e7          	jalr	1210(ra) # 80002806 <mycpu>
    80003354:	872a                	mv	a4,a0
    80003356:	fd442783          	lw	a5,-44(s0)
    8000335a:	df7c                	sw	a5,124(a4)
}
    8000335c:	0001                	nop
    8000335e:	70a2                	ld	ra,40(sp)
    80003360:	7402                	ld	s0,32(sp)
    80003362:	64e2                	ld	s1,24(sp)
    80003364:	6145                	addi	sp,sp,48
    80003366:	8082                	ret

0000000080003368 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
    80003368:	1101                	addi	sp,sp,-32
    8000336a:	ec06                	sd	ra,24(sp)
    8000336c:	e822                	sd	s0,16(sp)
    8000336e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80003370:	fffff097          	auipc	ra,0xfffff
    80003374:	4d0080e7          	jalr	1232(ra) # 80002840 <myproc>
    80003378:	fea43423          	sd	a0,-24(s0)
  acquire(&p->lock);
    8000337c:	fe843783          	ld	a5,-24(s0)
    80003380:	853e                	mv	a0,a5
    80003382:	ffffe097          	auipc	ra,0xffffe
    80003386:	ef6080e7          	jalr	-266(ra) # 80001278 <acquire>
  p->state = RUNNABLE;
    8000338a:	fe843783          	ld	a5,-24(s0)
    8000338e:	470d                	li	a4,3
    80003390:	cf98                	sw	a4,24(a5)
  sched();
    80003392:	00000097          	auipc	ra,0x0
    80003396:	ef4080e7          	jalr	-268(ra) # 80003286 <sched>
  release(&p->lock);
    8000339a:	fe843783          	ld	a5,-24(s0)
    8000339e:	853e                	mv	a0,a5
    800033a0:	ffffe097          	auipc	ra,0xffffe
    800033a4:	f3c080e7          	jalr	-196(ra) # 800012dc <release>
}
    800033a8:	0001                	nop
    800033aa:	60e2                	ld	ra,24(sp)
    800033ac:	6442                	ld	s0,16(sp)
    800033ae:	6105                	addi	sp,sp,32
    800033b0:	8082                	ret

00000000800033b2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800033b2:	1141                	addi	sp,sp,-16
    800033b4:	e406                	sd	ra,8(sp)
    800033b6:	e022                	sd	s0,0(sp)
    800033b8:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800033ba:	fffff097          	auipc	ra,0xfffff
    800033be:	486080e7          	jalr	1158(ra) # 80002840 <myproc>
    800033c2:	87aa                	mv	a5,a0
    800033c4:	853e                	mv	a0,a5
    800033c6:	ffffe097          	auipc	ra,0xffffe
    800033ca:	f16080e7          	jalr	-234(ra) # 800012dc <release>

  if (first) {
    800033ce:	00008797          	auipc	a5,0x8
    800033d2:	3c678793          	addi	a5,a5,966 # 8000b794 <first.1>
    800033d6:	439c                	lw	a5,0(a5)
    800033d8:	cf81                	beqz	a5,800033f0 <forkret+0x3e>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    first = 0;
    800033da:	00008797          	auipc	a5,0x8
    800033de:	3ba78793          	addi	a5,a5,954 # 8000b794 <first.1>
    800033e2:	0007a023          	sw	zero,0(a5)
    fsinit(ROOTDEV);
    800033e6:	4505                	li	a0,1
    800033e8:	00002097          	auipc	ra,0x2
    800033ec:	97a080e7          	jalr	-1670(ra) # 80004d62 <fsinit>
  }

  usertrapret();
    800033f0:	00001097          	auipc	ra,0x1
    800033f4:	b9e080e7          	jalr	-1122(ra) # 80003f8e <usertrapret>
}
    800033f8:	0001                	nop
    800033fa:	60a2                	ld	ra,8(sp)
    800033fc:	6402                	ld	s0,0(sp)
    800033fe:	0141                	addi	sp,sp,16
    80003400:	8082                	ret

0000000080003402 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80003402:	7179                	addi	sp,sp,-48
    80003404:	f406                	sd	ra,40(sp)
    80003406:	f022                	sd	s0,32(sp)
    80003408:	1800                	addi	s0,sp,48
    8000340a:	fca43c23          	sd	a0,-40(s0)
    8000340e:	fcb43823          	sd	a1,-48(s0)
  struct proc *p = myproc();
    80003412:	fffff097          	auipc	ra,0xfffff
    80003416:	42e080e7          	jalr	1070(ra) # 80002840 <myproc>
    8000341a:	fea43423          	sd	a0,-24(s0)
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000341e:	fe843783          	ld	a5,-24(s0)
    80003422:	853e                	mv	a0,a5
    80003424:	ffffe097          	auipc	ra,0xffffe
    80003428:	e54080e7          	jalr	-428(ra) # 80001278 <acquire>
  release(lk);
    8000342c:	fd043503          	ld	a0,-48(s0)
    80003430:	ffffe097          	auipc	ra,0xffffe
    80003434:	eac080e7          	jalr	-340(ra) # 800012dc <release>

  // Go to sleep.
  p->chan = chan;
    80003438:	fe843783          	ld	a5,-24(s0)
    8000343c:	fd843703          	ld	a4,-40(s0)
    80003440:	f398                	sd	a4,32(a5)
  p->state = SLEEPING;
    80003442:	fe843783          	ld	a5,-24(s0)
    80003446:	4709                	li	a4,2
    80003448:	cf98                	sw	a4,24(a5)

  sched();
    8000344a:	00000097          	auipc	ra,0x0
    8000344e:	e3c080e7          	jalr	-452(ra) # 80003286 <sched>

  // Tidy up.
  p->chan = 0;
    80003452:	fe843783          	ld	a5,-24(s0)
    80003456:	0207b023          	sd	zero,32(a5)

  // Reacquire original lock.
  release(&p->lock);
    8000345a:	fe843783          	ld	a5,-24(s0)
    8000345e:	853e                	mv	a0,a5
    80003460:	ffffe097          	auipc	ra,0xffffe
    80003464:	e7c080e7          	jalr	-388(ra) # 800012dc <release>
  acquire(lk);
    80003468:	fd043503          	ld	a0,-48(s0)
    8000346c:	ffffe097          	auipc	ra,0xffffe
    80003470:	e0c080e7          	jalr	-500(ra) # 80001278 <acquire>
}
    80003474:	0001                	nop
    80003476:	70a2                	ld	ra,40(sp)
    80003478:	7402                	ld	s0,32(sp)
    8000347a:	6145                	addi	sp,sp,48
    8000347c:	8082                	ret

000000008000347e <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000347e:	7179                	addi	sp,sp,-48
    80003480:	f406                	sd	ra,40(sp)
    80003482:	f022                	sd	s0,32(sp)
    80003484:	1800                	addi	s0,sp,48
    80003486:	fca43c23          	sd	a0,-40(s0)
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000348a:	00011797          	auipc	a5,0x11
    8000348e:	b1e78793          	addi	a5,a5,-1250 # 80013fa8 <proc>
    80003492:	fef43423          	sd	a5,-24(s0)
    80003496:	a085                	j	800034f6 <wakeup+0x78>
    if(p != myproc()){
    80003498:	fffff097          	auipc	ra,0xfffff
    8000349c:	3a8080e7          	jalr	936(ra) # 80002840 <myproc>
    800034a0:	872a                	mv	a4,a0
    800034a2:	fe843783          	ld	a5,-24(s0)
    800034a6:	04e78263          	beq	a5,a4,800034ea <wakeup+0x6c>
      acquire(&p->lock);
    800034aa:	fe843783          	ld	a5,-24(s0)
    800034ae:	853e                	mv	a0,a5
    800034b0:	ffffe097          	auipc	ra,0xffffe
    800034b4:	dc8080e7          	jalr	-568(ra) # 80001278 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800034b8:	fe843783          	ld	a5,-24(s0)
    800034bc:	4f9c                	lw	a5,24(a5)
    800034be:	873e                	mv	a4,a5
    800034c0:	4789                	li	a5,2
    800034c2:	00f71d63          	bne	a4,a5,800034dc <wakeup+0x5e>
    800034c6:	fe843783          	ld	a5,-24(s0)
    800034ca:	739c                	ld	a5,32(a5)
    800034cc:	fd843703          	ld	a4,-40(s0)
    800034d0:	00f71663          	bne	a4,a5,800034dc <wakeup+0x5e>
        p->state = RUNNABLE;
    800034d4:	fe843783          	ld	a5,-24(s0)
    800034d8:	470d                	li	a4,3
    800034da:	cf98                	sw	a4,24(a5)
      }
      release(&p->lock);
    800034dc:	fe843783          	ld	a5,-24(s0)
    800034e0:	853e                	mv	a0,a5
    800034e2:	ffffe097          	auipc	ra,0xffffe
    800034e6:	dfa080e7          	jalr	-518(ra) # 800012dc <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800034ea:	fe843783          	ld	a5,-24(s0)
    800034ee:	16878793          	addi	a5,a5,360
    800034f2:	fef43423          	sd	a5,-24(s0)
    800034f6:	fe843703          	ld	a4,-24(s0)
    800034fa:	00016797          	auipc	a5,0x16
    800034fe:	4ae78793          	addi	a5,a5,1198 # 800199a8 <pid_lock>
    80003502:	f8f76be3          	bltu	a4,a5,80003498 <wakeup+0x1a>
    }
  }
}
    80003506:	0001                	nop
    80003508:	0001                	nop
    8000350a:	70a2                	ld	ra,40(sp)
    8000350c:	7402                	ld	s0,32(sp)
    8000350e:	6145                	addi	sp,sp,48
    80003510:	8082                	ret

0000000080003512 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80003512:	7179                	addi	sp,sp,-48
    80003514:	f406                	sd	ra,40(sp)
    80003516:	f022                	sd	s0,32(sp)
    80003518:	1800                	addi	s0,sp,48
    8000351a:	87aa                	mv	a5,a0
    8000351c:	fcf42e23          	sw	a5,-36(s0)
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80003520:	00011797          	auipc	a5,0x11
    80003524:	a8878793          	addi	a5,a5,-1400 # 80013fa8 <proc>
    80003528:	fef43423          	sd	a5,-24(s0)
    8000352c:	a0ad                	j	80003596 <kill+0x84>
    acquire(&p->lock);
    8000352e:	fe843783          	ld	a5,-24(s0)
    80003532:	853e                	mv	a0,a5
    80003534:	ffffe097          	auipc	ra,0xffffe
    80003538:	d44080e7          	jalr	-700(ra) # 80001278 <acquire>
    if(p->pid == pid){
    8000353c:	fe843783          	ld	a5,-24(s0)
    80003540:	5b98                	lw	a4,48(a5)
    80003542:	fdc42783          	lw	a5,-36(s0)
    80003546:	2781                	sext.w	a5,a5
    80003548:	02e79a63          	bne	a5,a4,8000357c <kill+0x6a>
      p->killed = 1;
    8000354c:	fe843783          	ld	a5,-24(s0)
    80003550:	4705                	li	a4,1
    80003552:	d798                	sw	a4,40(a5)
      if(p->state == SLEEPING){
    80003554:	fe843783          	ld	a5,-24(s0)
    80003558:	4f9c                	lw	a5,24(a5)
    8000355a:	873e                	mv	a4,a5
    8000355c:	4789                	li	a5,2
    8000355e:	00f71663          	bne	a4,a5,8000356a <kill+0x58>
        // Wake process from sleep().
        p->state = RUNNABLE;
    80003562:	fe843783          	ld	a5,-24(s0)
    80003566:	470d                	li	a4,3
    80003568:	cf98                	sw	a4,24(a5)
      }
      release(&p->lock);
    8000356a:	fe843783          	ld	a5,-24(s0)
    8000356e:	853e                	mv	a0,a5
    80003570:	ffffe097          	auipc	ra,0xffffe
    80003574:	d6c080e7          	jalr	-660(ra) # 800012dc <release>
      return 0;
    80003578:	4781                	li	a5,0
    8000357a:	a03d                	j	800035a8 <kill+0x96>
    }
    release(&p->lock);
    8000357c:	fe843783          	ld	a5,-24(s0)
    80003580:	853e                	mv	a0,a5
    80003582:	ffffe097          	auipc	ra,0xffffe
    80003586:	d5a080e7          	jalr	-678(ra) # 800012dc <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000358a:	fe843783          	ld	a5,-24(s0)
    8000358e:	16878793          	addi	a5,a5,360
    80003592:	fef43423          	sd	a5,-24(s0)
    80003596:	fe843703          	ld	a4,-24(s0)
    8000359a:	00016797          	auipc	a5,0x16
    8000359e:	40e78793          	addi	a5,a5,1038 # 800199a8 <pid_lock>
    800035a2:	f8f766e3          	bltu	a4,a5,8000352e <kill+0x1c>
  }
  return -1;
    800035a6:	57fd                	li	a5,-1
}
    800035a8:	853e                	mv	a0,a5
    800035aa:	70a2                	ld	ra,40(sp)
    800035ac:	7402                	ld	s0,32(sp)
    800035ae:	6145                	addi	sp,sp,48
    800035b0:	8082                	ret

00000000800035b2 <setkilled>:

void
setkilled(struct proc *p)
{
    800035b2:	1101                	addi	sp,sp,-32
    800035b4:	ec06                	sd	ra,24(sp)
    800035b6:	e822                	sd	s0,16(sp)
    800035b8:	1000                	addi	s0,sp,32
    800035ba:	fea43423          	sd	a0,-24(s0)
  acquire(&p->lock);
    800035be:	fe843783          	ld	a5,-24(s0)
    800035c2:	853e                	mv	a0,a5
    800035c4:	ffffe097          	auipc	ra,0xffffe
    800035c8:	cb4080e7          	jalr	-844(ra) # 80001278 <acquire>
  p->killed = 1;
    800035cc:	fe843783          	ld	a5,-24(s0)
    800035d0:	4705                	li	a4,1
    800035d2:	d798                	sw	a4,40(a5)
  release(&p->lock);
    800035d4:	fe843783          	ld	a5,-24(s0)
    800035d8:	853e                	mv	a0,a5
    800035da:	ffffe097          	auipc	ra,0xffffe
    800035de:	d02080e7          	jalr	-766(ra) # 800012dc <release>
}
    800035e2:	0001                	nop
    800035e4:	60e2                	ld	ra,24(sp)
    800035e6:	6442                	ld	s0,16(sp)
    800035e8:	6105                	addi	sp,sp,32
    800035ea:	8082                	ret

00000000800035ec <killed>:

int
killed(struct proc *p)
{
    800035ec:	7179                	addi	sp,sp,-48
    800035ee:	f406                	sd	ra,40(sp)
    800035f0:	f022                	sd	s0,32(sp)
    800035f2:	1800                	addi	s0,sp,48
    800035f4:	fca43c23          	sd	a0,-40(s0)
  int k;
  
  acquire(&p->lock);
    800035f8:	fd843783          	ld	a5,-40(s0)
    800035fc:	853e                	mv	a0,a5
    800035fe:	ffffe097          	auipc	ra,0xffffe
    80003602:	c7a080e7          	jalr	-902(ra) # 80001278 <acquire>
  k = p->killed;
    80003606:	fd843783          	ld	a5,-40(s0)
    8000360a:	579c                	lw	a5,40(a5)
    8000360c:	fef42623          	sw	a5,-20(s0)
  release(&p->lock);
    80003610:	fd843783          	ld	a5,-40(s0)
    80003614:	853e                	mv	a0,a5
    80003616:	ffffe097          	auipc	ra,0xffffe
    8000361a:	cc6080e7          	jalr	-826(ra) # 800012dc <release>
  return k;
    8000361e:	fec42783          	lw	a5,-20(s0)
}
    80003622:	853e                	mv	a0,a5
    80003624:	70a2                	ld	ra,40(sp)
    80003626:	7402                	ld	s0,32(sp)
    80003628:	6145                	addi	sp,sp,48
    8000362a:	8082                	ret

000000008000362c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000362c:	7139                	addi	sp,sp,-64
    8000362e:	fc06                	sd	ra,56(sp)
    80003630:	f822                	sd	s0,48(sp)
    80003632:	0080                	addi	s0,sp,64
    80003634:	87aa                	mv	a5,a0
    80003636:	fcb43823          	sd	a1,-48(s0)
    8000363a:	fcc43423          	sd	a2,-56(s0)
    8000363e:	fcd43023          	sd	a3,-64(s0)
    80003642:	fcf42e23          	sw	a5,-36(s0)
  struct proc *p = myproc();
    80003646:	fffff097          	auipc	ra,0xfffff
    8000364a:	1fa080e7          	jalr	506(ra) # 80002840 <myproc>
    8000364e:	fea43423          	sd	a0,-24(s0)
  if(user_dst){
    80003652:	fdc42783          	lw	a5,-36(s0)
    80003656:	2781                	sext.w	a5,a5
    80003658:	c38d                	beqz	a5,8000367a <either_copyout+0x4e>
    return copyout(p->pagetable, dst, src, len);
    8000365a:	fe843783          	ld	a5,-24(s0)
    8000365e:	6bbc                	ld	a5,80(a5)
    80003660:	fc043683          	ld	a3,-64(s0)
    80003664:	fc843603          	ld	a2,-56(s0)
    80003668:	fd043583          	ld	a1,-48(s0)
    8000366c:	853e                	mv	a0,a5
    8000366e:	fffff097          	auipc	ra,0xfffff
    80003672:	c9c080e7          	jalr	-868(ra) # 8000230a <copyout>
    80003676:	87aa                	mv	a5,a0
    80003678:	a839                	j	80003696 <either_copyout+0x6a>
  } else {
    memmove((char *)dst, src, len);
    8000367a:	fd043783          	ld	a5,-48(s0)
    8000367e:	fc043703          	ld	a4,-64(s0)
    80003682:	2701                	sext.w	a4,a4
    80003684:	863a                	mv	a2,a4
    80003686:	fc843583          	ld	a1,-56(s0)
    8000368a:	853e                	mv	a0,a5
    8000368c:	ffffe097          	auipc	ra,0xffffe
    80003690:	ea4080e7          	jalr	-348(ra) # 80001530 <memmove>
    return 0;
    80003694:	4781                	li	a5,0
  }
}
    80003696:	853e                	mv	a0,a5
    80003698:	70e2                	ld	ra,56(sp)
    8000369a:	7442                	ld	s0,48(sp)
    8000369c:	6121                	addi	sp,sp,64
    8000369e:	8082                	ret

00000000800036a0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800036a0:	7139                	addi	sp,sp,-64
    800036a2:	fc06                	sd	ra,56(sp)
    800036a4:	f822                	sd	s0,48(sp)
    800036a6:	0080                	addi	s0,sp,64
    800036a8:	fca43c23          	sd	a0,-40(s0)
    800036ac:	87ae                	mv	a5,a1
    800036ae:	fcc43423          	sd	a2,-56(s0)
    800036b2:	fcd43023          	sd	a3,-64(s0)
    800036b6:	fcf42a23          	sw	a5,-44(s0)
  struct proc *p = myproc();
    800036ba:	fffff097          	auipc	ra,0xfffff
    800036be:	186080e7          	jalr	390(ra) # 80002840 <myproc>
    800036c2:	fea43423          	sd	a0,-24(s0)
  if(user_src){
    800036c6:	fd442783          	lw	a5,-44(s0)
    800036ca:	2781                	sext.w	a5,a5
    800036cc:	c38d                	beqz	a5,800036ee <either_copyin+0x4e>
    return copyin(p->pagetable, dst, src, len);
    800036ce:	fe843783          	ld	a5,-24(s0)
    800036d2:	6bbc                	ld	a5,80(a5)
    800036d4:	fc043683          	ld	a3,-64(s0)
    800036d8:	fc843603          	ld	a2,-56(s0)
    800036dc:	fd843583          	ld	a1,-40(s0)
    800036e0:	853e                	mv	a0,a5
    800036e2:	fffff097          	auipc	ra,0xfffff
    800036e6:	cf6080e7          	jalr	-778(ra) # 800023d8 <copyin>
    800036ea:	87aa                	mv	a5,a0
    800036ec:	a839                	j	8000370a <either_copyin+0x6a>
  } else {
    memmove(dst, (char*)src, len);
    800036ee:	fc843783          	ld	a5,-56(s0)
    800036f2:	fc043703          	ld	a4,-64(s0)
    800036f6:	2701                	sext.w	a4,a4
    800036f8:	863a                	mv	a2,a4
    800036fa:	85be                	mv	a1,a5
    800036fc:	fd843503          	ld	a0,-40(s0)
    80003700:	ffffe097          	auipc	ra,0xffffe
    80003704:	e30080e7          	jalr	-464(ra) # 80001530 <memmove>
    return 0;
    80003708:	4781                	li	a5,0
  }
}
    8000370a:	853e                	mv	a0,a5
    8000370c:	70e2                	ld	ra,56(sp)
    8000370e:	7442                	ld	s0,48(sp)
    80003710:	6121                	addi	sp,sp,64
    80003712:	8082                	ret

0000000080003714 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80003714:	1101                	addi	sp,sp,-32
    80003716:	ec06                	sd	ra,24(sp)
    80003718:	e822                	sd	s0,16(sp)
    8000371a:	1000                	addi	s0,sp,32
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000371c:	00008517          	auipc	a0,0x8
    80003720:	b4c50513          	addi	a0,a0,-1204 # 8000b268 <etext+0x268>
    80003724:	ffffd097          	auipc	ra,0xffffd
    80003728:	310080e7          	jalr	784(ra) # 80000a34 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000372c:	00011797          	auipc	a5,0x11
    80003730:	87c78793          	addi	a5,a5,-1924 # 80013fa8 <proc>
    80003734:	fef43423          	sd	a5,-24(s0)
    80003738:	a04d                	j	800037da <procdump+0xc6>
    if(p->state == UNUSED)
    8000373a:	fe843783          	ld	a5,-24(s0)
    8000373e:	4f9c                	lw	a5,24(a5)
    80003740:	c7d1                	beqz	a5,800037cc <procdump+0xb8>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80003742:	fe843783          	ld	a5,-24(s0)
    80003746:	4f9c                	lw	a5,24(a5)
    80003748:	873e                	mv	a4,a5
    8000374a:	4795                	li	a5,5
    8000374c:	02e7ee63          	bltu	a5,a4,80003788 <procdump+0x74>
    80003750:	fe843783          	ld	a5,-24(s0)
    80003754:	4f9c                	lw	a5,24(a5)
    80003756:	00008717          	auipc	a4,0x8
    8000375a:	09a70713          	addi	a4,a4,154 # 8000b7f0 <states.0>
    8000375e:	1782                	slli	a5,a5,0x20
    80003760:	9381                	srli	a5,a5,0x20
    80003762:	078e                	slli	a5,a5,0x3
    80003764:	97ba                	add	a5,a5,a4
    80003766:	639c                	ld	a5,0(a5)
    80003768:	c385                	beqz	a5,80003788 <procdump+0x74>
      state = states[p->state];
    8000376a:	fe843783          	ld	a5,-24(s0)
    8000376e:	4f9c                	lw	a5,24(a5)
    80003770:	00008717          	auipc	a4,0x8
    80003774:	08070713          	addi	a4,a4,128 # 8000b7f0 <states.0>
    80003778:	1782                	slli	a5,a5,0x20
    8000377a:	9381                	srli	a5,a5,0x20
    8000377c:	078e                	slli	a5,a5,0x3
    8000377e:	97ba                	add	a5,a5,a4
    80003780:	639c                	ld	a5,0(a5)
    80003782:	fef43023          	sd	a5,-32(s0)
    80003786:	a039                	j	80003794 <procdump+0x80>
    else
      state = "???";
    80003788:	00008797          	auipc	a5,0x8
    8000378c:	ae878793          	addi	a5,a5,-1304 # 8000b270 <etext+0x270>
    80003790:	fef43023          	sd	a5,-32(s0)
    printf("%d %s %s", p->pid, state, p->name);
    80003794:	fe843783          	ld	a5,-24(s0)
    80003798:	5b98                	lw	a4,48(a5)
    8000379a:	fe843783          	ld	a5,-24(s0)
    8000379e:	15878793          	addi	a5,a5,344
    800037a2:	86be                	mv	a3,a5
    800037a4:	fe043603          	ld	a2,-32(s0)
    800037a8:	85ba                	mv	a1,a4
    800037aa:	00008517          	auipc	a0,0x8
    800037ae:	ace50513          	addi	a0,a0,-1330 # 8000b278 <etext+0x278>
    800037b2:	ffffd097          	auipc	ra,0xffffd
    800037b6:	282080e7          	jalr	642(ra) # 80000a34 <printf>
    printf("\n");
    800037ba:	00008517          	auipc	a0,0x8
    800037be:	aae50513          	addi	a0,a0,-1362 # 8000b268 <etext+0x268>
    800037c2:	ffffd097          	auipc	ra,0xffffd
    800037c6:	272080e7          	jalr	626(ra) # 80000a34 <printf>
    800037ca:	a011                	j	800037ce <procdump+0xba>
      continue;
    800037cc:	0001                	nop
  for(p = proc; p < &proc[NPROC]; p++){
    800037ce:	fe843783          	ld	a5,-24(s0)
    800037d2:	16878793          	addi	a5,a5,360
    800037d6:	fef43423          	sd	a5,-24(s0)
    800037da:	fe843703          	ld	a4,-24(s0)
    800037de:	00016797          	auipc	a5,0x16
    800037e2:	1ca78793          	addi	a5,a5,458 # 800199a8 <pid_lock>
    800037e6:	f4f76ae3          	bltu	a4,a5,8000373a <procdump+0x26>
  }
}
    800037ea:	0001                	nop
    800037ec:	0001                	nop
    800037ee:	60e2                	ld	ra,24(sp)
    800037f0:	6442                	ld	s0,16(sp)
    800037f2:	6105                	addi	sp,sp,32
    800037f4:	8082                	ret

00000000800037f6 <ps>:

int
ps()
{
    800037f6:	1101                	addi	sp,sp,-32
    800037f8:	ec06                	sd	ra,24(sp)
    800037fa:	e822                	sd	s0,16(sp)
    800037fc:	1000                	addi	s0,sp,32
  for(struct proc* p = proc; p < &proc[NPROC]; p++){
    800037fe:	00010797          	auipc	a5,0x10
    80003802:	7aa78793          	addi	a5,a5,1962 # 80013fa8 <proc>
    80003806:	fef43423          	sd	a5,-24(s0)
    8000380a:	a0ad                	j	80003874 <ps+0x7e>
    acquire(&p->lock);
    8000380c:	fe843783          	ld	a5,-24(s0)
    80003810:	853e                	mv	a0,a5
    80003812:	ffffe097          	auipc	ra,0xffffe
    80003816:	a66080e7          	jalr	-1434(ra) # 80001278 <acquire>
    if(p->state == UNUSED) {
    8000381a:	fe843783          	ld	a5,-24(s0)
    8000381e:	4f9c                	lw	a5,24(a5)
    80003820:	eb89                	bnez	a5,80003832 <ps+0x3c>
      release(&p->lock);
    80003822:	fe843783          	ld	a5,-24(s0)
    80003826:	853e                	mv	a0,a5
    80003828:	ffffe097          	auipc	ra,0xffffe
    8000382c:	ab4080e7          	jalr	-1356(ra) # 800012dc <release>
      continue;
    80003830:	a825                	j	80003868 <ps+0x72>
    }
    printf("%s (%d): %d\n", p->name, p->pid, p->state);
    80003832:	fe843783          	ld	a5,-24(s0)
    80003836:	15878713          	addi	a4,a5,344
    8000383a:	fe843783          	ld	a5,-24(s0)
    8000383e:	5b90                	lw	a2,48(a5)
    80003840:	fe843783          	ld	a5,-24(s0)
    80003844:	4f9c                	lw	a5,24(a5)
    80003846:	86be                	mv	a3,a5
    80003848:	85ba                	mv	a1,a4
    8000384a:	00008517          	auipc	a0,0x8
    8000384e:	a3e50513          	addi	a0,a0,-1474 # 8000b288 <etext+0x288>
    80003852:	ffffd097          	auipc	ra,0xffffd
    80003856:	1e2080e7          	jalr	482(ra) # 80000a34 <printf>
    release(&p->lock);
    8000385a:	fe843783          	ld	a5,-24(s0)
    8000385e:	853e                	mv	a0,a5
    80003860:	ffffe097          	auipc	ra,0xffffe
    80003864:	a7c080e7          	jalr	-1412(ra) # 800012dc <release>
  for(struct proc* p = proc; p < &proc[NPROC]; p++){
    80003868:	fe843783          	ld	a5,-24(s0)
    8000386c:	16878793          	addi	a5,a5,360
    80003870:	fef43423          	sd	a5,-24(s0)
    80003874:	fe843703          	ld	a4,-24(s0)
    80003878:	00016797          	auipc	a5,0x16
    8000387c:	13078793          	addi	a5,a5,304 # 800199a8 <pid_lock>
    80003880:	f8f766e3          	bltu	a4,a5,8000380c <ps+0x16>
  }
  return 0;
    80003884:	4781                	li	a5,0
}
    80003886:	853e                	mv	a0,a5
    80003888:	60e2                	ld	ra,24(sp)
    8000388a:	6442                	ld	s0,16(sp)
    8000388c:	6105                	addi	sp,sp,32
    8000388e:	8082                	ret

0000000080003890 <printnode>:
  struct proc *p;
};

void
printnode(int index, int indent, struct treenode* nodes)
{
    80003890:	7139                	addi	sp,sp,-64
    80003892:	fc06                	sd	ra,56(sp)
    80003894:	f822                	sd	s0,48(sp)
    80003896:	0080                	addi	s0,sp,64
    80003898:	87aa                	mv	a5,a0
    8000389a:	872e                	mv	a4,a1
    8000389c:	fcc43023          	sd	a2,-64(s0)
    800038a0:	fcf42623          	sw	a5,-52(s0)
    800038a4:	87ba                	mv	a5,a4
    800038a6:	fcf42423          	sw	a5,-56(s0)
  for(int i = 0; i < (indent-1)*2; i++) {
    800038aa:	fe042623          	sw	zero,-20(s0)
    800038ae:	a831                	j	800038ca <printnode+0x3a>
    printf(" ");
    800038b0:	00008517          	auipc	a0,0x8
    800038b4:	9e850513          	addi	a0,a0,-1560 # 8000b298 <etext+0x298>
    800038b8:	ffffd097          	auipc	ra,0xffffd
    800038bc:	17c080e7          	jalr	380(ra) # 80000a34 <printf>
  for(int i = 0; i < (indent-1)*2; i++) {
    800038c0:	fec42783          	lw	a5,-20(s0)
    800038c4:	2785                	addiw	a5,a5,1
    800038c6:	fef42623          	sw	a5,-20(s0)
    800038ca:	fc842783          	lw	a5,-56(s0)
    800038ce:	37fd                	addiw	a5,a5,-1
    800038d0:	2781                	sext.w	a5,a5
    800038d2:	0017979b          	slliw	a5,a5,0x1
    800038d6:	0007871b          	sext.w	a4,a5
    800038da:	fec42783          	lw	a5,-20(s0)
    800038de:	2781                	sext.w	a5,a5
    800038e0:	fce7c8e3          	blt	a5,a4,800038b0 <printnode+0x20>
  }
  if(indent > 0) {
    800038e4:	fc842783          	lw	a5,-56(s0)
    800038e8:	2781                	sext.w	a5,a5
    800038ea:	00f05a63          	blez	a5,800038fe <printnode+0x6e>
    printf("|-");
    800038ee:	00008517          	auipc	a0,0x8
    800038f2:	9b250513          	addi	a0,a0,-1614 # 8000b2a0 <etext+0x2a0>
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	13e080e7          	jalr	318(ra) # 80000a34 <printf>
  }
  const struct treenode *node = nodes + index;
    800038fe:	fcc42703          	lw	a4,-52(s0)
    80003902:	87ba                	mv	a5,a4
    80003904:	078e                	slli	a5,a5,0x3
    80003906:	97ba                	add	a5,a5,a4
    80003908:	0796                	slli	a5,a5,0x5
    8000390a:	873e                	mv	a4,a5
    8000390c:	fc043783          	ld	a5,-64(s0)
    80003910:	97ba                	add	a5,a5,a4
    80003912:	fef43023          	sd	a5,-32(s0)
  struct proc *p = node->p;
    80003916:	fe043783          	ld	a5,-32(s0)
    8000391a:	1187b783          	ld	a5,280(a5)
    8000391e:	fcf43c23          	sd	a5,-40(s0)

  acquire(&p->lock);
    80003922:	fd843783          	ld	a5,-40(s0)
    80003926:	853e                	mv	a0,a5
    80003928:	ffffe097          	auipc	ra,0xffffe
    8000392c:	950080e7          	jalr	-1712(ra) # 80001278 <acquire>
  printf("%s (%d): %d\n", p->name, p->pid, p->state);
    80003930:	fd843783          	ld	a5,-40(s0)
    80003934:	15878713          	addi	a4,a5,344
    80003938:	fd843783          	ld	a5,-40(s0)
    8000393c:	5b90                	lw	a2,48(a5)
    8000393e:	fd843783          	ld	a5,-40(s0)
    80003942:	4f9c                	lw	a5,24(a5)
    80003944:	86be                	mv	a3,a5
    80003946:	85ba                	mv	a1,a4
    80003948:	00008517          	auipc	a0,0x8
    8000394c:	94050513          	addi	a0,a0,-1728 # 8000b288 <etext+0x288>
    80003950:	ffffd097          	auipc	ra,0xffffd
    80003954:	0e4080e7          	jalr	228(ra) # 80000a34 <printf>
  release(&p->lock);
    80003958:	fd843783          	ld	a5,-40(s0)
    8000395c:	853e                	mv	a0,a5
    8000395e:	ffffe097          	auipc	ra,0xffffe
    80003962:	97e080e7          	jalr	-1666(ra) # 800012dc <release>

  for(int i = 0; i < node->index; i++) {
    80003966:	fe042423          	sw	zero,-24(s0)
    8000396a:	a815                	j	8000399e <printnode+0x10e>
    printnode(node->children[i], indent + 1, nodes);
    8000396c:	fe043703          	ld	a4,-32(s0)
    80003970:	fe842783          	lw	a5,-24(s0)
    80003974:	0791                	addi	a5,a5,4
    80003976:	078a                	slli	a5,a5,0x2
    80003978:	97ba                	add	a5,a5,a4
    8000397a:	439c                	lw	a5,0(a5)
    8000397c:	fc842703          	lw	a4,-56(s0)
    80003980:	2705                	addiw	a4,a4,1
    80003982:	2701                	sext.w	a4,a4
    80003984:	fc043603          	ld	a2,-64(s0)
    80003988:	85ba                	mv	a1,a4
    8000398a:	853e                	mv	a0,a5
    8000398c:	00000097          	auipc	ra,0x0
    80003990:	f04080e7          	jalr	-252(ra) # 80003890 <printnode>
  for(int i = 0; i < node->index; i++) {
    80003994:	fe842783          	lw	a5,-24(s0)
    80003998:	2785                	addiw	a5,a5,1
    8000399a:	fef42423          	sw	a5,-24(s0)
    8000399e:	fe043783          	ld	a5,-32(s0)
    800039a2:	47d8                	lw	a4,12(a5)
    800039a4:	fe842783          	lw	a5,-24(s0)
    800039a8:	2781                	sext.w	a5,a5
    800039aa:	fce7c1e3          	blt	a5,a4,8000396c <printnode+0xdc>
  }
}
    800039ae:	0001                	nop
    800039b0:	0001                	nop
    800039b2:	70e2                	ld	ra,56(sp)
    800039b4:	7442                	ld	s0,48(sp)
    800039b6:	6121                	addi	sp,sp,64
    800039b8:	8082                	ret

00000000800039ba <proctree>:

int
proctree()
{
    800039ba:	715d                	addi	sp,sp,-80
    800039bc:	e486                	sd	ra,72(sp)
    800039be:	e0a2                	sd	s0,64(sp)
    800039c0:	0880                	addi	s0,sp,80
  struct treenode *nodes = (struct treenode*) kalloc();
    800039c2:	ffffd097          	auipc	ra,0xffffd
    800039c6:	762080e7          	jalr	1890(ra) # 80001124 <kalloc>
    800039ca:	fca43823          	sd	a0,-48(s0)
  memset(nodes, 0, PGSIZE);
    800039ce:	6605                	lui	a2,0x1
    800039d0:	4581                	li	a1,0
    800039d2:	fd043503          	ld	a0,-48(s0)
    800039d6:	ffffe097          	auipc	ra,0xffffe
    800039da:	a76080e7          	jalr	-1418(ra) # 8000144c <memset>
  int root;

  acquire(&wait_lock);
    800039de:	00016517          	auipc	a0,0x16
    800039e2:	fe250513          	addi	a0,a0,-30 # 800199c0 <wait_lock>
    800039e6:	ffffe097          	auipc	ra,0xffffe
    800039ea:	892080e7          	jalr	-1902(ra) # 80001278 <acquire>
  for(int i = 0; i < NPROC; i++) {
    800039ee:	fe042423          	sw	zero,-24(s0)
    800039f2:	a8ed                	j	80003aec <proctree+0x132>
    struct treenode *node = nodes + i;
    800039f4:	fe842703          	lw	a4,-24(s0)
    800039f8:	87ba                	mv	a5,a4
    800039fa:	078e                	slli	a5,a5,0x3
    800039fc:	97ba                	add	a5,a5,a4
    800039fe:	0796                	slli	a5,a5,0x5
    80003a00:	873e                	mv	a4,a5
    80003a02:	fd043783          	ld	a5,-48(s0)
    80003a06:	97ba                	add	a5,a5,a4
    80003a08:	fcf43423          	sd	a5,-56(s0)
    if(node->inited) {
    80003a0c:	fc843783          	ld	a5,-56(s0)
    80003a10:	1107c783          	lbu	a5,272(a5)
    80003a14:	e7f1                	bnez	a5,80003ae0 <proctree+0x126>
      continue;
    }

    struct proc* p = proc + i;
    80003a16:	fe842703          	lw	a4,-24(s0)
    80003a1a:	16800793          	li	a5,360
    80003a1e:	02f70733          	mul	a4,a4,a5
    80003a22:	00010797          	auipc	a5,0x10
    80003a26:	58678793          	addi	a5,a5,1414 # 80013fa8 <proc>
    80003a2a:	97ba                	add	a5,a5,a4
    80003a2c:	fcf43023          	sd	a5,-64(s0)
    acquire(&p->lock);
    80003a30:	fc043783          	ld	a5,-64(s0)
    80003a34:	853e                	mv	a0,a5
    80003a36:	ffffe097          	auipc	ra,0xffffe
    80003a3a:	842080e7          	jalr	-1982(ra) # 80001278 <acquire>
    if(p->state == UNUSED) {
    80003a3e:	fc043783          	ld	a5,-64(s0)
    80003a42:	4f9c                	lw	a5,24(a5)
    80003a44:	eb89                	bnez	a5,80003a56 <proctree+0x9c>
      release(&p->lock);
    80003a46:	fc043783          	ld	a5,-64(s0)
    80003a4a:	853e                	mv	a0,a5
    80003a4c:	ffffe097          	auipc	ra,0xffffe
    80003a50:	890080e7          	jalr	-1904(ra) # 800012dc <release>
      continue;
    80003a54:	a079                	j	80003ae2 <proctree+0x128>
    }

    node->inited = 1;
    80003a56:	fc843783          	ld	a5,-56(s0)
    80003a5a:	4705                	li	a4,1
    80003a5c:	10e78823          	sb	a4,272(a5)
    node->nodeIndex = i;
    80003a60:	fc843783          	ld	a5,-56(s0)
    80003a64:	fe842703          	lw	a4,-24(s0)
    80003a68:	c798                	sw	a4,8(a5)
    node->pid = p->pid;
    80003a6a:	fc043783          	ld	a5,-64(s0)
    80003a6e:	5b98                	lw	a4,48(a5)
    80003a70:	fc843783          	ld	a5,-56(s0)
    80003a74:	c398                	sw	a4,0(a5)
    node->p = p;
    80003a76:	fc843783          	ld	a5,-56(s0)
    80003a7a:	fc043703          	ld	a4,-64(s0)
    80003a7e:	10e7bc23          	sd	a4,280(a5)
    
    struct proc* parent = p->parent;
    80003a82:	fc043783          	ld	a5,-64(s0)
    80003a86:	7f9c                	ld	a5,56(a5)
    80003a88:	faf43c23          	sd	a5,-72(s0)
    release(&p->lock);
    80003a8c:	fc043783          	ld	a5,-64(s0)
    80003a90:	853e                	mv	a0,a5
    80003a92:	ffffe097          	auipc	ra,0xffffe
    80003a96:	84a080e7          	jalr	-1974(ra) # 800012dc <release>

    if (parent==0) {
    80003a9a:	fb843783          	ld	a5,-72(s0)
    80003a9e:	ef81                	bnez	a5,80003ab6 <proctree+0xfc>
      root = i;
    80003aa0:	fe842783          	lw	a5,-24(s0)
    80003aa4:	fef42623          	sw	a5,-20(s0)
      node->parentPid = node->pid;
    80003aa8:	fc843783          	ld	a5,-56(s0)
    80003aac:	4398                	lw	a4,0(a5)
    80003aae:	fc843783          	ld	a5,-56(s0)
    80003ab2:	c3d8                	sw	a4,4(a5)
      continue;
    80003ab4:	a03d                	j	80003ae2 <proctree+0x128>
    }

    acquire(&parent->lock);
    80003ab6:	fb843783          	ld	a5,-72(s0)
    80003aba:	853e                	mv	a0,a5
    80003abc:	ffffd097          	auipc	ra,0xffffd
    80003ac0:	7bc080e7          	jalr	1980(ra) # 80001278 <acquire>
    node->parentPid = parent->pid;
    80003ac4:	fb843783          	ld	a5,-72(s0)
    80003ac8:	5b98                	lw	a4,48(a5)
    80003aca:	fc843783          	ld	a5,-56(s0)
    80003ace:	c3d8                	sw	a4,4(a5)
    release(&parent->lock);
    80003ad0:	fb843783          	ld	a5,-72(s0)
    80003ad4:	853e                	mv	a0,a5
    80003ad6:	ffffe097          	auipc	ra,0xffffe
    80003ada:	806080e7          	jalr	-2042(ra) # 800012dc <release>
    80003ade:	a011                	j	80003ae2 <proctree+0x128>
      continue;
    80003ae0:	0001                	nop
  for(int i = 0; i < NPROC; i++) {
    80003ae2:	fe842783          	lw	a5,-24(s0)
    80003ae6:	2785                	addiw	a5,a5,1
    80003ae8:	fef42423          	sw	a5,-24(s0)
    80003aec:	fe842783          	lw	a5,-24(s0)
    80003af0:	0007871b          	sext.w	a4,a5
    80003af4:	03f00793          	li	a5,63
    80003af8:	eee7dee3          	bge	a5,a4,800039f4 <proctree+0x3a>
  }
  release(&wait_lock);
    80003afc:	00016517          	auipc	a0,0x16
    80003b00:	ec450513          	addi	a0,a0,-316 # 800199c0 <wait_lock>
    80003b04:	ffffd097          	auipc	ra,0xffffd
    80003b08:	7d8080e7          	jalr	2008(ra) # 800012dc <release>

  for(struct treenode *node = nodes; node < &nodes[NPROC]; node++) {
    80003b0c:	fd043783          	ld	a5,-48(s0)
    80003b10:	fef43023          	sd	a5,-32(s0)
    80003b14:	a061                	j	80003b9c <proctree+0x1e2>
    if(node->pid == node->parentPid) {
    80003b16:	fe043783          	ld	a5,-32(s0)
    80003b1a:	4398                	lw	a4,0(a5)
    80003b1c:	fe043783          	ld	a5,-32(s0)
    80003b20:	43dc                	lw	a5,4(a5)
    80003b22:	06f70663          	beq	a4,a5,80003b8e <proctree+0x1d4>
      continue;
    }
    for(struct treenode *parent = nodes; parent < &nodes[NPROC]; parent++) {
    80003b26:	fd043783          	ld	a5,-48(s0)
    80003b2a:	fcf43c23          	sd	a5,-40(s0)
    80003b2e:	a0a9                	j	80003b78 <proctree+0x1be>
      if(node->parentPid == parent->pid) {
    80003b30:	fe043783          	ld	a5,-32(s0)
    80003b34:	43d8                	lw	a4,4(a5)
    80003b36:	fd843783          	ld	a5,-40(s0)
    80003b3a:	439c                	lw	a5,0(a5)
    80003b3c:	02f71863          	bne	a4,a5,80003b6c <proctree+0x1b2>
	parent->children[parent->index] = node->nodeIndex;
    80003b40:	fd843783          	ld	a5,-40(s0)
    80003b44:	47dc                	lw	a5,12(a5)
    80003b46:	fe043703          	ld	a4,-32(s0)
    80003b4a:	4718                	lw	a4,8(a4)
    80003b4c:	fd843683          	ld	a3,-40(s0)
    80003b50:	0791                	addi	a5,a5,4
    80003b52:	078a                	slli	a5,a5,0x2
    80003b54:	97b6                	add	a5,a5,a3
    80003b56:	c398                	sw	a4,0(a5)
	parent->index++;
    80003b58:	fd843783          	ld	a5,-40(s0)
    80003b5c:	47dc                	lw	a5,12(a5)
    80003b5e:	2785                	addiw	a5,a5,1
    80003b60:	0007871b          	sext.w	a4,a5
    80003b64:	fd843783          	ld	a5,-40(s0)
    80003b68:	c7d8                	sw	a4,12(a5)
	break;
    80003b6a:	a01d                	j	80003b90 <proctree+0x1d6>
    for(struct treenode *parent = nodes; parent < &nodes[NPROC]; parent++) {
    80003b6c:	fd843783          	ld	a5,-40(s0)
    80003b70:	12078793          	addi	a5,a5,288
    80003b74:	fcf43c23          	sd	a5,-40(s0)
    80003b78:	fd043703          	ld	a4,-48(s0)
    80003b7c:	6795                	lui	a5,0x5
    80003b7e:	80078793          	addi	a5,a5,-2048 # 4800 <_entry-0x7fffb800>
    80003b82:	97ba                	add	a5,a5,a4
    80003b84:	fd843703          	ld	a4,-40(s0)
    80003b88:	faf764e3          	bltu	a4,a5,80003b30 <proctree+0x176>
    80003b8c:	a011                	j	80003b90 <proctree+0x1d6>
      continue;
    80003b8e:	0001                	nop
  for(struct treenode *node = nodes; node < &nodes[NPROC]; node++) {
    80003b90:	fe043783          	ld	a5,-32(s0)
    80003b94:	12078793          	addi	a5,a5,288
    80003b98:	fef43023          	sd	a5,-32(s0)
    80003b9c:	fd043703          	ld	a4,-48(s0)
    80003ba0:	6795                	lui	a5,0x5
    80003ba2:	80078793          	addi	a5,a5,-2048 # 4800 <_entry-0x7fffb800>
    80003ba6:	97ba                	add	a5,a5,a4
    80003ba8:	fe043703          	ld	a4,-32(s0)
    80003bac:	f6f765e3          	bltu	a4,a5,80003b16 <proctree+0x15c>
      }
    }
  }

  printnode(root, 0, nodes);
    80003bb0:	fec42783          	lw	a5,-20(s0)
    80003bb4:	fd043603          	ld	a2,-48(s0)
    80003bb8:	4581                	li	a1,0
    80003bba:	853e                	mv	a0,a5
    80003bbc:	00000097          	auipc	ra,0x0
    80003bc0:	cd4080e7          	jalr	-812(ra) # 80003890 <printnode>
  kfree((void *)nodes);
    80003bc4:	fd043503          	ld	a0,-48(s0)
    80003bc8:	ffffd097          	auipc	ra,0xffffd
    80003bcc:	4b8080e7          	jalr	1208(ra) # 80001080 <kfree>

  return 0;
    80003bd0:	4781                	li	a5,0
}
    80003bd2:	853e                	mv	a0,a5
    80003bd4:	60a6                	ld	ra,72(sp)
    80003bd6:	6406                	ld	s0,64(sp)
    80003bd8:	6161                	addi	sp,sp,80
    80003bda:	8082                	ret

0000000080003bdc <swtch>:
    80003bdc:	00153023          	sd	ra,0(a0)
    80003be0:	00253423          	sd	sp,8(a0)
    80003be4:	e900                	sd	s0,16(a0)
    80003be6:	ed04                	sd	s1,24(a0)
    80003be8:	03253023          	sd	s2,32(a0)
    80003bec:	03353423          	sd	s3,40(a0)
    80003bf0:	03453823          	sd	s4,48(a0)
    80003bf4:	03553c23          	sd	s5,56(a0)
    80003bf8:	05653023          	sd	s6,64(a0)
    80003bfc:	05753423          	sd	s7,72(a0)
    80003c00:	05853823          	sd	s8,80(a0)
    80003c04:	05953c23          	sd	s9,88(a0)
    80003c08:	07a53023          	sd	s10,96(a0)
    80003c0c:	07b53423          	sd	s11,104(a0)
    80003c10:	0005b083          	ld	ra,0(a1)
    80003c14:	0085b103          	ld	sp,8(a1)
    80003c18:	6980                	ld	s0,16(a1)
    80003c1a:	6d84                	ld	s1,24(a1)
    80003c1c:	0205b903          	ld	s2,32(a1)
    80003c20:	0285b983          	ld	s3,40(a1)
    80003c24:	0305ba03          	ld	s4,48(a1)
    80003c28:	0385ba83          	ld	s5,56(a1)
    80003c2c:	0405bb03          	ld	s6,64(a1)
    80003c30:	0485bb83          	ld	s7,72(a1)
    80003c34:	0505bc03          	ld	s8,80(a1)
    80003c38:	0585bc83          	ld	s9,88(a1)
    80003c3c:	0605bd03          	ld	s10,96(a1)
    80003c40:	0685bd83          	ld	s11,104(a1)
    80003c44:	8082                	ret

0000000080003c46 <r_sstatus>:
{
    80003c46:	1101                	addi	sp,sp,-32
    80003c48:	ec22                	sd	s0,24(sp)
    80003c4a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003c4c:	100027f3          	csrr	a5,sstatus
    80003c50:	fef43423          	sd	a5,-24(s0)
  return x;
    80003c54:	fe843783          	ld	a5,-24(s0)
}
    80003c58:	853e                	mv	a0,a5
    80003c5a:	6462                	ld	s0,24(sp)
    80003c5c:	6105                	addi	sp,sp,32
    80003c5e:	8082                	ret

0000000080003c60 <w_sstatus>:
{
    80003c60:	1101                	addi	sp,sp,-32
    80003c62:	ec22                	sd	s0,24(sp)
    80003c64:	1000                	addi	s0,sp,32
    80003c66:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80003c6a:	fe843783          	ld	a5,-24(s0)
    80003c6e:	10079073          	csrw	sstatus,a5
}
    80003c72:	0001                	nop
    80003c74:	6462                	ld	s0,24(sp)
    80003c76:	6105                	addi	sp,sp,32
    80003c78:	8082                	ret

0000000080003c7a <r_sip>:
{
    80003c7a:	1101                	addi	sp,sp,-32
    80003c7c:	ec22                	sd	s0,24(sp)
    80003c7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sip" : "=r" (x) );
    80003c80:	144027f3          	csrr	a5,sip
    80003c84:	fef43423          	sd	a5,-24(s0)
  return x;
    80003c88:	fe843783          	ld	a5,-24(s0)
}
    80003c8c:	853e                	mv	a0,a5
    80003c8e:	6462                	ld	s0,24(sp)
    80003c90:	6105                	addi	sp,sp,32
    80003c92:	8082                	ret

0000000080003c94 <w_sip>:
{
    80003c94:	1101                	addi	sp,sp,-32
    80003c96:	ec22                	sd	s0,24(sp)
    80003c98:	1000                	addi	s0,sp,32
    80003c9a:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw sip, %0" : : "r" (x));
    80003c9e:	fe843783          	ld	a5,-24(s0)
    80003ca2:	14479073          	csrw	sip,a5
}
    80003ca6:	0001                	nop
    80003ca8:	6462                	ld	s0,24(sp)
    80003caa:	6105                	addi	sp,sp,32
    80003cac:	8082                	ret

0000000080003cae <w_sepc>:
{
    80003cae:	1101                	addi	sp,sp,-32
    80003cb0:	ec22                	sd	s0,24(sp)
    80003cb2:	1000                	addi	s0,sp,32
    80003cb4:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003cb8:	fe843783          	ld	a5,-24(s0)
    80003cbc:	14179073          	csrw	sepc,a5
}
    80003cc0:	0001                	nop
    80003cc2:	6462                	ld	s0,24(sp)
    80003cc4:	6105                	addi	sp,sp,32
    80003cc6:	8082                	ret

0000000080003cc8 <r_sepc>:
{
    80003cc8:	1101                	addi	sp,sp,-32
    80003cca:	ec22                	sd	s0,24(sp)
    80003ccc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003cce:	141027f3          	csrr	a5,sepc
    80003cd2:	fef43423          	sd	a5,-24(s0)
  return x;
    80003cd6:	fe843783          	ld	a5,-24(s0)
}
    80003cda:	853e                	mv	a0,a5
    80003cdc:	6462                	ld	s0,24(sp)
    80003cde:	6105                	addi	sp,sp,32
    80003ce0:	8082                	ret

0000000080003ce2 <w_stvec>:
{
    80003ce2:	1101                	addi	sp,sp,-32
    80003ce4:	ec22                	sd	s0,24(sp)
    80003ce6:	1000                	addi	s0,sp,32
    80003ce8:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw stvec, %0" : : "r" (x));
    80003cec:	fe843783          	ld	a5,-24(s0)
    80003cf0:	10579073          	csrw	stvec,a5
}
    80003cf4:	0001                	nop
    80003cf6:	6462                	ld	s0,24(sp)
    80003cf8:	6105                	addi	sp,sp,32
    80003cfa:	8082                	ret

0000000080003cfc <r_satp>:
{
    80003cfc:	1101                	addi	sp,sp,-32
    80003cfe:	ec22                	sd	s0,24(sp)
    80003d00:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, satp" : "=r" (x) );
    80003d02:	180027f3          	csrr	a5,satp
    80003d06:	fef43423          	sd	a5,-24(s0)
  return x;
    80003d0a:	fe843783          	ld	a5,-24(s0)
}
    80003d0e:	853e                	mv	a0,a5
    80003d10:	6462                	ld	s0,24(sp)
    80003d12:	6105                	addi	sp,sp,32
    80003d14:	8082                	ret

0000000080003d16 <r_scause>:
{
    80003d16:	1101                	addi	sp,sp,-32
    80003d18:	ec22                	sd	s0,24(sp)
    80003d1a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80003d1c:	142027f3          	csrr	a5,scause
    80003d20:	fef43423          	sd	a5,-24(s0)
  return x;
    80003d24:	fe843783          	ld	a5,-24(s0)
}
    80003d28:	853e                	mv	a0,a5
    80003d2a:	6462                	ld	s0,24(sp)
    80003d2c:	6105                	addi	sp,sp,32
    80003d2e:	8082                	ret

0000000080003d30 <r_stval>:
{
    80003d30:	1101                	addi	sp,sp,-32
    80003d32:	ec22                	sd	s0,24(sp)
    80003d34:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003d36:	143027f3          	csrr	a5,stval
    80003d3a:	fef43423          	sd	a5,-24(s0)
  return x;
    80003d3e:	fe843783          	ld	a5,-24(s0)
}
    80003d42:	853e                	mv	a0,a5
    80003d44:	6462                	ld	s0,24(sp)
    80003d46:	6105                	addi	sp,sp,32
    80003d48:	8082                	ret

0000000080003d4a <intr_on>:
{
    80003d4a:	1141                	addi	sp,sp,-16
    80003d4c:	e406                	sd	ra,8(sp)
    80003d4e:	e022                	sd	s0,0(sp)
    80003d50:	0800                	addi	s0,sp,16
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80003d52:	00000097          	auipc	ra,0x0
    80003d56:	ef4080e7          	jalr	-268(ra) # 80003c46 <r_sstatus>
    80003d5a:	87aa                	mv	a5,a0
    80003d5c:	0027e793          	ori	a5,a5,2
    80003d60:	853e                	mv	a0,a5
    80003d62:	00000097          	auipc	ra,0x0
    80003d66:	efe080e7          	jalr	-258(ra) # 80003c60 <w_sstatus>
}
    80003d6a:	0001                	nop
    80003d6c:	60a2                	ld	ra,8(sp)
    80003d6e:	6402                	ld	s0,0(sp)
    80003d70:	0141                	addi	sp,sp,16
    80003d72:	8082                	ret

0000000080003d74 <intr_off>:
{
    80003d74:	1141                	addi	sp,sp,-16
    80003d76:	e406                	sd	ra,8(sp)
    80003d78:	e022                	sd	s0,0(sp)
    80003d7a:	0800                	addi	s0,sp,16
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80003d7c:	00000097          	auipc	ra,0x0
    80003d80:	eca080e7          	jalr	-310(ra) # 80003c46 <r_sstatus>
    80003d84:	87aa                	mv	a5,a0
    80003d86:	9bf5                	andi	a5,a5,-3
    80003d88:	853e                	mv	a0,a5
    80003d8a:	00000097          	auipc	ra,0x0
    80003d8e:	ed6080e7          	jalr	-298(ra) # 80003c60 <w_sstatus>
}
    80003d92:	0001                	nop
    80003d94:	60a2                	ld	ra,8(sp)
    80003d96:	6402                	ld	s0,0(sp)
    80003d98:	0141                	addi	sp,sp,16
    80003d9a:	8082                	ret

0000000080003d9c <intr_get>:
{
    80003d9c:	1101                	addi	sp,sp,-32
    80003d9e:	ec06                	sd	ra,24(sp)
    80003da0:	e822                	sd	s0,16(sp)
    80003da2:	1000                	addi	s0,sp,32
  uint64 x = r_sstatus();
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	ea2080e7          	jalr	-350(ra) # 80003c46 <r_sstatus>
    80003dac:	fea43423          	sd	a0,-24(s0)
  return (x & SSTATUS_SIE) != 0;
    80003db0:	fe843783          	ld	a5,-24(s0)
    80003db4:	8b89                	andi	a5,a5,2
    80003db6:	00f037b3          	snez	a5,a5
    80003dba:	0ff7f793          	zext.b	a5,a5
    80003dbe:	2781                	sext.w	a5,a5
}
    80003dc0:	853e                	mv	a0,a5
    80003dc2:	60e2                	ld	ra,24(sp)
    80003dc4:	6442                	ld	s0,16(sp)
    80003dc6:	6105                	addi	sp,sp,32
    80003dc8:	8082                	ret

0000000080003dca <r_tp>:
{
    80003dca:	1101                	addi	sp,sp,-32
    80003dcc:	ec22                	sd	s0,24(sp)
    80003dce:	1000                	addi	s0,sp,32
  asm volatile("mv %0, tp" : "=r" (x) );
    80003dd0:	8792                	mv	a5,tp
    80003dd2:	fef43423          	sd	a5,-24(s0)
  return x;
    80003dd6:	fe843783          	ld	a5,-24(s0)
}
    80003dda:	853e                	mv	a0,a5
    80003ddc:	6462                	ld	s0,24(sp)
    80003dde:	6105                	addi	sp,sp,32
    80003de0:	8082                	ret

0000000080003de2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80003de2:	1141                	addi	sp,sp,-16
    80003de4:	e406                	sd	ra,8(sp)
    80003de6:	e022                	sd	s0,0(sp)
    80003de8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80003dea:	00007597          	auipc	a1,0x7
    80003dee:	4f658593          	addi	a1,a1,1270 # 8000b2e0 <etext+0x2e0>
    80003df2:	00016517          	auipc	a0,0x16
    80003df6:	be650513          	addi	a0,a0,-1050 # 800199d8 <tickslock>
    80003dfa:	ffffd097          	auipc	ra,0xffffd
    80003dfe:	44e080e7          	jalr	1102(ra) # 80001248 <initlock>
}
    80003e02:	0001                	nop
    80003e04:	60a2                	ld	ra,8(sp)
    80003e06:	6402                	ld	s0,0(sp)
    80003e08:	0141                	addi	sp,sp,16
    80003e0a:	8082                	ret

0000000080003e0c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80003e0c:	1141                	addi	sp,sp,-16
    80003e0e:	e406                	sd	ra,8(sp)
    80003e10:	e022                	sd	s0,0(sp)
    80003e12:	0800                	addi	s0,sp,16
  w_stvec((uint64)kernelvec);
    80003e14:	00005797          	auipc	a5,0x5
    80003e18:	e5c78793          	addi	a5,a5,-420 # 80008c70 <kernelvec>
    80003e1c:	853e                	mv	a0,a5
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	ec4080e7          	jalr	-316(ra) # 80003ce2 <w_stvec>
}
    80003e26:	0001                	nop
    80003e28:	60a2                	ld	ra,8(sp)
    80003e2a:	6402                	ld	s0,0(sp)
    80003e2c:	0141                	addi	sp,sp,16
    80003e2e:	8082                	ret

0000000080003e30 <usertrap>:
// handle an interrupt, exception, or system call from user space.
// called from trampoline.S
//
void
usertrap(void)
{
    80003e30:	7179                	addi	sp,sp,-48
    80003e32:	f406                	sd	ra,40(sp)
    80003e34:	f022                	sd	s0,32(sp)
    80003e36:	ec26                	sd	s1,24(sp)
    80003e38:	1800                	addi	s0,sp,48
  int which_dev = 0;
    80003e3a:	fc042e23          	sw	zero,-36(s0)

  if((r_sstatus() & SSTATUS_SPP) != 0)
    80003e3e:	00000097          	auipc	ra,0x0
    80003e42:	e08080e7          	jalr	-504(ra) # 80003c46 <r_sstatus>
    80003e46:	87aa                	mv	a5,a0
    80003e48:	1007f793          	andi	a5,a5,256
    80003e4c:	cb89                	beqz	a5,80003e5e <usertrap+0x2e>
    panic("usertrap: not from user mode");
    80003e4e:	00007517          	auipc	a0,0x7
    80003e52:	49a50513          	addi	a0,a0,1178 # 8000b2e8 <etext+0x2e8>
    80003e56:	ffffd097          	auipc	ra,0xffffd
    80003e5a:	e34080e7          	jalr	-460(ra) # 80000c8a <panic>

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);
    80003e5e:	00005797          	auipc	a5,0x5
    80003e62:	e1278793          	addi	a5,a5,-494 # 80008c70 <kernelvec>
    80003e66:	853e                	mv	a0,a5
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	e7a080e7          	jalr	-390(ra) # 80003ce2 <w_stvec>

  struct proc *p = myproc();
    80003e70:	fffff097          	auipc	ra,0xfffff
    80003e74:	9d0080e7          	jalr	-1584(ra) # 80002840 <myproc>
    80003e78:	fca43823          	sd	a0,-48(s0)
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
    80003e7c:	fd043783          	ld	a5,-48(s0)
    80003e80:	6fa4                	ld	s1,88(a5)
    80003e82:	00000097          	auipc	ra,0x0
    80003e86:	e46080e7          	jalr	-442(ra) # 80003cc8 <r_sepc>
    80003e8a:	87aa                	mv	a5,a0
    80003e8c:	ec9c                	sd	a5,24(s1)
  
  if(r_scause() == 8){
    80003e8e:	00000097          	auipc	ra,0x0
    80003e92:	e88080e7          	jalr	-376(ra) # 80003d16 <r_scause>
    80003e96:	872a                	mv	a4,a0
    80003e98:	47a1                	li	a5,8
    80003e9a:	04f71163          	bne	a4,a5,80003edc <usertrap+0xac>
    // system call

    if(killed(p))
    80003e9e:	fd043503          	ld	a0,-48(s0)
    80003ea2:	fffff097          	auipc	ra,0xfffff
    80003ea6:	74a080e7          	jalr	1866(ra) # 800035ec <killed>
    80003eaa:	87aa                	mv	a5,a0
    80003eac:	c791                	beqz	a5,80003eb8 <usertrap+0x88>
      exit(-1);
    80003eae:	557d                	li	a0,-1
    80003eb0:	fffff097          	auipc	ra,0xfffff
    80003eb4:	082080e7          	jalr	130(ra) # 80002f32 <exit>

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;
    80003eb8:	fd043783          	ld	a5,-48(s0)
    80003ebc:	6fbc                	ld	a5,88(a5)
    80003ebe:	6f98                	ld	a4,24(a5)
    80003ec0:	fd043783          	ld	a5,-48(s0)
    80003ec4:	6fbc                	ld	a5,88(a5)
    80003ec6:	0711                	addi	a4,a4,4
    80003ec8:	ef98                	sd	a4,24(a5)

    // an interrupt will change sepc, scause, and sstatus,
    // so enable only now that we're done with those registers.
    intr_on();
    80003eca:	00000097          	auipc	ra,0x0
    80003ece:	e80080e7          	jalr	-384(ra) # 80003d4a <intr_on>

    syscall();
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	66c080e7          	jalr	1644(ra) # 8000453e <syscall>
    80003eda:	a885                	j	80003f4a <usertrap+0x11a>
  } else if((which_dev = devintr()) != 0){
    80003edc:	00000097          	auipc	ra,0x0
    80003ee0:	34e080e7          	jalr	846(ra) # 8000422a <devintr>
    80003ee4:	87aa                	mv	a5,a0
    80003ee6:	fcf42e23          	sw	a5,-36(s0)
    80003eea:	fdc42783          	lw	a5,-36(s0)
    80003eee:	2781                	sext.w	a5,a5
    80003ef0:	efa9                	bnez	a5,80003f4a <usertrap+0x11a>
    // ok
  } else {
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	e24080e7          	jalr	-476(ra) # 80003d16 <r_scause>
    80003efa:	872a                	mv	a4,a0
    80003efc:	fd043783          	ld	a5,-48(s0)
    80003f00:	5b9c                	lw	a5,48(a5)
    80003f02:	863e                	mv	a2,a5
    80003f04:	85ba                	mv	a1,a4
    80003f06:	00007517          	auipc	a0,0x7
    80003f0a:	40250513          	addi	a0,a0,1026 # 8000b308 <etext+0x308>
    80003f0e:	ffffd097          	auipc	ra,0xffffd
    80003f12:	b26080e7          	jalr	-1242(ra) # 80000a34 <printf>
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003f16:	00000097          	auipc	ra,0x0
    80003f1a:	db2080e7          	jalr	-590(ra) # 80003cc8 <r_sepc>
    80003f1e:	84aa                	mv	s1,a0
    80003f20:	00000097          	auipc	ra,0x0
    80003f24:	e10080e7          	jalr	-496(ra) # 80003d30 <r_stval>
    80003f28:	87aa                	mv	a5,a0
    80003f2a:	863e                	mv	a2,a5
    80003f2c:	85a6                	mv	a1,s1
    80003f2e:	00007517          	auipc	a0,0x7
    80003f32:	40a50513          	addi	a0,a0,1034 # 8000b338 <etext+0x338>
    80003f36:	ffffd097          	auipc	ra,0xffffd
    80003f3a:	afe080e7          	jalr	-1282(ra) # 80000a34 <printf>
    setkilled(p);
    80003f3e:	fd043503          	ld	a0,-48(s0)
    80003f42:	fffff097          	auipc	ra,0xfffff
    80003f46:	670080e7          	jalr	1648(ra) # 800035b2 <setkilled>
  }

  if(killed(p))
    80003f4a:	fd043503          	ld	a0,-48(s0)
    80003f4e:	fffff097          	auipc	ra,0xfffff
    80003f52:	69e080e7          	jalr	1694(ra) # 800035ec <killed>
    80003f56:	87aa                	mv	a5,a0
    80003f58:	c791                	beqz	a5,80003f64 <usertrap+0x134>
    exit(-1);
    80003f5a:	557d                	li	a0,-1
    80003f5c:	fffff097          	auipc	ra,0xfffff
    80003f60:	fd6080e7          	jalr	-42(ra) # 80002f32 <exit>

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2)
    80003f64:	fdc42783          	lw	a5,-36(s0)
    80003f68:	0007871b          	sext.w	a4,a5
    80003f6c:	4789                	li	a5,2
    80003f6e:	00f71663          	bne	a4,a5,80003f7a <usertrap+0x14a>
    yield();
    80003f72:	fffff097          	auipc	ra,0xfffff
    80003f76:	3f6080e7          	jalr	1014(ra) # 80003368 <yield>

  usertrapret();
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	014080e7          	jalr	20(ra) # 80003f8e <usertrapret>
}
    80003f82:	0001                	nop
    80003f84:	70a2                	ld	ra,40(sp)
    80003f86:	7402                	ld	s0,32(sp)
    80003f88:	64e2                	ld	s1,24(sp)
    80003f8a:	6145                	addi	sp,sp,48
    80003f8c:	8082                	ret

0000000080003f8e <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80003f8e:	715d                	addi	sp,sp,-80
    80003f90:	e486                	sd	ra,72(sp)
    80003f92:	e0a2                	sd	s0,64(sp)
    80003f94:	fc26                	sd	s1,56(sp)
    80003f96:	0880                	addi	s0,sp,80
  struct proc *p = myproc();
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	8a8080e7          	jalr	-1880(ra) # 80002840 <myproc>
    80003fa0:	fca43c23          	sd	a0,-40(s0)

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();
    80003fa4:	00000097          	auipc	ra,0x0
    80003fa8:	dd0080e7          	jalr	-560(ra) # 80003d74 <intr_off>

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80003fac:	00006717          	auipc	a4,0x6
    80003fb0:	05470713          	addi	a4,a4,84 # 8000a000 <_trampoline>
    80003fb4:	00006797          	auipc	a5,0x6
    80003fb8:	04c78793          	addi	a5,a5,76 # 8000a000 <_trampoline>
    80003fbc:	8f1d                	sub	a4,a4,a5
    80003fbe:	040007b7          	lui	a5,0x4000
    80003fc2:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80003fc4:	07b2                	slli	a5,a5,0xc
    80003fc6:	97ba                	add	a5,a5,a4
    80003fc8:	fcf43823          	sd	a5,-48(s0)
  w_stvec(trampoline_uservec);
    80003fcc:	fd043503          	ld	a0,-48(s0)
    80003fd0:	00000097          	auipc	ra,0x0
    80003fd4:	d12080e7          	jalr	-750(ra) # 80003ce2 <w_stvec>

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80003fd8:	fd843783          	ld	a5,-40(s0)
    80003fdc:	6fa4                	ld	s1,88(a5)
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	d1e080e7          	jalr	-738(ra) # 80003cfc <r_satp>
    80003fe6:	87aa                	mv	a5,a0
    80003fe8:	e09c                	sd	a5,0(s1)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80003fea:	fd843783          	ld	a5,-40(s0)
    80003fee:	63b4                	ld	a3,64(a5)
    80003ff0:	fd843783          	ld	a5,-40(s0)
    80003ff4:	6fbc                	ld	a5,88(a5)
    80003ff6:	6705                	lui	a4,0x1
    80003ff8:	9736                	add	a4,a4,a3
    80003ffa:	e798                	sd	a4,8(a5)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80003ffc:	fd843783          	ld	a5,-40(s0)
    80004000:	6fbc                	ld	a5,88(a5)
    80004002:	00000717          	auipc	a4,0x0
    80004006:	e2e70713          	addi	a4,a4,-466 # 80003e30 <usertrap>
    8000400a:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000400c:	fd843783          	ld	a5,-40(s0)
    80004010:	6fa4                	ld	s1,88(a5)
    80004012:	00000097          	auipc	ra,0x0
    80004016:	db8080e7          	jalr	-584(ra) # 80003dca <r_tp>
    8000401a:	87aa                	mv	a5,a0
    8000401c:	f09c                	sd	a5,32(s1)

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
    8000401e:	00000097          	auipc	ra,0x0
    80004022:	c28080e7          	jalr	-984(ra) # 80003c46 <r_sstatus>
    80004026:	fca43423          	sd	a0,-56(s0)
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000402a:	fc843783          	ld	a5,-56(s0)
    8000402e:	eff7f793          	andi	a5,a5,-257
    80004032:	fcf43423          	sd	a5,-56(s0)
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80004036:	fc843783          	ld	a5,-56(s0)
    8000403a:	0207e793          	ori	a5,a5,32
    8000403e:	fcf43423          	sd	a5,-56(s0)
  w_sstatus(x);
    80004042:	fc843503          	ld	a0,-56(s0)
    80004046:	00000097          	auipc	ra,0x0
    8000404a:	c1a080e7          	jalr	-998(ra) # 80003c60 <w_sstatus>

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000404e:	fd843783          	ld	a5,-40(s0)
    80004052:	6fbc                	ld	a5,88(a5)
    80004054:	6f9c                	ld	a5,24(a5)
    80004056:	853e                	mv	a0,a5
    80004058:	00000097          	auipc	ra,0x0
    8000405c:	c56080e7          	jalr	-938(ra) # 80003cae <w_sepc>

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80004060:	fd843783          	ld	a5,-40(s0)
    80004064:	6bbc                	ld	a5,80(a5)
    80004066:	00c7d713          	srli	a4,a5,0xc
    8000406a:	57fd                	li	a5,-1
    8000406c:	17fe                	slli	a5,a5,0x3f
    8000406e:	8fd9                	or	a5,a5,a4
    80004070:	fcf43023          	sd	a5,-64(s0)

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80004074:	00006717          	auipc	a4,0x6
    80004078:	02870713          	addi	a4,a4,40 # 8000a09c <userret>
    8000407c:	00006797          	auipc	a5,0x6
    80004080:	f8478793          	addi	a5,a5,-124 # 8000a000 <_trampoline>
    80004084:	8f1d                	sub	a4,a4,a5
    80004086:	040007b7          	lui	a5,0x4000
    8000408a:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000408c:	07b2                	slli	a5,a5,0xc
    8000408e:	97ba                	add	a5,a5,a4
    80004090:	faf43c23          	sd	a5,-72(s0)
  ((void (*)(uint64))trampoline_userret)(satp);
    80004094:	fb843783          	ld	a5,-72(s0)
    80004098:	fc043503          	ld	a0,-64(s0)
    8000409c:	9782                	jalr	a5
}
    8000409e:	0001                	nop
    800040a0:	60a6                	ld	ra,72(sp)
    800040a2:	6406                	ld	s0,64(sp)
    800040a4:	74e2                	ld	s1,56(sp)
    800040a6:	6161                	addi	sp,sp,80
    800040a8:	8082                	ret

00000000800040aa <kerneltrap>:

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void 
kerneltrap()
{
    800040aa:	7139                	addi	sp,sp,-64
    800040ac:	fc06                	sd	ra,56(sp)
    800040ae:	f822                	sd	s0,48(sp)
    800040b0:	f426                	sd	s1,40(sp)
    800040b2:	0080                	addi	s0,sp,64
  int which_dev = 0;
    800040b4:	fc042e23          	sw	zero,-36(s0)
  uint64 sepc = r_sepc();
    800040b8:	00000097          	auipc	ra,0x0
    800040bc:	c10080e7          	jalr	-1008(ra) # 80003cc8 <r_sepc>
    800040c0:	fca43823          	sd	a0,-48(s0)
  uint64 sstatus = r_sstatus();
    800040c4:	00000097          	auipc	ra,0x0
    800040c8:	b82080e7          	jalr	-1150(ra) # 80003c46 <r_sstatus>
    800040cc:	fca43423          	sd	a0,-56(s0)
  uint64 scause = r_scause();
    800040d0:	00000097          	auipc	ra,0x0
    800040d4:	c46080e7          	jalr	-954(ra) # 80003d16 <r_scause>
    800040d8:	fca43023          	sd	a0,-64(s0)
  
  if((sstatus & SSTATUS_SPP) == 0)
    800040dc:	fc843783          	ld	a5,-56(s0)
    800040e0:	1007f793          	andi	a5,a5,256
    800040e4:	eb89                	bnez	a5,800040f6 <kerneltrap+0x4c>
    panic("kerneltrap: not from supervisor mode");
    800040e6:	00007517          	auipc	a0,0x7
    800040ea:	27250513          	addi	a0,a0,626 # 8000b358 <etext+0x358>
    800040ee:	ffffd097          	auipc	ra,0xffffd
    800040f2:	b9c080e7          	jalr	-1124(ra) # 80000c8a <panic>
  if(intr_get() != 0)
    800040f6:	00000097          	auipc	ra,0x0
    800040fa:	ca6080e7          	jalr	-858(ra) # 80003d9c <intr_get>
    800040fe:	87aa                	mv	a5,a0
    80004100:	cb89                	beqz	a5,80004112 <kerneltrap+0x68>
    panic("kerneltrap: interrupts enabled");
    80004102:	00007517          	auipc	a0,0x7
    80004106:	27e50513          	addi	a0,a0,638 # 8000b380 <etext+0x380>
    8000410a:	ffffd097          	auipc	ra,0xffffd
    8000410e:	b80080e7          	jalr	-1152(ra) # 80000c8a <panic>

  if((which_dev = devintr()) == 0){
    80004112:	00000097          	auipc	ra,0x0
    80004116:	118080e7          	jalr	280(ra) # 8000422a <devintr>
    8000411a:	87aa                	mv	a5,a0
    8000411c:	fcf42e23          	sw	a5,-36(s0)
    80004120:	fdc42783          	lw	a5,-36(s0)
    80004124:	2781                	sext.w	a5,a5
    80004126:	e7b9                	bnez	a5,80004174 <kerneltrap+0xca>
    printf("scause %p\n", scause);
    80004128:	fc043583          	ld	a1,-64(s0)
    8000412c:	00007517          	auipc	a0,0x7
    80004130:	27450513          	addi	a0,a0,628 # 8000b3a0 <etext+0x3a0>
    80004134:	ffffd097          	auipc	ra,0xffffd
    80004138:	900080e7          	jalr	-1792(ra) # 80000a34 <printf>
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000413c:	00000097          	auipc	ra,0x0
    80004140:	b8c080e7          	jalr	-1140(ra) # 80003cc8 <r_sepc>
    80004144:	84aa                	mv	s1,a0
    80004146:	00000097          	auipc	ra,0x0
    8000414a:	bea080e7          	jalr	-1046(ra) # 80003d30 <r_stval>
    8000414e:	87aa                	mv	a5,a0
    80004150:	863e                	mv	a2,a5
    80004152:	85a6                	mv	a1,s1
    80004154:	00007517          	auipc	a0,0x7
    80004158:	25c50513          	addi	a0,a0,604 # 8000b3b0 <etext+0x3b0>
    8000415c:	ffffd097          	auipc	ra,0xffffd
    80004160:	8d8080e7          	jalr	-1832(ra) # 80000a34 <printf>
    panic("kerneltrap");
    80004164:	00007517          	auipc	a0,0x7
    80004168:	26450513          	addi	a0,a0,612 # 8000b3c8 <etext+0x3c8>
    8000416c:	ffffd097          	auipc	ra,0xffffd
    80004170:	b1e080e7          	jalr	-1250(ra) # 80000c8a <panic>
  }

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80004174:	fdc42783          	lw	a5,-36(s0)
    80004178:	0007871b          	sext.w	a4,a5
    8000417c:	4789                	li	a5,2
    8000417e:	02f71663          	bne	a4,a5,800041aa <kerneltrap+0x100>
    80004182:	ffffe097          	auipc	ra,0xffffe
    80004186:	6be080e7          	jalr	1726(ra) # 80002840 <myproc>
    8000418a:	87aa                	mv	a5,a0
    8000418c:	cf99                	beqz	a5,800041aa <kerneltrap+0x100>
    8000418e:	ffffe097          	auipc	ra,0xffffe
    80004192:	6b2080e7          	jalr	1714(ra) # 80002840 <myproc>
    80004196:	87aa                	mv	a5,a0
    80004198:	4f9c                	lw	a5,24(a5)
    8000419a:	873e                	mv	a4,a5
    8000419c:	4791                	li	a5,4
    8000419e:	00f71663          	bne	a4,a5,800041aa <kerneltrap+0x100>
    yield();
    800041a2:	fffff097          	auipc	ra,0xfffff
    800041a6:	1c6080e7          	jalr	454(ra) # 80003368 <yield>

  // the yield() may have caused some traps to occur,
  // so restore trap registers for use by kernelvec.S's sepc instruction.
  w_sepc(sepc);
    800041aa:	fd043503          	ld	a0,-48(s0)
    800041ae:	00000097          	auipc	ra,0x0
    800041b2:	b00080e7          	jalr	-1280(ra) # 80003cae <w_sepc>
  w_sstatus(sstatus);
    800041b6:	fc843503          	ld	a0,-56(s0)
    800041ba:	00000097          	auipc	ra,0x0
    800041be:	aa6080e7          	jalr	-1370(ra) # 80003c60 <w_sstatus>
}
    800041c2:	0001                	nop
    800041c4:	70e2                	ld	ra,56(sp)
    800041c6:	7442                	ld	s0,48(sp)
    800041c8:	74a2                	ld	s1,40(sp)
    800041ca:	6121                	addi	sp,sp,64
    800041cc:	8082                	ret

00000000800041ce <clockintr>:

void
clockintr()
{
    800041ce:	1141                	addi	sp,sp,-16
    800041d0:	e406                	sd	ra,8(sp)
    800041d2:	e022                	sd	s0,0(sp)
    800041d4:	0800                	addi	s0,sp,16
  acquire(&tickslock);
    800041d6:	00016517          	auipc	a0,0x16
    800041da:	80250513          	addi	a0,a0,-2046 # 800199d8 <tickslock>
    800041de:	ffffd097          	auipc	ra,0xffffd
    800041e2:	09a080e7          	jalr	154(ra) # 80001278 <acquire>
  ticks++;
    800041e6:	00007797          	auipc	a5,0x7
    800041ea:	75278793          	addi	a5,a5,1874 # 8000b938 <ticks>
    800041ee:	439c                	lw	a5,0(a5)
    800041f0:	2785                	addiw	a5,a5,1
    800041f2:	0007871b          	sext.w	a4,a5
    800041f6:	00007797          	auipc	a5,0x7
    800041fa:	74278793          	addi	a5,a5,1858 # 8000b938 <ticks>
    800041fe:	c398                	sw	a4,0(a5)
  wakeup(&ticks);
    80004200:	00007517          	auipc	a0,0x7
    80004204:	73850513          	addi	a0,a0,1848 # 8000b938 <ticks>
    80004208:	fffff097          	auipc	ra,0xfffff
    8000420c:	276080e7          	jalr	630(ra) # 8000347e <wakeup>
  release(&tickslock);
    80004210:	00015517          	auipc	a0,0x15
    80004214:	7c850513          	addi	a0,a0,1992 # 800199d8 <tickslock>
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	0c4080e7          	jalr	196(ra) # 800012dc <release>
}
    80004220:	0001                	nop
    80004222:	60a2                	ld	ra,8(sp)
    80004224:	6402                	ld	s0,0(sp)
    80004226:	0141                	addi	sp,sp,16
    80004228:	8082                	ret

000000008000422a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000422a:	1101                	addi	sp,sp,-32
    8000422c:	ec06                	sd	ra,24(sp)
    8000422e:	e822                	sd	s0,16(sp)
    80004230:	1000                	addi	s0,sp,32
  uint64 scause = r_scause();
    80004232:	00000097          	auipc	ra,0x0
    80004236:	ae4080e7          	jalr	-1308(ra) # 80003d16 <r_scause>
    8000423a:	fea43423          	sd	a0,-24(s0)

  if((scause & 0x8000000000000000L) &&
    8000423e:	fe843783          	ld	a5,-24(s0)
    80004242:	0807d463          	bgez	a5,800042ca <devintr+0xa0>
     (scause & 0xff) == 9){
    80004246:	fe843783          	ld	a5,-24(s0)
    8000424a:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    8000424e:	47a5                	li	a5,9
    80004250:	06f71d63          	bne	a4,a5,800042ca <devintr+0xa0>
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();
    80004254:	00005097          	auipc	ra,0x5
    80004258:	b4e080e7          	jalr	-1202(ra) # 80008da2 <plic_claim>
    8000425c:	87aa                	mv	a5,a0
    8000425e:	fef42223          	sw	a5,-28(s0)

    if(irq == UART0_IRQ){
    80004262:	fe442783          	lw	a5,-28(s0)
    80004266:	0007871b          	sext.w	a4,a5
    8000426a:	47a9                	li	a5,10
    8000426c:	00f71763          	bne	a4,a5,8000427a <devintr+0x50>
      uartintr();
    80004270:	ffffd097          	auipc	ra,0xffffd
    80004274:	d10080e7          	jalr	-752(ra) # 80000f80 <uartintr>
    80004278:	a825                	j	800042b0 <devintr+0x86>
    } else if(irq == VIRTIO0_IRQ){
    8000427a:	fe442783          	lw	a5,-28(s0)
    8000427e:	0007871b          	sext.w	a4,a5
    80004282:	4785                	li	a5,1
    80004284:	00f71763          	bne	a4,a5,80004292 <devintr+0x68>
      virtio_disk_intr();
    80004288:	00005097          	auipc	ra,0x5
    8000428c:	4dc080e7          	jalr	1244(ra) # 80009764 <virtio_disk_intr>
    80004290:	a005                	j	800042b0 <devintr+0x86>
    } else if(irq){
    80004292:	fe442783          	lw	a5,-28(s0)
    80004296:	2781                	sext.w	a5,a5
    80004298:	cf81                	beqz	a5,800042b0 <devintr+0x86>
      printf("unexpected interrupt irq=%d\n", irq);
    8000429a:	fe442783          	lw	a5,-28(s0)
    8000429e:	85be                	mv	a1,a5
    800042a0:	00007517          	auipc	a0,0x7
    800042a4:	13850513          	addi	a0,a0,312 # 8000b3d8 <etext+0x3d8>
    800042a8:	ffffc097          	auipc	ra,0xffffc
    800042ac:	78c080e7          	jalr	1932(ra) # 80000a34 <printf>
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if(irq)
    800042b0:	fe442783          	lw	a5,-28(s0)
    800042b4:	2781                	sext.w	a5,a5
    800042b6:	cb81                	beqz	a5,800042c6 <devintr+0x9c>
      plic_complete(irq);
    800042b8:	fe442783          	lw	a5,-28(s0)
    800042bc:	853e                	mv	a0,a5
    800042be:	00005097          	auipc	ra,0x5
    800042c2:	b22080e7          	jalr	-1246(ra) # 80008de0 <plic_complete>

    return 1;
    800042c6:	4785                	li	a5,1
    800042c8:	a081                	j	80004308 <devintr+0xde>
  } else if(scause == 0x8000000000000001L){
    800042ca:	fe843703          	ld	a4,-24(s0)
    800042ce:	57fd                	li	a5,-1
    800042d0:	17fe                	slli	a5,a5,0x3f
    800042d2:	0785                	addi	a5,a5,1
    800042d4:	02f71963          	bne	a4,a5,80004306 <devintr+0xdc>
    // software interrupt from a machine-mode timer interrupt,
    // forwarded by timervec in kernelvec.S.

    if(cpuid() == 0){
    800042d8:	ffffe097          	auipc	ra,0xffffe
    800042dc:	50a080e7          	jalr	1290(ra) # 800027e2 <cpuid>
    800042e0:	87aa                	mv	a5,a0
    800042e2:	e789                	bnez	a5,800042ec <devintr+0xc2>
      clockintr();
    800042e4:	00000097          	auipc	ra,0x0
    800042e8:	eea080e7          	jalr	-278(ra) # 800041ce <clockintr>
    }
    
    // acknowledge the software interrupt by clearing
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);
    800042ec:	00000097          	auipc	ra,0x0
    800042f0:	98e080e7          	jalr	-1650(ra) # 80003c7a <r_sip>
    800042f4:	87aa                	mv	a5,a0
    800042f6:	9bf5                	andi	a5,a5,-3
    800042f8:	853e                	mv	a0,a5
    800042fa:	00000097          	auipc	ra,0x0
    800042fe:	99a080e7          	jalr	-1638(ra) # 80003c94 <w_sip>

    return 2;
    80004302:	4789                	li	a5,2
    80004304:	a011                	j	80004308 <devintr+0xde>
  } else {
    return 0;
    80004306:	4781                	li	a5,0
  }
}
    80004308:	853e                	mv	a0,a5
    8000430a:	60e2                	ld	ra,24(sp)
    8000430c:	6442                	ld	s0,16(sp)
    8000430e:	6105                	addi	sp,sp,32
    80004310:	8082                	ret

0000000080004312 <fetchaddr>:
#include "defs.h"

// Fetch the uint64 at addr from the current process.
int
fetchaddr(uint64 addr, uint64 *ip)
{
    80004312:	7179                	addi	sp,sp,-48
    80004314:	f406                	sd	ra,40(sp)
    80004316:	f022                	sd	s0,32(sp)
    80004318:	1800                	addi	s0,sp,48
    8000431a:	fca43c23          	sd	a0,-40(s0)
    8000431e:	fcb43823          	sd	a1,-48(s0)
  struct proc *p = myproc();
    80004322:	ffffe097          	auipc	ra,0xffffe
    80004326:	51e080e7          	jalr	1310(ra) # 80002840 <myproc>
    8000432a:	fea43423          	sd	a0,-24(s0)
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000432e:	fe843783          	ld	a5,-24(s0)
    80004332:	67bc                	ld	a5,72(a5)
    80004334:	fd843703          	ld	a4,-40(s0)
    80004338:	00f77b63          	bgeu	a4,a5,8000434e <fetchaddr+0x3c>
    8000433c:	fd843783          	ld	a5,-40(s0)
    80004340:	00878713          	addi	a4,a5,8
    80004344:	fe843783          	ld	a5,-24(s0)
    80004348:	67bc                	ld	a5,72(a5)
    8000434a:	00e7f463          	bgeu	a5,a4,80004352 <fetchaddr+0x40>
    return -1;
    8000434e:	57fd                	li	a5,-1
    80004350:	a01d                	j	80004376 <fetchaddr+0x64>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80004352:	fe843783          	ld	a5,-24(s0)
    80004356:	6bbc                	ld	a5,80(a5)
    80004358:	46a1                	li	a3,8
    8000435a:	fd843603          	ld	a2,-40(s0)
    8000435e:	fd043583          	ld	a1,-48(s0)
    80004362:	853e                	mv	a0,a5
    80004364:	ffffe097          	auipc	ra,0xffffe
    80004368:	074080e7          	jalr	116(ra) # 800023d8 <copyin>
    8000436c:	87aa                	mv	a5,a0
    8000436e:	c399                	beqz	a5,80004374 <fetchaddr+0x62>
    return -1;
    80004370:	57fd                	li	a5,-1
    80004372:	a011                	j	80004376 <fetchaddr+0x64>
  return 0;
    80004374:	4781                	li	a5,0
}
    80004376:	853e                	mv	a0,a5
    80004378:	70a2                	ld	ra,40(sp)
    8000437a:	7402                	ld	s0,32(sp)
    8000437c:	6145                	addi	sp,sp,48
    8000437e:	8082                	ret

0000000080004380 <fetchstr>:

// Fetch the nul-terminated string at addr from the current process.
// Returns length of string, not including nul, or -1 for error.
int
fetchstr(uint64 addr, char *buf, int max)
{
    80004380:	7139                	addi	sp,sp,-64
    80004382:	fc06                	sd	ra,56(sp)
    80004384:	f822                	sd	s0,48(sp)
    80004386:	0080                	addi	s0,sp,64
    80004388:	fca43c23          	sd	a0,-40(s0)
    8000438c:	fcb43823          	sd	a1,-48(s0)
    80004390:	87b2                	mv	a5,a2
    80004392:	fcf42623          	sw	a5,-52(s0)
  struct proc *p = myproc();
    80004396:	ffffe097          	auipc	ra,0xffffe
    8000439a:	4aa080e7          	jalr	1194(ra) # 80002840 <myproc>
    8000439e:	fea43423          	sd	a0,-24(s0)
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800043a2:	fe843783          	ld	a5,-24(s0)
    800043a6:	6bbc                	ld	a5,80(a5)
    800043a8:	fcc42703          	lw	a4,-52(s0)
    800043ac:	86ba                	mv	a3,a4
    800043ae:	fd843603          	ld	a2,-40(s0)
    800043b2:	fd043583          	ld	a1,-48(s0)
    800043b6:	853e                	mv	a0,a5
    800043b8:	ffffe097          	auipc	ra,0xffffe
    800043bc:	0ee080e7          	jalr	238(ra) # 800024a6 <copyinstr>
    800043c0:	87aa                	mv	a5,a0
    800043c2:	0007d463          	bgez	a5,800043ca <fetchstr+0x4a>
    return -1;
    800043c6:	57fd                	li	a5,-1
    800043c8:	a801                	j	800043d8 <fetchstr+0x58>
  return strlen(buf);
    800043ca:	fd043503          	ld	a0,-48(s0)
    800043ce:	ffffd097          	auipc	ra,0xffffd
    800043d2:	3fe080e7          	jalr	1022(ra) # 800017cc <strlen>
    800043d6:	87aa                	mv	a5,a0
}
    800043d8:	853e                	mv	a0,a5
    800043da:	70e2                	ld	ra,56(sp)
    800043dc:	7442                	ld	s0,48(sp)
    800043de:	6121                	addi	sp,sp,64
    800043e0:	8082                	ret

00000000800043e2 <argraw>:

static uint64
argraw(int n)
{
    800043e2:	7179                	addi	sp,sp,-48
    800043e4:	f406                	sd	ra,40(sp)
    800043e6:	f022                	sd	s0,32(sp)
    800043e8:	1800                	addi	s0,sp,48
    800043ea:	87aa                	mv	a5,a0
    800043ec:	fcf42e23          	sw	a5,-36(s0)
  struct proc *p = myproc();
    800043f0:	ffffe097          	auipc	ra,0xffffe
    800043f4:	450080e7          	jalr	1104(ra) # 80002840 <myproc>
    800043f8:	fea43423          	sd	a0,-24(s0)
  switch (n) {
    800043fc:	fdc42783          	lw	a5,-36(s0)
    80004400:	0007871b          	sext.w	a4,a5
    80004404:	4795                	li	a5,5
    80004406:	06e7e263          	bltu	a5,a4,8000446a <argraw+0x88>
    8000440a:	fdc46783          	lwu	a5,-36(s0)
    8000440e:	00279713          	slli	a4,a5,0x2
    80004412:	00007797          	auipc	a5,0x7
    80004416:	fee78793          	addi	a5,a5,-18 # 8000b400 <etext+0x400>
    8000441a:	97ba                	add	a5,a5,a4
    8000441c:	439c                	lw	a5,0(a5)
    8000441e:	0007871b          	sext.w	a4,a5
    80004422:	00007797          	auipc	a5,0x7
    80004426:	fde78793          	addi	a5,a5,-34 # 8000b400 <etext+0x400>
    8000442a:	97ba                	add	a5,a5,a4
    8000442c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000442e:	fe843783          	ld	a5,-24(s0)
    80004432:	6fbc                	ld	a5,88(a5)
    80004434:	7bbc                	ld	a5,112(a5)
    80004436:	a091                	j	8000447a <argraw+0x98>
  case 1:
    return p->trapframe->a1;
    80004438:	fe843783          	ld	a5,-24(s0)
    8000443c:	6fbc                	ld	a5,88(a5)
    8000443e:	7fbc                	ld	a5,120(a5)
    80004440:	a82d                	j	8000447a <argraw+0x98>
  case 2:
    return p->trapframe->a2;
    80004442:	fe843783          	ld	a5,-24(s0)
    80004446:	6fbc                	ld	a5,88(a5)
    80004448:	63dc                	ld	a5,128(a5)
    8000444a:	a805                	j	8000447a <argraw+0x98>
  case 3:
    return p->trapframe->a3;
    8000444c:	fe843783          	ld	a5,-24(s0)
    80004450:	6fbc                	ld	a5,88(a5)
    80004452:	67dc                	ld	a5,136(a5)
    80004454:	a01d                	j	8000447a <argraw+0x98>
  case 4:
    return p->trapframe->a4;
    80004456:	fe843783          	ld	a5,-24(s0)
    8000445a:	6fbc                	ld	a5,88(a5)
    8000445c:	6bdc                	ld	a5,144(a5)
    8000445e:	a831                	j	8000447a <argraw+0x98>
  case 5:
    return p->trapframe->a5;
    80004460:	fe843783          	ld	a5,-24(s0)
    80004464:	6fbc                	ld	a5,88(a5)
    80004466:	6fdc                	ld	a5,152(a5)
    80004468:	a809                	j	8000447a <argraw+0x98>
  }
  panic("argraw");
    8000446a:	00007517          	auipc	a0,0x7
    8000446e:	f8e50513          	addi	a0,a0,-114 # 8000b3f8 <etext+0x3f8>
    80004472:	ffffd097          	auipc	ra,0xffffd
    80004476:	818080e7          	jalr	-2024(ra) # 80000c8a <panic>
  return -1;
}
    8000447a:	853e                	mv	a0,a5
    8000447c:	70a2                	ld	ra,40(sp)
    8000447e:	7402                	ld	s0,32(sp)
    80004480:	6145                	addi	sp,sp,48
    80004482:	8082                	ret

0000000080004484 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80004484:	1101                	addi	sp,sp,-32
    80004486:	ec06                	sd	ra,24(sp)
    80004488:	e822                	sd	s0,16(sp)
    8000448a:	1000                	addi	s0,sp,32
    8000448c:	87aa                	mv	a5,a0
    8000448e:	feb43023          	sd	a1,-32(s0)
    80004492:	fef42623          	sw	a5,-20(s0)
  *ip = argraw(n);
    80004496:	fec42783          	lw	a5,-20(s0)
    8000449a:	853e                	mv	a0,a5
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	f46080e7          	jalr	-186(ra) # 800043e2 <argraw>
    800044a4:	87aa                	mv	a5,a0
    800044a6:	0007871b          	sext.w	a4,a5
    800044aa:	fe043783          	ld	a5,-32(s0)
    800044ae:	c398                	sw	a4,0(a5)
}
    800044b0:	0001                	nop
    800044b2:	60e2                	ld	ra,24(sp)
    800044b4:	6442                	ld	s0,16(sp)
    800044b6:	6105                	addi	sp,sp,32
    800044b8:	8082                	ret

00000000800044ba <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800044ba:	1101                	addi	sp,sp,-32
    800044bc:	ec06                	sd	ra,24(sp)
    800044be:	e822                	sd	s0,16(sp)
    800044c0:	1000                	addi	s0,sp,32
    800044c2:	87aa                	mv	a5,a0
    800044c4:	feb43023          	sd	a1,-32(s0)
    800044c8:	fef42623          	sw	a5,-20(s0)
  *ip = argraw(n);
    800044cc:	fec42783          	lw	a5,-20(s0)
    800044d0:	853e                	mv	a0,a5
    800044d2:	00000097          	auipc	ra,0x0
    800044d6:	f10080e7          	jalr	-240(ra) # 800043e2 <argraw>
    800044da:	872a                	mv	a4,a0
    800044dc:	fe043783          	ld	a5,-32(s0)
    800044e0:	e398                	sd	a4,0(a5)
}
    800044e2:	0001                	nop
    800044e4:	60e2                	ld	ra,24(sp)
    800044e6:	6442                	ld	s0,16(sp)
    800044e8:	6105                	addi	sp,sp,32
    800044ea:	8082                	ret

00000000800044ec <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800044ec:	7179                	addi	sp,sp,-48
    800044ee:	f406                	sd	ra,40(sp)
    800044f0:	f022                	sd	s0,32(sp)
    800044f2:	1800                	addi	s0,sp,48
    800044f4:	87aa                	mv	a5,a0
    800044f6:	fcb43823          	sd	a1,-48(s0)
    800044fa:	8732                	mv	a4,a2
    800044fc:	fcf42e23          	sw	a5,-36(s0)
    80004500:	87ba                	mv	a5,a4
    80004502:	fcf42c23          	sw	a5,-40(s0)
  uint64 addr;
  argaddr(n, &addr);
    80004506:	fe840713          	addi	a4,s0,-24
    8000450a:	fdc42783          	lw	a5,-36(s0)
    8000450e:	85ba                	mv	a1,a4
    80004510:	853e                	mv	a0,a5
    80004512:	00000097          	auipc	ra,0x0
    80004516:	fa8080e7          	jalr	-88(ra) # 800044ba <argaddr>
  return fetchstr(addr, buf, max);
    8000451a:	fe843783          	ld	a5,-24(s0)
    8000451e:	fd842703          	lw	a4,-40(s0)
    80004522:	863a                	mv	a2,a4
    80004524:	fd043583          	ld	a1,-48(s0)
    80004528:	853e                	mv	a0,a5
    8000452a:	00000097          	auipc	ra,0x0
    8000452e:	e56080e7          	jalr	-426(ra) # 80004380 <fetchstr>
    80004532:	87aa                	mv	a5,a0
}
    80004534:	853e                	mv	a0,a5
    80004536:	70a2                	ld	ra,40(sp)
    80004538:	7402                	ld	s0,32(sp)
    8000453a:	6145                	addi	sp,sp,48
    8000453c:	8082                	ret

000000008000453e <syscall>:
[SYS_proctree] sys_proctree,
};

void
syscall(void)
{
    8000453e:	7179                	addi	sp,sp,-48
    80004540:	f406                	sd	ra,40(sp)
    80004542:	f022                	sd	s0,32(sp)
    80004544:	ec26                	sd	s1,24(sp)
    80004546:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    80004548:	ffffe097          	auipc	ra,0xffffe
    8000454c:	2f8080e7          	jalr	760(ra) # 80002840 <myproc>
    80004550:	fca43c23          	sd	a0,-40(s0)

  num = p->trapframe->a7;
    80004554:	fd843783          	ld	a5,-40(s0)
    80004558:	6fbc                	ld	a5,88(a5)
    8000455a:	77dc                	ld	a5,168(a5)
    8000455c:	fcf42a23          	sw	a5,-44(s0)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80004560:	fd442783          	lw	a5,-44(s0)
    80004564:	2781                	sext.w	a5,a5
    80004566:	04f05263          	blez	a5,800045aa <syscall+0x6c>
    8000456a:	fd442783          	lw	a5,-44(s0)
    8000456e:	873e                	mv	a4,a5
    80004570:	47e5                	li	a5,25
    80004572:	02e7ec63          	bltu	a5,a4,800045aa <syscall+0x6c>
    80004576:	00007717          	auipc	a4,0x7
    8000457a:	2aa70713          	addi	a4,a4,682 # 8000b820 <syscalls>
    8000457e:	fd442783          	lw	a5,-44(s0)
    80004582:	078e                	slli	a5,a5,0x3
    80004584:	97ba                	add	a5,a5,a4
    80004586:	639c                	ld	a5,0(a5)
    80004588:	c38d                	beqz	a5,800045aa <syscall+0x6c>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000458a:	00007717          	auipc	a4,0x7
    8000458e:	29670713          	addi	a4,a4,662 # 8000b820 <syscalls>
    80004592:	fd442783          	lw	a5,-44(s0)
    80004596:	078e                	slli	a5,a5,0x3
    80004598:	97ba                	add	a5,a5,a4
    8000459a:	639c                	ld	a5,0(a5)
    8000459c:	fd843703          	ld	a4,-40(s0)
    800045a0:	6f24                	ld	s1,88(a4)
    800045a2:	9782                	jalr	a5
    800045a4:	87aa                	mv	a5,a0
    800045a6:	f8bc                	sd	a5,112(s1)
    800045a8:	a815                	j	800045dc <syscall+0x9e>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800045aa:	fd843783          	ld	a5,-40(s0)
    800045ae:	5b98                	lw	a4,48(a5)
            p->pid, p->name, num);
    800045b0:	fd843783          	ld	a5,-40(s0)
    800045b4:	15878793          	addi	a5,a5,344
    printf("%d %s: unknown sys call %d\n",
    800045b8:	fd442683          	lw	a3,-44(s0)
    800045bc:	863e                	mv	a2,a5
    800045be:	85ba                	mv	a1,a4
    800045c0:	00007517          	auipc	a0,0x7
    800045c4:	e5850513          	addi	a0,a0,-424 # 8000b418 <etext+0x418>
    800045c8:	ffffc097          	auipc	ra,0xffffc
    800045cc:	46c080e7          	jalr	1132(ra) # 80000a34 <printf>
    p->trapframe->a0 = -1;
    800045d0:	fd843783          	ld	a5,-40(s0)
    800045d4:	6fbc                	ld	a5,88(a5)
    800045d6:	577d                	li	a4,-1
    800045d8:	fbb8                	sd	a4,112(a5)
  }
}
    800045da:	0001                	nop
    800045dc:	0001                	nop
    800045de:	70a2                	ld	ra,40(sp)
    800045e0:	7402                	ld	s0,32(sp)
    800045e2:	64e2                	ld	s1,24(sp)
    800045e4:	6145                	addi	sp,sp,48
    800045e6:	8082                	ret

00000000800045e8 <sys_proctree>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_proctree(void)
{
    800045e8:	1141                	addi	sp,sp,-16
    800045ea:	e406                	sd	ra,8(sp)
    800045ec:	e022                	sd	s0,0(sp)
    800045ee:	0800                	addi	s0,sp,16
  return proctree();
    800045f0:	fffff097          	auipc	ra,0xfffff
    800045f4:	3ca080e7          	jalr	970(ra) # 800039ba <proctree>
    800045f8:	87aa                	mv	a5,a0
}
    800045fa:	853e                	mv	a0,a5
    800045fc:	60a2                	ld	ra,8(sp)
    800045fe:	6402                	ld	s0,0(sp)
    80004600:	0141                	addi	sp,sp,16
    80004602:	8082                	ret

0000000080004604 <sys_ps>:

uint64
sys_ps(void)
{
    80004604:	1141                	addi	sp,sp,-16
    80004606:	e406                	sd	ra,8(sp)
    80004608:	e022                	sd	s0,0(sp)
    8000460a:	0800                	addi	s0,sp,16
  return ps();
    8000460c:	fffff097          	auipc	ra,0xfffff
    80004610:	1ea080e7          	jalr	490(ra) # 800037f6 <ps>
    80004614:	87aa                	mv	a5,a0
}
    80004616:	853e                	mv	a0,a5
    80004618:	60a2                	ld	ra,8(sp)
    8000461a:	6402                	ld	s0,0(sp)
    8000461c:	0141                	addi	sp,sp,16
    8000461e:	8082                	ret

0000000080004620 <sys_getproc>:

uint64
sys_getproc(void)
{
    80004620:	7179                	addi	sp,sp,-48
    80004622:	f406                	sd	ra,40(sp)
    80004624:	f022                	sd	s0,32(sp)
    80004626:	1800                	addi	s0,sp,48
  uint64 buff;
  argaddr(0, &buff);
    80004628:	fe040793          	addi	a5,s0,-32
    8000462c:	85be                	mv	a1,a5
    8000462e:	4501                	li	a0,0
    80004630:	00000097          	auipc	ra,0x0
    80004634:	e8a080e7          	jalr	-374(ra) # 800044ba <argaddr>
  struct proc *p = myproc();
    80004638:	ffffe097          	auipc	ra,0xffffe
    8000463c:	208080e7          	jalr	520(ra) # 80002840 <myproc>
    80004640:	fea43423          	sd	a0,-24(s0)
  acquire(&p->lock);
    80004644:	fe843783          	ld	a5,-24(s0)
    80004648:	853e                	mv	a0,a5
    8000464a:	ffffd097          	auipc	ra,0xffffd
    8000464e:	c2e080e7          	jalr	-978(ra) # 80001278 <acquire>
  const int info[] = {p->pid, p->state};
    80004652:	fe843783          	ld	a5,-24(s0)
    80004656:	5b9c                	lw	a5,48(a5)
    80004658:	fcf42c23          	sw	a5,-40(s0)
    8000465c:	fe843783          	ld	a5,-24(s0)
    80004660:	4f9c                	lw	a5,24(a5)
    80004662:	2781                	sext.w	a5,a5
    80004664:	fcf42e23          	sw	a5,-36(s0)
  release(&p->lock);
    80004668:	fe843783          	ld	a5,-24(s0)
    8000466c:	853e                	mv	a0,a5
    8000466e:	ffffd097          	auipc	ra,0xffffd
    80004672:	c6e080e7          	jalr	-914(ra) # 800012dc <release>
  copyout(p->pagetable, buff, (char*) info, sizeof(info));
    80004676:	fe843783          	ld	a5,-24(s0)
    8000467a:	6bbc                	ld	a5,80(a5)
    8000467c:	fe043703          	ld	a4,-32(s0)
    80004680:	fd840613          	addi	a2,s0,-40
    80004684:	46a1                	li	a3,8
    80004686:	85ba                	mv	a1,a4
    80004688:	853e                	mv	a0,a5
    8000468a:	ffffe097          	auipc	ra,0xffffe
    8000468e:	c80080e7          	jalr	-896(ra) # 8000230a <copyout>
  return 0;
    80004692:	4781                	li	a5,0
}
    80004694:	853e                	mv	a0,a5
    80004696:	70a2                	ld	ra,40(sp)
    80004698:	7402                	ld	s0,32(sp)
    8000469a:	6145                	addi	sp,sp,48
    8000469c:	8082                	ret

000000008000469e <sys_exit>:

uint64
sys_exit(void)
{
    8000469e:	1101                	addi	sp,sp,-32
    800046a0:	ec06                	sd	ra,24(sp)
    800046a2:	e822                	sd	s0,16(sp)
    800046a4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800046a6:	fec40793          	addi	a5,s0,-20
    800046aa:	85be                	mv	a1,a5
    800046ac:	4501                	li	a0,0
    800046ae:	00000097          	auipc	ra,0x0
    800046b2:	dd6080e7          	jalr	-554(ra) # 80004484 <argint>
  exit(n);
    800046b6:	fec42783          	lw	a5,-20(s0)
    800046ba:	853e                	mv	a0,a5
    800046bc:	fffff097          	auipc	ra,0xfffff
    800046c0:	876080e7          	jalr	-1930(ra) # 80002f32 <exit>
  return 0;  // not reached
    800046c4:	4781                	li	a5,0
}
    800046c6:	853e                	mv	a0,a5
    800046c8:	60e2                	ld	ra,24(sp)
    800046ca:	6442                	ld	s0,16(sp)
    800046cc:	6105                	addi	sp,sp,32
    800046ce:	8082                	ret

00000000800046d0 <sys_getpid>:

uint64
sys_getpid(void)
{
    800046d0:	1141                	addi	sp,sp,-16
    800046d2:	e406                	sd	ra,8(sp)
    800046d4:	e022                	sd	s0,0(sp)
    800046d6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800046d8:	ffffe097          	auipc	ra,0xffffe
    800046dc:	168080e7          	jalr	360(ra) # 80002840 <myproc>
    800046e0:	87aa                	mv	a5,a0
    800046e2:	5b9c                	lw	a5,48(a5)
}
    800046e4:	853e                	mv	a0,a5
    800046e6:	60a2                	ld	ra,8(sp)
    800046e8:	6402                	ld	s0,0(sp)
    800046ea:	0141                	addi	sp,sp,16
    800046ec:	8082                	ret

00000000800046ee <sys_fork>:

uint64
sys_fork(void)
{
    800046ee:	1141                	addi	sp,sp,-16
    800046f0:	e406                	sd	ra,8(sp)
    800046f2:	e022                	sd	s0,0(sp)
    800046f4:	0800                	addi	s0,sp,16
  return fork();
    800046f6:	ffffe097          	auipc	ra,0xffffe
    800046fa:	61a080e7          	jalr	1562(ra) # 80002d10 <fork>
    800046fe:	87aa                	mv	a5,a0
}
    80004700:	853e                	mv	a0,a5
    80004702:	60a2                	ld	ra,8(sp)
    80004704:	6402                	ld	s0,0(sp)
    80004706:	0141                	addi	sp,sp,16
    80004708:	8082                	ret

000000008000470a <sys_wait>:

uint64
sys_wait(void)
{
    8000470a:	1101                	addi	sp,sp,-32
    8000470c:	ec06                	sd	ra,24(sp)
    8000470e:	e822                	sd	s0,16(sp)
    80004710:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80004712:	fe840793          	addi	a5,s0,-24
    80004716:	85be                	mv	a1,a5
    80004718:	4501                	li	a0,0
    8000471a:	00000097          	auipc	ra,0x0
    8000471e:	da0080e7          	jalr	-608(ra) # 800044ba <argaddr>
  return wait(p);
    80004722:	fe843783          	ld	a5,-24(s0)
    80004726:	853e                	mv	a0,a5
    80004728:	fffff097          	auipc	ra,0xfffff
    8000472c:	946080e7          	jalr	-1722(ra) # 8000306e <wait>
    80004730:	87aa                	mv	a5,a0
}
    80004732:	853e                	mv	a0,a5
    80004734:	60e2                	ld	ra,24(sp)
    80004736:	6442                	ld	s0,16(sp)
    80004738:	6105                	addi	sp,sp,32
    8000473a:	8082                	ret

000000008000473c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000473c:	1101                	addi	sp,sp,-32
    8000473e:	ec06                	sd	ra,24(sp)
    80004740:	e822                	sd	s0,16(sp)
    80004742:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  argint(0, &n);
    80004744:	fe440793          	addi	a5,s0,-28
    80004748:	85be                	mv	a1,a5
    8000474a:	4501                	li	a0,0
    8000474c:	00000097          	auipc	ra,0x0
    80004750:	d38080e7          	jalr	-712(ra) # 80004484 <argint>
  addr = myproc()->sz;
    80004754:	ffffe097          	auipc	ra,0xffffe
    80004758:	0ec080e7          	jalr	236(ra) # 80002840 <myproc>
    8000475c:	87aa                	mv	a5,a0
    8000475e:	67bc                	ld	a5,72(a5)
    80004760:	fef43423          	sd	a5,-24(s0)
  if(growproc(n) < 0)
    80004764:	fe442783          	lw	a5,-28(s0)
    80004768:	853e                	mv	a0,a5
    8000476a:	ffffe097          	auipc	ra,0xffffe
    8000476e:	506080e7          	jalr	1286(ra) # 80002c70 <growproc>
    80004772:	87aa                	mv	a5,a0
    80004774:	0007d463          	bgez	a5,8000477c <sys_sbrk+0x40>
    return -1;
    80004778:	57fd                	li	a5,-1
    8000477a:	a019                	j	80004780 <sys_sbrk+0x44>
  return addr;
    8000477c:	fe843783          	ld	a5,-24(s0)
}
    80004780:	853e                	mv	a0,a5
    80004782:	60e2                	ld	ra,24(sp)
    80004784:	6442                	ld	s0,16(sp)
    80004786:	6105                	addi	sp,sp,32
    80004788:	8082                	ret

000000008000478a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000478a:	1101                	addi	sp,sp,-32
    8000478c:	ec06                	sd	ra,24(sp)
    8000478e:	e822                	sd	s0,16(sp)
    80004790:	1000                	addi	s0,sp,32
  int n;
  uint ticks0;

  argint(0, &n);
    80004792:	fe840793          	addi	a5,s0,-24
    80004796:	85be                	mv	a1,a5
    80004798:	4501                	li	a0,0
    8000479a:	00000097          	auipc	ra,0x0
    8000479e:	cea080e7          	jalr	-790(ra) # 80004484 <argint>
  acquire(&tickslock);
    800047a2:	00015517          	auipc	a0,0x15
    800047a6:	23650513          	addi	a0,a0,566 # 800199d8 <tickslock>
    800047aa:	ffffd097          	auipc	ra,0xffffd
    800047ae:	ace080e7          	jalr	-1330(ra) # 80001278 <acquire>
  ticks0 = ticks;
    800047b2:	00007797          	auipc	a5,0x7
    800047b6:	18678793          	addi	a5,a5,390 # 8000b938 <ticks>
    800047ba:	439c                	lw	a5,0(a5)
    800047bc:	fef42623          	sw	a5,-20(s0)
  while(ticks - ticks0 < n){
    800047c0:	a099                	j	80004806 <sys_sleep+0x7c>
    if(killed(myproc())){
    800047c2:	ffffe097          	auipc	ra,0xffffe
    800047c6:	07e080e7          	jalr	126(ra) # 80002840 <myproc>
    800047ca:	87aa                	mv	a5,a0
    800047cc:	853e                	mv	a0,a5
    800047ce:	fffff097          	auipc	ra,0xfffff
    800047d2:	e1e080e7          	jalr	-482(ra) # 800035ec <killed>
    800047d6:	87aa                	mv	a5,a0
    800047d8:	cb99                	beqz	a5,800047ee <sys_sleep+0x64>
      release(&tickslock);
    800047da:	00015517          	auipc	a0,0x15
    800047de:	1fe50513          	addi	a0,a0,510 # 800199d8 <tickslock>
    800047e2:	ffffd097          	auipc	ra,0xffffd
    800047e6:	afa080e7          	jalr	-1286(ra) # 800012dc <release>
      return -1;
    800047ea:	57fd                	li	a5,-1
    800047ec:	a0a9                	j	80004836 <sys_sleep+0xac>
    }
    sleep(&ticks, &tickslock);
    800047ee:	00015597          	auipc	a1,0x15
    800047f2:	1ea58593          	addi	a1,a1,490 # 800199d8 <tickslock>
    800047f6:	00007517          	auipc	a0,0x7
    800047fa:	14250513          	addi	a0,a0,322 # 8000b938 <ticks>
    800047fe:	fffff097          	auipc	ra,0xfffff
    80004802:	c04080e7          	jalr	-1020(ra) # 80003402 <sleep>
  while(ticks - ticks0 < n){
    80004806:	00007797          	auipc	a5,0x7
    8000480a:	13278793          	addi	a5,a5,306 # 8000b938 <ticks>
    8000480e:	439c                	lw	a5,0(a5)
    80004810:	fec42703          	lw	a4,-20(s0)
    80004814:	9f99                	subw	a5,a5,a4
    80004816:	0007871b          	sext.w	a4,a5
    8000481a:	fe842783          	lw	a5,-24(s0)
    8000481e:	2781                	sext.w	a5,a5
    80004820:	faf761e3          	bltu	a4,a5,800047c2 <sys_sleep+0x38>
  }
  release(&tickslock);
    80004824:	00015517          	auipc	a0,0x15
    80004828:	1b450513          	addi	a0,a0,436 # 800199d8 <tickslock>
    8000482c:	ffffd097          	auipc	ra,0xffffd
    80004830:	ab0080e7          	jalr	-1360(ra) # 800012dc <release>
  return 0;
    80004834:	4781                	li	a5,0
}
    80004836:	853e                	mv	a0,a5
    80004838:	60e2                	ld	ra,24(sp)
    8000483a:	6442                	ld	s0,16(sp)
    8000483c:	6105                	addi	sp,sp,32
    8000483e:	8082                	ret

0000000080004840 <sys_kill>:

uint64
sys_kill(void)
{
    80004840:	1101                	addi	sp,sp,-32
    80004842:	ec06                	sd	ra,24(sp)
    80004844:	e822                	sd	s0,16(sp)
    80004846:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80004848:	fec40793          	addi	a5,s0,-20
    8000484c:	85be                	mv	a1,a5
    8000484e:	4501                	li	a0,0
    80004850:	00000097          	auipc	ra,0x0
    80004854:	c34080e7          	jalr	-972(ra) # 80004484 <argint>
  return kill(pid);
    80004858:	fec42783          	lw	a5,-20(s0)
    8000485c:	853e                	mv	a0,a5
    8000485e:	fffff097          	auipc	ra,0xfffff
    80004862:	cb4080e7          	jalr	-844(ra) # 80003512 <kill>
    80004866:	87aa                	mv	a5,a0
}
    80004868:	853e                	mv	a0,a5
    8000486a:	60e2                	ld	ra,24(sp)
    8000486c:	6442                	ld	s0,16(sp)
    8000486e:	6105                	addi	sp,sp,32
    80004870:	8082                	ret

0000000080004872 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80004872:	1101                	addi	sp,sp,-32
    80004874:	ec06                	sd	ra,24(sp)
    80004876:	e822                	sd	s0,16(sp)
    80004878:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000487a:	00015517          	auipc	a0,0x15
    8000487e:	15e50513          	addi	a0,a0,350 # 800199d8 <tickslock>
    80004882:	ffffd097          	auipc	ra,0xffffd
    80004886:	9f6080e7          	jalr	-1546(ra) # 80001278 <acquire>
  xticks = ticks;
    8000488a:	00007797          	auipc	a5,0x7
    8000488e:	0ae78793          	addi	a5,a5,174 # 8000b938 <ticks>
    80004892:	439c                	lw	a5,0(a5)
    80004894:	fef42623          	sw	a5,-20(s0)
  release(&tickslock);
    80004898:	00015517          	auipc	a0,0x15
    8000489c:	14050513          	addi	a0,a0,320 # 800199d8 <tickslock>
    800048a0:	ffffd097          	auipc	ra,0xffffd
    800048a4:	a3c080e7          	jalr	-1476(ra) # 800012dc <release>
  return xticks;
    800048a8:	fec46783          	lwu	a5,-20(s0)
}
    800048ac:	853e                	mv	a0,a5
    800048ae:	60e2                	ld	ra,24(sp)
    800048b0:	6442                	ld	s0,16(sp)
    800048b2:	6105                	addi	sp,sp,32
    800048b4:	8082                	ret

00000000800048b6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800048b6:	1101                	addi	sp,sp,-32
    800048b8:	ec06                	sd	ra,24(sp)
    800048ba:	e822                	sd	s0,16(sp)
    800048bc:	1000                	addi	s0,sp,32
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800048be:	00007597          	auipc	a1,0x7
    800048c2:	b7a58593          	addi	a1,a1,-1158 # 8000b438 <etext+0x438>
    800048c6:	00015517          	auipc	a0,0x15
    800048ca:	12a50513          	addi	a0,a0,298 # 800199f0 <bcache>
    800048ce:	ffffd097          	auipc	ra,0xffffd
    800048d2:	97a080e7          	jalr	-1670(ra) # 80001248 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800048d6:	00015717          	auipc	a4,0x15
    800048da:	11a70713          	addi	a4,a4,282 # 800199f0 <bcache>
    800048de:	67a1                	lui	a5,0x8
    800048e0:	97ba                	add	a5,a5,a4
    800048e2:	0001d717          	auipc	a4,0x1d
    800048e6:	37670713          	addi	a4,a4,886 # 80021c58 <bcache+0x8268>
    800048ea:	2ae7b823          	sd	a4,688(a5) # 82b0 <_entry-0x7fff7d50>
  bcache.head.next = &bcache.head;
    800048ee:	00015717          	auipc	a4,0x15
    800048f2:	10270713          	addi	a4,a4,258 # 800199f0 <bcache>
    800048f6:	67a1                	lui	a5,0x8
    800048f8:	97ba                	add	a5,a5,a4
    800048fa:	0001d717          	auipc	a4,0x1d
    800048fe:	35e70713          	addi	a4,a4,862 # 80021c58 <bcache+0x8268>
    80004902:	2ae7bc23          	sd	a4,696(a5) # 82b8 <_entry-0x7fff7d48>
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80004906:	00015797          	auipc	a5,0x15
    8000490a:	10278793          	addi	a5,a5,258 # 80019a08 <bcache+0x18>
    8000490e:	fef43423          	sd	a5,-24(s0)
    80004912:	a895                	j	80004986 <binit+0xd0>
    b->next = bcache.head.next;
    80004914:	00015717          	auipc	a4,0x15
    80004918:	0dc70713          	addi	a4,a4,220 # 800199f0 <bcache>
    8000491c:	67a1                	lui	a5,0x8
    8000491e:	97ba                	add	a5,a5,a4
    80004920:	2b87b703          	ld	a4,696(a5) # 82b8 <_entry-0x7fff7d48>
    80004924:	fe843783          	ld	a5,-24(s0)
    80004928:	ebb8                	sd	a4,80(a5)
    b->prev = &bcache.head;
    8000492a:	fe843783          	ld	a5,-24(s0)
    8000492e:	0001d717          	auipc	a4,0x1d
    80004932:	32a70713          	addi	a4,a4,810 # 80021c58 <bcache+0x8268>
    80004936:	e7b8                	sd	a4,72(a5)
    initsleeplock(&b->lock, "buffer");
    80004938:	fe843783          	ld	a5,-24(s0)
    8000493c:	07c1                	addi	a5,a5,16
    8000493e:	00007597          	auipc	a1,0x7
    80004942:	b0258593          	addi	a1,a1,-1278 # 8000b440 <etext+0x440>
    80004946:	853e                	mv	a0,a5
    80004948:	00002097          	auipc	ra,0x2
    8000494c:	022080e7          	jalr	34(ra) # 8000696a <initsleeplock>
    bcache.head.next->prev = b;
    80004950:	00015717          	auipc	a4,0x15
    80004954:	0a070713          	addi	a4,a4,160 # 800199f0 <bcache>
    80004958:	67a1                	lui	a5,0x8
    8000495a:	97ba                	add	a5,a5,a4
    8000495c:	2b87b783          	ld	a5,696(a5) # 82b8 <_entry-0x7fff7d48>
    80004960:	fe843703          	ld	a4,-24(s0)
    80004964:	e7b8                	sd	a4,72(a5)
    bcache.head.next = b;
    80004966:	00015717          	auipc	a4,0x15
    8000496a:	08a70713          	addi	a4,a4,138 # 800199f0 <bcache>
    8000496e:	67a1                	lui	a5,0x8
    80004970:	97ba                	add	a5,a5,a4
    80004972:	fe843703          	ld	a4,-24(s0)
    80004976:	2ae7bc23          	sd	a4,696(a5) # 82b8 <_entry-0x7fff7d48>
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000497a:	fe843783          	ld	a5,-24(s0)
    8000497e:	45878793          	addi	a5,a5,1112
    80004982:	fef43423          	sd	a5,-24(s0)
    80004986:	0001d797          	auipc	a5,0x1d
    8000498a:	2d278793          	addi	a5,a5,722 # 80021c58 <bcache+0x8268>
    8000498e:	fe843703          	ld	a4,-24(s0)
    80004992:	f8f761e3          	bltu	a4,a5,80004914 <binit+0x5e>
  }
}
    80004996:	0001                	nop
    80004998:	0001                	nop
    8000499a:	60e2                	ld	ra,24(sp)
    8000499c:	6442                	ld	s0,16(sp)
    8000499e:	6105                	addi	sp,sp,32
    800049a0:	8082                	ret

00000000800049a2 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
    800049a2:	7179                	addi	sp,sp,-48
    800049a4:	f406                	sd	ra,40(sp)
    800049a6:	f022                	sd	s0,32(sp)
    800049a8:	1800                	addi	s0,sp,48
    800049aa:	87aa                	mv	a5,a0
    800049ac:	872e                	mv	a4,a1
    800049ae:	fcf42e23          	sw	a5,-36(s0)
    800049b2:	87ba                	mv	a5,a4
    800049b4:	fcf42c23          	sw	a5,-40(s0)
  struct buf *b;

  acquire(&bcache.lock);
    800049b8:	00015517          	auipc	a0,0x15
    800049bc:	03850513          	addi	a0,a0,56 # 800199f0 <bcache>
    800049c0:	ffffd097          	auipc	ra,0xffffd
    800049c4:	8b8080e7          	jalr	-1864(ra) # 80001278 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800049c8:	00015717          	auipc	a4,0x15
    800049cc:	02870713          	addi	a4,a4,40 # 800199f0 <bcache>
    800049d0:	67a1                	lui	a5,0x8
    800049d2:	97ba                	add	a5,a5,a4
    800049d4:	2b87b783          	ld	a5,696(a5) # 82b8 <_entry-0x7fff7d48>
    800049d8:	fef43423          	sd	a5,-24(s0)
    800049dc:	a095                	j	80004a40 <bget+0x9e>
    if(b->dev == dev && b->blockno == blockno){
    800049de:	fe843783          	ld	a5,-24(s0)
    800049e2:	4798                	lw	a4,8(a5)
    800049e4:	fdc42783          	lw	a5,-36(s0)
    800049e8:	2781                	sext.w	a5,a5
    800049ea:	04e79663          	bne	a5,a4,80004a36 <bget+0x94>
    800049ee:	fe843783          	ld	a5,-24(s0)
    800049f2:	47d8                	lw	a4,12(a5)
    800049f4:	fd842783          	lw	a5,-40(s0)
    800049f8:	2781                	sext.w	a5,a5
    800049fa:	02e79e63          	bne	a5,a4,80004a36 <bget+0x94>
      b->refcnt++;
    800049fe:	fe843783          	ld	a5,-24(s0)
    80004a02:	43bc                	lw	a5,64(a5)
    80004a04:	2785                	addiw	a5,a5,1
    80004a06:	0007871b          	sext.w	a4,a5
    80004a0a:	fe843783          	ld	a5,-24(s0)
    80004a0e:	c3b8                	sw	a4,64(a5)
      release(&bcache.lock);
    80004a10:	00015517          	auipc	a0,0x15
    80004a14:	fe050513          	addi	a0,a0,-32 # 800199f0 <bcache>
    80004a18:	ffffd097          	auipc	ra,0xffffd
    80004a1c:	8c4080e7          	jalr	-1852(ra) # 800012dc <release>
      acquiresleep(&b->lock);
    80004a20:	fe843783          	ld	a5,-24(s0)
    80004a24:	07c1                	addi	a5,a5,16
    80004a26:	853e                	mv	a0,a5
    80004a28:	00002097          	auipc	ra,0x2
    80004a2c:	f8e080e7          	jalr	-114(ra) # 800069b6 <acquiresleep>
      return b;
    80004a30:	fe843783          	ld	a5,-24(s0)
    80004a34:	a07d                	j	80004ae2 <bget+0x140>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80004a36:	fe843783          	ld	a5,-24(s0)
    80004a3a:	6bbc                	ld	a5,80(a5)
    80004a3c:	fef43423          	sd	a5,-24(s0)
    80004a40:	fe843703          	ld	a4,-24(s0)
    80004a44:	0001d797          	auipc	a5,0x1d
    80004a48:	21478793          	addi	a5,a5,532 # 80021c58 <bcache+0x8268>
    80004a4c:	f8f719e3          	bne	a4,a5,800049de <bget+0x3c>
    }
  }

  // Not cached.
  // Recycle the least recently used (LRU) unused buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004a50:	00015717          	auipc	a4,0x15
    80004a54:	fa070713          	addi	a4,a4,-96 # 800199f0 <bcache>
    80004a58:	67a1                	lui	a5,0x8
    80004a5a:	97ba                	add	a5,a5,a4
    80004a5c:	2b07b783          	ld	a5,688(a5) # 82b0 <_entry-0x7fff7d50>
    80004a60:	fef43423          	sd	a5,-24(s0)
    80004a64:	a8b9                	j	80004ac2 <bget+0x120>
    if(b->refcnt == 0) {
    80004a66:	fe843783          	ld	a5,-24(s0)
    80004a6a:	43bc                	lw	a5,64(a5)
    80004a6c:	e7b1                	bnez	a5,80004ab8 <bget+0x116>
      b->dev = dev;
    80004a6e:	fe843783          	ld	a5,-24(s0)
    80004a72:	fdc42703          	lw	a4,-36(s0)
    80004a76:	c798                	sw	a4,8(a5)
      b->blockno = blockno;
    80004a78:	fe843783          	ld	a5,-24(s0)
    80004a7c:	fd842703          	lw	a4,-40(s0)
    80004a80:	c7d8                	sw	a4,12(a5)
      b->valid = 0;
    80004a82:	fe843783          	ld	a5,-24(s0)
    80004a86:	0007a023          	sw	zero,0(a5)
      b->refcnt = 1;
    80004a8a:	fe843783          	ld	a5,-24(s0)
    80004a8e:	4705                	li	a4,1
    80004a90:	c3b8                	sw	a4,64(a5)
      release(&bcache.lock);
    80004a92:	00015517          	auipc	a0,0x15
    80004a96:	f5e50513          	addi	a0,a0,-162 # 800199f0 <bcache>
    80004a9a:	ffffd097          	auipc	ra,0xffffd
    80004a9e:	842080e7          	jalr	-1982(ra) # 800012dc <release>
      acquiresleep(&b->lock);
    80004aa2:	fe843783          	ld	a5,-24(s0)
    80004aa6:	07c1                	addi	a5,a5,16
    80004aa8:	853e                	mv	a0,a5
    80004aaa:	00002097          	auipc	ra,0x2
    80004aae:	f0c080e7          	jalr	-244(ra) # 800069b6 <acquiresleep>
      return b;
    80004ab2:	fe843783          	ld	a5,-24(s0)
    80004ab6:	a035                	j	80004ae2 <bget+0x140>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80004ab8:	fe843783          	ld	a5,-24(s0)
    80004abc:	67bc                	ld	a5,72(a5)
    80004abe:	fef43423          	sd	a5,-24(s0)
    80004ac2:	fe843703          	ld	a4,-24(s0)
    80004ac6:	0001d797          	auipc	a5,0x1d
    80004aca:	19278793          	addi	a5,a5,402 # 80021c58 <bcache+0x8268>
    80004ace:	f8f71ce3          	bne	a4,a5,80004a66 <bget+0xc4>
    }
  }
  panic("bget: no buffers");
    80004ad2:	00007517          	auipc	a0,0x7
    80004ad6:	97650513          	addi	a0,a0,-1674 # 8000b448 <etext+0x448>
    80004ada:	ffffc097          	auipc	ra,0xffffc
    80004ade:	1b0080e7          	jalr	432(ra) # 80000c8a <panic>
}
    80004ae2:	853e                	mv	a0,a5
    80004ae4:	70a2                	ld	ra,40(sp)
    80004ae6:	7402                	ld	s0,32(sp)
    80004ae8:	6145                	addi	sp,sp,48
    80004aea:	8082                	ret

0000000080004aec <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80004aec:	7179                	addi	sp,sp,-48
    80004aee:	f406                	sd	ra,40(sp)
    80004af0:	f022                	sd	s0,32(sp)
    80004af2:	1800                	addi	s0,sp,48
    80004af4:	87aa                	mv	a5,a0
    80004af6:	872e                	mv	a4,a1
    80004af8:	fcf42e23          	sw	a5,-36(s0)
    80004afc:	87ba                	mv	a5,a4
    80004afe:	fcf42c23          	sw	a5,-40(s0)
  struct buf *b;

  b = bget(dev, blockno);
    80004b02:	fd842703          	lw	a4,-40(s0)
    80004b06:	fdc42783          	lw	a5,-36(s0)
    80004b0a:	85ba                	mv	a1,a4
    80004b0c:	853e                	mv	a0,a5
    80004b0e:	00000097          	auipc	ra,0x0
    80004b12:	e94080e7          	jalr	-364(ra) # 800049a2 <bget>
    80004b16:	fea43423          	sd	a0,-24(s0)
  if(!b->valid) {
    80004b1a:	fe843783          	ld	a5,-24(s0)
    80004b1e:	439c                	lw	a5,0(a5)
    80004b20:	ef81                	bnez	a5,80004b38 <bread+0x4c>
    virtio_disk_rw(b, 0);
    80004b22:	4581                	li	a1,0
    80004b24:	fe843503          	ld	a0,-24(s0)
    80004b28:	00005097          	auipc	ra,0x5
    80004b2c:	8fa080e7          	jalr	-1798(ra) # 80009422 <virtio_disk_rw>
    b->valid = 1;
    80004b30:	fe843783          	ld	a5,-24(s0)
    80004b34:	4705                	li	a4,1
    80004b36:	c398                	sw	a4,0(a5)
  }
  return b;
    80004b38:	fe843783          	ld	a5,-24(s0)
}
    80004b3c:	853e                	mv	a0,a5
    80004b3e:	70a2                	ld	ra,40(sp)
    80004b40:	7402                	ld	s0,32(sp)
    80004b42:	6145                	addi	sp,sp,48
    80004b44:	8082                	ret

0000000080004b46 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80004b46:	1101                	addi	sp,sp,-32
    80004b48:	ec06                	sd	ra,24(sp)
    80004b4a:	e822                	sd	s0,16(sp)
    80004b4c:	1000                	addi	s0,sp,32
    80004b4e:	fea43423          	sd	a0,-24(s0)
  if(!holdingsleep(&b->lock))
    80004b52:	fe843783          	ld	a5,-24(s0)
    80004b56:	07c1                	addi	a5,a5,16
    80004b58:	853e                	mv	a0,a5
    80004b5a:	00002097          	auipc	ra,0x2
    80004b5e:	f1c080e7          	jalr	-228(ra) # 80006a76 <holdingsleep>
    80004b62:	87aa                	mv	a5,a0
    80004b64:	eb89                	bnez	a5,80004b76 <bwrite+0x30>
    panic("bwrite");
    80004b66:	00007517          	auipc	a0,0x7
    80004b6a:	8fa50513          	addi	a0,a0,-1798 # 8000b460 <etext+0x460>
    80004b6e:	ffffc097          	auipc	ra,0xffffc
    80004b72:	11c080e7          	jalr	284(ra) # 80000c8a <panic>
  virtio_disk_rw(b, 1);
    80004b76:	4585                	li	a1,1
    80004b78:	fe843503          	ld	a0,-24(s0)
    80004b7c:	00005097          	auipc	ra,0x5
    80004b80:	8a6080e7          	jalr	-1882(ra) # 80009422 <virtio_disk_rw>
}
    80004b84:	0001                	nop
    80004b86:	60e2                	ld	ra,24(sp)
    80004b88:	6442                	ld	s0,16(sp)
    80004b8a:	6105                	addi	sp,sp,32
    80004b8c:	8082                	ret

0000000080004b8e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80004b8e:	1101                	addi	sp,sp,-32
    80004b90:	ec06                	sd	ra,24(sp)
    80004b92:	e822                	sd	s0,16(sp)
    80004b94:	1000                	addi	s0,sp,32
    80004b96:	fea43423          	sd	a0,-24(s0)
  if(!holdingsleep(&b->lock))
    80004b9a:	fe843783          	ld	a5,-24(s0)
    80004b9e:	07c1                	addi	a5,a5,16
    80004ba0:	853e                	mv	a0,a5
    80004ba2:	00002097          	auipc	ra,0x2
    80004ba6:	ed4080e7          	jalr	-300(ra) # 80006a76 <holdingsleep>
    80004baa:	87aa                	mv	a5,a0
    80004bac:	eb89                	bnez	a5,80004bbe <brelse+0x30>
    panic("brelse");
    80004bae:	00007517          	auipc	a0,0x7
    80004bb2:	8ba50513          	addi	a0,a0,-1862 # 8000b468 <etext+0x468>
    80004bb6:	ffffc097          	auipc	ra,0xffffc
    80004bba:	0d4080e7          	jalr	212(ra) # 80000c8a <panic>

  releasesleep(&b->lock);
    80004bbe:	fe843783          	ld	a5,-24(s0)
    80004bc2:	07c1                	addi	a5,a5,16
    80004bc4:	853e                	mv	a0,a5
    80004bc6:	00002097          	auipc	ra,0x2
    80004bca:	e5e080e7          	jalr	-418(ra) # 80006a24 <releasesleep>

  acquire(&bcache.lock);
    80004bce:	00015517          	auipc	a0,0x15
    80004bd2:	e2250513          	addi	a0,a0,-478 # 800199f0 <bcache>
    80004bd6:	ffffc097          	auipc	ra,0xffffc
    80004bda:	6a2080e7          	jalr	1698(ra) # 80001278 <acquire>
  b->refcnt--;
    80004bde:	fe843783          	ld	a5,-24(s0)
    80004be2:	43bc                	lw	a5,64(a5)
    80004be4:	37fd                	addiw	a5,a5,-1
    80004be6:	0007871b          	sext.w	a4,a5
    80004bea:	fe843783          	ld	a5,-24(s0)
    80004bee:	c3b8                	sw	a4,64(a5)
  if (b->refcnt == 0) {
    80004bf0:	fe843783          	ld	a5,-24(s0)
    80004bf4:	43bc                	lw	a5,64(a5)
    80004bf6:	e7b5                	bnez	a5,80004c62 <brelse+0xd4>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80004bf8:	fe843783          	ld	a5,-24(s0)
    80004bfc:	6bbc                	ld	a5,80(a5)
    80004bfe:	fe843703          	ld	a4,-24(s0)
    80004c02:	6738                	ld	a4,72(a4)
    80004c04:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80004c06:	fe843783          	ld	a5,-24(s0)
    80004c0a:	67bc                	ld	a5,72(a5)
    80004c0c:	fe843703          	ld	a4,-24(s0)
    80004c10:	6b38                	ld	a4,80(a4)
    80004c12:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80004c14:	00015717          	auipc	a4,0x15
    80004c18:	ddc70713          	addi	a4,a4,-548 # 800199f0 <bcache>
    80004c1c:	67a1                	lui	a5,0x8
    80004c1e:	97ba                	add	a5,a5,a4
    80004c20:	2b87b703          	ld	a4,696(a5) # 82b8 <_entry-0x7fff7d48>
    80004c24:	fe843783          	ld	a5,-24(s0)
    80004c28:	ebb8                	sd	a4,80(a5)
    b->prev = &bcache.head;
    80004c2a:	fe843783          	ld	a5,-24(s0)
    80004c2e:	0001d717          	auipc	a4,0x1d
    80004c32:	02a70713          	addi	a4,a4,42 # 80021c58 <bcache+0x8268>
    80004c36:	e7b8                	sd	a4,72(a5)
    bcache.head.next->prev = b;
    80004c38:	00015717          	auipc	a4,0x15
    80004c3c:	db870713          	addi	a4,a4,-584 # 800199f0 <bcache>
    80004c40:	67a1                	lui	a5,0x8
    80004c42:	97ba                	add	a5,a5,a4
    80004c44:	2b87b783          	ld	a5,696(a5) # 82b8 <_entry-0x7fff7d48>
    80004c48:	fe843703          	ld	a4,-24(s0)
    80004c4c:	e7b8                	sd	a4,72(a5)
    bcache.head.next = b;
    80004c4e:	00015717          	auipc	a4,0x15
    80004c52:	da270713          	addi	a4,a4,-606 # 800199f0 <bcache>
    80004c56:	67a1                	lui	a5,0x8
    80004c58:	97ba                	add	a5,a5,a4
    80004c5a:	fe843703          	ld	a4,-24(s0)
    80004c5e:	2ae7bc23          	sd	a4,696(a5) # 82b8 <_entry-0x7fff7d48>
  }
  
  release(&bcache.lock);
    80004c62:	00015517          	auipc	a0,0x15
    80004c66:	d8e50513          	addi	a0,a0,-626 # 800199f0 <bcache>
    80004c6a:	ffffc097          	auipc	ra,0xffffc
    80004c6e:	672080e7          	jalr	1650(ra) # 800012dc <release>
}
    80004c72:	0001                	nop
    80004c74:	60e2                	ld	ra,24(sp)
    80004c76:	6442                	ld	s0,16(sp)
    80004c78:	6105                	addi	sp,sp,32
    80004c7a:	8082                	ret

0000000080004c7c <bpin>:

void
bpin(struct buf *b) {
    80004c7c:	1101                	addi	sp,sp,-32
    80004c7e:	ec06                	sd	ra,24(sp)
    80004c80:	e822                	sd	s0,16(sp)
    80004c82:	1000                	addi	s0,sp,32
    80004c84:	fea43423          	sd	a0,-24(s0)
  acquire(&bcache.lock);
    80004c88:	00015517          	auipc	a0,0x15
    80004c8c:	d6850513          	addi	a0,a0,-664 # 800199f0 <bcache>
    80004c90:	ffffc097          	auipc	ra,0xffffc
    80004c94:	5e8080e7          	jalr	1512(ra) # 80001278 <acquire>
  b->refcnt++;
    80004c98:	fe843783          	ld	a5,-24(s0)
    80004c9c:	43bc                	lw	a5,64(a5)
    80004c9e:	2785                	addiw	a5,a5,1
    80004ca0:	0007871b          	sext.w	a4,a5
    80004ca4:	fe843783          	ld	a5,-24(s0)
    80004ca8:	c3b8                	sw	a4,64(a5)
  release(&bcache.lock);
    80004caa:	00015517          	auipc	a0,0x15
    80004cae:	d4650513          	addi	a0,a0,-698 # 800199f0 <bcache>
    80004cb2:	ffffc097          	auipc	ra,0xffffc
    80004cb6:	62a080e7          	jalr	1578(ra) # 800012dc <release>
}
    80004cba:	0001                	nop
    80004cbc:	60e2                	ld	ra,24(sp)
    80004cbe:	6442                	ld	s0,16(sp)
    80004cc0:	6105                	addi	sp,sp,32
    80004cc2:	8082                	ret

0000000080004cc4 <bunpin>:

void
bunpin(struct buf *b) {
    80004cc4:	1101                	addi	sp,sp,-32
    80004cc6:	ec06                	sd	ra,24(sp)
    80004cc8:	e822                	sd	s0,16(sp)
    80004cca:	1000                	addi	s0,sp,32
    80004ccc:	fea43423          	sd	a0,-24(s0)
  acquire(&bcache.lock);
    80004cd0:	00015517          	auipc	a0,0x15
    80004cd4:	d2050513          	addi	a0,a0,-736 # 800199f0 <bcache>
    80004cd8:	ffffc097          	auipc	ra,0xffffc
    80004cdc:	5a0080e7          	jalr	1440(ra) # 80001278 <acquire>
  b->refcnt--;
    80004ce0:	fe843783          	ld	a5,-24(s0)
    80004ce4:	43bc                	lw	a5,64(a5)
    80004ce6:	37fd                	addiw	a5,a5,-1
    80004ce8:	0007871b          	sext.w	a4,a5
    80004cec:	fe843783          	ld	a5,-24(s0)
    80004cf0:	c3b8                	sw	a4,64(a5)
  release(&bcache.lock);
    80004cf2:	00015517          	auipc	a0,0x15
    80004cf6:	cfe50513          	addi	a0,a0,-770 # 800199f0 <bcache>
    80004cfa:	ffffc097          	auipc	ra,0xffffc
    80004cfe:	5e2080e7          	jalr	1506(ra) # 800012dc <release>
}
    80004d02:	0001                	nop
    80004d04:	60e2                	ld	ra,24(sp)
    80004d06:	6442                	ld	s0,16(sp)
    80004d08:	6105                	addi	sp,sp,32
    80004d0a:	8082                	ret

0000000080004d0c <readsb>:
struct superblock sb; 

// Read the super block.
static void
readsb(int dev, struct superblock *sb)
{
    80004d0c:	7179                	addi	sp,sp,-48
    80004d0e:	f406                	sd	ra,40(sp)
    80004d10:	f022                	sd	s0,32(sp)
    80004d12:	1800                	addi	s0,sp,48
    80004d14:	87aa                	mv	a5,a0
    80004d16:	fcb43823          	sd	a1,-48(s0)
    80004d1a:	fcf42e23          	sw	a5,-36(s0)
  struct buf *bp;

  bp = bread(dev, 1);
    80004d1e:	fdc42783          	lw	a5,-36(s0)
    80004d22:	4585                	li	a1,1
    80004d24:	853e                	mv	a0,a5
    80004d26:	00000097          	auipc	ra,0x0
    80004d2a:	dc6080e7          	jalr	-570(ra) # 80004aec <bread>
    80004d2e:	fea43423          	sd	a0,-24(s0)
  memmove(sb, bp->data, sizeof(*sb));
    80004d32:	fe843783          	ld	a5,-24(s0)
    80004d36:	05878793          	addi	a5,a5,88
    80004d3a:	02000613          	li	a2,32
    80004d3e:	85be                	mv	a1,a5
    80004d40:	fd043503          	ld	a0,-48(s0)
    80004d44:	ffffc097          	auipc	ra,0xffffc
    80004d48:	7ec080e7          	jalr	2028(ra) # 80001530 <memmove>
  brelse(bp);
    80004d4c:	fe843503          	ld	a0,-24(s0)
    80004d50:	00000097          	auipc	ra,0x0
    80004d54:	e3e080e7          	jalr	-450(ra) # 80004b8e <brelse>
}
    80004d58:	0001                	nop
    80004d5a:	70a2                	ld	ra,40(sp)
    80004d5c:	7402                	ld	s0,32(sp)
    80004d5e:	6145                	addi	sp,sp,48
    80004d60:	8082                	ret

0000000080004d62 <fsinit>:

// Init fs
void
fsinit(int dev) {
    80004d62:	1101                	addi	sp,sp,-32
    80004d64:	ec06                	sd	ra,24(sp)
    80004d66:	e822                	sd	s0,16(sp)
    80004d68:	1000                	addi	s0,sp,32
    80004d6a:	87aa                	mv	a5,a0
    80004d6c:	fef42623          	sw	a5,-20(s0)
  readsb(dev, &sb);
    80004d70:	fec42783          	lw	a5,-20(s0)
    80004d74:	0001d597          	auipc	a1,0x1d
    80004d78:	33c58593          	addi	a1,a1,828 # 800220b0 <sb>
    80004d7c:	853e                	mv	a0,a5
    80004d7e:	00000097          	auipc	ra,0x0
    80004d82:	f8e080e7          	jalr	-114(ra) # 80004d0c <readsb>
  if(sb.magic != FSMAGIC)
    80004d86:	0001d797          	auipc	a5,0x1d
    80004d8a:	32a78793          	addi	a5,a5,810 # 800220b0 <sb>
    80004d8e:	439c                	lw	a5,0(a5)
    80004d90:	873e                	mv	a4,a5
    80004d92:	102037b7          	lui	a5,0x10203
    80004d96:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80004d9a:	00f70a63          	beq	a4,a5,80004dae <fsinit+0x4c>
    panic("invalid file system");
    80004d9e:	00006517          	auipc	a0,0x6
    80004da2:	6d250513          	addi	a0,a0,1746 # 8000b470 <etext+0x470>
    80004da6:	ffffc097          	auipc	ra,0xffffc
    80004daa:	ee4080e7          	jalr	-284(ra) # 80000c8a <panic>
  initlog(dev, &sb);
    80004dae:	fec42783          	lw	a5,-20(s0)
    80004db2:	0001d597          	auipc	a1,0x1d
    80004db6:	2fe58593          	addi	a1,a1,766 # 800220b0 <sb>
    80004dba:	853e                	mv	a0,a5
    80004dbc:	00001097          	auipc	ra,0x1
    80004dc0:	492080e7          	jalr	1170(ra) # 8000624e <initlog>
}
    80004dc4:	0001                	nop
    80004dc6:	60e2                	ld	ra,24(sp)
    80004dc8:	6442                	ld	s0,16(sp)
    80004dca:	6105                	addi	sp,sp,32
    80004dcc:	8082                	ret

0000000080004dce <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
    80004dce:	7179                	addi	sp,sp,-48
    80004dd0:	f406                	sd	ra,40(sp)
    80004dd2:	f022                	sd	s0,32(sp)
    80004dd4:	1800                	addi	s0,sp,48
    80004dd6:	87aa                	mv	a5,a0
    80004dd8:	872e                	mv	a4,a1
    80004dda:	fcf42e23          	sw	a5,-36(s0)
    80004dde:	87ba                	mv	a5,a4
    80004de0:	fcf42c23          	sw	a5,-40(s0)
  struct buf *bp;

  bp = bread(dev, bno);
    80004de4:	fdc42783          	lw	a5,-36(s0)
    80004de8:	fd842703          	lw	a4,-40(s0)
    80004dec:	85ba                	mv	a1,a4
    80004dee:	853e                	mv	a0,a5
    80004df0:	00000097          	auipc	ra,0x0
    80004df4:	cfc080e7          	jalr	-772(ra) # 80004aec <bread>
    80004df8:	fea43423          	sd	a0,-24(s0)
  memset(bp->data, 0, BSIZE);
    80004dfc:	fe843783          	ld	a5,-24(s0)
    80004e00:	05878793          	addi	a5,a5,88
    80004e04:	40000613          	li	a2,1024
    80004e08:	4581                	li	a1,0
    80004e0a:	853e                	mv	a0,a5
    80004e0c:	ffffc097          	auipc	ra,0xffffc
    80004e10:	640080e7          	jalr	1600(ra) # 8000144c <memset>
  log_write(bp);
    80004e14:	fe843503          	ld	a0,-24(s0)
    80004e18:	00002097          	auipc	ra,0x2
    80004e1c:	a1e080e7          	jalr	-1506(ra) # 80006836 <log_write>
  brelse(bp);
    80004e20:	fe843503          	ld	a0,-24(s0)
    80004e24:	00000097          	auipc	ra,0x0
    80004e28:	d6a080e7          	jalr	-662(ra) # 80004b8e <brelse>
}
    80004e2c:	0001                	nop
    80004e2e:	70a2                	ld	ra,40(sp)
    80004e30:	7402                	ld	s0,32(sp)
    80004e32:	6145                	addi	sp,sp,48
    80004e34:	8082                	ret

0000000080004e36 <balloc>:

// Allocate a zeroed disk block.
// returns 0 if out of disk space.
static uint
balloc(uint dev)
{
    80004e36:	7139                	addi	sp,sp,-64
    80004e38:	fc06                	sd	ra,56(sp)
    80004e3a:	f822                	sd	s0,48(sp)
    80004e3c:	0080                	addi	s0,sp,64
    80004e3e:	87aa                	mv	a5,a0
    80004e40:	fcf42623          	sw	a5,-52(s0)
  int b, bi, m;
  struct buf *bp;

  bp = 0;
    80004e44:	fe043023          	sd	zero,-32(s0)
  for(b = 0; b < sb.size; b += BPB){
    80004e48:	fe042623          	sw	zero,-20(s0)
    80004e4c:	a295                	j	80004fb0 <balloc+0x17a>
    bp = bread(dev, BBLOCK(b, sb));
    80004e4e:	fec42783          	lw	a5,-20(s0)
    80004e52:	41f7d71b          	sraiw	a4,a5,0x1f
    80004e56:	0137571b          	srliw	a4,a4,0x13
    80004e5a:	9fb9                	addw	a5,a5,a4
    80004e5c:	40d7d79b          	sraiw	a5,a5,0xd
    80004e60:	2781                	sext.w	a5,a5
    80004e62:	0007871b          	sext.w	a4,a5
    80004e66:	0001d797          	auipc	a5,0x1d
    80004e6a:	24a78793          	addi	a5,a5,586 # 800220b0 <sb>
    80004e6e:	4fdc                	lw	a5,28(a5)
    80004e70:	9fb9                	addw	a5,a5,a4
    80004e72:	0007871b          	sext.w	a4,a5
    80004e76:	fcc42783          	lw	a5,-52(s0)
    80004e7a:	85ba                	mv	a1,a4
    80004e7c:	853e                	mv	a0,a5
    80004e7e:	00000097          	auipc	ra,0x0
    80004e82:	c6e080e7          	jalr	-914(ra) # 80004aec <bread>
    80004e86:	fea43023          	sd	a0,-32(s0)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004e8a:	fe042423          	sw	zero,-24(s0)
    80004e8e:	a8e9                	j	80004f68 <balloc+0x132>
      m = 1 << (bi % 8);
    80004e90:	fe842783          	lw	a5,-24(s0)
    80004e94:	8b9d                	andi	a5,a5,7
    80004e96:	2781                	sext.w	a5,a5
    80004e98:	4705                	li	a4,1
    80004e9a:	00f717bb          	sllw	a5,a4,a5
    80004e9e:	fcf42e23          	sw	a5,-36(s0)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80004ea2:	fe842783          	lw	a5,-24(s0)
    80004ea6:	41f7d71b          	sraiw	a4,a5,0x1f
    80004eaa:	01d7571b          	srliw	a4,a4,0x1d
    80004eae:	9fb9                	addw	a5,a5,a4
    80004eb0:	4037d79b          	sraiw	a5,a5,0x3
    80004eb4:	2781                	sext.w	a5,a5
    80004eb6:	fe043703          	ld	a4,-32(s0)
    80004eba:	97ba                	add	a5,a5,a4
    80004ebc:	0587c783          	lbu	a5,88(a5)
    80004ec0:	2781                	sext.w	a5,a5
    80004ec2:	fdc42703          	lw	a4,-36(s0)
    80004ec6:	8ff9                	and	a5,a5,a4
    80004ec8:	2781                	sext.w	a5,a5
    80004eca:	ebd1                	bnez	a5,80004f5e <balloc+0x128>
        bp->data[bi/8] |= m;  // Mark block in use.
    80004ecc:	fe842783          	lw	a5,-24(s0)
    80004ed0:	41f7d71b          	sraiw	a4,a5,0x1f
    80004ed4:	01d7571b          	srliw	a4,a4,0x1d
    80004ed8:	9fb9                	addw	a5,a5,a4
    80004eda:	4037d79b          	sraiw	a5,a5,0x3
    80004ede:	2781                	sext.w	a5,a5
    80004ee0:	fe043703          	ld	a4,-32(s0)
    80004ee4:	973e                	add	a4,a4,a5
    80004ee6:	05874703          	lbu	a4,88(a4)
    80004eea:	0187169b          	slliw	a3,a4,0x18
    80004eee:	4186d69b          	sraiw	a3,a3,0x18
    80004ef2:	fdc42703          	lw	a4,-36(s0)
    80004ef6:	0187171b          	slliw	a4,a4,0x18
    80004efa:	4187571b          	sraiw	a4,a4,0x18
    80004efe:	8f55                	or	a4,a4,a3
    80004f00:	0187171b          	slliw	a4,a4,0x18
    80004f04:	4187571b          	sraiw	a4,a4,0x18
    80004f08:	0ff77713          	zext.b	a4,a4
    80004f0c:	fe043683          	ld	a3,-32(s0)
    80004f10:	97b6                	add	a5,a5,a3
    80004f12:	04e78c23          	sb	a4,88(a5)
        log_write(bp);
    80004f16:	fe043503          	ld	a0,-32(s0)
    80004f1a:	00002097          	auipc	ra,0x2
    80004f1e:	91c080e7          	jalr	-1764(ra) # 80006836 <log_write>
        brelse(bp);
    80004f22:	fe043503          	ld	a0,-32(s0)
    80004f26:	00000097          	auipc	ra,0x0
    80004f2a:	c68080e7          	jalr	-920(ra) # 80004b8e <brelse>
        bzero(dev, b + bi);
    80004f2e:	fcc42783          	lw	a5,-52(s0)
    80004f32:	fec42703          	lw	a4,-20(s0)
    80004f36:	86ba                	mv	a3,a4
    80004f38:	fe842703          	lw	a4,-24(s0)
    80004f3c:	9f35                	addw	a4,a4,a3
    80004f3e:	2701                	sext.w	a4,a4
    80004f40:	85ba                	mv	a1,a4
    80004f42:	853e                	mv	a0,a5
    80004f44:	00000097          	auipc	ra,0x0
    80004f48:	e8a080e7          	jalr	-374(ra) # 80004dce <bzero>
        return b + bi;
    80004f4c:	fec42783          	lw	a5,-20(s0)
    80004f50:	873e                	mv	a4,a5
    80004f52:	fe842783          	lw	a5,-24(s0)
    80004f56:	9fb9                	addw	a5,a5,a4
    80004f58:	2781                	sext.w	a5,a5
    80004f5a:	2781                	sext.w	a5,a5
    80004f5c:	a8a5                	j	80004fd4 <balloc+0x19e>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80004f5e:	fe842783          	lw	a5,-24(s0)
    80004f62:	2785                	addiw	a5,a5,1
    80004f64:	fef42423          	sw	a5,-24(s0)
    80004f68:	fe842783          	lw	a5,-24(s0)
    80004f6c:	0007871b          	sext.w	a4,a5
    80004f70:	6789                	lui	a5,0x2
    80004f72:	02f75263          	bge	a4,a5,80004f96 <balloc+0x160>
    80004f76:	fec42783          	lw	a5,-20(s0)
    80004f7a:	873e                	mv	a4,a5
    80004f7c:	fe842783          	lw	a5,-24(s0)
    80004f80:	9fb9                	addw	a5,a5,a4
    80004f82:	2781                	sext.w	a5,a5
    80004f84:	0007871b          	sext.w	a4,a5
    80004f88:	0001d797          	auipc	a5,0x1d
    80004f8c:	12878793          	addi	a5,a5,296 # 800220b0 <sb>
    80004f90:	43dc                	lw	a5,4(a5)
    80004f92:	eef76fe3          	bltu	a4,a5,80004e90 <balloc+0x5a>
      }
    }
    brelse(bp);
    80004f96:	fe043503          	ld	a0,-32(s0)
    80004f9a:	00000097          	auipc	ra,0x0
    80004f9e:	bf4080e7          	jalr	-1036(ra) # 80004b8e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80004fa2:	fec42783          	lw	a5,-20(s0)
    80004fa6:	873e                	mv	a4,a5
    80004fa8:	6789                	lui	a5,0x2
    80004faa:	9fb9                	addw	a5,a5,a4
    80004fac:	fef42623          	sw	a5,-20(s0)
    80004fb0:	0001d797          	auipc	a5,0x1d
    80004fb4:	10078793          	addi	a5,a5,256 # 800220b0 <sb>
    80004fb8:	43d8                	lw	a4,4(a5)
    80004fba:	fec42783          	lw	a5,-20(s0)
    80004fbe:	e8e7e8e3          	bltu	a5,a4,80004e4e <balloc+0x18>
  }
  printf("balloc: out of blocks\n");
    80004fc2:	00006517          	auipc	a0,0x6
    80004fc6:	4c650513          	addi	a0,a0,1222 # 8000b488 <etext+0x488>
    80004fca:	ffffc097          	auipc	ra,0xffffc
    80004fce:	a6a080e7          	jalr	-1430(ra) # 80000a34 <printf>
  return 0;
    80004fd2:	4781                	li	a5,0
}
    80004fd4:	853e                	mv	a0,a5
    80004fd6:	70e2                	ld	ra,56(sp)
    80004fd8:	7442                	ld	s0,48(sp)
    80004fda:	6121                	addi	sp,sp,64
    80004fdc:	8082                	ret

0000000080004fde <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80004fde:	7179                	addi	sp,sp,-48
    80004fe0:	f406                	sd	ra,40(sp)
    80004fe2:	f022                	sd	s0,32(sp)
    80004fe4:	1800                	addi	s0,sp,48
    80004fe6:	87aa                	mv	a5,a0
    80004fe8:	872e                	mv	a4,a1
    80004fea:	fcf42e23          	sw	a5,-36(s0)
    80004fee:	87ba                	mv	a5,a4
    80004ff0:	fcf42c23          	sw	a5,-40(s0)
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80004ff4:	fdc42683          	lw	a3,-36(s0)
    80004ff8:	fd842783          	lw	a5,-40(s0)
    80004ffc:	00d7d79b          	srliw	a5,a5,0xd
    80005000:	0007871b          	sext.w	a4,a5
    80005004:	0001d797          	auipc	a5,0x1d
    80005008:	0ac78793          	addi	a5,a5,172 # 800220b0 <sb>
    8000500c:	4fdc                	lw	a5,28(a5)
    8000500e:	9fb9                	addw	a5,a5,a4
    80005010:	2781                	sext.w	a5,a5
    80005012:	85be                	mv	a1,a5
    80005014:	8536                	mv	a0,a3
    80005016:	00000097          	auipc	ra,0x0
    8000501a:	ad6080e7          	jalr	-1322(ra) # 80004aec <bread>
    8000501e:	fea43423          	sd	a0,-24(s0)
  bi = b % BPB;
    80005022:	fd842703          	lw	a4,-40(s0)
    80005026:	6789                	lui	a5,0x2
    80005028:	17fd                	addi	a5,a5,-1 # 1fff <_entry-0x7fffe001>
    8000502a:	8ff9                	and	a5,a5,a4
    8000502c:	fef42223          	sw	a5,-28(s0)
  m = 1 << (bi % 8);
    80005030:	fe442783          	lw	a5,-28(s0)
    80005034:	8b9d                	andi	a5,a5,7
    80005036:	2781                	sext.w	a5,a5
    80005038:	4705                	li	a4,1
    8000503a:	00f717bb          	sllw	a5,a4,a5
    8000503e:	fef42023          	sw	a5,-32(s0)
  if((bp->data[bi/8] & m) == 0)
    80005042:	fe442783          	lw	a5,-28(s0)
    80005046:	41f7d71b          	sraiw	a4,a5,0x1f
    8000504a:	01d7571b          	srliw	a4,a4,0x1d
    8000504e:	9fb9                	addw	a5,a5,a4
    80005050:	4037d79b          	sraiw	a5,a5,0x3
    80005054:	2781                	sext.w	a5,a5
    80005056:	fe843703          	ld	a4,-24(s0)
    8000505a:	97ba                	add	a5,a5,a4
    8000505c:	0587c783          	lbu	a5,88(a5)
    80005060:	2781                	sext.w	a5,a5
    80005062:	fe042703          	lw	a4,-32(s0)
    80005066:	8ff9                	and	a5,a5,a4
    80005068:	2781                	sext.w	a5,a5
    8000506a:	eb89                	bnez	a5,8000507c <bfree+0x9e>
    panic("freeing free block");
    8000506c:	00006517          	auipc	a0,0x6
    80005070:	43450513          	addi	a0,a0,1076 # 8000b4a0 <etext+0x4a0>
    80005074:	ffffc097          	auipc	ra,0xffffc
    80005078:	c16080e7          	jalr	-1002(ra) # 80000c8a <panic>
  bp->data[bi/8] &= ~m;
    8000507c:	fe442783          	lw	a5,-28(s0)
    80005080:	41f7d71b          	sraiw	a4,a5,0x1f
    80005084:	01d7571b          	srliw	a4,a4,0x1d
    80005088:	9fb9                	addw	a5,a5,a4
    8000508a:	4037d79b          	sraiw	a5,a5,0x3
    8000508e:	2781                	sext.w	a5,a5
    80005090:	fe843703          	ld	a4,-24(s0)
    80005094:	973e                	add	a4,a4,a5
    80005096:	05874703          	lbu	a4,88(a4)
    8000509a:	0187169b          	slliw	a3,a4,0x18
    8000509e:	4186d69b          	sraiw	a3,a3,0x18
    800050a2:	fe042703          	lw	a4,-32(s0)
    800050a6:	0187171b          	slliw	a4,a4,0x18
    800050aa:	4187571b          	sraiw	a4,a4,0x18
    800050ae:	fff74713          	not	a4,a4
    800050b2:	0187171b          	slliw	a4,a4,0x18
    800050b6:	4187571b          	sraiw	a4,a4,0x18
    800050ba:	8f75                	and	a4,a4,a3
    800050bc:	0187171b          	slliw	a4,a4,0x18
    800050c0:	4187571b          	sraiw	a4,a4,0x18
    800050c4:	0ff77713          	zext.b	a4,a4
    800050c8:	fe843683          	ld	a3,-24(s0)
    800050cc:	97b6                	add	a5,a5,a3
    800050ce:	04e78c23          	sb	a4,88(a5)
  log_write(bp);
    800050d2:	fe843503          	ld	a0,-24(s0)
    800050d6:	00001097          	auipc	ra,0x1
    800050da:	760080e7          	jalr	1888(ra) # 80006836 <log_write>
  brelse(bp);
    800050de:	fe843503          	ld	a0,-24(s0)
    800050e2:	00000097          	auipc	ra,0x0
    800050e6:	aac080e7          	jalr	-1364(ra) # 80004b8e <brelse>
}
    800050ea:	0001                	nop
    800050ec:	70a2                	ld	ra,40(sp)
    800050ee:	7402                	ld	s0,32(sp)
    800050f0:	6145                	addi	sp,sp,48
    800050f2:	8082                	ret

00000000800050f4 <iinit>:
  struct inode inode[NINODE];
} itable;

void
iinit()
{
    800050f4:	1101                	addi	sp,sp,-32
    800050f6:	ec06                	sd	ra,24(sp)
    800050f8:	e822                	sd	s0,16(sp)
    800050fa:	1000                	addi	s0,sp,32
  int i = 0;
    800050fc:	fe042623          	sw	zero,-20(s0)
  
  initlock(&itable.lock, "itable");
    80005100:	00006597          	auipc	a1,0x6
    80005104:	3b858593          	addi	a1,a1,952 # 8000b4b8 <etext+0x4b8>
    80005108:	0001d517          	auipc	a0,0x1d
    8000510c:	fc850513          	addi	a0,a0,-56 # 800220d0 <itable>
    80005110:	ffffc097          	auipc	ra,0xffffc
    80005114:	138080e7          	jalr	312(ra) # 80001248 <initlock>
  for(i = 0; i < NINODE; i++) {
    80005118:	fe042623          	sw	zero,-20(s0)
    8000511c:	a82d                	j	80005156 <iinit+0x62>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000511e:	fec42703          	lw	a4,-20(s0)
    80005122:	87ba                	mv	a5,a4
    80005124:	0792                	slli	a5,a5,0x4
    80005126:	97ba                	add	a5,a5,a4
    80005128:	078e                	slli	a5,a5,0x3
    8000512a:	02078713          	addi	a4,a5,32
    8000512e:	0001d797          	auipc	a5,0x1d
    80005132:	fa278793          	addi	a5,a5,-94 # 800220d0 <itable>
    80005136:	97ba                	add	a5,a5,a4
    80005138:	07a1                	addi	a5,a5,8
    8000513a:	00006597          	auipc	a1,0x6
    8000513e:	38658593          	addi	a1,a1,902 # 8000b4c0 <etext+0x4c0>
    80005142:	853e                	mv	a0,a5
    80005144:	00002097          	auipc	ra,0x2
    80005148:	826080e7          	jalr	-2010(ra) # 8000696a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000514c:	fec42783          	lw	a5,-20(s0)
    80005150:	2785                	addiw	a5,a5,1
    80005152:	fef42623          	sw	a5,-20(s0)
    80005156:	fec42783          	lw	a5,-20(s0)
    8000515a:	0007871b          	sext.w	a4,a5
    8000515e:	03100793          	li	a5,49
    80005162:	fae7dee3          	bge	a5,a4,8000511e <iinit+0x2a>
  }
}
    80005166:	0001                	nop
    80005168:	0001                	nop
    8000516a:	60e2                	ld	ra,24(sp)
    8000516c:	6442                	ld	s0,16(sp)
    8000516e:	6105                	addi	sp,sp,32
    80005170:	8082                	ret

0000000080005172 <ialloc>:
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode,
// or NULL if there is no free inode.
struct inode*
ialloc(uint dev, short type)
{
    80005172:	7139                	addi	sp,sp,-64
    80005174:	fc06                	sd	ra,56(sp)
    80005176:	f822                	sd	s0,48(sp)
    80005178:	0080                	addi	s0,sp,64
    8000517a:	87aa                	mv	a5,a0
    8000517c:	872e                	mv	a4,a1
    8000517e:	fcf42623          	sw	a5,-52(s0)
    80005182:	87ba                	mv	a5,a4
    80005184:	fcf41523          	sh	a5,-54(s0)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
    80005188:	4785                	li	a5,1
    8000518a:	fef42623          	sw	a5,-20(s0)
    8000518e:	a855                	j	80005242 <ialloc+0xd0>
    bp = bread(dev, IBLOCK(inum, sb));
    80005190:	fec42783          	lw	a5,-20(s0)
    80005194:	8391                	srli	a5,a5,0x4
    80005196:	0007871b          	sext.w	a4,a5
    8000519a:	0001d797          	auipc	a5,0x1d
    8000519e:	f1678793          	addi	a5,a5,-234 # 800220b0 <sb>
    800051a2:	4f9c                	lw	a5,24(a5)
    800051a4:	9fb9                	addw	a5,a5,a4
    800051a6:	0007871b          	sext.w	a4,a5
    800051aa:	fcc42783          	lw	a5,-52(s0)
    800051ae:	85ba                	mv	a1,a4
    800051b0:	853e                	mv	a0,a5
    800051b2:	00000097          	auipc	ra,0x0
    800051b6:	93a080e7          	jalr	-1734(ra) # 80004aec <bread>
    800051ba:	fea43023          	sd	a0,-32(s0)
    dip = (struct dinode*)bp->data + inum%IPB;
    800051be:	fe043783          	ld	a5,-32(s0)
    800051c2:	05878713          	addi	a4,a5,88
    800051c6:	fec42783          	lw	a5,-20(s0)
    800051ca:	8bbd                	andi	a5,a5,15
    800051cc:	079a                	slli	a5,a5,0x6
    800051ce:	97ba                	add	a5,a5,a4
    800051d0:	fcf43c23          	sd	a5,-40(s0)
    if(dip->type == 0){  // a free inode
    800051d4:	fd843783          	ld	a5,-40(s0)
    800051d8:	00079783          	lh	a5,0(a5)
    800051dc:	eba1                	bnez	a5,8000522c <ialloc+0xba>
      memset(dip, 0, sizeof(*dip));
    800051de:	04000613          	li	a2,64
    800051e2:	4581                	li	a1,0
    800051e4:	fd843503          	ld	a0,-40(s0)
    800051e8:	ffffc097          	auipc	ra,0xffffc
    800051ec:	264080e7          	jalr	612(ra) # 8000144c <memset>
      dip->type = type;
    800051f0:	fd843783          	ld	a5,-40(s0)
    800051f4:	fca45703          	lhu	a4,-54(s0)
    800051f8:	00e79023          	sh	a4,0(a5)
      log_write(bp);   // mark it allocated on the disk
    800051fc:	fe043503          	ld	a0,-32(s0)
    80005200:	00001097          	auipc	ra,0x1
    80005204:	636080e7          	jalr	1590(ra) # 80006836 <log_write>
      brelse(bp);
    80005208:	fe043503          	ld	a0,-32(s0)
    8000520c:	00000097          	auipc	ra,0x0
    80005210:	982080e7          	jalr	-1662(ra) # 80004b8e <brelse>
      return iget(dev, inum);
    80005214:	fec42703          	lw	a4,-20(s0)
    80005218:	fcc42783          	lw	a5,-52(s0)
    8000521c:	85ba                	mv	a1,a4
    8000521e:	853e                	mv	a0,a5
    80005220:	00000097          	auipc	ra,0x0
    80005224:	138080e7          	jalr	312(ra) # 80005358 <iget>
    80005228:	87aa                	mv	a5,a0
    8000522a:	a835                	j	80005266 <ialloc+0xf4>
    }
    brelse(bp);
    8000522c:	fe043503          	ld	a0,-32(s0)
    80005230:	00000097          	auipc	ra,0x0
    80005234:	95e080e7          	jalr	-1698(ra) # 80004b8e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80005238:	fec42783          	lw	a5,-20(s0)
    8000523c:	2785                	addiw	a5,a5,1
    8000523e:	fef42623          	sw	a5,-20(s0)
    80005242:	0001d797          	auipc	a5,0x1d
    80005246:	e6e78793          	addi	a5,a5,-402 # 800220b0 <sb>
    8000524a:	47d8                	lw	a4,12(a5)
    8000524c:	fec42783          	lw	a5,-20(s0)
    80005250:	f4e7e0e3          	bltu	a5,a4,80005190 <ialloc+0x1e>
  }
  printf("ialloc: no inodes\n");
    80005254:	00006517          	auipc	a0,0x6
    80005258:	27450513          	addi	a0,a0,628 # 8000b4c8 <etext+0x4c8>
    8000525c:	ffffb097          	auipc	ra,0xffffb
    80005260:	7d8080e7          	jalr	2008(ra) # 80000a34 <printf>
  return 0;
    80005264:	4781                	li	a5,0
}
    80005266:	853e                	mv	a0,a5
    80005268:	70e2                	ld	ra,56(sp)
    8000526a:	7442                	ld	s0,48(sp)
    8000526c:	6121                	addi	sp,sp,64
    8000526e:	8082                	ret

0000000080005270 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
    80005270:	7179                	addi	sp,sp,-48
    80005272:	f406                	sd	ra,40(sp)
    80005274:	f022                	sd	s0,32(sp)
    80005276:	1800                	addi	s0,sp,48
    80005278:	fca43c23          	sd	a0,-40(s0)
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000527c:	fd843783          	ld	a5,-40(s0)
    80005280:	4394                	lw	a3,0(a5)
    80005282:	fd843783          	ld	a5,-40(s0)
    80005286:	43dc                	lw	a5,4(a5)
    80005288:	0047d79b          	srliw	a5,a5,0x4
    8000528c:	0007871b          	sext.w	a4,a5
    80005290:	0001d797          	auipc	a5,0x1d
    80005294:	e2078793          	addi	a5,a5,-480 # 800220b0 <sb>
    80005298:	4f9c                	lw	a5,24(a5)
    8000529a:	9fb9                	addw	a5,a5,a4
    8000529c:	2781                	sext.w	a5,a5
    8000529e:	85be                	mv	a1,a5
    800052a0:	8536                	mv	a0,a3
    800052a2:	00000097          	auipc	ra,0x0
    800052a6:	84a080e7          	jalr	-1974(ra) # 80004aec <bread>
    800052aa:	fea43423          	sd	a0,-24(s0)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800052ae:	fe843783          	ld	a5,-24(s0)
    800052b2:	05878713          	addi	a4,a5,88
    800052b6:	fd843783          	ld	a5,-40(s0)
    800052ba:	43dc                	lw	a5,4(a5)
    800052bc:	1782                	slli	a5,a5,0x20
    800052be:	9381                	srli	a5,a5,0x20
    800052c0:	8bbd                	andi	a5,a5,15
    800052c2:	079a                	slli	a5,a5,0x6
    800052c4:	97ba                	add	a5,a5,a4
    800052c6:	fef43023          	sd	a5,-32(s0)
  dip->type = ip->type;
    800052ca:	fd843783          	ld	a5,-40(s0)
    800052ce:	04479703          	lh	a4,68(a5)
    800052d2:	fe043783          	ld	a5,-32(s0)
    800052d6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800052da:	fd843783          	ld	a5,-40(s0)
    800052de:	04679703          	lh	a4,70(a5)
    800052e2:	fe043783          	ld	a5,-32(s0)
    800052e6:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800052ea:	fd843783          	ld	a5,-40(s0)
    800052ee:	04879703          	lh	a4,72(a5)
    800052f2:	fe043783          	ld	a5,-32(s0)
    800052f6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800052fa:	fd843783          	ld	a5,-40(s0)
    800052fe:	04a79703          	lh	a4,74(a5)
    80005302:	fe043783          	ld	a5,-32(s0)
    80005306:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000530a:	fd843783          	ld	a5,-40(s0)
    8000530e:	47f8                	lw	a4,76(a5)
    80005310:	fe043783          	ld	a5,-32(s0)
    80005314:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80005316:	fe043783          	ld	a5,-32(s0)
    8000531a:	00c78713          	addi	a4,a5,12
    8000531e:	fd843783          	ld	a5,-40(s0)
    80005322:	05078793          	addi	a5,a5,80
    80005326:	03400613          	li	a2,52
    8000532a:	85be                	mv	a1,a5
    8000532c:	853a                	mv	a0,a4
    8000532e:	ffffc097          	auipc	ra,0xffffc
    80005332:	202080e7          	jalr	514(ra) # 80001530 <memmove>
  log_write(bp);
    80005336:	fe843503          	ld	a0,-24(s0)
    8000533a:	00001097          	auipc	ra,0x1
    8000533e:	4fc080e7          	jalr	1276(ra) # 80006836 <log_write>
  brelse(bp);
    80005342:	fe843503          	ld	a0,-24(s0)
    80005346:	00000097          	auipc	ra,0x0
    8000534a:	848080e7          	jalr	-1976(ra) # 80004b8e <brelse>
}
    8000534e:	0001                	nop
    80005350:	70a2                	ld	ra,40(sp)
    80005352:	7402                	ld	s0,32(sp)
    80005354:	6145                	addi	sp,sp,48
    80005356:	8082                	ret

0000000080005358 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
    80005358:	7179                	addi	sp,sp,-48
    8000535a:	f406                	sd	ra,40(sp)
    8000535c:	f022                	sd	s0,32(sp)
    8000535e:	1800                	addi	s0,sp,48
    80005360:	87aa                	mv	a5,a0
    80005362:	872e                	mv	a4,a1
    80005364:	fcf42e23          	sw	a5,-36(s0)
    80005368:	87ba                	mv	a5,a4
    8000536a:	fcf42c23          	sw	a5,-40(s0)
  struct inode *ip, *empty;

  acquire(&itable.lock);
    8000536e:	0001d517          	auipc	a0,0x1d
    80005372:	d6250513          	addi	a0,a0,-670 # 800220d0 <itable>
    80005376:	ffffc097          	auipc	ra,0xffffc
    8000537a:	f02080e7          	jalr	-254(ra) # 80001278 <acquire>

  // Is the inode already in the table?
  empty = 0;
    8000537e:	fe043023          	sd	zero,-32(s0)
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80005382:	0001d797          	auipc	a5,0x1d
    80005386:	d6678793          	addi	a5,a5,-666 # 800220e8 <itable+0x18>
    8000538a:	fef43423          	sd	a5,-24(s0)
    8000538e:	a89d                	j	80005404 <iget+0xac>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80005390:	fe843783          	ld	a5,-24(s0)
    80005394:	479c                	lw	a5,8(a5)
    80005396:	04f05663          	blez	a5,800053e2 <iget+0x8a>
    8000539a:	fe843783          	ld	a5,-24(s0)
    8000539e:	4398                	lw	a4,0(a5)
    800053a0:	fdc42783          	lw	a5,-36(s0)
    800053a4:	2781                	sext.w	a5,a5
    800053a6:	02e79e63          	bne	a5,a4,800053e2 <iget+0x8a>
    800053aa:	fe843783          	ld	a5,-24(s0)
    800053ae:	43d8                	lw	a4,4(a5)
    800053b0:	fd842783          	lw	a5,-40(s0)
    800053b4:	2781                	sext.w	a5,a5
    800053b6:	02e79663          	bne	a5,a4,800053e2 <iget+0x8a>
      ip->ref++;
    800053ba:	fe843783          	ld	a5,-24(s0)
    800053be:	479c                	lw	a5,8(a5)
    800053c0:	2785                	addiw	a5,a5,1
    800053c2:	0007871b          	sext.w	a4,a5
    800053c6:	fe843783          	ld	a5,-24(s0)
    800053ca:	c798                	sw	a4,8(a5)
      release(&itable.lock);
    800053cc:	0001d517          	auipc	a0,0x1d
    800053d0:	d0450513          	addi	a0,a0,-764 # 800220d0 <itable>
    800053d4:	ffffc097          	auipc	ra,0xffffc
    800053d8:	f08080e7          	jalr	-248(ra) # 800012dc <release>
      return ip;
    800053dc:	fe843783          	ld	a5,-24(s0)
    800053e0:	a069                	j	8000546a <iget+0x112>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800053e2:	fe043783          	ld	a5,-32(s0)
    800053e6:	eb89                	bnez	a5,800053f8 <iget+0xa0>
    800053e8:	fe843783          	ld	a5,-24(s0)
    800053ec:	479c                	lw	a5,8(a5)
    800053ee:	e789                	bnez	a5,800053f8 <iget+0xa0>
      empty = ip;
    800053f0:	fe843783          	ld	a5,-24(s0)
    800053f4:	fef43023          	sd	a5,-32(s0)
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800053f8:	fe843783          	ld	a5,-24(s0)
    800053fc:	08878793          	addi	a5,a5,136
    80005400:	fef43423          	sd	a5,-24(s0)
    80005404:	fe843703          	ld	a4,-24(s0)
    80005408:	0001e797          	auipc	a5,0x1e
    8000540c:	77078793          	addi	a5,a5,1904 # 80023b78 <log>
    80005410:	f8f760e3          	bltu	a4,a5,80005390 <iget+0x38>
  }

  // Recycle an inode entry.
  if(empty == 0)
    80005414:	fe043783          	ld	a5,-32(s0)
    80005418:	eb89                	bnez	a5,8000542a <iget+0xd2>
    panic("iget: no inodes");
    8000541a:	00006517          	auipc	a0,0x6
    8000541e:	0c650513          	addi	a0,a0,198 # 8000b4e0 <etext+0x4e0>
    80005422:	ffffc097          	auipc	ra,0xffffc
    80005426:	868080e7          	jalr	-1944(ra) # 80000c8a <panic>

  ip = empty;
    8000542a:	fe043783          	ld	a5,-32(s0)
    8000542e:	fef43423          	sd	a5,-24(s0)
  ip->dev = dev;
    80005432:	fe843783          	ld	a5,-24(s0)
    80005436:	fdc42703          	lw	a4,-36(s0)
    8000543a:	c398                	sw	a4,0(a5)
  ip->inum = inum;
    8000543c:	fe843783          	ld	a5,-24(s0)
    80005440:	fd842703          	lw	a4,-40(s0)
    80005444:	c3d8                	sw	a4,4(a5)
  ip->ref = 1;
    80005446:	fe843783          	ld	a5,-24(s0)
    8000544a:	4705                	li	a4,1
    8000544c:	c798                	sw	a4,8(a5)
  ip->valid = 0;
    8000544e:	fe843783          	ld	a5,-24(s0)
    80005452:	0407a023          	sw	zero,64(a5)
  release(&itable.lock);
    80005456:	0001d517          	auipc	a0,0x1d
    8000545a:	c7a50513          	addi	a0,a0,-902 # 800220d0 <itable>
    8000545e:	ffffc097          	auipc	ra,0xffffc
    80005462:	e7e080e7          	jalr	-386(ra) # 800012dc <release>

  return ip;
    80005466:	fe843783          	ld	a5,-24(s0)
}
    8000546a:	853e                	mv	a0,a5
    8000546c:	70a2                	ld	ra,40(sp)
    8000546e:	7402                	ld	s0,32(sp)
    80005470:	6145                	addi	sp,sp,48
    80005472:	8082                	ret

0000000080005474 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
    80005474:	1101                	addi	sp,sp,-32
    80005476:	ec06                	sd	ra,24(sp)
    80005478:	e822                	sd	s0,16(sp)
    8000547a:	1000                	addi	s0,sp,32
    8000547c:	fea43423          	sd	a0,-24(s0)
  acquire(&itable.lock);
    80005480:	0001d517          	auipc	a0,0x1d
    80005484:	c5050513          	addi	a0,a0,-944 # 800220d0 <itable>
    80005488:	ffffc097          	auipc	ra,0xffffc
    8000548c:	df0080e7          	jalr	-528(ra) # 80001278 <acquire>
  ip->ref++;
    80005490:	fe843783          	ld	a5,-24(s0)
    80005494:	479c                	lw	a5,8(a5)
    80005496:	2785                	addiw	a5,a5,1
    80005498:	0007871b          	sext.w	a4,a5
    8000549c:	fe843783          	ld	a5,-24(s0)
    800054a0:	c798                	sw	a4,8(a5)
  release(&itable.lock);
    800054a2:	0001d517          	auipc	a0,0x1d
    800054a6:	c2e50513          	addi	a0,a0,-978 # 800220d0 <itable>
    800054aa:	ffffc097          	auipc	ra,0xffffc
    800054ae:	e32080e7          	jalr	-462(ra) # 800012dc <release>
  return ip;
    800054b2:	fe843783          	ld	a5,-24(s0)
}
    800054b6:	853e                	mv	a0,a5
    800054b8:	60e2                	ld	ra,24(sp)
    800054ba:	6442                	ld	s0,16(sp)
    800054bc:	6105                	addi	sp,sp,32
    800054be:	8082                	ret

00000000800054c0 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
    800054c0:	7179                	addi	sp,sp,-48
    800054c2:	f406                	sd	ra,40(sp)
    800054c4:	f022                	sd	s0,32(sp)
    800054c6:	1800                	addi	s0,sp,48
    800054c8:	fca43c23          	sd	a0,-40(s0)
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    800054cc:	fd843783          	ld	a5,-40(s0)
    800054d0:	c791                	beqz	a5,800054dc <ilock+0x1c>
    800054d2:	fd843783          	ld	a5,-40(s0)
    800054d6:	479c                	lw	a5,8(a5)
    800054d8:	00f04a63          	bgtz	a5,800054ec <ilock+0x2c>
    panic("ilock");
    800054dc:	00006517          	auipc	a0,0x6
    800054e0:	01450513          	addi	a0,a0,20 # 8000b4f0 <etext+0x4f0>
    800054e4:	ffffb097          	auipc	ra,0xffffb
    800054e8:	7a6080e7          	jalr	1958(ra) # 80000c8a <panic>

  acquiresleep(&ip->lock);
    800054ec:	fd843783          	ld	a5,-40(s0)
    800054f0:	07c1                	addi	a5,a5,16
    800054f2:	853e                	mv	a0,a5
    800054f4:	00001097          	auipc	ra,0x1
    800054f8:	4c2080e7          	jalr	1218(ra) # 800069b6 <acquiresleep>

  if(ip->valid == 0){
    800054fc:	fd843783          	ld	a5,-40(s0)
    80005500:	43bc                	lw	a5,64(a5)
    80005502:	e7e5                	bnez	a5,800055ea <ilock+0x12a>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80005504:	fd843783          	ld	a5,-40(s0)
    80005508:	4394                	lw	a3,0(a5)
    8000550a:	fd843783          	ld	a5,-40(s0)
    8000550e:	43dc                	lw	a5,4(a5)
    80005510:	0047d79b          	srliw	a5,a5,0x4
    80005514:	0007871b          	sext.w	a4,a5
    80005518:	0001d797          	auipc	a5,0x1d
    8000551c:	b9878793          	addi	a5,a5,-1128 # 800220b0 <sb>
    80005520:	4f9c                	lw	a5,24(a5)
    80005522:	9fb9                	addw	a5,a5,a4
    80005524:	2781                	sext.w	a5,a5
    80005526:	85be                	mv	a1,a5
    80005528:	8536                	mv	a0,a3
    8000552a:	fffff097          	auipc	ra,0xfffff
    8000552e:	5c2080e7          	jalr	1474(ra) # 80004aec <bread>
    80005532:	fea43423          	sd	a0,-24(s0)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80005536:	fe843783          	ld	a5,-24(s0)
    8000553a:	05878713          	addi	a4,a5,88
    8000553e:	fd843783          	ld	a5,-40(s0)
    80005542:	43dc                	lw	a5,4(a5)
    80005544:	1782                	slli	a5,a5,0x20
    80005546:	9381                	srli	a5,a5,0x20
    80005548:	8bbd                	andi	a5,a5,15
    8000554a:	079a                	slli	a5,a5,0x6
    8000554c:	97ba                	add	a5,a5,a4
    8000554e:	fef43023          	sd	a5,-32(s0)
    ip->type = dip->type;
    80005552:	fe043783          	ld	a5,-32(s0)
    80005556:	00079703          	lh	a4,0(a5)
    8000555a:	fd843783          	ld	a5,-40(s0)
    8000555e:	04e79223          	sh	a4,68(a5)
    ip->major = dip->major;
    80005562:	fe043783          	ld	a5,-32(s0)
    80005566:	00279703          	lh	a4,2(a5)
    8000556a:	fd843783          	ld	a5,-40(s0)
    8000556e:	04e79323          	sh	a4,70(a5)
    ip->minor = dip->minor;
    80005572:	fe043783          	ld	a5,-32(s0)
    80005576:	00479703          	lh	a4,4(a5)
    8000557a:	fd843783          	ld	a5,-40(s0)
    8000557e:	04e79423          	sh	a4,72(a5)
    ip->nlink = dip->nlink;
    80005582:	fe043783          	ld	a5,-32(s0)
    80005586:	00679703          	lh	a4,6(a5)
    8000558a:	fd843783          	ld	a5,-40(s0)
    8000558e:	04e79523          	sh	a4,74(a5)
    ip->size = dip->size;
    80005592:	fe043783          	ld	a5,-32(s0)
    80005596:	4798                	lw	a4,8(a5)
    80005598:	fd843783          	ld	a5,-40(s0)
    8000559c:	c7f8                	sw	a4,76(a5)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000559e:	fd843783          	ld	a5,-40(s0)
    800055a2:	05078713          	addi	a4,a5,80
    800055a6:	fe043783          	ld	a5,-32(s0)
    800055aa:	07b1                	addi	a5,a5,12
    800055ac:	03400613          	li	a2,52
    800055b0:	85be                	mv	a1,a5
    800055b2:	853a                	mv	a0,a4
    800055b4:	ffffc097          	auipc	ra,0xffffc
    800055b8:	f7c080e7          	jalr	-132(ra) # 80001530 <memmove>
    brelse(bp);
    800055bc:	fe843503          	ld	a0,-24(s0)
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	5ce080e7          	jalr	1486(ra) # 80004b8e <brelse>
    ip->valid = 1;
    800055c8:	fd843783          	ld	a5,-40(s0)
    800055cc:	4705                	li	a4,1
    800055ce:	c3b8                	sw	a4,64(a5)
    if(ip->type == 0)
    800055d0:	fd843783          	ld	a5,-40(s0)
    800055d4:	04479783          	lh	a5,68(a5)
    800055d8:	eb89                	bnez	a5,800055ea <ilock+0x12a>
      panic("ilock: no type");
    800055da:	00006517          	auipc	a0,0x6
    800055de:	f1e50513          	addi	a0,a0,-226 # 8000b4f8 <etext+0x4f8>
    800055e2:	ffffb097          	auipc	ra,0xffffb
    800055e6:	6a8080e7          	jalr	1704(ra) # 80000c8a <panic>
  }
}
    800055ea:	0001                	nop
    800055ec:	70a2                	ld	ra,40(sp)
    800055ee:	7402                	ld	s0,32(sp)
    800055f0:	6145                	addi	sp,sp,48
    800055f2:	8082                	ret

00000000800055f4 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
    800055f4:	1101                	addi	sp,sp,-32
    800055f6:	ec06                	sd	ra,24(sp)
    800055f8:	e822                	sd	s0,16(sp)
    800055fa:	1000                	addi	s0,sp,32
    800055fc:	fea43423          	sd	a0,-24(s0)
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80005600:	fe843783          	ld	a5,-24(s0)
    80005604:	c385                	beqz	a5,80005624 <iunlock+0x30>
    80005606:	fe843783          	ld	a5,-24(s0)
    8000560a:	07c1                	addi	a5,a5,16
    8000560c:	853e                	mv	a0,a5
    8000560e:	00001097          	auipc	ra,0x1
    80005612:	468080e7          	jalr	1128(ra) # 80006a76 <holdingsleep>
    80005616:	87aa                	mv	a5,a0
    80005618:	c791                	beqz	a5,80005624 <iunlock+0x30>
    8000561a:	fe843783          	ld	a5,-24(s0)
    8000561e:	479c                	lw	a5,8(a5)
    80005620:	00f04a63          	bgtz	a5,80005634 <iunlock+0x40>
    panic("iunlock");
    80005624:	00006517          	auipc	a0,0x6
    80005628:	ee450513          	addi	a0,a0,-284 # 8000b508 <etext+0x508>
    8000562c:	ffffb097          	auipc	ra,0xffffb
    80005630:	65e080e7          	jalr	1630(ra) # 80000c8a <panic>

  releasesleep(&ip->lock);
    80005634:	fe843783          	ld	a5,-24(s0)
    80005638:	07c1                	addi	a5,a5,16
    8000563a:	853e                	mv	a0,a5
    8000563c:	00001097          	auipc	ra,0x1
    80005640:	3e8080e7          	jalr	1000(ra) # 80006a24 <releasesleep>
}
    80005644:	0001                	nop
    80005646:	60e2                	ld	ra,24(sp)
    80005648:	6442                	ld	s0,16(sp)
    8000564a:	6105                	addi	sp,sp,32
    8000564c:	8082                	ret

000000008000564e <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
    8000564e:	1101                	addi	sp,sp,-32
    80005650:	ec06                	sd	ra,24(sp)
    80005652:	e822                	sd	s0,16(sp)
    80005654:	1000                	addi	s0,sp,32
    80005656:	fea43423          	sd	a0,-24(s0)
  acquire(&itable.lock);
    8000565a:	0001d517          	auipc	a0,0x1d
    8000565e:	a7650513          	addi	a0,a0,-1418 # 800220d0 <itable>
    80005662:	ffffc097          	auipc	ra,0xffffc
    80005666:	c16080e7          	jalr	-1002(ra) # 80001278 <acquire>

  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000566a:	fe843783          	ld	a5,-24(s0)
    8000566e:	479c                	lw	a5,8(a5)
    80005670:	873e                	mv	a4,a5
    80005672:	4785                	li	a5,1
    80005674:	06f71f63          	bne	a4,a5,800056f2 <iput+0xa4>
    80005678:	fe843783          	ld	a5,-24(s0)
    8000567c:	43bc                	lw	a5,64(a5)
    8000567e:	cbb5                	beqz	a5,800056f2 <iput+0xa4>
    80005680:	fe843783          	ld	a5,-24(s0)
    80005684:	04a79783          	lh	a5,74(a5)
    80005688:	e7ad                	bnez	a5,800056f2 <iput+0xa4>
    // inode has no links and no other references: truncate and free.

    // ip->ref == 1 means no other process can have ip locked,
    // so this acquiresleep() won't block (or deadlock).
    acquiresleep(&ip->lock);
    8000568a:	fe843783          	ld	a5,-24(s0)
    8000568e:	07c1                	addi	a5,a5,16
    80005690:	853e                	mv	a0,a5
    80005692:	00001097          	auipc	ra,0x1
    80005696:	324080e7          	jalr	804(ra) # 800069b6 <acquiresleep>

    release(&itable.lock);
    8000569a:	0001d517          	auipc	a0,0x1d
    8000569e:	a3650513          	addi	a0,a0,-1482 # 800220d0 <itable>
    800056a2:	ffffc097          	auipc	ra,0xffffc
    800056a6:	c3a080e7          	jalr	-966(ra) # 800012dc <release>

    itrunc(ip);
    800056aa:	fe843503          	ld	a0,-24(s0)
    800056ae:	00000097          	auipc	ra,0x0
    800056b2:	21a080e7          	jalr	538(ra) # 800058c8 <itrunc>
    ip->type = 0;
    800056b6:	fe843783          	ld	a5,-24(s0)
    800056ba:	04079223          	sh	zero,68(a5)
    iupdate(ip);
    800056be:	fe843503          	ld	a0,-24(s0)
    800056c2:	00000097          	auipc	ra,0x0
    800056c6:	bae080e7          	jalr	-1106(ra) # 80005270 <iupdate>
    ip->valid = 0;
    800056ca:	fe843783          	ld	a5,-24(s0)
    800056ce:	0407a023          	sw	zero,64(a5)

    releasesleep(&ip->lock);
    800056d2:	fe843783          	ld	a5,-24(s0)
    800056d6:	07c1                	addi	a5,a5,16
    800056d8:	853e                	mv	a0,a5
    800056da:	00001097          	auipc	ra,0x1
    800056de:	34a080e7          	jalr	842(ra) # 80006a24 <releasesleep>

    acquire(&itable.lock);
    800056e2:	0001d517          	auipc	a0,0x1d
    800056e6:	9ee50513          	addi	a0,a0,-1554 # 800220d0 <itable>
    800056ea:	ffffc097          	auipc	ra,0xffffc
    800056ee:	b8e080e7          	jalr	-1138(ra) # 80001278 <acquire>
  }

  ip->ref--;
    800056f2:	fe843783          	ld	a5,-24(s0)
    800056f6:	479c                	lw	a5,8(a5)
    800056f8:	37fd                	addiw	a5,a5,-1
    800056fa:	0007871b          	sext.w	a4,a5
    800056fe:	fe843783          	ld	a5,-24(s0)
    80005702:	c798                	sw	a4,8(a5)
  release(&itable.lock);
    80005704:	0001d517          	auipc	a0,0x1d
    80005708:	9cc50513          	addi	a0,a0,-1588 # 800220d0 <itable>
    8000570c:	ffffc097          	auipc	ra,0xffffc
    80005710:	bd0080e7          	jalr	-1072(ra) # 800012dc <release>
}
    80005714:	0001                	nop
    80005716:	60e2                	ld	ra,24(sp)
    80005718:	6442                	ld	s0,16(sp)
    8000571a:	6105                	addi	sp,sp,32
    8000571c:	8082                	ret

000000008000571e <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
    8000571e:	1101                	addi	sp,sp,-32
    80005720:	ec06                	sd	ra,24(sp)
    80005722:	e822                	sd	s0,16(sp)
    80005724:	1000                	addi	s0,sp,32
    80005726:	fea43423          	sd	a0,-24(s0)
  iunlock(ip);
    8000572a:	fe843503          	ld	a0,-24(s0)
    8000572e:	00000097          	auipc	ra,0x0
    80005732:	ec6080e7          	jalr	-314(ra) # 800055f4 <iunlock>
  iput(ip);
    80005736:	fe843503          	ld	a0,-24(s0)
    8000573a:	00000097          	auipc	ra,0x0
    8000573e:	f14080e7          	jalr	-236(ra) # 8000564e <iput>
}
    80005742:	0001                	nop
    80005744:	60e2                	ld	ra,24(sp)
    80005746:	6442                	ld	s0,16(sp)
    80005748:	6105                	addi	sp,sp,32
    8000574a:	8082                	ret

000000008000574c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000574c:	7139                	addi	sp,sp,-64
    8000574e:	fc06                	sd	ra,56(sp)
    80005750:	f822                	sd	s0,48(sp)
    80005752:	0080                	addi	s0,sp,64
    80005754:	fca43423          	sd	a0,-56(s0)
    80005758:	87ae                	mv	a5,a1
    8000575a:	fcf42223          	sw	a5,-60(s0)
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000575e:	fc442783          	lw	a5,-60(s0)
    80005762:	0007871b          	sext.w	a4,a5
    80005766:	47ad                	li	a5,11
    80005768:	04e7ee63          	bltu	a5,a4,800057c4 <bmap+0x78>
    if((addr = ip->addrs[bn]) == 0){
    8000576c:	fc843703          	ld	a4,-56(s0)
    80005770:	fc446783          	lwu	a5,-60(s0)
    80005774:	07d1                	addi	a5,a5,20
    80005776:	078a                	slli	a5,a5,0x2
    80005778:	97ba                	add	a5,a5,a4
    8000577a:	439c                	lw	a5,0(a5)
    8000577c:	fef42623          	sw	a5,-20(s0)
    80005780:	fec42783          	lw	a5,-20(s0)
    80005784:	2781                	sext.w	a5,a5
    80005786:	ef85                	bnez	a5,800057be <bmap+0x72>
      addr = balloc(ip->dev);
    80005788:	fc843783          	ld	a5,-56(s0)
    8000578c:	439c                	lw	a5,0(a5)
    8000578e:	853e                	mv	a0,a5
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	6a6080e7          	jalr	1702(ra) # 80004e36 <balloc>
    80005798:	87aa                	mv	a5,a0
    8000579a:	fef42623          	sw	a5,-20(s0)
      if(addr == 0)
    8000579e:	fec42783          	lw	a5,-20(s0)
    800057a2:	2781                	sext.w	a5,a5
    800057a4:	e399                	bnez	a5,800057aa <bmap+0x5e>
        return 0;
    800057a6:	4781                	li	a5,0
    800057a8:	aa19                	j	800058be <bmap+0x172>
      ip->addrs[bn] = addr;
    800057aa:	fc843703          	ld	a4,-56(s0)
    800057ae:	fc446783          	lwu	a5,-60(s0)
    800057b2:	07d1                	addi	a5,a5,20
    800057b4:	078a                	slli	a5,a5,0x2
    800057b6:	97ba                	add	a5,a5,a4
    800057b8:	fec42703          	lw	a4,-20(s0)
    800057bc:	c398                	sw	a4,0(a5)
    }
    return addr;
    800057be:	fec42783          	lw	a5,-20(s0)
    800057c2:	a8f5                	j	800058be <bmap+0x172>
  }
  bn -= NDIRECT;
    800057c4:	fc442783          	lw	a5,-60(s0)
    800057c8:	37d1                	addiw	a5,a5,-12
    800057ca:	fcf42223          	sw	a5,-60(s0)

  if(bn < NINDIRECT){
    800057ce:	fc442783          	lw	a5,-60(s0)
    800057d2:	0007871b          	sext.w	a4,a5
    800057d6:	0ff00793          	li	a5,255
    800057da:	0ce7ea63          	bltu	a5,a4,800058ae <bmap+0x162>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800057de:	fc843783          	ld	a5,-56(s0)
    800057e2:	0807a783          	lw	a5,128(a5)
    800057e6:	fef42623          	sw	a5,-20(s0)
    800057ea:	fec42783          	lw	a5,-20(s0)
    800057ee:	2781                	sext.w	a5,a5
    800057f0:	eb85                	bnez	a5,80005820 <bmap+0xd4>
      addr = balloc(ip->dev);
    800057f2:	fc843783          	ld	a5,-56(s0)
    800057f6:	439c                	lw	a5,0(a5)
    800057f8:	853e                	mv	a0,a5
    800057fa:	fffff097          	auipc	ra,0xfffff
    800057fe:	63c080e7          	jalr	1596(ra) # 80004e36 <balloc>
    80005802:	87aa                	mv	a5,a0
    80005804:	fef42623          	sw	a5,-20(s0)
      if(addr == 0)
    80005808:	fec42783          	lw	a5,-20(s0)
    8000580c:	2781                	sext.w	a5,a5
    8000580e:	e399                	bnez	a5,80005814 <bmap+0xc8>
        return 0;
    80005810:	4781                	li	a5,0
    80005812:	a075                	j	800058be <bmap+0x172>
      ip->addrs[NDIRECT] = addr;
    80005814:	fc843783          	ld	a5,-56(s0)
    80005818:	fec42703          	lw	a4,-20(s0)
    8000581c:	08e7a023          	sw	a4,128(a5)
    }
    bp = bread(ip->dev, addr);
    80005820:	fc843783          	ld	a5,-56(s0)
    80005824:	439c                	lw	a5,0(a5)
    80005826:	fec42703          	lw	a4,-20(s0)
    8000582a:	85ba                	mv	a1,a4
    8000582c:	853e                	mv	a0,a5
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	2be080e7          	jalr	702(ra) # 80004aec <bread>
    80005836:	fea43023          	sd	a0,-32(s0)
    a = (uint*)bp->data;
    8000583a:	fe043783          	ld	a5,-32(s0)
    8000583e:	05878793          	addi	a5,a5,88
    80005842:	fcf43c23          	sd	a5,-40(s0)
    if((addr = a[bn]) == 0){
    80005846:	fc446783          	lwu	a5,-60(s0)
    8000584a:	078a                	slli	a5,a5,0x2
    8000584c:	fd843703          	ld	a4,-40(s0)
    80005850:	97ba                	add	a5,a5,a4
    80005852:	439c                	lw	a5,0(a5)
    80005854:	fef42623          	sw	a5,-20(s0)
    80005858:	fec42783          	lw	a5,-20(s0)
    8000585c:	2781                	sext.w	a5,a5
    8000585e:	ef9d                	bnez	a5,8000589c <bmap+0x150>
      addr = balloc(ip->dev);
    80005860:	fc843783          	ld	a5,-56(s0)
    80005864:	439c                	lw	a5,0(a5)
    80005866:	853e                	mv	a0,a5
    80005868:	fffff097          	auipc	ra,0xfffff
    8000586c:	5ce080e7          	jalr	1486(ra) # 80004e36 <balloc>
    80005870:	87aa                	mv	a5,a0
    80005872:	fef42623          	sw	a5,-20(s0)
      if(addr){
    80005876:	fec42783          	lw	a5,-20(s0)
    8000587a:	2781                	sext.w	a5,a5
    8000587c:	c385                	beqz	a5,8000589c <bmap+0x150>
        a[bn] = addr;
    8000587e:	fc446783          	lwu	a5,-60(s0)
    80005882:	078a                	slli	a5,a5,0x2
    80005884:	fd843703          	ld	a4,-40(s0)
    80005888:	97ba                	add	a5,a5,a4
    8000588a:	fec42703          	lw	a4,-20(s0)
    8000588e:	c398                	sw	a4,0(a5)
        log_write(bp);
    80005890:	fe043503          	ld	a0,-32(s0)
    80005894:	00001097          	auipc	ra,0x1
    80005898:	fa2080e7          	jalr	-94(ra) # 80006836 <log_write>
      }
    }
    brelse(bp);
    8000589c:	fe043503          	ld	a0,-32(s0)
    800058a0:	fffff097          	auipc	ra,0xfffff
    800058a4:	2ee080e7          	jalr	750(ra) # 80004b8e <brelse>
    return addr;
    800058a8:	fec42783          	lw	a5,-20(s0)
    800058ac:	a809                	j	800058be <bmap+0x172>
  }

  panic("bmap: out of range");
    800058ae:	00006517          	auipc	a0,0x6
    800058b2:	c6250513          	addi	a0,a0,-926 # 8000b510 <etext+0x510>
    800058b6:	ffffb097          	auipc	ra,0xffffb
    800058ba:	3d4080e7          	jalr	980(ra) # 80000c8a <panic>
}
    800058be:	853e                	mv	a0,a5
    800058c0:	70e2                	ld	ra,56(sp)
    800058c2:	7442                	ld	s0,48(sp)
    800058c4:	6121                	addi	sp,sp,64
    800058c6:	8082                	ret

00000000800058c8 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800058c8:	7139                	addi	sp,sp,-64
    800058ca:	fc06                	sd	ra,56(sp)
    800058cc:	f822                	sd	s0,48(sp)
    800058ce:	0080                	addi	s0,sp,64
    800058d0:	fca43423          	sd	a0,-56(s0)
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800058d4:	fe042623          	sw	zero,-20(s0)
    800058d8:	a899                	j	8000592e <itrunc+0x66>
    if(ip->addrs[i]){
    800058da:	fc843703          	ld	a4,-56(s0)
    800058de:	fec42783          	lw	a5,-20(s0)
    800058e2:	07d1                	addi	a5,a5,20
    800058e4:	078a                	slli	a5,a5,0x2
    800058e6:	97ba                	add	a5,a5,a4
    800058e8:	439c                	lw	a5,0(a5)
    800058ea:	cf8d                	beqz	a5,80005924 <itrunc+0x5c>
      bfree(ip->dev, ip->addrs[i]);
    800058ec:	fc843783          	ld	a5,-56(s0)
    800058f0:	439c                	lw	a5,0(a5)
    800058f2:	0007869b          	sext.w	a3,a5
    800058f6:	fc843703          	ld	a4,-56(s0)
    800058fa:	fec42783          	lw	a5,-20(s0)
    800058fe:	07d1                	addi	a5,a5,20
    80005900:	078a                	slli	a5,a5,0x2
    80005902:	97ba                	add	a5,a5,a4
    80005904:	439c                	lw	a5,0(a5)
    80005906:	85be                	mv	a1,a5
    80005908:	8536                	mv	a0,a3
    8000590a:	fffff097          	auipc	ra,0xfffff
    8000590e:	6d4080e7          	jalr	1748(ra) # 80004fde <bfree>
      ip->addrs[i] = 0;
    80005912:	fc843703          	ld	a4,-56(s0)
    80005916:	fec42783          	lw	a5,-20(s0)
    8000591a:	07d1                	addi	a5,a5,20
    8000591c:	078a                	slli	a5,a5,0x2
    8000591e:	97ba                	add	a5,a5,a4
    80005920:	0007a023          	sw	zero,0(a5)
  for(i = 0; i < NDIRECT; i++){
    80005924:	fec42783          	lw	a5,-20(s0)
    80005928:	2785                	addiw	a5,a5,1
    8000592a:	fef42623          	sw	a5,-20(s0)
    8000592e:	fec42783          	lw	a5,-20(s0)
    80005932:	0007871b          	sext.w	a4,a5
    80005936:	47ad                	li	a5,11
    80005938:	fae7d1e3          	bge	a5,a4,800058da <itrunc+0x12>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000593c:	fc843783          	ld	a5,-56(s0)
    80005940:	0807a783          	lw	a5,128(a5)
    80005944:	cbc5                	beqz	a5,800059f4 <itrunc+0x12c>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80005946:	fc843783          	ld	a5,-56(s0)
    8000594a:	4398                	lw	a4,0(a5)
    8000594c:	fc843783          	ld	a5,-56(s0)
    80005950:	0807a783          	lw	a5,128(a5)
    80005954:	85be                	mv	a1,a5
    80005956:	853a                	mv	a0,a4
    80005958:	fffff097          	auipc	ra,0xfffff
    8000595c:	194080e7          	jalr	404(ra) # 80004aec <bread>
    80005960:	fea43023          	sd	a0,-32(s0)
    a = (uint*)bp->data;
    80005964:	fe043783          	ld	a5,-32(s0)
    80005968:	05878793          	addi	a5,a5,88
    8000596c:	fcf43c23          	sd	a5,-40(s0)
    for(j = 0; j < NINDIRECT; j++){
    80005970:	fe042423          	sw	zero,-24(s0)
    80005974:	a081                	j	800059b4 <itrunc+0xec>
      if(a[j])
    80005976:	fe842783          	lw	a5,-24(s0)
    8000597a:	078a                	slli	a5,a5,0x2
    8000597c:	fd843703          	ld	a4,-40(s0)
    80005980:	97ba                	add	a5,a5,a4
    80005982:	439c                	lw	a5,0(a5)
    80005984:	c39d                	beqz	a5,800059aa <itrunc+0xe2>
        bfree(ip->dev, a[j]);
    80005986:	fc843783          	ld	a5,-56(s0)
    8000598a:	439c                	lw	a5,0(a5)
    8000598c:	0007869b          	sext.w	a3,a5
    80005990:	fe842783          	lw	a5,-24(s0)
    80005994:	078a                	slli	a5,a5,0x2
    80005996:	fd843703          	ld	a4,-40(s0)
    8000599a:	97ba                	add	a5,a5,a4
    8000599c:	439c                	lw	a5,0(a5)
    8000599e:	85be                	mv	a1,a5
    800059a0:	8536                	mv	a0,a3
    800059a2:	fffff097          	auipc	ra,0xfffff
    800059a6:	63c080e7          	jalr	1596(ra) # 80004fde <bfree>
    for(j = 0; j < NINDIRECT; j++){
    800059aa:	fe842783          	lw	a5,-24(s0)
    800059ae:	2785                	addiw	a5,a5,1
    800059b0:	fef42423          	sw	a5,-24(s0)
    800059b4:	fe842783          	lw	a5,-24(s0)
    800059b8:	873e                	mv	a4,a5
    800059ba:	0ff00793          	li	a5,255
    800059be:	fae7fce3          	bgeu	a5,a4,80005976 <itrunc+0xae>
    }
    brelse(bp);
    800059c2:	fe043503          	ld	a0,-32(s0)
    800059c6:	fffff097          	auipc	ra,0xfffff
    800059ca:	1c8080e7          	jalr	456(ra) # 80004b8e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800059ce:	fc843783          	ld	a5,-56(s0)
    800059d2:	439c                	lw	a5,0(a5)
    800059d4:	0007871b          	sext.w	a4,a5
    800059d8:	fc843783          	ld	a5,-56(s0)
    800059dc:	0807a783          	lw	a5,128(a5)
    800059e0:	85be                	mv	a1,a5
    800059e2:	853a                	mv	a0,a4
    800059e4:	fffff097          	auipc	ra,0xfffff
    800059e8:	5fa080e7          	jalr	1530(ra) # 80004fde <bfree>
    ip->addrs[NDIRECT] = 0;
    800059ec:	fc843783          	ld	a5,-56(s0)
    800059f0:	0807a023          	sw	zero,128(a5)
  }

  ip->size = 0;
    800059f4:	fc843783          	ld	a5,-56(s0)
    800059f8:	0407a623          	sw	zero,76(a5)
  iupdate(ip);
    800059fc:	fc843503          	ld	a0,-56(s0)
    80005a00:	00000097          	auipc	ra,0x0
    80005a04:	870080e7          	jalr	-1936(ra) # 80005270 <iupdate>
}
    80005a08:	0001                	nop
    80005a0a:	70e2                	ld	ra,56(sp)
    80005a0c:	7442                	ld	s0,48(sp)
    80005a0e:	6121                	addi	sp,sp,64
    80005a10:	8082                	ret

0000000080005a12 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80005a12:	1101                	addi	sp,sp,-32
    80005a14:	ec22                	sd	s0,24(sp)
    80005a16:	1000                	addi	s0,sp,32
    80005a18:	fea43423          	sd	a0,-24(s0)
    80005a1c:	feb43023          	sd	a1,-32(s0)
  st->dev = ip->dev;
    80005a20:	fe843783          	ld	a5,-24(s0)
    80005a24:	439c                	lw	a5,0(a5)
    80005a26:	0007871b          	sext.w	a4,a5
    80005a2a:	fe043783          	ld	a5,-32(s0)
    80005a2e:	c398                	sw	a4,0(a5)
  st->ino = ip->inum;
    80005a30:	fe843783          	ld	a5,-24(s0)
    80005a34:	43d8                	lw	a4,4(a5)
    80005a36:	fe043783          	ld	a5,-32(s0)
    80005a3a:	c3d8                	sw	a4,4(a5)
  st->type = ip->type;
    80005a3c:	fe843783          	ld	a5,-24(s0)
    80005a40:	04479703          	lh	a4,68(a5)
    80005a44:	fe043783          	ld	a5,-32(s0)
    80005a48:	00e79423          	sh	a4,8(a5)
  st->nlink = ip->nlink;
    80005a4c:	fe843783          	ld	a5,-24(s0)
    80005a50:	04a79703          	lh	a4,74(a5)
    80005a54:	fe043783          	ld	a5,-32(s0)
    80005a58:	00e79523          	sh	a4,10(a5)
  st->size = ip->size;
    80005a5c:	fe843783          	ld	a5,-24(s0)
    80005a60:	47fc                	lw	a5,76(a5)
    80005a62:	02079713          	slli	a4,a5,0x20
    80005a66:	9301                	srli	a4,a4,0x20
    80005a68:	fe043783          	ld	a5,-32(s0)
    80005a6c:	eb98                	sd	a4,16(a5)
}
    80005a6e:	0001                	nop
    80005a70:	6462                	ld	s0,24(sp)
    80005a72:	6105                	addi	sp,sp,32
    80005a74:	8082                	ret

0000000080005a76 <readi>:
// Caller must hold ip->lock.
// If user_dst==1, then dst is a user virtual address;
// otherwise, dst is a kernel address.
int
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
    80005a76:	715d                	addi	sp,sp,-80
    80005a78:	e486                	sd	ra,72(sp)
    80005a7a:	e0a2                	sd	s0,64(sp)
    80005a7c:	0880                	addi	s0,sp,80
    80005a7e:	fca43423          	sd	a0,-56(s0)
    80005a82:	87ae                	mv	a5,a1
    80005a84:	fac43c23          	sd	a2,-72(s0)
    80005a88:	fcf42223          	sw	a5,-60(s0)
    80005a8c:	87b6                	mv	a5,a3
    80005a8e:	fcf42023          	sw	a5,-64(s0)
    80005a92:	87ba                	mv	a5,a4
    80005a94:	faf42a23          	sw	a5,-76(s0)
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80005a98:	fc843783          	ld	a5,-56(s0)
    80005a9c:	47f8                	lw	a4,76(a5)
    80005a9e:	fc042783          	lw	a5,-64(s0)
    80005aa2:	2781                	sext.w	a5,a5
    80005aa4:	00f76f63          	bltu	a4,a5,80005ac2 <readi+0x4c>
    80005aa8:	fc042783          	lw	a5,-64(s0)
    80005aac:	873e                	mv	a4,a5
    80005aae:	fb442783          	lw	a5,-76(s0)
    80005ab2:	9fb9                	addw	a5,a5,a4
    80005ab4:	0007871b          	sext.w	a4,a5
    80005ab8:	fc042783          	lw	a5,-64(s0)
    80005abc:	2781                	sext.w	a5,a5
    80005abe:	00f77463          	bgeu	a4,a5,80005ac6 <readi+0x50>
    return 0;
    80005ac2:	4781                	li	a5,0
    80005ac4:	a299                	j	80005c0a <readi+0x194>
  if(off + n > ip->size)
    80005ac6:	fc042783          	lw	a5,-64(s0)
    80005aca:	873e                	mv	a4,a5
    80005acc:	fb442783          	lw	a5,-76(s0)
    80005ad0:	9fb9                	addw	a5,a5,a4
    80005ad2:	0007871b          	sext.w	a4,a5
    80005ad6:	fc843783          	ld	a5,-56(s0)
    80005ada:	47fc                	lw	a5,76(a5)
    80005adc:	00e7fa63          	bgeu	a5,a4,80005af0 <readi+0x7a>
    n = ip->size - off;
    80005ae0:	fc843783          	ld	a5,-56(s0)
    80005ae4:	47fc                	lw	a5,76(a5)
    80005ae6:	fc042703          	lw	a4,-64(s0)
    80005aea:	9f99                	subw	a5,a5,a4
    80005aec:	faf42a23          	sw	a5,-76(s0)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005af0:	fe042623          	sw	zero,-20(s0)
    80005af4:	a8f5                	j	80005bf0 <readi+0x17a>
    uint addr = bmap(ip, off/BSIZE);
    80005af6:	fc042783          	lw	a5,-64(s0)
    80005afa:	00a7d79b          	srliw	a5,a5,0xa
    80005afe:	2781                	sext.w	a5,a5
    80005b00:	85be                	mv	a1,a5
    80005b02:	fc843503          	ld	a0,-56(s0)
    80005b06:	00000097          	auipc	ra,0x0
    80005b0a:	c46080e7          	jalr	-954(ra) # 8000574c <bmap>
    80005b0e:	87aa                	mv	a5,a0
    80005b10:	fef42423          	sw	a5,-24(s0)
    if(addr == 0)
    80005b14:	fe842783          	lw	a5,-24(s0)
    80005b18:	2781                	sext.w	a5,a5
    80005b1a:	c7ed                	beqz	a5,80005c04 <readi+0x18e>
      break;
    bp = bread(ip->dev, addr);
    80005b1c:	fc843783          	ld	a5,-56(s0)
    80005b20:	439c                	lw	a5,0(a5)
    80005b22:	fe842703          	lw	a4,-24(s0)
    80005b26:	85ba                	mv	a1,a4
    80005b28:	853e                	mv	a0,a5
    80005b2a:	fffff097          	auipc	ra,0xfffff
    80005b2e:	fc2080e7          	jalr	-62(ra) # 80004aec <bread>
    80005b32:	fea43023          	sd	a0,-32(s0)
    m = min(n - tot, BSIZE - off%BSIZE);
    80005b36:	fc042783          	lw	a5,-64(s0)
    80005b3a:	3ff7f793          	andi	a5,a5,1023
    80005b3e:	2781                	sext.w	a5,a5
    80005b40:	40000713          	li	a4,1024
    80005b44:	40f707bb          	subw	a5,a4,a5
    80005b48:	2781                	sext.w	a5,a5
    80005b4a:	fb442703          	lw	a4,-76(s0)
    80005b4e:	86ba                	mv	a3,a4
    80005b50:	fec42703          	lw	a4,-20(s0)
    80005b54:	40e6873b          	subw	a4,a3,a4
    80005b58:	2701                	sext.w	a4,a4
    80005b5a:	863a                	mv	a2,a4
    80005b5c:	0007869b          	sext.w	a3,a5
    80005b60:	0006071b          	sext.w	a4,a2
    80005b64:	00d77363          	bgeu	a4,a3,80005b6a <readi+0xf4>
    80005b68:	87b2                	mv	a5,a2
    80005b6a:	fcf42e23          	sw	a5,-36(s0)
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80005b6e:	fe043783          	ld	a5,-32(s0)
    80005b72:	05878713          	addi	a4,a5,88
    80005b76:	fc046783          	lwu	a5,-64(s0)
    80005b7a:	3ff7f793          	andi	a5,a5,1023
    80005b7e:	973e                	add	a4,a4,a5
    80005b80:	fdc46683          	lwu	a3,-36(s0)
    80005b84:	fc442783          	lw	a5,-60(s0)
    80005b88:	863a                	mv	a2,a4
    80005b8a:	fb843583          	ld	a1,-72(s0)
    80005b8e:	853e                	mv	a0,a5
    80005b90:	ffffe097          	auipc	ra,0xffffe
    80005b94:	a9c080e7          	jalr	-1380(ra) # 8000362c <either_copyout>
    80005b98:	87aa                	mv	a5,a0
    80005b9a:	873e                	mv	a4,a5
    80005b9c:	57fd                	li	a5,-1
    80005b9e:	00f71c63          	bne	a4,a5,80005bb6 <readi+0x140>
      brelse(bp);
    80005ba2:	fe043503          	ld	a0,-32(s0)
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	fe8080e7          	jalr	-24(ra) # 80004b8e <brelse>
      tot = -1;
    80005bae:	57fd                	li	a5,-1
    80005bb0:	fef42623          	sw	a5,-20(s0)
      break;
    80005bb4:	a889                	j	80005c06 <readi+0x190>
    }
    brelse(bp);
    80005bb6:	fe043503          	ld	a0,-32(s0)
    80005bba:	fffff097          	auipc	ra,0xfffff
    80005bbe:	fd4080e7          	jalr	-44(ra) # 80004b8e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80005bc2:	fec42783          	lw	a5,-20(s0)
    80005bc6:	873e                	mv	a4,a5
    80005bc8:	fdc42783          	lw	a5,-36(s0)
    80005bcc:	9fb9                	addw	a5,a5,a4
    80005bce:	fef42623          	sw	a5,-20(s0)
    80005bd2:	fc042783          	lw	a5,-64(s0)
    80005bd6:	873e                	mv	a4,a5
    80005bd8:	fdc42783          	lw	a5,-36(s0)
    80005bdc:	9fb9                	addw	a5,a5,a4
    80005bde:	fcf42023          	sw	a5,-64(s0)
    80005be2:	fdc46783          	lwu	a5,-36(s0)
    80005be6:	fb843703          	ld	a4,-72(s0)
    80005bea:	97ba                	add	a5,a5,a4
    80005bec:	faf43c23          	sd	a5,-72(s0)
    80005bf0:	fec42783          	lw	a5,-20(s0)
    80005bf4:	873e                	mv	a4,a5
    80005bf6:	fb442783          	lw	a5,-76(s0)
    80005bfa:	2701                	sext.w	a4,a4
    80005bfc:	2781                	sext.w	a5,a5
    80005bfe:	eef76ce3          	bltu	a4,a5,80005af6 <readi+0x80>
    80005c02:	a011                	j	80005c06 <readi+0x190>
      break;
    80005c04:	0001                	nop
  }
  return tot;
    80005c06:	fec42783          	lw	a5,-20(s0)
}
    80005c0a:	853e                	mv	a0,a5
    80005c0c:	60a6                	ld	ra,72(sp)
    80005c0e:	6406                	ld	s0,64(sp)
    80005c10:	6161                	addi	sp,sp,80
    80005c12:	8082                	ret

0000000080005c14 <writei>:
// Returns the number of bytes successfully written.
// If the return value is less than the requested n,
// there was an error of some kind.
int
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
    80005c14:	715d                	addi	sp,sp,-80
    80005c16:	e486                	sd	ra,72(sp)
    80005c18:	e0a2                	sd	s0,64(sp)
    80005c1a:	0880                	addi	s0,sp,80
    80005c1c:	fca43423          	sd	a0,-56(s0)
    80005c20:	87ae                	mv	a5,a1
    80005c22:	fac43c23          	sd	a2,-72(s0)
    80005c26:	fcf42223          	sw	a5,-60(s0)
    80005c2a:	87b6                	mv	a5,a3
    80005c2c:	fcf42023          	sw	a5,-64(s0)
    80005c30:	87ba                	mv	a5,a4
    80005c32:	faf42a23          	sw	a5,-76(s0)
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80005c36:	fc843783          	ld	a5,-56(s0)
    80005c3a:	47f8                	lw	a4,76(a5)
    80005c3c:	fc042783          	lw	a5,-64(s0)
    80005c40:	2781                	sext.w	a5,a5
    80005c42:	00f76f63          	bltu	a4,a5,80005c60 <writei+0x4c>
    80005c46:	fc042783          	lw	a5,-64(s0)
    80005c4a:	873e                	mv	a4,a5
    80005c4c:	fb442783          	lw	a5,-76(s0)
    80005c50:	9fb9                	addw	a5,a5,a4
    80005c52:	0007871b          	sext.w	a4,a5
    80005c56:	fc042783          	lw	a5,-64(s0)
    80005c5a:	2781                	sext.w	a5,a5
    80005c5c:	00f77463          	bgeu	a4,a5,80005c64 <writei+0x50>
    return -1;
    80005c60:	57fd                	li	a5,-1
    80005c62:	a295                	j	80005dc6 <writei+0x1b2>
  if(off + n > MAXFILE*BSIZE)
    80005c64:	fc042783          	lw	a5,-64(s0)
    80005c68:	873e                	mv	a4,a5
    80005c6a:	fb442783          	lw	a5,-76(s0)
    80005c6e:	9fb9                	addw	a5,a5,a4
    80005c70:	2781                	sext.w	a5,a5
    80005c72:	873e                	mv	a4,a5
    80005c74:	000437b7          	lui	a5,0x43
    80005c78:	00e7f463          	bgeu	a5,a4,80005c80 <writei+0x6c>
    return -1;
    80005c7c:	57fd                	li	a5,-1
    80005c7e:	a2a1                	j	80005dc6 <writei+0x1b2>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80005c80:	fe042623          	sw	zero,-20(s0)
    80005c84:	a209                	j	80005d86 <writei+0x172>
    uint addr = bmap(ip, off/BSIZE);
    80005c86:	fc042783          	lw	a5,-64(s0)
    80005c8a:	00a7d79b          	srliw	a5,a5,0xa
    80005c8e:	2781                	sext.w	a5,a5
    80005c90:	85be                	mv	a1,a5
    80005c92:	fc843503          	ld	a0,-56(s0)
    80005c96:	00000097          	auipc	ra,0x0
    80005c9a:	ab6080e7          	jalr	-1354(ra) # 8000574c <bmap>
    80005c9e:	87aa                	mv	a5,a0
    80005ca0:	fef42423          	sw	a5,-24(s0)
    if(addr == 0)
    80005ca4:	fe842783          	lw	a5,-24(s0)
    80005ca8:	2781                	sext.w	a5,a5
    80005caa:	cbe5                	beqz	a5,80005d9a <writei+0x186>
      break;
    bp = bread(ip->dev, addr);
    80005cac:	fc843783          	ld	a5,-56(s0)
    80005cb0:	439c                	lw	a5,0(a5)
    80005cb2:	fe842703          	lw	a4,-24(s0)
    80005cb6:	85ba                	mv	a1,a4
    80005cb8:	853e                	mv	a0,a5
    80005cba:	fffff097          	auipc	ra,0xfffff
    80005cbe:	e32080e7          	jalr	-462(ra) # 80004aec <bread>
    80005cc2:	fea43023          	sd	a0,-32(s0)
    m = min(n - tot, BSIZE - off%BSIZE);
    80005cc6:	fc042783          	lw	a5,-64(s0)
    80005cca:	3ff7f793          	andi	a5,a5,1023
    80005cce:	2781                	sext.w	a5,a5
    80005cd0:	40000713          	li	a4,1024
    80005cd4:	40f707bb          	subw	a5,a4,a5
    80005cd8:	2781                	sext.w	a5,a5
    80005cda:	fb442703          	lw	a4,-76(s0)
    80005cde:	86ba                	mv	a3,a4
    80005ce0:	fec42703          	lw	a4,-20(s0)
    80005ce4:	40e6873b          	subw	a4,a3,a4
    80005ce8:	2701                	sext.w	a4,a4
    80005cea:	863a                	mv	a2,a4
    80005cec:	0007869b          	sext.w	a3,a5
    80005cf0:	0006071b          	sext.w	a4,a2
    80005cf4:	00d77363          	bgeu	a4,a3,80005cfa <writei+0xe6>
    80005cf8:	87b2                	mv	a5,a2
    80005cfa:	fcf42e23          	sw	a5,-36(s0)
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80005cfe:	fe043783          	ld	a5,-32(s0)
    80005d02:	05878713          	addi	a4,a5,88 # 43058 <_entry-0x7ffbcfa8>
    80005d06:	fc046783          	lwu	a5,-64(s0)
    80005d0a:	3ff7f793          	andi	a5,a5,1023
    80005d0e:	97ba                	add	a5,a5,a4
    80005d10:	fdc46683          	lwu	a3,-36(s0)
    80005d14:	fc442703          	lw	a4,-60(s0)
    80005d18:	fb843603          	ld	a2,-72(s0)
    80005d1c:	85ba                	mv	a1,a4
    80005d1e:	853e                	mv	a0,a5
    80005d20:	ffffe097          	auipc	ra,0xffffe
    80005d24:	980080e7          	jalr	-1664(ra) # 800036a0 <either_copyin>
    80005d28:	87aa                	mv	a5,a0
    80005d2a:	873e                	mv	a4,a5
    80005d2c:	57fd                	li	a5,-1
    80005d2e:	00f71963          	bne	a4,a5,80005d40 <writei+0x12c>
      brelse(bp);
    80005d32:	fe043503          	ld	a0,-32(s0)
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	e58080e7          	jalr	-424(ra) # 80004b8e <brelse>
      break;
    80005d3e:	a8b9                	j	80005d9c <writei+0x188>
    }
    log_write(bp);
    80005d40:	fe043503          	ld	a0,-32(s0)
    80005d44:	00001097          	auipc	ra,0x1
    80005d48:	af2080e7          	jalr	-1294(ra) # 80006836 <log_write>
    brelse(bp);
    80005d4c:	fe043503          	ld	a0,-32(s0)
    80005d50:	fffff097          	auipc	ra,0xfffff
    80005d54:	e3e080e7          	jalr	-450(ra) # 80004b8e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80005d58:	fec42783          	lw	a5,-20(s0)
    80005d5c:	873e                	mv	a4,a5
    80005d5e:	fdc42783          	lw	a5,-36(s0)
    80005d62:	9fb9                	addw	a5,a5,a4
    80005d64:	fef42623          	sw	a5,-20(s0)
    80005d68:	fc042783          	lw	a5,-64(s0)
    80005d6c:	873e                	mv	a4,a5
    80005d6e:	fdc42783          	lw	a5,-36(s0)
    80005d72:	9fb9                	addw	a5,a5,a4
    80005d74:	fcf42023          	sw	a5,-64(s0)
    80005d78:	fdc46783          	lwu	a5,-36(s0)
    80005d7c:	fb843703          	ld	a4,-72(s0)
    80005d80:	97ba                	add	a5,a5,a4
    80005d82:	faf43c23          	sd	a5,-72(s0)
    80005d86:	fec42783          	lw	a5,-20(s0)
    80005d8a:	873e                	mv	a4,a5
    80005d8c:	fb442783          	lw	a5,-76(s0)
    80005d90:	2701                	sext.w	a4,a4
    80005d92:	2781                	sext.w	a5,a5
    80005d94:	eef769e3          	bltu	a4,a5,80005c86 <writei+0x72>
    80005d98:	a011                	j	80005d9c <writei+0x188>
      break;
    80005d9a:	0001                	nop
  }

  if(off > ip->size)
    80005d9c:	fc843783          	ld	a5,-56(s0)
    80005da0:	47f8                	lw	a4,76(a5)
    80005da2:	fc042783          	lw	a5,-64(s0)
    80005da6:	2781                	sext.w	a5,a5
    80005da8:	00f77763          	bgeu	a4,a5,80005db6 <writei+0x1a2>
    ip->size = off;
    80005dac:	fc843783          	ld	a5,-56(s0)
    80005db0:	fc042703          	lw	a4,-64(s0)
    80005db4:	c7f8                	sw	a4,76(a5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80005db6:	fc843503          	ld	a0,-56(s0)
    80005dba:	fffff097          	auipc	ra,0xfffff
    80005dbe:	4b6080e7          	jalr	1206(ra) # 80005270 <iupdate>

  return tot;
    80005dc2:	fec42783          	lw	a5,-20(s0)
}
    80005dc6:	853e                	mv	a0,a5
    80005dc8:	60a6                	ld	ra,72(sp)
    80005dca:	6406                	ld	s0,64(sp)
    80005dcc:	6161                	addi	sp,sp,80
    80005dce:	8082                	ret

0000000080005dd0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80005dd0:	1101                	addi	sp,sp,-32
    80005dd2:	ec06                	sd	ra,24(sp)
    80005dd4:	e822                	sd	s0,16(sp)
    80005dd6:	1000                	addi	s0,sp,32
    80005dd8:	fea43423          	sd	a0,-24(s0)
    80005ddc:	feb43023          	sd	a1,-32(s0)
  return strncmp(s, t, DIRSIZ);
    80005de0:	4639                	li	a2,14
    80005de2:	fe043583          	ld	a1,-32(s0)
    80005de6:	fe843503          	ld	a0,-24(s0)
    80005dea:	ffffc097          	auipc	ra,0xffffc
    80005dee:	85a080e7          	jalr	-1958(ra) # 80001644 <strncmp>
    80005df2:	87aa                	mv	a5,a0
}
    80005df4:	853e                	mv	a0,a5
    80005df6:	60e2                	ld	ra,24(sp)
    80005df8:	6442                	ld	s0,16(sp)
    80005dfa:	6105                	addi	sp,sp,32
    80005dfc:	8082                	ret

0000000080005dfe <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80005dfe:	715d                	addi	sp,sp,-80
    80005e00:	e486                	sd	ra,72(sp)
    80005e02:	e0a2                	sd	s0,64(sp)
    80005e04:	0880                	addi	s0,sp,80
    80005e06:	fca43423          	sd	a0,-56(s0)
    80005e0a:	fcb43023          	sd	a1,-64(s0)
    80005e0e:	fac43c23          	sd	a2,-72(s0)
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80005e12:	fc843783          	ld	a5,-56(s0)
    80005e16:	04479783          	lh	a5,68(a5)
    80005e1a:	0007871b          	sext.w	a4,a5
    80005e1e:	4785                	li	a5,1
    80005e20:	00f70a63          	beq	a4,a5,80005e34 <dirlookup+0x36>
    panic("dirlookup not DIR");
    80005e24:	00005517          	auipc	a0,0x5
    80005e28:	70450513          	addi	a0,a0,1796 # 8000b528 <etext+0x528>
    80005e2c:	ffffb097          	auipc	ra,0xffffb
    80005e30:	e5e080e7          	jalr	-418(ra) # 80000c8a <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
    80005e34:	fe042623          	sw	zero,-20(s0)
    80005e38:	a849                	j	80005eca <dirlookup+0xcc>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e3a:	fd840793          	addi	a5,s0,-40
    80005e3e:	fec42683          	lw	a3,-20(s0)
    80005e42:	4741                	li	a4,16
    80005e44:	863e                	mv	a2,a5
    80005e46:	4581                	li	a1,0
    80005e48:	fc843503          	ld	a0,-56(s0)
    80005e4c:	00000097          	auipc	ra,0x0
    80005e50:	c2a080e7          	jalr	-982(ra) # 80005a76 <readi>
    80005e54:	87aa                	mv	a5,a0
    80005e56:	873e                	mv	a4,a5
    80005e58:	47c1                	li	a5,16
    80005e5a:	00f70a63          	beq	a4,a5,80005e6e <dirlookup+0x70>
      panic("dirlookup read");
    80005e5e:	00005517          	auipc	a0,0x5
    80005e62:	6e250513          	addi	a0,a0,1762 # 8000b540 <etext+0x540>
    80005e66:	ffffb097          	auipc	ra,0xffffb
    80005e6a:	e24080e7          	jalr	-476(ra) # 80000c8a <panic>
    if(de.inum == 0)
    80005e6e:	fd845783          	lhu	a5,-40(s0)
    80005e72:	c7b1                	beqz	a5,80005ebe <dirlookup+0xc0>
      continue;
    if(namecmp(name, de.name) == 0){
    80005e74:	fd840793          	addi	a5,s0,-40
    80005e78:	0789                	addi	a5,a5,2
    80005e7a:	85be                	mv	a1,a5
    80005e7c:	fc043503          	ld	a0,-64(s0)
    80005e80:	00000097          	auipc	ra,0x0
    80005e84:	f50080e7          	jalr	-176(ra) # 80005dd0 <namecmp>
    80005e88:	87aa                	mv	a5,a0
    80005e8a:	eb9d                	bnez	a5,80005ec0 <dirlookup+0xc2>
      // entry matches path element
      if(poff)
    80005e8c:	fb843783          	ld	a5,-72(s0)
    80005e90:	c791                	beqz	a5,80005e9c <dirlookup+0x9e>
        *poff = off;
    80005e92:	fb843783          	ld	a5,-72(s0)
    80005e96:	fec42703          	lw	a4,-20(s0)
    80005e9a:	c398                	sw	a4,0(a5)
      inum = de.inum;
    80005e9c:	fd845783          	lhu	a5,-40(s0)
    80005ea0:	fef42423          	sw	a5,-24(s0)
      return iget(dp->dev, inum);
    80005ea4:	fc843783          	ld	a5,-56(s0)
    80005ea8:	439c                	lw	a5,0(a5)
    80005eaa:	fe842703          	lw	a4,-24(s0)
    80005eae:	85ba                	mv	a1,a4
    80005eb0:	853e                	mv	a0,a5
    80005eb2:	fffff097          	auipc	ra,0xfffff
    80005eb6:	4a6080e7          	jalr	1190(ra) # 80005358 <iget>
    80005eba:	87aa                	mv	a5,a0
    80005ebc:	a005                	j	80005edc <dirlookup+0xde>
      continue;
    80005ebe:	0001                	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005ec0:	fec42783          	lw	a5,-20(s0)
    80005ec4:	27c1                	addiw	a5,a5,16
    80005ec6:	fef42623          	sw	a5,-20(s0)
    80005eca:	fc843783          	ld	a5,-56(s0)
    80005ece:	47f8                	lw	a4,76(a5)
    80005ed0:	fec42783          	lw	a5,-20(s0)
    80005ed4:	2781                	sext.w	a5,a5
    80005ed6:	f6e7e2e3          	bltu	a5,a4,80005e3a <dirlookup+0x3c>
    }
  }

  return 0;
    80005eda:	4781                	li	a5,0
}
    80005edc:	853e                	mv	a0,a5
    80005ede:	60a6                	ld	ra,72(sp)
    80005ee0:	6406                	ld	s0,64(sp)
    80005ee2:	6161                	addi	sp,sp,80
    80005ee4:	8082                	ret

0000000080005ee6 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
// Returns 0 on success, -1 on failure (e.g. out of disk blocks).
int
dirlink(struct inode *dp, char *name, uint inum)
{
    80005ee6:	715d                	addi	sp,sp,-80
    80005ee8:	e486                	sd	ra,72(sp)
    80005eea:	e0a2                	sd	s0,64(sp)
    80005eec:	0880                	addi	s0,sp,80
    80005eee:	fca43423          	sd	a0,-56(s0)
    80005ef2:	fcb43023          	sd	a1,-64(s0)
    80005ef6:	87b2                	mv	a5,a2
    80005ef8:	faf42e23          	sw	a5,-68(s0)
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    80005efc:	4601                	li	a2,0
    80005efe:	fc043583          	ld	a1,-64(s0)
    80005f02:	fc843503          	ld	a0,-56(s0)
    80005f06:	00000097          	auipc	ra,0x0
    80005f0a:	ef8080e7          	jalr	-264(ra) # 80005dfe <dirlookup>
    80005f0e:	fea43023          	sd	a0,-32(s0)
    80005f12:	fe043783          	ld	a5,-32(s0)
    80005f16:	cb89                	beqz	a5,80005f28 <dirlink+0x42>
    iput(ip);
    80005f18:	fe043503          	ld	a0,-32(s0)
    80005f1c:	fffff097          	auipc	ra,0xfffff
    80005f20:	732080e7          	jalr	1842(ra) # 8000564e <iput>
    return -1;
    80005f24:	57fd                	li	a5,-1
    80005f26:	a075                	j	80005fd2 <dirlink+0xec>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005f28:	fe042623          	sw	zero,-20(s0)
    80005f2c:	a0a1                	j	80005f74 <dirlink+0x8e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005f2e:	fd040793          	addi	a5,s0,-48
    80005f32:	fec42683          	lw	a3,-20(s0)
    80005f36:	4741                	li	a4,16
    80005f38:	863e                	mv	a2,a5
    80005f3a:	4581                	li	a1,0
    80005f3c:	fc843503          	ld	a0,-56(s0)
    80005f40:	00000097          	auipc	ra,0x0
    80005f44:	b36080e7          	jalr	-1226(ra) # 80005a76 <readi>
    80005f48:	87aa                	mv	a5,a0
    80005f4a:	873e                	mv	a4,a5
    80005f4c:	47c1                	li	a5,16
    80005f4e:	00f70a63          	beq	a4,a5,80005f62 <dirlink+0x7c>
      panic("dirlink read");
    80005f52:	00005517          	auipc	a0,0x5
    80005f56:	5fe50513          	addi	a0,a0,1534 # 8000b550 <etext+0x550>
    80005f5a:	ffffb097          	auipc	ra,0xffffb
    80005f5e:	d30080e7          	jalr	-720(ra) # 80000c8a <panic>
    if(de.inum == 0)
    80005f62:	fd045783          	lhu	a5,-48(s0)
    80005f66:	cf99                	beqz	a5,80005f84 <dirlink+0x9e>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80005f68:	fec42783          	lw	a5,-20(s0)
    80005f6c:	27c1                	addiw	a5,a5,16
    80005f6e:	2781                	sext.w	a5,a5
    80005f70:	fef42623          	sw	a5,-20(s0)
    80005f74:	fc843783          	ld	a5,-56(s0)
    80005f78:	47f8                	lw	a4,76(a5)
    80005f7a:	fec42783          	lw	a5,-20(s0)
    80005f7e:	fae7e8e3          	bltu	a5,a4,80005f2e <dirlink+0x48>
    80005f82:	a011                	j	80005f86 <dirlink+0xa0>
      break;
    80005f84:	0001                	nop
  }

  strncpy(de.name, name, DIRSIZ);
    80005f86:	fd040793          	addi	a5,s0,-48
    80005f8a:	0789                	addi	a5,a5,2
    80005f8c:	4639                	li	a2,14
    80005f8e:	fc043583          	ld	a1,-64(s0)
    80005f92:	853e                	mv	a0,a5
    80005f94:	ffffb097          	auipc	ra,0xffffb
    80005f98:	73a080e7          	jalr	1850(ra) # 800016ce <strncpy>
  de.inum = inum;
    80005f9c:	fbc42783          	lw	a5,-68(s0)
    80005fa0:	17c2                	slli	a5,a5,0x30
    80005fa2:	93c1                	srli	a5,a5,0x30
    80005fa4:	fcf41823          	sh	a5,-48(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005fa8:	fd040793          	addi	a5,s0,-48
    80005fac:	fec42683          	lw	a3,-20(s0)
    80005fb0:	4741                	li	a4,16
    80005fb2:	863e                	mv	a2,a5
    80005fb4:	4581                	li	a1,0
    80005fb6:	fc843503          	ld	a0,-56(s0)
    80005fba:	00000097          	auipc	ra,0x0
    80005fbe:	c5a080e7          	jalr	-934(ra) # 80005c14 <writei>
    80005fc2:	87aa                	mv	a5,a0
    80005fc4:	873e                	mv	a4,a5
    80005fc6:	47c1                	li	a5,16
    80005fc8:	00f70463          	beq	a4,a5,80005fd0 <dirlink+0xea>
    return -1;
    80005fcc:	57fd                	li	a5,-1
    80005fce:	a011                	j	80005fd2 <dirlink+0xec>

  return 0;
    80005fd0:	4781                	li	a5,0
}
    80005fd2:	853e                	mv	a0,a5
    80005fd4:	60a6                	ld	ra,72(sp)
    80005fd6:	6406                	ld	s0,64(sp)
    80005fd8:	6161                	addi	sp,sp,80
    80005fda:	8082                	ret

0000000080005fdc <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
    80005fdc:	7179                	addi	sp,sp,-48
    80005fde:	f406                	sd	ra,40(sp)
    80005fe0:	f022                	sd	s0,32(sp)
    80005fe2:	1800                	addi	s0,sp,48
    80005fe4:	fca43c23          	sd	a0,-40(s0)
    80005fe8:	fcb43823          	sd	a1,-48(s0)
  char *s;
  int len;

  while(*path == '/')
    80005fec:	a031                	j	80005ff8 <skipelem+0x1c>
    path++;
    80005fee:	fd843783          	ld	a5,-40(s0)
    80005ff2:	0785                	addi	a5,a5,1
    80005ff4:	fcf43c23          	sd	a5,-40(s0)
  while(*path == '/')
    80005ff8:	fd843783          	ld	a5,-40(s0)
    80005ffc:	0007c783          	lbu	a5,0(a5)
    80006000:	873e                	mv	a4,a5
    80006002:	02f00793          	li	a5,47
    80006006:	fef704e3          	beq	a4,a5,80005fee <skipelem+0x12>
  if(*path == 0)
    8000600a:	fd843783          	ld	a5,-40(s0)
    8000600e:	0007c783          	lbu	a5,0(a5)
    80006012:	e399                	bnez	a5,80006018 <skipelem+0x3c>
    return 0;
    80006014:	4781                	li	a5,0
    80006016:	a06d                	j	800060c0 <skipelem+0xe4>
  s = path;
    80006018:	fd843783          	ld	a5,-40(s0)
    8000601c:	fef43423          	sd	a5,-24(s0)
  while(*path != '/' && *path != 0)
    80006020:	a031                	j	8000602c <skipelem+0x50>
    path++;
    80006022:	fd843783          	ld	a5,-40(s0)
    80006026:	0785                	addi	a5,a5,1
    80006028:	fcf43c23          	sd	a5,-40(s0)
  while(*path != '/' && *path != 0)
    8000602c:	fd843783          	ld	a5,-40(s0)
    80006030:	0007c783          	lbu	a5,0(a5)
    80006034:	873e                	mv	a4,a5
    80006036:	02f00793          	li	a5,47
    8000603a:	00f70763          	beq	a4,a5,80006048 <skipelem+0x6c>
    8000603e:	fd843783          	ld	a5,-40(s0)
    80006042:	0007c783          	lbu	a5,0(a5)
    80006046:	fff1                	bnez	a5,80006022 <skipelem+0x46>
  len = path - s;
    80006048:	fd843703          	ld	a4,-40(s0)
    8000604c:	fe843783          	ld	a5,-24(s0)
    80006050:	40f707b3          	sub	a5,a4,a5
    80006054:	fef42223          	sw	a5,-28(s0)
  if(len >= DIRSIZ)
    80006058:	fe442783          	lw	a5,-28(s0)
    8000605c:	0007871b          	sext.w	a4,a5
    80006060:	47b5                	li	a5,13
    80006062:	00e7dc63          	bge	a5,a4,8000607a <skipelem+0x9e>
    memmove(name, s, DIRSIZ);
    80006066:	4639                	li	a2,14
    80006068:	fe843583          	ld	a1,-24(s0)
    8000606c:	fd043503          	ld	a0,-48(s0)
    80006070:	ffffb097          	auipc	ra,0xffffb
    80006074:	4c0080e7          	jalr	1216(ra) # 80001530 <memmove>
    80006078:	a80d                	j	800060aa <skipelem+0xce>
  else {
    memmove(name, s, len);
    8000607a:	fe442783          	lw	a5,-28(s0)
    8000607e:	863e                	mv	a2,a5
    80006080:	fe843583          	ld	a1,-24(s0)
    80006084:	fd043503          	ld	a0,-48(s0)
    80006088:	ffffb097          	auipc	ra,0xffffb
    8000608c:	4a8080e7          	jalr	1192(ra) # 80001530 <memmove>
    name[len] = 0;
    80006090:	fe442783          	lw	a5,-28(s0)
    80006094:	fd043703          	ld	a4,-48(s0)
    80006098:	97ba                	add	a5,a5,a4
    8000609a:	00078023          	sb	zero,0(a5)
  }
  while(*path == '/')
    8000609e:	a031                	j	800060aa <skipelem+0xce>
    path++;
    800060a0:	fd843783          	ld	a5,-40(s0)
    800060a4:	0785                	addi	a5,a5,1
    800060a6:	fcf43c23          	sd	a5,-40(s0)
  while(*path == '/')
    800060aa:	fd843783          	ld	a5,-40(s0)
    800060ae:	0007c783          	lbu	a5,0(a5)
    800060b2:	873e                	mv	a4,a5
    800060b4:	02f00793          	li	a5,47
    800060b8:	fef704e3          	beq	a4,a5,800060a0 <skipelem+0xc4>
  return path;
    800060bc:	fd843783          	ld	a5,-40(s0)
}
    800060c0:	853e                	mv	a0,a5
    800060c2:	70a2                	ld	ra,40(sp)
    800060c4:	7402                	ld	s0,32(sp)
    800060c6:	6145                	addi	sp,sp,48
    800060c8:	8082                	ret

00000000800060ca <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800060ca:	7139                	addi	sp,sp,-64
    800060cc:	fc06                	sd	ra,56(sp)
    800060ce:	f822                	sd	s0,48(sp)
    800060d0:	0080                	addi	s0,sp,64
    800060d2:	fca43c23          	sd	a0,-40(s0)
    800060d6:	87ae                	mv	a5,a1
    800060d8:	fcc43423          	sd	a2,-56(s0)
    800060dc:	fcf42a23          	sw	a5,-44(s0)
  struct inode *ip, *next;

  if(*path == '/')
    800060e0:	fd843783          	ld	a5,-40(s0)
    800060e4:	0007c783          	lbu	a5,0(a5)
    800060e8:	873e                	mv	a4,a5
    800060ea:	02f00793          	li	a5,47
    800060ee:	00f71b63          	bne	a4,a5,80006104 <namex+0x3a>
    ip = iget(ROOTDEV, ROOTINO);
    800060f2:	4585                	li	a1,1
    800060f4:	4505                	li	a0,1
    800060f6:	fffff097          	auipc	ra,0xfffff
    800060fa:	262080e7          	jalr	610(ra) # 80005358 <iget>
    800060fe:	fea43423          	sd	a0,-24(s0)
    80006102:	a84d                	j	800061b4 <namex+0xea>
  else
    ip = idup(myproc()->cwd);
    80006104:	ffffc097          	auipc	ra,0xffffc
    80006108:	73c080e7          	jalr	1852(ra) # 80002840 <myproc>
    8000610c:	87aa                	mv	a5,a0
    8000610e:	1507b783          	ld	a5,336(a5)
    80006112:	853e                	mv	a0,a5
    80006114:	fffff097          	auipc	ra,0xfffff
    80006118:	360080e7          	jalr	864(ra) # 80005474 <idup>
    8000611c:	fea43423          	sd	a0,-24(s0)

  while((path = skipelem(path, name)) != 0){
    80006120:	a851                	j	800061b4 <namex+0xea>
    ilock(ip);
    80006122:	fe843503          	ld	a0,-24(s0)
    80006126:	fffff097          	auipc	ra,0xfffff
    8000612a:	39a080e7          	jalr	922(ra) # 800054c0 <ilock>
    if(ip->type != T_DIR){
    8000612e:	fe843783          	ld	a5,-24(s0)
    80006132:	04479783          	lh	a5,68(a5)
    80006136:	0007871b          	sext.w	a4,a5
    8000613a:	4785                	li	a5,1
    8000613c:	00f70a63          	beq	a4,a5,80006150 <namex+0x86>
      iunlockput(ip);
    80006140:	fe843503          	ld	a0,-24(s0)
    80006144:	fffff097          	auipc	ra,0xfffff
    80006148:	5da080e7          	jalr	1498(ra) # 8000571e <iunlockput>
      return 0;
    8000614c:	4781                	li	a5,0
    8000614e:	a871                	j	800061ea <namex+0x120>
    }
    if(nameiparent && *path == '\0'){
    80006150:	fd442783          	lw	a5,-44(s0)
    80006154:	2781                	sext.w	a5,a5
    80006156:	cf99                	beqz	a5,80006174 <namex+0xaa>
    80006158:	fd843783          	ld	a5,-40(s0)
    8000615c:	0007c783          	lbu	a5,0(a5)
    80006160:	eb91                	bnez	a5,80006174 <namex+0xaa>
      // Stop one level early.
      iunlock(ip);
    80006162:	fe843503          	ld	a0,-24(s0)
    80006166:	fffff097          	auipc	ra,0xfffff
    8000616a:	48e080e7          	jalr	1166(ra) # 800055f4 <iunlock>
      return ip;
    8000616e:	fe843783          	ld	a5,-24(s0)
    80006172:	a8a5                	j	800061ea <namex+0x120>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
    80006174:	4601                	li	a2,0
    80006176:	fc843583          	ld	a1,-56(s0)
    8000617a:	fe843503          	ld	a0,-24(s0)
    8000617e:	00000097          	auipc	ra,0x0
    80006182:	c80080e7          	jalr	-896(ra) # 80005dfe <dirlookup>
    80006186:	fea43023          	sd	a0,-32(s0)
    8000618a:	fe043783          	ld	a5,-32(s0)
    8000618e:	eb89                	bnez	a5,800061a0 <namex+0xd6>
      iunlockput(ip);
    80006190:	fe843503          	ld	a0,-24(s0)
    80006194:	fffff097          	auipc	ra,0xfffff
    80006198:	58a080e7          	jalr	1418(ra) # 8000571e <iunlockput>
      return 0;
    8000619c:	4781                	li	a5,0
    8000619e:	a0b1                	j	800061ea <namex+0x120>
    }
    iunlockput(ip);
    800061a0:	fe843503          	ld	a0,-24(s0)
    800061a4:	fffff097          	auipc	ra,0xfffff
    800061a8:	57a080e7          	jalr	1402(ra) # 8000571e <iunlockput>
    ip = next;
    800061ac:	fe043783          	ld	a5,-32(s0)
    800061b0:	fef43423          	sd	a5,-24(s0)
  while((path = skipelem(path, name)) != 0){
    800061b4:	fc843583          	ld	a1,-56(s0)
    800061b8:	fd843503          	ld	a0,-40(s0)
    800061bc:	00000097          	auipc	ra,0x0
    800061c0:	e20080e7          	jalr	-480(ra) # 80005fdc <skipelem>
    800061c4:	fca43c23          	sd	a0,-40(s0)
    800061c8:	fd843783          	ld	a5,-40(s0)
    800061cc:	fbb9                	bnez	a5,80006122 <namex+0x58>
  }
  if(nameiparent){
    800061ce:	fd442783          	lw	a5,-44(s0)
    800061d2:	2781                	sext.w	a5,a5
    800061d4:	cb89                	beqz	a5,800061e6 <namex+0x11c>
    iput(ip);
    800061d6:	fe843503          	ld	a0,-24(s0)
    800061da:	fffff097          	auipc	ra,0xfffff
    800061de:	474080e7          	jalr	1140(ra) # 8000564e <iput>
    return 0;
    800061e2:	4781                	li	a5,0
    800061e4:	a019                	j	800061ea <namex+0x120>
  }
  return ip;
    800061e6:	fe843783          	ld	a5,-24(s0)
}
    800061ea:	853e                	mv	a0,a5
    800061ec:	70e2                	ld	ra,56(sp)
    800061ee:	7442                	ld	s0,48(sp)
    800061f0:	6121                	addi	sp,sp,64
    800061f2:	8082                	ret

00000000800061f4 <namei>:

struct inode*
namei(char *path)
{
    800061f4:	7179                	addi	sp,sp,-48
    800061f6:	f406                	sd	ra,40(sp)
    800061f8:	f022                	sd	s0,32(sp)
    800061fa:	1800                	addi	s0,sp,48
    800061fc:	fca43c23          	sd	a0,-40(s0)
  char name[DIRSIZ];
  return namex(path, 0, name);
    80006200:	fe040793          	addi	a5,s0,-32
    80006204:	863e                	mv	a2,a5
    80006206:	4581                	li	a1,0
    80006208:	fd843503          	ld	a0,-40(s0)
    8000620c:	00000097          	auipc	ra,0x0
    80006210:	ebe080e7          	jalr	-322(ra) # 800060ca <namex>
    80006214:	87aa                	mv	a5,a0
}
    80006216:	853e                	mv	a0,a5
    80006218:	70a2                	ld	ra,40(sp)
    8000621a:	7402                	ld	s0,32(sp)
    8000621c:	6145                	addi	sp,sp,48
    8000621e:	8082                	ret

0000000080006220 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80006220:	1101                	addi	sp,sp,-32
    80006222:	ec06                	sd	ra,24(sp)
    80006224:	e822                	sd	s0,16(sp)
    80006226:	1000                	addi	s0,sp,32
    80006228:	fea43423          	sd	a0,-24(s0)
    8000622c:	feb43023          	sd	a1,-32(s0)
  return namex(path, 1, name);
    80006230:	fe043603          	ld	a2,-32(s0)
    80006234:	4585                	li	a1,1
    80006236:	fe843503          	ld	a0,-24(s0)
    8000623a:	00000097          	auipc	ra,0x0
    8000623e:	e90080e7          	jalr	-368(ra) # 800060ca <namex>
    80006242:	87aa                	mv	a5,a0
}
    80006244:	853e                	mv	a0,a5
    80006246:	60e2                	ld	ra,24(sp)
    80006248:	6442                	ld	s0,16(sp)
    8000624a:	6105                	addi	sp,sp,32
    8000624c:	8082                	ret

000000008000624e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev, struct superblock *sb)
{
    8000624e:	1101                	addi	sp,sp,-32
    80006250:	ec06                	sd	ra,24(sp)
    80006252:	e822                	sd	s0,16(sp)
    80006254:	1000                	addi	s0,sp,32
    80006256:	87aa                	mv	a5,a0
    80006258:	feb43023          	sd	a1,-32(s0)
    8000625c:	fef42623          	sw	a5,-20(s0)
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  initlock(&log.lock, "log");
    80006260:	00005597          	auipc	a1,0x5
    80006264:	30058593          	addi	a1,a1,768 # 8000b560 <etext+0x560>
    80006268:	0001e517          	auipc	a0,0x1e
    8000626c:	91050513          	addi	a0,a0,-1776 # 80023b78 <log>
    80006270:	ffffb097          	auipc	ra,0xffffb
    80006274:	fd8080e7          	jalr	-40(ra) # 80001248 <initlock>
  log.start = sb->logstart;
    80006278:	fe043783          	ld	a5,-32(s0)
    8000627c:	4bdc                	lw	a5,20(a5)
    8000627e:	0007871b          	sext.w	a4,a5
    80006282:	0001e797          	auipc	a5,0x1e
    80006286:	8f678793          	addi	a5,a5,-1802 # 80023b78 <log>
    8000628a:	cf98                	sw	a4,24(a5)
  log.size = sb->nlog;
    8000628c:	fe043783          	ld	a5,-32(s0)
    80006290:	4b9c                	lw	a5,16(a5)
    80006292:	0007871b          	sext.w	a4,a5
    80006296:	0001e797          	auipc	a5,0x1e
    8000629a:	8e278793          	addi	a5,a5,-1822 # 80023b78 <log>
    8000629e:	cfd8                	sw	a4,28(a5)
  log.dev = dev;
    800062a0:	0001e797          	auipc	a5,0x1e
    800062a4:	8d878793          	addi	a5,a5,-1832 # 80023b78 <log>
    800062a8:	fec42703          	lw	a4,-20(s0)
    800062ac:	d798                	sw	a4,40(a5)
  recover_from_log();
    800062ae:	00000097          	auipc	ra,0x0
    800062b2:	272080e7          	jalr	626(ra) # 80006520 <recover_from_log>
}
    800062b6:	0001                	nop
    800062b8:	60e2                	ld	ra,24(sp)
    800062ba:	6442                	ld	s0,16(sp)
    800062bc:	6105                	addi	sp,sp,32
    800062be:	8082                	ret

00000000800062c0 <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(int recovering)
{
    800062c0:	7139                	addi	sp,sp,-64
    800062c2:	fc06                	sd	ra,56(sp)
    800062c4:	f822                	sd	s0,48(sp)
    800062c6:	0080                	addi	s0,sp,64
    800062c8:	87aa                	mv	a5,a0
    800062ca:	fcf42623          	sw	a5,-52(s0)
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    800062ce:	fe042623          	sw	zero,-20(s0)
    800062d2:	a0f9                	j	800063a0 <install_trans+0xe0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800062d4:	0001e797          	auipc	a5,0x1e
    800062d8:	8a478793          	addi	a5,a5,-1884 # 80023b78 <log>
    800062dc:	579c                	lw	a5,40(a5)
    800062de:	0007871b          	sext.w	a4,a5
    800062e2:	0001e797          	auipc	a5,0x1e
    800062e6:	89678793          	addi	a5,a5,-1898 # 80023b78 <log>
    800062ea:	4f9c                	lw	a5,24(a5)
    800062ec:	fec42683          	lw	a3,-20(s0)
    800062f0:	9fb5                	addw	a5,a5,a3
    800062f2:	2781                	sext.w	a5,a5
    800062f4:	2785                	addiw	a5,a5,1
    800062f6:	2781                	sext.w	a5,a5
    800062f8:	2781                	sext.w	a5,a5
    800062fa:	85be                	mv	a1,a5
    800062fc:	853a                	mv	a0,a4
    800062fe:	ffffe097          	auipc	ra,0xffffe
    80006302:	7ee080e7          	jalr	2030(ra) # 80004aec <bread>
    80006306:	fea43023          	sd	a0,-32(s0)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000630a:	0001e797          	auipc	a5,0x1e
    8000630e:	86e78793          	addi	a5,a5,-1938 # 80023b78 <log>
    80006312:	579c                	lw	a5,40(a5)
    80006314:	0007869b          	sext.w	a3,a5
    80006318:	0001e717          	auipc	a4,0x1e
    8000631c:	86070713          	addi	a4,a4,-1952 # 80023b78 <log>
    80006320:	fec42783          	lw	a5,-20(s0)
    80006324:	07a1                	addi	a5,a5,8
    80006326:	078a                	slli	a5,a5,0x2
    80006328:	97ba                	add	a5,a5,a4
    8000632a:	4b9c                	lw	a5,16(a5)
    8000632c:	2781                	sext.w	a5,a5
    8000632e:	85be                	mv	a1,a5
    80006330:	8536                	mv	a0,a3
    80006332:	ffffe097          	auipc	ra,0xffffe
    80006336:	7ba080e7          	jalr	1978(ra) # 80004aec <bread>
    8000633a:	fca43c23          	sd	a0,-40(s0)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000633e:	fd843783          	ld	a5,-40(s0)
    80006342:	05878713          	addi	a4,a5,88
    80006346:	fe043783          	ld	a5,-32(s0)
    8000634a:	05878793          	addi	a5,a5,88
    8000634e:	40000613          	li	a2,1024
    80006352:	85be                	mv	a1,a5
    80006354:	853a                	mv	a0,a4
    80006356:	ffffb097          	auipc	ra,0xffffb
    8000635a:	1da080e7          	jalr	474(ra) # 80001530 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000635e:	fd843503          	ld	a0,-40(s0)
    80006362:	ffffe097          	auipc	ra,0xffffe
    80006366:	7e4080e7          	jalr	2020(ra) # 80004b46 <bwrite>
    if(recovering == 0)
    8000636a:	fcc42783          	lw	a5,-52(s0)
    8000636e:	2781                	sext.w	a5,a5
    80006370:	e799                	bnez	a5,8000637e <install_trans+0xbe>
      bunpin(dbuf);
    80006372:	fd843503          	ld	a0,-40(s0)
    80006376:	fffff097          	auipc	ra,0xfffff
    8000637a:	94e080e7          	jalr	-1714(ra) # 80004cc4 <bunpin>
    brelse(lbuf);
    8000637e:	fe043503          	ld	a0,-32(s0)
    80006382:	fffff097          	auipc	ra,0xfffff
    80006386:	80c080e7          	jalr	-2036(ra) # 80004b8e <brelse>
    brelse(dbuf);
    8000638a:	fd843503          	ld	a0,-40(s0)
    8000638e:	fffff097          	auipc	ra,0xfffff
    80006392:	800080e7          	jalr	-2048(ra) # 80004b8e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80006396:	fec42783          	lw	a5,-20(s0)
    8000639a:	2785                	addiw	a5,a5,1
    8000639c:	fef42623          	sw	a5,-20(s0)
    800063a0:	0001d797          	auipc	a5,0x1d
    800063a4:	7d878793          	addi	a5,a5,2008 # 80023b78 <log>
    800063a8:	57d8                	lw	a4,44(a5)
    800063aa:	fec42783          	lw	a5,-20(s0)
    800063ae:	2781                	sext.w	a5,a5
    800063b0:	f2e7c2e3          	blt	a5,a4,800062d4 <install_trans+0x14>
  }
}
    800063b4:	0001                	nop
    800063b6:	0001                	nop
    800063b8:	70e2                	ld	ra,56(sp)
    800063ba:	7442                	ld	s0,48(sp)
    800063bc:	6121                	addi	sp,sp,64
    800063be:	8082                	ret

00000000800063c0 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
    800063c0:	7179                	addi	sp,sp,-48
    800063c2:	f406                	sd	ra,40(sp)
    800063c4:	f022                	sd	s0,32(sp)
    800063c6:	1800                	addi	s0,sp,48
  struct buf *buf = bread(log.dev, log.start);
    800063c8:	0001d797          	auipc	a5,0x1d
    800063cc:	7b078793          	addi	a5,a5,1968 # 80023b78 <log>
    800063d0:	579c                	lw	a5,40(a5)
    800063d2:	0007871b          	sext.w	a4,a5
    800063d6:	0001d797          	auipc	a5,0x1d
    800063da:	7a278793          	addi	a5,a5,1954 # 80023b78 <log>
    800063de:	4f9c                	lw	a5,24(a5)
    800063e0:	2781                	sext.w	a5,a5
    800063e2:	85be                	mv	a1,a5
    800063e4:	853a                	mv	a0,a4
    800063e6:	ffffe097          	auipc	ra,0xffffe
    800063ea:	706080e7          	jalr	1798(ra) # 80004aec <bread>
    800063ee:	fea43023          	sd	a0,-32(s0)
  struct logheader *lh = (struct logheader *) (buf->data);
    800063f2:	fe043783          	ld	a5,-32(s0)
    800063f6:	05878793          	addi	a5,a5,88
    800063fa:	fcf43c23          	sd	a5,-40(s0)
  int i;
  log.lh.n = lh->n;
    800063fe:	fd843783          	ld	a5,-40(s0)
    80006402:	4398                	lw	a4,0(a5)
    80006404:	0001d797          	auipc	a5,0x1d
    80006408:	77478793          	addi	a5,a5,1908 # 80023b78 <log>
    8000640c:	d7d8                	sw	a4,44(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000640e:	fe042623          	sw	zero,-20(s0)
    80006412:	a03d                	j	80006440 <read_head+0x80>
    log.lh.block[i] = lh->block[i];
    80006414:	fd843703          	ld	a4,-40(s0)
    80006418:	fec42783          	lw	a5,-20(s0)
    8000641c:	078a                	slli	a5,a5,0x2
    8000641e:	97ba                	add	a5,a5,a4
    80006420:	43d8                	lw	a4,4(a5)
    80006422:	0001d697          	auipc	a3,0x1d
    80006426:	75668693          	addi	a3,a3,1878 # 80023b78 <log>
    8000642a:	fec42783          	lw	a5,-20(s0)
    8000642e:	07a1                	addi	a5,a5,8
    80006430:	078a                	slli	a5,a5,0x2
    80006432:	97b6                	add	a5,a5,a3
    80006434:	cb98                	sw	a4,16(a5)
  for (i = 0; i < log.lh.n; i++) {
    80006436:	fec42783          	lw	a5,-20(s0)
    8000643a:	2785                	addiw	a5,a5,1
    8000643c:	fef42623          	sw	a5,-20(s0)
    80006440:	0001d797          	auipc	a5,0x1d
    80006444:	73878793          	addi	a5,a5,1848 # 80023b78 <log>
    80006448:	57d8                	lw	a4,44(a5)
    8000644a:	fec42783          	lw	a5,-20(s0)
    8000644e:	2781                	sext.w	a5,a5
    80006450:	fce7c2e3          	blt	a5,a4,80006414 <read_head+0x54>
  }
  brelse(buf);
    80006454:	fe043503          	ld	a0,-32(s0)
    80006458:	ffffe097          	auipc	ra,0xffffe
    8000645c:	736080e7          	jalr	1846(ra) # 80004b8e <brelse>
}
    80006460:	0001                	nop
    80006462:	70a2                	ld	ra,40(sp)
    80006464:	7402                	ld	s0,32(sp)
    80006466:	6145                	addi	sp,sp,48
    80006468:	8082                	ret

000000008000646a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000646a:	7179                	addi	sp,sp,-48
    8000646c:	f406                	sd	ra,40(sp)
    8000646e:	f022                	sd	s0,32(sp)
    80006470:	1800                	addi	s0,sp,48
  struct buf *buf = bread(log.dev, log.start);
    80006472:	0001d797          	auipc	a5,0x1d
    80006476:	70678793          	addi	a5,a5,1798 # 80023b78 <log>
    8000647a:	579c                	lw	a5,40(a5)
    8000647c:	0007871b          	sext.w	a4,a5
    80006480:	0001d797          	auipc	a5,0x1d
    80006484:	6f878793          	addi	a5,a5,1784 # 80023b78 <log>
    80006488:	4f9c                	lw	a5,24(a5)
    8000648a:	2781                	sext.w	a5,a5
    8000648c:	85be                	mv	a1,a5
    8000648e:	853a                	mv	a0,a4
    80006490:	ffffe097          	auipc	ra,0xffffe
    80006494:	65c080e7          	jalr	1628(ra) # 80004aec <bread>
    80006498:	fea43023          	sd	a0,-32(s0)
  struct logheader *hb = (struct logheader *) (buf->data);
    8000649c:	fe043783          	ld	a5,-32(s0)
    800064a0:	05878793          	addi	a5,a5,88
    800064a4:	fcf43c23          	sd	a5,-40(s0)
  int i;
  hb->n = log.lh.n;
    800064a8:	0001d797          	auipc	a5,0x1d
    800064ac:	6d078793          	addi	a5,a5,1744 # 80023b78 <log>
    800064b0:	57d8                	lw	a4,44(a5)
    800064b2:	fd843783          	ld	a5,-40(s0)
    800064b6:	c398                	sw	a4,0(a5)
  for (i = 0; i < log.lh.n; i++) {
    800064b8:	fe042623          	sw	zero,-20(s0)
    800064bc:	a03d                	j	800064ea <write_head+0x80>
    hb->block[i] = log.lh.block[i];
    800064be:	0001d717          	auipc	a4,0x1d
    800064c2:	6ba70713          	addi	a4,a4,1722 # 80023b78 <log>
    800064c6:	fec42783          	lw	a5,-20(s0)
    800064ca:	07a1                	addi	a5,a5,8
    800064cc:	078a                	slli	a5,a5,0x2
    800064ce:	97ba                	add	a5,a5,a4
    800064d0:	4b98                	lw	a4,16(a5)
    800064d2:	fd843683          	ld	a3,-40(s0)
    800064d6:	fec42783          	lw	a5,-20(s0)
    800064da:	078a                	slli	a5,a5,0x2
    800064dc:	97b6                	add	a5,a5,a3
    800064de:	c3d8                	sw	a4,4(a5)
  for (i = 0; i < log.lh.n; i++) {
    800064e0:	fec42783          	lw	a5,-20(s0)
    800064e4:	2785                	addiw	a5,a5,1
    800064e6:	fef42623          	sw	a5,-20(s0)
    800064ea:	0001d797          	auipc	a5,0x1d
    800064ee:	68e78793          	addi	a5,a5,1678 # 80023b78 <log>
    800064f2:	57d8                	lw	a4,44(a5)
    800064f4:	fec42783          	lw	a5,-20(s0)
    800064f8:	2781                	sext.w	a5,a5
    800064fa:	fce7c2e3          	blt	a5,a4,800064be <write_head+0x54>
  }
  bwrite(buf);
    800064fe:	fe043503          	ld	a0,-32(s0)
    80006502:	ffffe097          	auipc	ra,0xffffe
    80006506:	644080e7          	jalr	1604(ra) # 80004b46 <bwrite>
  brelse(buf);
    8000650a:	fe043503          	ld	a0,-32(s0)
    8000650e:	ffffe097          	auipc	ra,0xffffe
    80006512:	680080e7          	jalr	1664(ra) # 80004b8e <brelse>
}
    80006516:	0001                	nop
    80006518:	70a2                	ld	ra,40(sp)
    8000651a:	7402                	ld	s0,32(sp)
    8000651c:	6145                	addi	sp,sp,48
    8000651e:	8082                	ret

0000000080006520 <recover_from_log>:

static void
recover_from_log(void)
{
    80006520:	1141                	addi	sp,sp,-16
    80006522:	e406                	sd	ra,8(sp)
    80006524:	e022                	sd	s0,0(sp)
    80006526:	0800                	addi	s0,sp,16
  read_head();
    80006528:	00000097          	auipc	ra,0x0
    8000652c:	e98080e7          	jalr	-360(ra) # 800063c0 <read_head>
  install_trans(1); // if committed, copy from log to disk
    80006530:	4505                	li	a0,1
    80006532:	00000097          	auipc	ra,0x0
    80006536:	d8e080e7          	jalr	-626(ra) # 800062c0 <install_trans>
  log.lh.n = 0;
    8000653a:	0001d797          	auipc	a5,0x1d
    8000653e:	63e78793          	addi	a5,a5,1598 # 80023b78 <log>
    80006542:	0207a623          	sw	zero,44(a5)
  write_head(); // clear the log
    80006546:	00000097          	auipc	ra,0x0
    8000654a:	f24080e7          	jalr	-220(ra) # 8000646a <write_head>
}
    8000654e:	0001                	nop
    80006550:	60a2                	ld	ra,8(sp)
    80006552:	6402                	ld	s0,0(sp)
    80006554:	0141                	addi	sp,sp,16
    80006556:	8082                	ret

0000000080006558 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
    80006558:	1141                	addi	sp,sp,-16
    8000655a:	e406                	sd	ra,8(sp)
    8000655c:	e022                	sd	s0,0(sp)
    8000655e:	0800                	addi	s0,sp,16
  acquire(&log.lock);
    80006560:	0001d517          	auipc	a0,0x1d
    80006564:	61850513          	addi	a0,a0,1560 # 80023b78 <log>
    80006568:	ffffb097          	auipc	ra,0xffffb
    8000656c:	d10080e7          	jalr	-752(ra) # 80001278 <acquire>
  while(1){
    if(log.committing){
    80006570:	0001d797          	auipc	a5,0x1d
    80006574:	60878793          	addi	a5,a5,1544 # 80023b78 <log>
    80006578:	53dc                	lw	a5,36(a5)
    8000657a:	cf91                	beqz	a5,80006596 <begin_op+0x3e>
      sleep(&log, &log.lock);
    8000657c:	0001d597          	auipc	a1,0x1d
    80006580:	5fc58593          	addi	a1,a1,1532 # 80023b78 <log>
    80006584:	0001d517          	auipc	a0,0x1d
    80006588:	5f450513          	addi	a0,a0,1524 # 80023b78 <log>
    8000658c:	ffffd097          	auipc	ra,0xffffd
    80006590:	e76080e7          	jalr	-394(ra) # 80003402 <sleep>
    80006594:	bff1                	j	80006570 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80006596:	0001d797          	auipc	a5,0x1d
    8000659a:	5e278793          	addi	a5,a5,1506 # 80023b78 <log>
    8000659e:	57d8                	lw	a4,44(a5)
    800065a0:	0001d797          	auipc	a5,0x1d
    800065a4:	5d878793          	addi	a5,a5,1496 # 80023b78 <log>
    800065a8:	539c                	lw	a5,32(a5)
    800065aa:	2785                	addiw	a5,a5,1
    800065ac:	2781                	sext.w	a5,a5
    800065ae:	86be                	mv	a3,a5
    800065b0:	87b6                	mv	a5,a3
    800065b2:	0027979b          	slliw	a5,a5,0x2
    800065b6:	9fb5                	addw	a5,a5,a3
    800065b8:	0017979b          	slliw	a5,a5,0x1
    800065bc:	2781                	sext.w	a5,a5
    800065be:	9fb9                	addw	a5,a5,a4
    800065c0:	2781                	sext.w	a5,a5
    800065c2:	873e                	mv	a4,a5
    800065c4:	47f9                	li	a5,30
    800065c6:	00e7df63          	bge	a5,a4,800065e4 <begin_op+0x8c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800065ca:	0001d597          	auipc	a1,0x1d
    800065ce:	5ae58593          	addi	a1,a1,1454 # 80023b78 <log>
    800065d2:	0001d517          	auipc	a0,0x1d
    800065d6:	5a650513          	addi	a0,a0,1446 # 80023b78 <log>
    800065da:	ffffd097          	auipc	ra,0xffffd
    800065de:	e28080e7          	jalr	-472(ra) # 80003402 <sleep>
    800065e2:	b779                	j	80006570 <begin_op+0x18>
    } else {
      log.outstanding += 1;
    800065e4:	0001d797          	auipc	a5,0x1d
    800065e8:	59478793          	addi	a5,a5,1428 # 80023b78 <log>
    800065ec:	539c                	lw	a5,32(a5)
    800065ee:	2785                	addiw	a5,a5,1
    800065f0:	0007871b          	sext.w	a4,a5
    800065f4:	0001d797          	auipc	a5,0x1d
    800065f8:	58478793          	addi	a5,a5,1412 # 80023b78 <log>
    800065fc:	d398                	sw	a4,32(a5)
      release(&log.lock);
    800065fe:	0001d517          	auipc	a0,0x1d
    80006602:	57a50513          	addi	a0,a0,1402 # 80023b78 <log>
    80006606:	ffffb097          	auipc	ra,0xffffb
    8000660a:	cd6080e7          	jalr	-810(ra) # 800012dc <release>
      break;
    8000660e:	0001                	nop
    }
  }
}
    80006610:	0001                	nop
    80006612:	60a2                	ld	ra,8(sp)
    80006614:	6402                	ld	s0,0(sp)
    80006616:	0141                	addi	sp,sp,16
    80006618:	8082                	ret

000000008000661a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000661a:	1101                	addi	sp,sp,-32
    8000661c:	ec06                	sd	ra,24(sp)
    8000661e:	e822                	sd	s0,16(sp)
    80006620:	1000                	addi	s0,sp,32
  int do_commit = 0;
    80006622:	fe042623          	sw	zero,-20(s0)

  acquire(&log.lock);
    80006626:	0001d517          	auipc	a0,0x1d
    8000662a:	55250513          	addi	a0,a0,1362 # 80023b78 <log>
    8000662e:	ffffb097          	auipc	ra,0xffffb
    80006632:	c4a080e7          	jalr	-950(ra) # 80001278 <acquire>
  log.outstanding -= 1;
    80006636:	0001d797          	auipc	a5,0x1d
    8000663a:	54278793          	addi	a5,a5,1346 # 80023b78 <log>
    8000663e:	539c                	lw	a5,32(a5)
    80006640:	37fd                	addiw	a5,a5,-1
    80006642:	0007871b          	sext.w	a4,a5
    80006646:	0001d797          	auipc	a5,0x1d
    8000664a:	53278793          	addi	a5,a5,1330 # 80023b78 <log>
    8000664e:	d398                	sw	a4,32(a5)
  if(log.committing)
    80006650:	0001d797          	auipc	a5,0x1d
    80006654:	52878793          	addi	a5,a5,1320 # 80023b78 <log>
    80006658:	53dc                	lw	a5,36(a5)
    8000665a:	cb89                	beqz	a5,8000666c <end_op+0x52>
    panic("log.committing");
    8000665c:	00005517          	auipc	a0,0x5
    80006660:	f0c50513          	addi	a0,a0,-244 # 8000b568 <etext+0x568>
    80006664:	ffffa097          	auipc	ra,0xffffa
    80006668:	626080e7          	jalr	1574(ra) # 80000c8a <panic>
  if(log.outstanding == 0){
    8000666c:	0001d797          	auipc	a5,0x1d
    80006670:	50c78793          	addi	a5,a5,1292 # 80023b78 <log>
    80006674:	539c                	lw	a5,32(a5)
    80006676:	eb99                	bnez	a5,8000668c <end_op+0x72>
    do_commit = 1;
    80006678:	4785                	li	a5,1
    8000667a:	fef42623          	sw	a5,-20(s0)
    log.committing = 1;
    8000667e:	0001d797          	auipc	a5,0x1d
    80006682:	4fa78793          	addi	a5,a5,1274 # 80023b78 <log>
    80006686:	4705                	li	a4,1
    80006688:	d3d8                	sw	a4,36(a5)
    8000668a:	a809                	j	8000669c <end_op+0x82>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
    8000668c:	0001d517          	auipc	a0,0x1d
    80006690:	4ec50513          	addi	a0,a0,1260 # 80023b78 <log>
    80006694:	ffffd097          	auipc	ra,0xffffd
    80006698:	dea080e7          	jalr	-534(ra) # 8000347e <wakeup>
  }
  release(&log.lock);
    8000669c:	0001d517          	auipc	a0,0x1d
    800066a0:	4dc50513          	addi	a0,a0,1244 # 80023b78 <log>
    800066a4:	ffffb097          	auipc	ra,0xffffb
    800066a8:	c38080e7          	jalr	-968(ra) # 800012dc <release>

  if(do_commit){
    800066ac:	fec42783          	lw	a5,-20(s0)
    800066b0:	2781                	sext.w	a5,a5
    800066b2:	c3b9                	beqz	a5,800066f8 <end_op+0xde>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
    800066b4:	00000097          	auipc	ra,0x0
    800066b8:	134080e7          	jalr	308(ra) # 800067e8 <commit>
    acquire(&log.lock);
    800066bc:	0001d517          	auipc	a0,0x1d
    800066c0:	4bc50513          	addi	a0,a0,1212 # 80023b78 <log>
    800066c4:	ffffb097          	auipc	ra,0xffffb
    800066c8:	bb4080e7          	jalr	-1100(ra) # 80001278 <acquire>
    log.committing = 0;
    800066cc:	0001d797          	auipc	a5,0x1d
    800066d0:	4ac78793          	addi	a5,a5,1196 # 80023b78 <log>
    800066d4:	0207a223          	sw	zero,36(a5)
    wakeup(&log);
    800066d8:	0001d517          	auipc	a0,0x1d
    800066dc:	4a050513          	addi	a0,a0,1184 # 80023b78 <log>
    800066e0:	ffffd097          	auipc	ra,0xffffd
    800066e4:	d9e080e7          	jalr	-610(ra) # 8000347e <wakeup>
    release(&log.lock);
    800066e8:	0001d517          	auipc	a0,0x1d
    800066ec:	49050513          	addi	a0,a0,1168 # 80023b78 <log>
    800066f0:	ffffb097          	auipc	ra,0xffffb
    800066f4:	bec080e7          	jalr	-1044(ra) # 800012dc <release>
  }
}
    800066f8:	0001                	nop
    800066fa:	60e2                	ld	ra,24(sp)
    800066fc:	6442                	ld	s0,16(sp)
    800066fe:	6105                	addi	sp,sp,32
    80006700:	8082                	ret

0000000080006702 <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
    80006702:	7179                	addi	sp,sp,-48
    80006704:	f406                	sd	ra,40(sp)
    80006706:	f022                	sd	s0,32(sp)
    80006708:	1800                	addi	s0,sp,48
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    8000670a:	fe042623          	sw	zero,-20(s0)
    8000670e:	a86d                	j	800067c8 <write_log+0xc6>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80006710:	0001d797          	auipc	a5,0x1d
    80006714:	46878793          	addi	a5,a5,1128 # 80023b78 <log>
    80006718:	579c                	lw	a5,40(a5)
    8000671a:	0007871b          	sext.w	a4,a5
    8000671e:	0001d797          	auipc	a5,0x1d
    80006722:	45a78793          	addi	a5,a5,1114 # 80023b78 <log>
    80006726:	4f9c                	lw	a5,24(a5)
    80006728:	fec42683          	lw	a3,-20(s0)
    8000672c:	9fb5                	addw	a5,a5,a3
    8000672e:	2781                	sext.w	a5,a5
    80006730:	2785                	addiw	a5,a5,1
    80006732:	2781                	sext.w	a5,a5
    80006734:	2781                	sext.w	a5,a5
    80006736:	85be                	mv	a1,a5
    80006738:	853a                	mv	a0,a4
    8000673a:	ffffe097          	auipc	ra,0xffffe
    8000673e:	3b2080e7          	jalr	946(ra) # 80004aec <bread>
    80006742:	fea43023          	sd	a0,-32(s0)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80006746:	0001d797          	auipc	a5,0x1d
    8000674a:	43278793          	addi	a5,a5,1074 # 80023b78 <log>
    8000674e:	579c                	lw	a5,40(a5)
    80006750:	0007869b          	sext.w	a3,a5
    80006754:	0001d717          	auipc	a4,0x1d
    80006758:	42470713          	addi	a4,a4,1060 # 80023b78 <log>
    8000675c:	fec42783          	lw	a5,-20(s0)
    80006760:	07a1                	addi	a5,a5,8
    80006762:	078a                	slli	a5,a5,0x2
    80006764:	97ba                	add	a5,a5,a4
    80006766:	4b9c                	lw	a5,16(a5)
    80006768:	2781                	sext.w	a5,a5
    8000676a:	85be                	mv	a1,a5
    8000676c:	8536                	mv	a0,a3
    8000676e:	ffffe097          	auipc	ra,0xffffe
    80006772:	37e080e7          	jalr	894(ra) # 80004aec <bread>
    80006776:	fca43c23          	sd	a0,-40(s0)
    memmove(to->data, from->data, BSIZE);
    8000677a:	fe043783          	ld	a5,-32(s0)
    8000677e:	05878713          	addi	a4,a5,88
    80006782:	fd843783          	ld	a5,-40(s0)
    80006786:	05878793          	addi	a5,a5,88
    8000678a:	40000613          	li	a2,1024
    8000678e:	85be                	mv	a1,a5
    80006790:	853a                	mv	a0,a4
    80006792:	ffffb097          	auipc	ra,0xffffb
    80006796:	d9e080e7          	jalr	-610(ra) # 80001530 <memmove>
    bwrite(to);  // write the log
    8000679a:	fe043503          	ld	a0,-32(s0)
    8000679e:	ffffe097          	auipc	ra,0xffffe
    800067a2:	3a8080e7          	jalr	936(ra) # 80004b46 <bwrite>
    brelse(from);
    800067a6:	fd843503          	ld	a0,-40(s0)
    800067aa:	ffffe097          	auipc	ra,0xffffe
    800067ae:	3e4080e7          	jalr	996(ra) # 80004b8e <brelse>
    brelse(to);
    800067b2:	fe043503          	ld	a0,-32(s0)
    800067b6:	ffffe097          	auipc	ra,0xffffe
    800067ba:	3d8080e7          	jalr	984(ra) # 80004b8e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800067be:	fec42783          	lw	a5,-20(s0)
    800067c2:	2785                	addiw	a5,a5,1
    800067c4:	fef42623          	sw	a5,-20(s0)
    800067c8:	0001d797          	auipc	a5,0x1d
    800067cc:	3b078793          	addi	a5,a5,944 # 80023b78 <log>
    800067d0:	57d8                	lw	a4,44(a5)
    800067d2:	fec42783          	lw	a5,-20(s0)
    800067d6:	2781                	sext.w	a5,a5
    800067d8:	f2e7cce3          	blt	a5,a4,80006710 <write_log+0xe>
  }
}
    800067dc:	0001                	nop
    800067de:	0001                	nop
    800067e0:	70a2                	ld	ra,40(sp)
    800067e2:	7402                	ld	s0,32(sp)
    800067e4:	6145                	addi	sp,sp,48
    800067e6:	8082                	ret

00000000800067e8 <commit>:

static void
commit()
{
    800067e8:	1141                	addi	sp,sp,-16
    800067ea:	e406                	sd	ra,8(sp)
    800067ec:	e022                	sd	s0,0(sp)
    800067ee:	0800                	addi	s0,sp,16
  if (log.lh.n > 0) {
    800067f0:	0001d797          	auipc	a5,0x1d
    800067f4:	38878793          	addi	a5,a5,904 # 80023b78 <log>
    800067f8:	57dc                	lw	a5,44(a5)
    800067fa:	02f05963          	blez	a5,8000682c <commit+0x44>
    write_log();     // Write modified blocks from cache to log
    800067fe:	00000097          	auipc	ra,0x0
    80006802:	f04080e7          	jalr	-252(ra) # 80006702 <write_log>
    write_head();    // Write header to disk -- the real commit
    80006806:	00000097          	auipc	ra,0x0
    8000680a:	c64080e7          	jalr	-924(ra) # 8000646a <write_head>
    install_trans(0); // Now install writes to home locations
    8000680e:	4501                	li	a0,0
    80006810:	00000097          	auipc	ra,0x0
    80006814:	ab0080e7          	jalr	-1360(ra) # 800062c0 <install_trans>
    log.lh.n = 0;
    80006818:	0001d797          	auipc	a5,0x1d
    8000681c:	36078793          	addi	a5,a5,864 # 80023b78 <log>
    80006820:	0207a623          	sw	zero,44(a5)
    write_head();    // Erase the transaction from the log
    80006824:	00000097          	auipc	ra,0x0
    80006828:	c46080e7          	jalr	-954(ra) # 8000646a <write_head>
  }
}
    8000682c:	0001                	nop
    8000682e:	60a2                	ld	ra,8(sp)
    80006830:	6402                	ld	s0,0(sp)
    80006832:	0141                	addi	sp,sp,16
    80006834:	8082                	ret

0000000080006836 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80006836:	7179                	addi	sp,sp,-48
    80006838:	f406                	sd	ra,40(sp)
    8000683a:	f022                	sd	s0,32(sp)
    8000683c:	1800                	addi	s0,sp,48
    8000683e:	fca43c23          	sd	a0,-40(s0)
  int i;

  acquire(&log.lock);
    80006842:	0001d517          	auipc	a0,0x1d
    80006846:	33650513          	addi	a0,a0,822 # 80023b78 <log>
    8000684a:	ffffb097          	auipc	ra,0xffffb
    8000684e:	a2e080e7          	jalr	-1490(ra) # 80001278 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80006852:	0001d797          	auipc	a5,0x1d
    80006856:	32678793          	addi	a5,a5,806 # 80023b78 <log>
    8000685a:	57dc                	lw	a5,44(a5)
    8000685c:	873e                	mv	a4,a5
    8000685e:	47f5                	li	a5,29
    80006860:	02e7c063          	blt	a5,a4,80006880 <log_write+0x4a>
    80006864:	0001d797          	auipc	a5,0x1d
    80006868:	31478793          	addi	a5,a5,788 # 80023b78 <log>
    8000686c:	57d8                	lw	a4,44(a5)
    8000686e:	0001d797          	auipc	a5,0x1d
    80006872:	30a78793          	addi	a5,a5,778 # 80023b78 <log>
    80006876:	4fdc                	lw	a5,28(a5)
    80006878:	37fd                	addiw	a5,a5,-1
    8000687a:	2781                	sext.w	a5,a5
    8000687c:	00f74a63          	blt	a4,a5,80006890 <log_write+0x5a>
    panic("too big a transaction");
    80006880:	00005517          	auipc	a0,0x5
    80006884:	cf850513          	addi	a0,a0,-776 # 8000b578 <etext+0x578>
    80006888:	ffffa097          	auipc	ra,0xffffa
    8000688c:	402080e7          	jalr	1026(ra) # 80000c8a <panic>
  if (log.outstanding < 1)
    80006890:	0001d797          	auipc	a5,0x1d
    80006894:	2e878793          	addi	a5,a5,744 # 80023b78 <log>
    80006898:	539c                	lw	a5,32(a5)
    8000689a:	00f04a63          	bgtz	a5,800068ae <log_write+0x78>
    panic("log_write outside of trans");
    8000689e:	00005517          	auipc	a0,0x5
    800068a2:	cf250513          	addi	a0,a0,-782 # 8000b590 <etext+0x590>
    800068a6:	ffffa097          	auipc	ra,0xffffa
    800068aa:	3e4080e7          	jalr	996(ra) # 80000c8a <panic>

  for (i = 0; i < log.lh.n; i++) {
    800068ae:	fe042623          	sw	zero,-20(s0)
    800068b2:	a03d                	j	800068e0 <log_write+0xaa>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800068b4:	0001d717          	auipc	a4,0x1d
    800068b8:	2c470713          	addi	a4,a4,708 # 80023b78 <log>
    800068bc:	fec42783          	lw	a5,-20(s0)
    800068c0:	07a1                	addi	a5,a5,8
    800068c2:	078a                	slli	a5,a5,0x2
    800068c4:	97ba                	add	a5,a5,a4
    800068c6:	4b9c                	lw	a5,16(a5)
    800068c8:	0007871b          	sext.w	a4,a5
    800068cc:	fd843783          	ld	a5,-40(s0)
    800068d0:	47dc                	lw	a5,12(a5)
    800068d2:	02f70263          	beq	a4,a5,800068f6 <log_write+0xc0>
  for (i = 0; i < log.lh.n; i++) {
    800068d6:	fec42783          	lw	a5,-20(s0)
    800068da:	2785                	addiw	a5,a5,1
    800068dc:	fef42623          	sw	a5,-20(s0)
    800068e0:	0001d797          	auipc	a5,0x1d
    800068e4:	29878793          	addi	a5,a5,664 # 80023b78 <log>
    800068e8:	57d8                	lw	a4,44(a5)
    800068ea:	fec42783          	lw	a5,-20(s0)
    800068ee:	2781                	sext.w	a5,a5
    800068f0:	fce7c2e3          	blt	a5,a4,800068b4 <log_write+0x7e>
    800068f4:	a011                	j	800068f8 <log_write+0xc2>
      break;
    800068f6:	0001                	nop
  }
  log.lh.block[i] = b->blockno;
    800068f8:	fd843783          	ld	a5,-40(s0)
    800068fc:	47dc                	lw	a5,12(a5)
    800068fe:	0007871b          	sext.w	a4,a5
    80006902:	0001d697          	auipc	a3,0x1d
    80006906:	27668693          	addi	a3,a3,630 # 80023b78 <log>
    8000690a:	fec42783          	lw	a5,-20(s0)
    8000690e:	07a1                	addi	a5,a5,8
    80006910:	078a                	slli	a5,a5,0x2
    80006912:	97b6                	add	a5,a5,a3
    80006914:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    80006916:	0001d797          	auipc	a5,0x1d
    8000691a:	26278793          	addi	a5,a5,610 # 80023b78 <log>
    8000691e:	57d8                	lw	a4,44(a5)
    80006920:	fec42783          	lw	a5,-20(s0)
    80006924:	2781                	sext.w	a5,a5
    80006926:	02e79563          	bne	a5,a4,80006950 <log_write+0x11a>
    bpin(b);
    8000692a:	fd843503          	ld	a0,-40(s0)
    8000692e:	ffffe097          	auipc	ra,0xffffe
    80006932:	34e080e7          	jalr	846(ra) # 80004c7c <bpin>
    log.lh.n++;
    80006936:	0001d797          	auipc	a5,0x1d
    8000693a:	24278793          	addi	a5,a5,578 # 80023b78 <log>
    8000693e:	57dc                	lw	a5,44(a5)
    80006940:	2785                	addiw	a5,a5,1
    80006942:	0007871b          	sext.w	a4,a5
    80006946:	0001d797          	auipc	a5,0x1d
    8000694a:	23278793          	addi	a5,a5,562 # 80023b78 <log>
    8000694e:	d7d8                	sw	a4,44(a5)
  }
  release(&log.lock);
    80006950:	0001d517          	auipc	a0,0x1d
    80006954:	22850513          	addi	a0,a0,552 # 80023b78 <log>
    80006958:	ffffb097          	auipc	ra,0xffffb
    8000695c:	984080e7          	jalr	-1660(ra) # 800012dc <release>
}
    80006960:	0001                	nop
    80006962:	70a2                	ld	ra,40(sp)
    80006964:	7402                	ld	s0,32(sp)
    80006966:	6145                	addi	sp,sp,48
    80006968:	8082                	ret

000000008000696a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000696a:	1101                	addi	sp,sp,-32
    8000696c:	ec06                	sd	ra,24(sp)
    8000696e:	e822                	sd	s0,16(sp)
    80006970:	1000                	addi	s0,sp,32
    80006972:	fea43423          	sd	a0,-24(s0)
    80006976:	feb43023          	sd	a1,-32(s0)
  initlock(&lk->lk, "sleep lock");
    8000697a:	fe843783          	ld	a5,-24(s0)
    8000697e:	07a1                	addi	a5,a5,8
    80006980:	00005597          	auipc	a1,0x5
    80006984:	c3058593          	addi	a1,a1,-976 # 8000b5b0 <etext+0x5b0>
    80006988:	853e                	mv	a0,a5
    8000698a:	ffffb097          	auipc	ra,0xffffb
    8000698e:	8be080e7          	jalr	-1858(ra) # 80001248 <initlock>
  lk->name = name;
    80006992:	fe843783          	ld	a5,-24(s0)
    80006996:	fe043703          	ld	a4,-32(s0)
    8000699a:	f398                	sd	a4,32(a5)
  lk->locked = 0;
    8000699c:	fe843783          	ld	a5,-24(s0)
    800069a0:	0007a023          	sw	zero,0(a5)
  lk->pid = 0;
    800069a4:	fe843783          	ld	a5,-24(s0)
    800069a8:	0207a423          	sw	zero,40(a5)
}
    800069ac:	0001                	nop
    800069ae:	60e2                	ld	ra,24(sp)
    800069b0:	6442                	ld	s0,16(sp)
    800069b2:	6105                	addi	sp,sp,32
    800069b4:	8082                	ret

00000000800069b6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800069b6:	1101                	addi	sp,sp,-32
    800069b8:	ec06                	sd	ra,24(sp)
    800069ba:	e822                	sd	s0,16(sp)
    800069bc:	1000                	addi	s0,sp,32
    800069be:	fea43423          	sd	a0,-24(s0)
  acquire(&lk->lk);
    800069c2:	fe843783          	ld	a5,-24(s0)
    800069c6:	07a1                	addi	a5,a5,8
    800069c8:	853e                	mv	a0,a5
    800069ca:	ffffb097          	auipc	ra,0xffffb
    800069ce:	8ae080e7          	jalr	-1874(ra) # 80001278 <acquire>
  while (lk->locked) {
    800069d2:	a819                	j	800069e8 <acquiresleep+0x32>
    sleep(lk, &lk->lk);
    800069d4:	fe843783          	ld	a5,-24(s0)
    800069d8:	07a1                	addi	a5,a5,8
    800069da:	85be                	mv	a1,a5
    800069dc:	fe843503          	ld	a0,-24(s0)
    800069e0:	ffffd097          	auipc	ra,0xffffd
    800069e4:	a22080e7          	jalr	-1502(ra) # 80003402 <sleep>
  while (lk->locked) {
    800069e8:	fe843783          	ld	a5,-24(s0)
    800069ec:	439c                	lw	a5,0(a5)
    800069ee:	f3fd                	bnez	a5,800069d4 <acquiresleep+0x1e>
  }
  lk->locked = 1;
    800069f0:	fe843783          	ld	a5,-24(s0)
    800069f4:	4705                	li	a4,1
    800069f6:	c398                	sw	a4,0(a5)
  lk->pid = myproc()->pid;
    800069f8:	ffffc097          	auipc	ra,0xffffc
    800069fc:	e48080e7          	jalr	-440(ra) # 80002840 <myproc>
    80006a00:	87aa                	mv	a5,a0
    80006a02:	5b98                	lw	a4,48(a5)
    80006a04:	fe843783          	ld	a5,-24(s0)
    80006a08:	d798                	sw	a4,40(a5)
  release(&lk->lk);
    80006a0a:	fe843783          	ld	a5,-24(s0)
    80006a0e:	07a1                	addi	a5,a5,8
    80006a10:	853e                	mv	a0,a5
    80006a12:	ffffb097          	auipc	ra,0xffffb
    80006a16:	8ca080e7          	jalr	-1846(ra) # 800012dc <release>
}
    80006a1a:	0001                	nop
    80006a1c:	60e2                	ld	ra,24(sp)
    80006a1e:	6442                	ld	s0,16(sp)
    80006a20:	6105                	addi	sp,sp,32
    80006a22:	8082                	ret

0000000080006a24 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80006a24:	1101                	addi	sp,sp,-32
    80006a26:	ec06                	sd	ra,24(sp)
    80006a28:	e822                	sd	s0,16(sp)
    80006a2a:	1000                	addi	s0,sp,32
    80006a2c:	fea43423          	sd	a0,-24(s0)
  acquire(&lk->lk);
    80006a30:	fe843783          	ld	a5,-24(s0)
    80006a34:	07a1                	addi	a5,a5,8
    80006a36:	853e                	mv	a0,a5
    80006a38:	ffffb097          	auipc	ra,0xffffb
    80006a3c:	840080e7          	jalr	-1984(ra) # 80001278 <acquire>
  lk->locked = 0;
    80006a40:	fe843783          	ld	a5,-24(s0)
    80006a44:	0007a023          	sw	zero,0(a5)
  lk->pid = 0;
    80006a48:	fe843783          	ld	a5,-24(s0)
    80006a4c:	0207a423          	sw	zero,40(a5)
  wakeup(lk);
    80006a50:	fe843503          	ld	a0,-24(s0)
    80006a54:	ffffd097          	auipc	ra,0xffffd
    80006a58:	a2a080e7          	jalr	-1494(ra) # 8000347e <wakeup>
  release(&lk->lk);
    80006a5c:	fe843783          	ld	a5,-24(s0)
    80006a60:	07a1                	addi	a5,a5,8
    80006a62:	853e                	mv	a0,a5
    80006a64:	ffffb097          	auipc	ra,0xffffb
    80006a68:	878080e7          	jalr	-1928(ra) # 800012dc <release>
}
    80006a6c:	0001                	nop
    80006a6e:	60e2                	ld	ra,24(sp)
    80006a70:	6442                	ld	s0,16(sp)
    80006a72:	6105                	addi	sp,sp,32
    80006a74:	8082                	ret

0000000080006a76 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80006a76:	7139                	addi	sp,sp,-64
    80006a78:	fc06                	sd	ra,56(sp)
    80006a7a:	f822                	sd	s0,48(sp)
    80006a7c:	f426                	sd	s1,40(sp)
    80006a7e:	0080                	addi	s0,sp,64
    80006a80:	fca43423          	sd	a0,-56(s0)
  int r;
  
  acquire(&lk->lk);
    80006a84:	fc843783          	ld	a5,-56(s0)
    80006a88:	07a1                	addi	a5,a5,8
    80006a8a:	853e                	mv	a0,a5
    80006a8c:	ffffa097          	auipc	ra,0xffffa
    80006a90:	7ec080e7          	jalr	2028(ra) # 80001278 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80006a94:	fc843783          	ld	a5,-56(s0)
    80006a98:	439c                	lw	a5,0(a5)
    80006a9a:	cf99                	beqz	a5,80006ab8 <holdingsleep+0x42>
    80006a9c:	fc843783          	ld	a5,-56(s0)
    80006aa0:	5784                	lw	s1,40(a5)
    80006aa2:	ffffc097          	auipc	ra,0xffffc
    80006aa6:	d9e080e7          	jalr	-610(ra) # 80002840 <myproc>
    80006aaa:	87aa                	mv	a5,a0
    80006aac:	5b9c                	lw	a5,48(a5)
    80006aae:	8726                	mv	a4,s1
    80006ab0:	00f71463          	bne	a4,a5,80006ab8 <holdingsleep+0x42>
    80006ab4:	4785                	li	a5,1
    80006ab6:	a011                	j	80006aba <holdingsleep+0x44>
    80006ab8:	4781                	li	a5,0
    80006aba:	fcf42e23          	sw	a5,-36(s0)
  release(&lk->lk);
    80006abe:	fc843783          	ld	a5,-56(s0)
    80006ac2:	07a1                	addi	a5,a5,8
    80006ac4:	853e                	mv	a0,a5
    80006ac6:	ffffb097          	auipc	ra,0xffffb
    80006aca:	816080e7          	jalr	-2026(ra) # 800012dc <release>
  return r;
    80006ace:	fdc42783          	lw	a5,-36(s0)
}
    80006ad2:	853e                	mv	a0,a5
    80006ad4:	70e2                	ld	ra,56(sp)
    80006ad6:	7442                	ld	s0,48(sp)
    80006ad8:	74a2                	ld	s1,40(sp)
    80006ada:	6121                	addi	sp,sp,64
    80006adc:	8082                	ret

0000000080006ade <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80006ade:	1141                	addi	sp,sp,-16
    80006ae0:	e406                	sd	ra,8(sp)
    80006ae2:	e022                	sd	s0,0(sp)
    80006ae4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80006ae6:	00005597          	auipc	a1,0x5
    80006aea:	ada58593          	addi	a1,a1,-1318 # 8000b5c0 <etext+0x5c0>
    80006aee:	0001d517          	auipc	a0,0x1d
    80006af2:	1d250513          	addi	a0,a0,466 # 80023cc0 <ftable>
    80006af6:	ffffa097          	auipc	ra,0xffffa
    80006afa:	752080e7          	jalr	1874(ra) # 80001248 <initlock>
}
    80006afe:	0001                	nop
    80006b00:	60a2                	ld	ra,8(sp)
    80006b02:	6402                	ld	s0,0(sp)
    80006b04:	0141                	addi	sp,sp,16
    80006b06:	8082                	ret

0000000080006b08 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80006b08:	1101                	addi	sp,sp,-32
    80006b0a:	ec06                	sd	ra,24(sp)
    80006b0c:	e822                	sd	s0,16(sp)
    80006b0e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80006b10:	0001d517          	auipc	a0,0x1d
    80006b14:	1b050513          	addi	a0,a0,432 # 80023cc0 <ftable>
    80006b18:	ffffa097          	auipc	ra,0xffffa
    80006b1c:	760080e7          	jalr	1888(ra) # 80001278 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80006b20:	0001d797          	auipc	a5,0x1d
    80006b24:	1b878793          	addi	a5,a5,440 # 80023cd8 <ftable+0x18>
    80006b28:	fef43423          	sd	a5,-24(s0)
    80006b2c:	a815                	j	80006b60 <filealloc+0x58>
    if(f->ref == 0){
    80006b2e:	fe843783          	ld	a5,-24(s0)
    80006b32:	43dc                	lw	a5,4(a5)
    80006b34:	e385                	bnez	a5,80006b54 <filealloc+0x4c>
      f->ref = 1;
    80006b36:	fe843783          	ld	a5,-24(s0)
    80006b3a:	4705                	li	a4,1
    80006b3c:	c3d8                	sw	a4,4(a5)
      release(&ftable.lock);
    80006b3e:	0001d517          	auipc	a0,0x1d
    80006b42:	18250513          	addi	a0,a0,386 # 80023cc0 <ftable>
    80006b46:	ffffa097          	auipc	ra,0xffffa
    80006b4a:	796080e7          	jalr	1942(ra) # 800012dc <release>
      return f;
    80006b4e:	fe843783          	ld	a5,-24(s0)
    80006b52:	a805                	j	80006b82 <filealloc+0x7a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80006b54:	fe843783          	ld	a5,-24(s0)
    80006b58:	02878793          	addi	a5,a5,40
    80006b5c:	fef43423          	sd	a5,-24(s0)
    80006b60:	0001e797          	auipc	a5,0x1e
    80006b64:	11878793          	addi	a5,a5,280 # 80024c78 <disk>
    80006b68:	fe843703          	ld	a4,-24(s0)
    80006b6c:	fcf761e3          	bltu	a4,a5,80006b2e <filealloc+0x26>
    }
  }
  release(&ftable.lock);
    80006b70:	0001d517          	auipc	a0,0x1d
    80006b74:	15050513          	addi	a0,a0,336 # 80023cc0 <ftable>
    80006b78:	ffffa097          	auipc	ra,0xffffa
    80006b7c:	764080e7          	jalr	1892(ra) # 800012dc <release>
  return 0;
    80006b80:	4781                	li	a5,0
}
    80006b82:	853e                	mv	a0,a5
    80006b84:	60e2                	ld	ra,24(sp)
    80006b86:	6442                	ld	s0,16(sp)
    80006b88:	6105                	addi	sp,sp,32
    80006b8a:	8082                	ret

0000000080006b8c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80006b8c:	1101                	addi	sp,sp,-32
    80006b8e:	ec06                	sd	ra,24(sp)
    80006b90:	e822                	sd	s0,16(sp)
    80006b92:	1000                	addi	s0,sp,32
    80006b94:	fea43423          	sd	a0,-24(s0)
  acquire(&ftable.lock);
    80006b98:	0001d517          	auipc	a0,0x1d
    80006b9c:	12850513          	addi	a0,a0,296 # 80023cc0 <ftable>
    80006ba0:	ffffa097          	auipc	ra,0xffffa
    80006ba4:	6d8080e7          	jalr	1752(ra) # 80001278 <acquire>
  if(f->ref < 1)
    80006ba8:	fe843783          	ld	a5,-24(s0)
    80006bac:	43dc                	lw	a5,4(a5)
    80006bae:	00f04a63          	bgtz	a5,80006bc2 <filedup+0x36>
    panic("filedup");
    80006bb2:	00005517          	auipc	a0,0x5
    80006bb6:	a1650513          	addi	a0,a0,-1514 # 8000b5c8 <etext+0x5c8>
    80006bba:	ffffa097          	auipc	ra,0xffffa
    80006bbe:	0d0080e7          	jalr	208(ra) # 80000c8a <panic>
  f->ref++;
    80006bc2:	fe843783          	ld	a5,-24(s0)
    80006bc6:	43dc                	lw	a5,4(a5)
    80006bc8:	2785                	addiw	a5,a5,1
    80006bca:	0007871b          	sext.w	a4,a5
    80006bce:	fe843783          	ld	a5,-24(s0)
    80006bd2:	c3d8                	sw	a4,4(a5)
  release(&ftable.lock);
    80006bd4:	0001d517          	auipc	a0,0x1d
    80006bd8:	0ec50513          	addi	a0,a0,236 # 80023cc0 <ftable>
    80006bdc:	ffffa097          	auipc	ra,0xffffa
    80006be0:	700080e7          	jalr	1792(ra) # 800012dc <release>
  return f;
    80006be4:	fe843783          	ld	a5,-24(s0)
}
    80006be8:	853e                	mv	a0,a5
    80006bea:	60e2                	ld	ra,24(sp)
    80006bec:	6442                	ld	s0,16(sp)
    80006bee:	6105                	addi	sp,sp,32
    80006bf0:	8082                	ret

0000000080006bf2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80006bf2:	715d                	addi	sp,sp,-80
    80006bf4:	e486                	sd	ra,72(sp)
    80006bf6:	e0a2                	sd	s0,64(sp)
    80006bf8:	0880                	addi	s0,sp,80
    80006bfa:	faa43c23          	sd	a0,-72(s0)
  struct file ff;

  acquire(&ftable.lock);
    80006bfe:	0001d517          	auipc	a0,0x1d
    80006c02:	0c250513          	addi	a0,a0,194 # 80023cc0 <ftable>
    80006c06:	ffffa097          	auipc	ra,0xffffa
    80006c0a:	672080e7          	jalr	1650(ra) # 80001278 <acquire>
  if(f->ref < 1)
    80006c0e:	fb843783          	ld	a5,-72(s0)
    80006c12:	43dc                	lw	a5,4(a5)
    80006c14:	00f04a63          	bgtz	a5,80006c28 <fileclose+0x36>
    panic("fileclose");
    80006c18:	00005517          	auipc	a0,0x5
    80006c1c:	9b850513          	addi	a0,a0,-1608 # 8000b5d0 <etext+0x5d0>
    80006c20:	ffffa097          	auipc	ra,0xffffa
    80006c24:	06a080e7          	jalr	106(ra) # 80000c8a <panic>
  if(--f->ref > 0){
    80006c28:	fb843783          	ld	a5,-72(s0)
    80006c2c:	43dc                	lw	a5,4(a5)
    80006c2e:	37fd                	addiw	a5,a5,-1
    80006c30:	0007871b          	sext.w	a4,a5
    80006c34:	fb843783          	ld	a5,-72(s0)
    80006c38:	c3d8                	sw	a4,4(a5)
    80006c3a:	fb843783          	ld	a5,-72(s0)
    80006c3e:	43dc                	lw	a5,4(a5)
    80006c40:	00f05b63          	blez	a5,80006c56 <fileclose+0x64>
    release(&ftable.lock);
    80006c44:	0001d517          	auipc	a0,0x1d
    80006c48:	07c50513          	addi	a0,a0,124 # 80023cc0 <ftable>
    80006c4c:	ffffa097          	auipc	ra,0xffffa
    80006c50:	690080e7          	jalr	1680(ra) # 800012dc <release>
    80006c54:	a879                	j	80006cf2 <fileclose+0x100>
    return;
  }
  ff = *f;
    80006c56:	fb843783          	ld	a5,-72(s0)
    80006c5a:	638c                	ld	a1,0(a5)
    80006c5c:	6790                	ld	a2,8(a5)
    80006c5e:	6b94                	ld	a3,16(a5)
    80006c60:	6f98                	ld	a4,24(a5)
    80006c62:	739c                	ld	a5,32(a5)
    80006c64:	fcb43423          	sd	a1,-56(s0)
    80006c68:	fcc43823          	sd	a2,-48(s0)
    80006c6c:	fcd43c23          	sd	a3,-40(s0)
    80006c70:	fee43023          	sd	a4,-32(s0)
    80006c74:	fef43423          	sd	a5,-24(s0)
  f->ref = 0;
    80006c78:	fb843783          	ld	a5,-72(s0)
    80006c7c:	0007a223          	sw	zero,4(a5)
  f->type = FD_NONE;
    80006c80:	fb843783          	ld	a5,-72(s0)
    80006c84:	0007a023          	sw	zero,0(a5)
  release(&ftable.lock);
    80006c88:	0001d517          	auipc	a0,0x1d
    80006c8c:	03850513          	addi	a0,a0,56 # 80023cc0 <ftable>
    80006c90:	ffffa097          	auipc	ra,0xffffa
    80006c94:	64c080e7          	jalr	1612(ra) # 800012dc <release>

  if(ff.type == FD_PIPE){
    80006c98:	fc842783          	lw	a5,-56(s0)
    80006c9c:	873e                	mv	a4,a5
    80006c9e:	4785                	li	a5,1
    80006ca0:	00f71e63          	bne	a4,a5,80006cbc <fileclose+0xca>
    pipeclose(ff.pipe, ff.writable);
    80006ca4:	fd843783          	ld	a5,-40(s0)
    80006ca8:	fd144703          	lbu	a4,-47(s0)
    80006cac:	2701                	sext.w	a4,a4
    80006cae:	85ba                	mv	a1,a4
    80006cb0:	853e                	mv	a0,a5
    80006cb2:	00000097          	auipc	ra,0x0
    80006cb6:	5b6080e7          	jalr	1462(ra) # 80007268 <pipeclose>
    80006cba:	a825                	j	80006cf2 <fileclose+0x100>
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80006cbc:	fc842783          	lw	a5,-56(s0)
    80006cc0:	873e                	mv	a4,a5
    80006cc2:	4789                	li	a5,2
    80006cc4:	00f70863          	beq	a4,a5,80006cd4 <fileclose+0xe2>
    80006cc8:	fc842783          	lw	a5,-56(s0)
    80006ccc:	873e                	mv	a4,a5
    80006cce:	478d                	li	a5,3
    80006cd0:	02f71163          	bne	a4,a5,80006cf2 <fileclose+0x100>
    begin_op();
    80006cd4:	00000097          	auipc	ra,0x0
    80006cd8:	884080e7          	jalr	-1916(ra) # 80006558 <begin_op>
    iput(ff.ip);
    80006cdc:	fe043783          	ld	a5,-32(s0)
    80006ce0:	853e                	mv	a0,a5
    80006ce2:	fffff097          	auipc	ra,0xfffff
    80006ce6:	96c080e7          	jalr	-1684(ra) # 8000564e <iput>
    end_op();
    80006cea:	00000097          	auipc	ra,0x0
    80006cee:	930080e7          	jalr	-1744(ra) # 8000661a <end_op>
  }
}
    80006cf2:	60a6                	ld	ra,72(sp)
    80006cf4:	6406                	ld	s0,64(sp)
    80006cf6:	6161                	addi	sp,sp,80
    80006cf8:	8082                	ret

0000000080006cfa <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80006cfa:	7139                	addi	sp,sp,-64
    80006cfc:	fc06                	sd	ra,56(sp)
    80006cfe:	f822                	sd	s0,48(sp)
    80006d00:	0080                	addi	s0,sp,64
    80006d02:	fca43423          	sd	a0,-56(s0)
    80006d06:	fcb43023          	sd	a1,-64(s0)
  struct proc *p = myproc();
    80006d0a:	ffffc097          	auipc	ra,0xffffc
    80006d0e:	b36080e7          	jalr	-1226(ra) # 80002840 <myproc>
    80006d12:	fea43423          	sd	a0,-24(s0)
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80006d16:	fc843783          	ld	a5,-56(s0)
    80006d1a:	439c                	lw	a5,0(a5)
    80006d1c:	873e                	mv	a4,a5
    80006d1e:	4789                	li	a5,2
    80006d20:	00f70963          	beq	a4,a5,80006d32 <filestat+0x38>
    80006d24:	fc843783          	ld	a5,-56(s0)
    80006d28:	439c                	lw	a5,0(a5)
    80006d2a:	873e                	mv	a4,a5
    80006d2c:	478d                	li	a5,3
    80006d2e:	06f71263          	bne	a4,a5,80006d92 <filestat+0x98>
    ilock(f->ip);
    80006d32:	fc843783          	ld	a5,-56(s0)
    80006d36:	6f9c                	ld	a5,24(a5)
    80006d38:	853e                	mv	a0,a5
    80006d3a:	ffffe097          	auipc	ra,0xffffe
    80006d3e:	786080e7          	jalr	1926(ra) # 800054c0 <ilock>
    stati(f->ip, &st);
    80006d42:	fc843783          	ld	a5,-56(s0)
    80006d46:	6f9c                	ld	a5,24(a5)
    80006d48:	fd040713          	addi	a4,s0,-48
    80006d4c:	85ba                	mv	a1,a4
    80006d4e:	853e                	mv	a0,a5
    80006d50:	fffff097          	auipc	ra,0xfffff
    80006d54:	cc2080e7          	jalr	-830(ra) # 80005a12 <stati>
    iunlock(f->ip);
    80006d58:	fc843783          	ld	a5,-56(s0)
    80006d5c:	6f9c                	ld	a5,24(a5)
    80006d5e:	853e                	mv	a0,a5
    80006d60:	fffff097          	auipc	ra,0xfffff
    80006d64:	894080e7          	jalr	-1900(ra) # 800055f4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80006d68:	fe843783          	ld	a5,-24(s0)
    80006d6c:	6bbc                	ld	a5,80(a5)
    80006d6e:	fd040713          	addi	a4,s0,-48
    80006d72:	46e1                	li	a3,24
    80006d74:	863a                	mv	a2,a4
    80006d76:	fc043583          	ld	a1,-64(s0)
    80006d7a:	853e                	mv	a0,a5
    80006d7c:	ffffb097          	auipc	ra,0xffffb
    80006d80:	58e080e7          	jalr	1422(ra) # 8000230a <copyout>
    80006d84:	87aa                	mv	a5,a0
    80006d86:	0007d463          	bgez	a5,80006d8e <filestat+0x94>
      return -1;
    80006d8a:	57fd                	li	a5,-1
    80006d8c:	a021                	j	80006d94 <filestat+0x9a>
    return 0;
    80006d8e:	4781                	li	a5,0
    80006d90:	a011                	j	80006d94 <filestat+0x9a>
  }
  return -1;
    80006d92:	57fd                	li	a5,-1
}
    80006d94:	853e                	mv	a0,a5
    80006d96:	70e2                	ld	ra,56(sp)
    80006d98:	7442                	ld	s0,48(sp)
    80006d9a:	6121                	addi	sp,sp,64
    80006d9c:	8082                	ret

0000000080006d9e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80006d9e:	7139                	addi	sp,sp,-64
    80006da0:	fc06                	sd	ra,56(sp)
    80006da2:	f822                	sd	s0,48(sp)
    80006da4:	0080                	addi	s0,sp,64
    80006da6:	fca43c23          	sd	a0,-40(s0)
    80006daa:	fcb43823          	sd	a1,-48(s0)
    80006dae:	87b2                	mv	a5,a2
    80006db0:	fcf42623          	sw	a5,-52(s0)
  int r = 0;
    80006db4:	fe042623          	sw	zero,-20(s0)

  if(f->readable == 0)
    80006db8:	fd843783          	ld	a5,-40(s0)
    80006dbc:	0087c783          	lbu	a5,8(a5)
    80006dc0:	e399                	bnez	a5,80006dc6 <fileread+0x28>
    return -1;
    80006dc2:	57fd                	li	a5,-1
    80006dc4:	aa1d                	j	80006efa <fileread+0x15c>

  if(f->type == FD_PIPE){
    80006dc6:	fd843783          	ld	a5,-40(s0)
    80006dca:	439c                	lw	a5,0(a5)
    80006dcc:	873e                	mv	a4,a5
    80006dce:	4785                	li	a5,1
    80006dd0:	02f71363          	bne	a4,a5,80006df6 <fileread+0x58>
    r = piperead(f->pipe, addr, n);
    80006dd4:	fd843783          	ld	a5,-40(s0)
    80006dd8:	6b9c                	ld	a5,16(a5)
    80006dda:	fcc42703          	lw	a4,-52(s0)
    80006dde:	863a                	mv	a2,a4
    80006de0:	fd043583          	ld	a1,-48(s0)
    80006de4:	853e                	mv	a0,a5
    80006de6:	00000097          	auipc	ra,0x0
    80006dea:	67e080e7          	jalr	1662(ra) # 80007464 <piperead>
    80006dee:	87aa                	mv	a5,a0
    80006df0:	fef42623          	sw	a5,-20(s0)
    80006df4:	a209                	j	80006ef6 <fileread+0x158>
  } else if(f->type == FD_DEVICE){
    80006df6:	fd843783          	ld	a5,-40(s0)
    80006dfa:	439c                	lw	a5,0(a5)
    80006dfc:	873e                	mv	a4,a5
    80006dfe:	478d                	li	a5,3
    80006e00:	06f71863          	bne	a4,a5,80006e70 <fileread+0xd2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80006e04:	fd843783          	ld	a5,-40(s0)
    80006e08:	02479783          	lh	a5,36(a5)
    80006e0c:	2781                	sext.w	a5,a5
    80006e0e:	0207c863          	bltz	a5,80006e3e <fileread+0xa0>
    80006e12:	fd843783          	ld	a5,-40(s0)
    80006e16:	02479783          	lh	a5,36(a5)
    80006e1a:	0007871b          	sext.w	a4,a5
    80006e1e:	47a5                	li	a5,9
    80006e20:	00e7cf63          	blt	a5,a4,80006e3e <fileread+0xa0>
    80006e24:	fd843783          	ld	a5,-40(s0)
    80006e28:	02479783          	lh	a5,36(a5)
    80006e2c:	2781                	sext.w	a5,a5
    80006e2e:	0001d717          	auipc	a4,0x1d
    80006e32:	df270713          	addi	a4,a4,-526 # 80023c20 <devsw>
    80006e36:	0792                	slli	a5,a5,0x4
    80006e38:	97ba                	add	a5,a5,a4
    80006e3a:	639c                	ld	a5,0(a5)
    80006e3c:	e399                	bnez	a5,80006e42 <fileread+0xa4>
      return -1;
    80006e3e:	57fd                	li	a5,-1
    80006e40:	a86d                	j	80006efa <fileread+0x15c>
    r = devsw[f->major].read(1, addr, n);
    80006e42:	fd843783          	ld	a5,-40(s0)
    80006e46:	02479783          	lh	a5,36(a5)
    80006e4a:	2781                	sext.w	a5,a5
    80006e4c:	0001d717          	auipc	a4,0x1d
    80006e50:	dd470713          	addi	a4,a4,-556 # 80023c20 <devsw>
    80006e54:	0792                	slli	a5,a5,0x4
    80006e56:	97ba                	add	a5,a5,a4
    80006e58:	639c                	ld	a5,0(a5)
    80006e5a:	fcc42703          	lw	a4,-52(s0)
    80006e5e:	863a                	mv	a2,a4
    80006e60:	fd043583          	ld	a1,-48(s0)
    80006e64:	4505                	li	a0,1
    80006e66:	9782                	jalr	a5
    80006e68:	87aa                	mv	a5,a0
    80006e6a:	fef42623          	sw	a5,-20(s0)
    80006e6e:	a061                	j	80006ef6 <fileread+0x158>
  } else if(f->type == FD_INODE){
    80006e70:	fd843783          	ld	a5,-40(s0)
    80006e74:	439c                	lw	a5,0(a5)
    80006e76:	873e                	mv	a4,a5
    80006e78:	4789                	li	a5,2
    80006e7a:	06f71663          	bne	a4,a5,80006ee6 <fileread+0x148>
    ilock(f->ip);
    80006e7e:	fd843783          	ld	a5,-40(s0)
    80006e82:	6f9c                	ld	a5,24(a5)
    80006e84:	853e                	mv	a0,a5
    80006e86:	ffffe097          	auipc	ra,0xffffe
    80006e8a:	63a080e7          	jalr	1594(ra) # 800054c0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80006e8e:	fd843783          	ld	a5,-40(s0)
    80006e92:	6f88                	ld	a0,24(a5)
    80006e94:	fd843783          	ld	a5,-40(s0)
    80006e98:	539c                	lw	a5,32(a5)
    80006e9a:	fcc42703          	lw	a4,-52(s0)
    80006e9e:	86be                	mv	a3,a5
    80006ea0:	fd043603          	ld	a2,-48(s0)
    80006ea4:	4585                	li	a1,1
    80006ea6:	fffff097          	auipc	ra,0xfffff
    80006eaa:	bd0080e7          	jalr	-1072(ra) # 80005a76 <readi>
    80006eae:	87aa                	mv	a5,a0
    80006eb0:	fef42623          	sw	a5,-20(s0)
    80006eb4:	fec42783          	lw	a5,-20(s0)
    80006eb8:	2781                	sext.w	a5,a5
    80006eba:	00f05d63          	blez	a5,80006ed4 <fileread+0x136>
      f->off += r;
    80006ebe:	fd843783          	ld	a5,-40(s0)
    80006ec2:	5398                	lw	a4,32(a5)
    80006ec4:	fec42783          	lw	a5,-20(s0)
    80006ec8:	9fb9                	addw	a5,a5,a4
    80006eca:	0007871b          	sext.w	a4,a5
    80006ece:	fd843783          	ld	a5,-40(s0)
    80006ed2:	d398                	sw	a4,32(a5)
    iunlock(f->ip);
    80006ed4:	fd843783          	ld	a5,-40(s0)
    80006ed8:	6f9c                	ld	a5,24(a5)
    80006eda:	853e                	mv	a0,a5
    80006edc:	ffffe097          	auipc	ra,0xffffe
    80006ee0:	718080e7          	jalr	1816(ra) # 800055f4 <iunlock>
    80006ee4:	a809                	j	80006ef6 <fileread+0x158>
  } else {
    panic("fileread");
    80006ee6:	00004517          	auipc	a0,0x4
    80006eea:	6fa50513          	addi	a0,a0,1786 # 8000b5e0 <etext+0x5e0>
    80006eee:	ffffa097          	auipc	ra,0xffffa
    80006ef2:	d9c080e7          	jalr	-612(ra) # 80000c8a <panic>
  }

  return r;
    80006ef6:	fec42783          	lw	a5,-20(s0)
}
    80006efa:	853e                	mv	a0,a5
    80006efc:	70e2                	ld	ra,56(sp)
    80006efe:	7442                	ld	s0,48(sp)
    80006f00:	6121                	addi	sp,sp,64
    80006f02:	8082                	ret

0000000080006f04 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80006f04:	715d                	addi	sp,sp,-80
    80006f06:	e486                	sd	ra,72(sp)
    80006f08:	e0a2                	sd	s0,64(sp)
    80006f0a:	0880                	addi	s0,sp,80
    80006f0c:	fca43423          	sd	a0,-56(s0)
    80006f10:	fcb43023          	sd	a1,-64(s0)
    80006f14:	87b2                	mv	a5,a2
    80006f16:	faf42e23          	sw	a5,-68(s0)
  int r, ret = 0;
    80006f1a:	fe042623          	sw	zero,-20(s0)

  if(f->writable == 0)
    80006f1e:	fc843783          	ld	a5,-56(s0)
    80006f22:	0097c783          	lbu	a5,9(a5)
    80006f26:	e399                	bnez	a5,80006f2c <filewrite+0x28>
    return -1;
    80006f28:	57fd                	li	a5,-1
    80006f2a:	a2c5                	j	8000710a <filewrite+0x206>

  if(f->type == FD_PIPE){
    80006f2c:	fc843783          	ld	a5,-56(s0)
    80006f30:	439c                	lw	a5,0(a5)
    80006f32:	873e                	mv	a4,a5
    80006f34:	4785                	li	a5,1
    80006f36:	02f71363          	bne	a4,a5,80006f5c <filewrite+0x58>
    ret = pipewrite(f->pipe, addr, n);
    80006f3a:	fc843783          	ld	a5,-56(s0)
    80006f3e:	6b9c                	ld	a5,16(a5)
    80006f40:	fbc42703          	lw	a4,-68(s0)
    80006f44:	863a                	mv	a2,a4
    80006f46:	fc043583          	ld	a1,-64(s0)
    80006f4a:	853e                	mv	a0,a5
    80006f4c:	00000097          	auipc	ra,0x0
    80006f50:	3c4080e7          	jalr	964(ra) # 80007310 <pipewrite>
    80006f54:	87aa                	mv	a5,a0
    80006f56:	fef42623          	sw	a5,-20(s0)
    80006f5a:	a275                	j	80007106 <filewrite+0x202>
  } else if(f->type == FD_DEVICE){
    80006f5c:	fc843783          	ld	a5,-56(s0)
    80006f60:	439c                	lw	a5,0(a5)
    80006f62:	873e                	mv	a4,a5
    80006f64:	478d                	li	a5,3
    80006f66:	06f71863          	bne	a4,a5,80006fd6 <filewrite+0xd2>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80006f6a:	fc843783          	ld	a5,-56(s0)
    80006f6e:	02479783          	lh	a5,36(a5)
    80006f72:	2781                	sext.w	a5,a5
    80006f74:	0207c863          	bltz	a5,80006fa4 <filewrite+0xa0>
    80006f78:	fc843783          	ld	a5,-56(s0)
    80006f7c:	02479783          	lh	a5,36(a5)
    80006f80:	0007871b          	sext.w	a4,a5
    80006f84:	47a5                	li	a5,9
    80006f86:	00e7cf63          	blt	a5,a4,80006fa4 <filewrite+0xa0>
    80006f8a:	fc843783          	ld	a5,-56(s0)
    80006f8e:	02479783          	lh	a5,36(a5)
    80006f92:	2781                	sext.w	a5,a5
    80006f94:	0001d717          	auipc	a4,0x1d
    80006f98:	c8c70713          	addi	a4,a4,-884 # 80023c20 <devsw>
    80006f9c:	0792                	slli	a5,a5,0x4
    80006f9e:	97ba                	add	a5,a5,a4
    80006fa0:	679c                	ld	a5,8(a5)
    80006fa2:	e399                	bnez	a5,80006fa8 <filewrite+0xa4>
      return -1;
    80006fa4:	57fd                	li	a5,-1
    80006fa6:	a295                	j	8000710a <filewrite+0x206>
    ret = devsw[f->major].write(1, addr, n);
    80006fa8:	fc843783          	ld	a5,-56(s0)
    80006fac:	02479783          	lh	a5,36(a5)
    80006fb0:	2781                	sext.w	a5,a5
    80006fb2:	0001d717          	auipc	a4,0x1d
    80006fb6:	c6e70713          	addi	a4,a4,-914 # 80023c20 <devsw>
    80006fba:	0792                	slli	a5,a5,0x4
    80006fbc:	97ba                	add	a5,a5,a4
    80006fbe:	679c                	ld	a5,8(a5)
    80006fc0:	fbc42703          	lw	a4,-68(s0)
    80006fc4:	863a                	mv	a2,a4
    80006fc6:	fc043583          	ld	a1,-64(s0)
    80006fca:	4505                	li	a0,1
    80006fcc:	9782                	jalr	a5
    80006fce:	87aa                	mv	a5,a0
    80006fd0:	fef42623          	sw	a5,-20(s0)
    80006fd4:	aa0d                	j	80007106 <filewrite+0x202>
  } else if(f->type == FD_INODE){
    80006fd6:	fc843783          	ld	a5,-56(s0)
    80006fda:	439c                	lw	a5,0(a5)
    80006fdc:	873e                	mv	a4,a5
    80006fde:	4789                	li	a5,2
    80006fe0:	10f71b63          	bne	a4,a5,800070f6 <filewrite+0x1f2>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    80006fe4:	6785                	lui	a5,0x1
    80006fe6:	c0078793          	addi	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80006fea:	fef42023          	sw	a5,-32(s0)
    int i = 0;
    80006fee:	fe042423          	sw	zero,-24(s0)
    while(i < n){
    80006ff2:	a0f9                	j	800070c0 <filewrite+0x1bc>
      int n1 = n - i;
    80006ff4:	fbc42783          	lw	a5,-68(s0)
    80006ff8:	873e                	mv	a4,a5
    80006ffa:	fe842783          	lw	a5,-24(s0)
    80006ffe:	40f707bb          	subw	a5,a4,a5
    80007002:	fef42223          	sw	a5,-28(s0)
      if(n1 > max)
    80007006:	fe442783          	lw	a5,-28(s0)
    8000700a:	873e                	mv	a4,a5
    8000700c:	fe042783          	lw	a5,-32(s0)
    80007010:	2701                	sext.w	a4,a4
    80007012:	2781                	sext.w	a5,a5
    80007014:	00e7d663          	bge	a5,a4,80007020 <filewrite+0x11c>
        n1 = max;
    80007018:	fe042783          	lw	a5,-32(s0)
    8000701c:	fef42223          	sw	a5,-28(s0)

      begin_op();
    80007020:	fffff097          	auipc	ra,0xfffff
    80007024:	538080e7          	jalr	1336(ra) # 80006558 <begin_op>
      ilock(f->ip);
    80007028:	fc843783          	ld	a5,-56(s0)
    8000702c:	6f9c                	ld	a5,24(a5)
    8000702e:	853e                	mv	a0,a5
    80007030:	ffffe097          	auipc	ra,0xffffe
    80007034:	490080e7          	jalr	1168(ra) # 800054c0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80007038:	fc843783          	ld	a5,-56(s0)
    8000703c:	6f88                	ld	a0,24(a5)
    8000703e:	fe842703          	lw	a4,-24(s0)
    80007042:	fc043783          	ld	a5,-64(s0)
    80007046:	00f70633          	add	a2,a4,a5
    8000704a:	fc843783          	ld	a5,-56(s0)
    8000704e:	539c                	lw	a5,32(a5)
    80007050:	fe442703          	lw	a4,-28(s0)
    80007054:	86be                	mv	a3,a5
    80007056:	4585                	li	a1,1
    80007058:	fffff097          	auipc	ra,0xfffff
    8000705c:	bbc080e7          	jalr	-1092(ra) # 80005c14 <writei>
    80007060:	87aa                	mv	a5,a0
    80007062:	fcf42e23          	sw	a5,-36(s0)
    80007066:	fdc42783          	lw	a5,-36(s0)
    8000706a:	2781                	sext.w	a5,a5
    8000706c:	00f05d63          	blez	a5,80007086 <filewrite+0x182>
        f->off += r;
    80007070:	fc843783          	ld	a5,-56(s0)
    80007074:	5398                	lw	a4,32(a5)
    80007076:	fdc42783          	lw	a5,-36(s0)
    8000707a:	9fb9                	addw	a5,a5,a4
    8000707c:	0007871b          	sext.w	a4,a5
    80007080:	fc843783          	ld	a5,-56(s0)
    80007084:	d398                	sw	a4,32(a5)
      iunlock(f->ip);
    80007086:	fc843783          	ld	a5,-56(s0)
    8000708a:	6f9c                	ld	a5,24(a5)
    8000708c:	853e                	mv	a0,a5
    8000708e:	ffffe097          	auipc	ra,0xffffe
    80007092:	566080e7          	jalr	1382(ra) # 800055f4 <iunlock>
      end_op();
    80007096:	fffff097          	auipc	ra,0xfffff
    8000709a:	584080e7          	jalr	1412(ra) # 8000661a <end_op>

      if(r != n1){
    8000709e:	fdc42783          	lw	a5,-36(s0)
    800070a2:	873e                	mv	a4,a5
    800070a4:	fe442783          	lw	a5,-28(s0)
    800070a8:	2701                	sext.w	a4,a4
    800070aa:	2781                	sext.w	a5,a5
    800070ac:	02f71463          	bne	a4,a5,800070d4 <filewrite+0x1d0>
        // error from writei
        break;
      }
      i += r;
    800070b0:	fe842783          	lw	a5,-24(s0)
    800070b4:	873e                	mv	a4,a5
    800070b6:	fdc42783          	lw	a5,-36(s0)
    800070ba:	9fb9                	addw	a5,a5,a4
    800070bc:	fef42423          	sw	a5,-24(s0)
    while(i < n){
    800070c0:	fe842783          	lw	a5,-24(s0)
    800070c4:	873e                	mv	a4,a5
    800070c6:	fbc42783          	lw	a5,-68(s0)
    800070ca:	2701                	sext.w	a4,a4
    800070cc:	2781                	sext.w	a5,a5
    800070ce:	f2f743e3          	blt	a4,a5,80006ff4 <filewrite+0xf0>
    800070d2:	a011                	j	800070d6 <filewrite+0x1d2>
        break;
    800070d4:	0001                	nop
    }
    ret = (i == n ? n : -1);
    800070d6:	fe842783          	lw	a5,-24(s0)
    800070da:	873e                	mv	a4,a5
    800070dc:	fbc42783          	lw	a5,-68(s0)
    800070e0:	2701                	sext.w	a4,a4
    800070e2:	2781                	sext.w	a5,a5
    800070e4:	00f71563          	bne	a4,a5,800070ee <filewrite+0x1ea>
    800070e8:	fbc42783          	lw	a5,-68(s0)
    800070ec:	a011                	j	800070f0 <filewrite+0x1ec>
    800070ee:	57fd                	li	a5,-1
    800070f0:	fef42623          	sw	a5,-20(s0)
    800070f4:	a809                	j	80007106 <filewrite+0x202>
  } else {
    panic("filewrite");
    800070f6:	00004517          	auipc	a0,0x4
    800070fa:	4fa50513          	addi	a0,a0,1274 # 8000b5f0 <etext+0x5f0>
    800070fe:	ffffa097          	auipc	ra,0xffffa
    80007102:	b8c080e7          	jalr	-1140(ra) # 80000c8a <panic>
  }

  return ret;
    80007106:	fec42783          	lw	a5,-20(s0)
}
    8000710a:	853e                	mv	a0,a5
    8000710c:	60a6                	ld	ra,72(sp)
    8000710e:	6406                	ld	s0,64(sp)
    80007110:	6161                	addi	sp,sp,80
    80007112:	8082                	ret

0000000080007114 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80007114:	7179                	addi	sp,sp,-48
    80007116:	f406                	sd	ra,40(sp)
    80007118:	f022                	sd	s0,32(sp)
    8000711a:	1800                	addi	s0,sp,48
    8000711c:	fca43c23          	sd	a0,-40(s0)
    80007120:	fcb43823          	sd	a1,-48(s0)
  struct pipe *pi;

  pi = 0;
    80007124:	fe043423          	sd	zero,-24(s0)
  *f0 = *f1 = 0;
    80007128:	fd043783          	ld	a5,-48(s0)
    8000712c:	0007b023          	sd	zero,0(a5)
    80007130:	fd043783          	ld	a5,-48(s0)
    80007134:	6398                	ld	a4,0(a5)
    80007136:	fd843783          	ld	a5,-40(s0)
    8000713a:	e398                	sd	a4,0(a5)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000713c:	00000097          	auipc	ra,0x0
    80007140:	9cc080e7          	jalr	-1588(ra) # 80006b08 <filealloc>
    80007144:	872a                	mv	a4,a0
    80007146:	fd843783          	ld	a5,-40(s0)
    8000714a:	e398                	sd	a4,0(a5)
    8000714c:	fd843783          	ld	a5,-40(s0)
    80007150:	639c                	ld	a5,0(a5)
    80007152:	c3e9                	beqz	a5,80007214 <pipealloc+0x100>
    80007154:	00000097          	auipc	ra,0x0
    80007158:	9b4080e7          	jalr	-1612(ra) # 80006b08 <filealloc>
    8000715c:	872a                	mv	a4,a0
    8000715e:	fd043783          	ld	a5,-48(s0)
    80007162:	e398                	sd	a4,0(a5)
    80007164:	fd043783          	ld	a5,-48(s0)
    80007168:	639c                	ld	a5,0(a5)
    8000716a:	c7cd                	beqz	a5,80007214 <pipealloc+0x100>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000716c:	ffffa097          	auipc	ra,0xffffa
    80007170:	fb8080e7          	jalr	-72(ra) # 80001124 <kalloc>
    80007174:	fea43423          	sd	a0,-24(s0)
    80007178:	fe843783          	ld	a5,-24(s0)
    8000717c:	cfd1                	beqz	a5,80007218 <pipealloc+0x104>
    goto bad;
  pi->readopen = 1;
    8000717e:	fe843783          	ld	a5,-24(s0)
    80007182:	4705                	li	a4,1
    80007184:	22e7a023          	sw	a4,544(a5)
  pi->writeopen = 1;
    80007188:	fe843783          	ld	a5,-24(s0)
    8000718c:	4705                	li	a4,1
    8000718e:	22e7a223          	sw	a4,548(a5)
  pi->nwrite = 0;
    80007192:	fe843783          	ld	a5,-24(s0)
    80007196:	2007ae23          	sw	zero,540(a5)
  pi->nread = 0;
    8000719a:	fe843783          	ld	a5,-24(s0)
    8000719e:	2007ac23          	sw	zero,536(a5)
  initlock(&pi->lock, "pipe");
    800071a2:	fe843783          	ld	a5,-24(s0)
    800071a6:	00004597          	auipc	a1,0x4
    800071aa:	45a58593          	addi	a1,a1,1114 # 8000b600 <etext+0x600>
    800071ae:	853e                	mv	a0,a5
    800071b0:	ffffa097          	auipc	ra,0xffffa
    800071b4:	098080e7          	jalr	152(ra) # 80001248 <initlock>
  (*f0)->type = FD_PIPE;
    800071b8:	fd843783          	ld	a5,-40(s0)
    800071bc:	639c                	ld	a5,0(a5)
    800071be:	4705                	li	a4,1
    800071c0:	c398                	sw	a4,0(a5)
  (*f0)->readable = 1;
    800071c2:	fd843783          	ld	a5,-40(s0)
    800071c6:	639c                	ld	a5,0(a5)
    800071c8:	4705                	li	a4,1
    800071ca:	00e78423          	sb	a4,8(a5)
  (*f0)->writable = 0;
    800071ce:	fd843783          	ld	a5,-40(s0)
    800071d2:	639c                	ld	a5,0(a5)
    800071d4:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800071d8:	fd843783          	ld	a5,-40(s0)
    800071dc:	639c                	ld	a5,0(a5)
    800071de:	fe843703          	ld	a4,-24(s0)
    800071e2:	eb98                	sd	a4,16(a5)
  (*f1)->type = FD_PIPE;
    800071e4:	fd043783          	ld	a5,-48(s0)
    800071e8:	639c                	ld	a5,0(a5)
    800071ea:	4705                	li	a4,1
    800071ec:	c398                	sw	a4,0(a5)
  (*f1)->readable = 0;
    800071ee:	fd043783          	ld	a5,-48(s0)
    800071f2:	639c                	ld	a5,0(a5)
    800071f4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800071f8:	fd043783          	ld	a5,-48(s0)
    800071fc:	639c                	ld	a5,0(a5)
    800071fe:	4705                	li	a4,1
    80007200:	00e784a3          	sb	a4,9(a5)
  (*f1)->pipe = pi;
    80007204:	fd043783          	ld	a5,-48(s0)
    80007208:	639c                	ld	a5,0(a5)
    8000720a:	fe843703          	ld	a4,-24(s0)
    8000720e:	eb98                	sd	a4,16(a5)
  return 0;
    80007210:	4781                	li	a5,0
    80007212:	a0b1                	j	8000725e <pipealloc+0x14a>
    goto bad;
    80007214:	0001                	nop
    80007216:	a011                	j	8000721a <pipealloc+0x106>
    goto bad;
    80007218:	0001                	nop

 bad:
  if(pi)
    8000721a:	fe843783          	ld	a5,-24(s0)
    8000721e:	c799                	beqz	a5,8000722c <pipealloc+0x118>
    kfree((char*)pi);
    80007220:	fe843503          	ld	a0,-24(s0)
    80007224:	ffffa097          	auipc	ra,0xffffa
    80007228:	e5c080e7          	jalr	-420(ra) # 80001080 <kfree>
  if(*f0)
    8000722c:	fd843783          	ld	a5,-40(s0)
    80007230:	639c                	ld	a5,0(a5)
    80007232:	cb89                	beqz	a5,80007244 <pipealloc+0x130>
    fileclose(*f0);
    80007234:	fd843783          	ld	a5,-40(s0)
    80007238:	639c                	ld	a5,0(a5)
    8000723a:	853e                	mv	a0,a5
    8000723c:	00000097          	auipc	ra,0x0
    80007240:	9b6080e7          	jalr	-1610(ra) # 80006bf2 <fileclose>
  if(*f1)
    80007244:	fd043783          	ld	a5,-48(s0)
    80007248:	639c                	ld	a5,0(a5)
    8000724a:	cb89                	beqz	a5,8000725c <pipealloc+0x148>
    fileclose(*f1);
    8000724c:	fd043783          	ld	a5,-48(s0)
    80007250:	639c                	ld	a5,0(a5)
    80007252:	853e                	mv	a0,a5
    80007254:	00000097          	auipc	ra,0x0
    80007258:	99e080e7          	jalr	-1634(ra) # 80006bf2 <fileclose>
  return -1;
    8000725c:	57fd                	li	a5,-1
}
    8000725e:	853e                	mv	a0,a5
    80007260:	70a2                	ld	ra,40(sp)
    80007262:	7402                	ld	s0,32(sp)
    80007264:	6145                	addi	sp,sp,48
    80007266:	8082                	ret

0000000080007268 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80007268:	1101                	addi	sp,sp,-32
    8000726a:	ec06                	sd	ra,24(sp)
    8000726c:	e822                	sd	s0,16(sp)
    8000726e:	1000                	addi	s0,sp,32
    80007270:	fea43423          	sd	a0,-24(s0)
    80007274:	87ae                	mv	a5,a1
    80007276:	fef42223          	sw	a5,-28(s0)
  acquire(&pi->lock);
    8000727a:	fe843783          	ld	a5,-24(s0)
    8000727e:	853e                	mv	a0,a5
    80007280:	ffffa097          	auipc	ra,0xffffa
    80007284:	ff8080e7          	jalr	-8(ra) # 80001278 <acquire>
  if(writable){
    80007288:	fe442783          	lw	a5,-28(s0)
    8000728c:	2781                	sext.w	a5,a5
    8000728e:	cf99                	beqz	a5,800072ac <pipeclose+0x44>
    pi->writeopen = 0;
    80007290:	fe843783          	ld	a5,-24(s0)
    80007294:	2207a223          	sw	zero,548(a5)
    wakeup(&pi->nread);
    80007298:	fe843783          	ld	a5,-24(s0)
    8000729c:	21878793          	addi	a5,a5,536
    800072a0:	853e                	mv	a0,a5
    800072a2:	ffffc097          	auipc	ra,0xffffc
    800072a6:	1dc080e7          	jalr	476(ra) # 8000347e <wakeup>
    800072aa:	a831                	j	800072c6 <pipeclose+0x5e>
  } else {
    pi->readopen = 0;
    800072ac:	fe843783          	ld	a5,-24(s0)
    800072b0:	2207a023          	sw	zero,544(a5)
    wakeup(&pi->nwrite);
    800072b4:	fe843783          	ld	a5,-24(s0)
    800072b8:	21c78793          	addi	a5,a5,540
    800072bc:	853e                	mv	a0,a5
    800072be:	ffffc097          	auipc	ra,0xffffc
    800072c2:	1c0080e7          	jalr	448(ra) # 8000347e <wakeup>
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800072c6:	fe843783          	ld	a5,-24(s0)
    800072ca:	2207a783          	lw	a5,544(a5)
    800072ce:	e785                	bnez	a5,800072f6 <pipeclose+0x8e>
    800072d0:	fe843783          	ld	a5,-24(s0)
    800072d4:	2247a783          	lw	a5,548(a5)
    800072d8:	ef99                	bnez	a5,800072f6 <pipeclose+0x8e>
    release(&pi->lock);
    800072da:	fe843783          	ld	a5,-24(s0)
    800072de:	853e                	mv	a0,a5
    800072e0:	ffffa097          	auipc	ra,0xffffa
    800072e4:	ffc080e7          	jalr	-4(ra) # 800012dc <release>
    kfree((char*)pi);
    800072e8:	fe843503          	ld	a0,-24(s0)
    800072ec:	ffffa097          	auipc	ra,0xffffa
    800072f0:	d94080e7          	jalr	-620(ra) # 80001080 <kfree>
    800072f4:	a809                	j	80007306 <pipeclose+0x9e>
  } else
    release(&pi->lock);
    800072f6:	fe843783          	ld	a5,-24(s0)
    800072fa:	853e                	mv	a0,a5
    800072fc:	ffffa097          	auipc	ra,0xffffa
    80007300:	fe0080e7          	jalr	-32(ra) # 800012dc <release>
}
    80007304:	0001                	nop
    80007306:	0001                	nop
    80007308:	60e2                	ld	ra,24(sp)
    8000730a:	6442                	ld	s0,16(sp)
    8000730c:	6105                	addi	sp,sp,32
    8000730e:	8082                	ret

0000000080007310 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80007310:	715d                	addi	sp,sp,-80
    80007312:	e486                	sd	ra,72(sp)
    80007314:	e0a2                	sd	s0,64(sp)
    80007316:	0880                	addi	s0,sp,80
    80007318:	fca43423          	sd	a0,-56(s0)
    8000731c:	fcb43023          	sd	a1,-64(s0)
    80007320:	87b2                	mv	a5,a2
    80007322:	faf42e23          	sw	a5,-68(s0)
  int i = 0;
    80007326:	fe042623          	sw	zero,-20(s0)
  struct proc *pr = myproc();
    8000732a:	ffffb097          	auipc	ra,0xffffb
    8000732e:	516080e7          	jalr	1302(ra) # 80002840 <myproc>
    80007332:	fea43023          	sd	a0,-32(s0)

  acquire(&pi->lock);
    80007336:	fc843783          	ld	a5,-56(s0)
    8000733a:	853e                	mv	a0,a5
    8000733c:	ffffa097          	auipc	ra,0xffffa
    80007340:	f3c080e7          	jalr	-196(ra) # 80001278 <acquire>
  while(i < n){
    80007344:	a8f1                	j	80007420 <pipewrite+0x110>
    if(pi->readopen == 0 || killed(pr)){
    80007346:	fc843783          	ld	a5,-56(s0)
    8000734a:	2207a783          	lw	a5,544(a5)
    8000734e:	cb89                	beqz	a5,80007360 <pipewrite+0x50>
    80007350:	fe043503          	ld	a0,-32(s0)
    80007354:	ffffc097          	auipc	ra,0xffffc
    80007358:	298080e7          	jalr	664(ra) # 800035ec <killed>
    8000735c:	87aa                	mv	a5,a0
    8000735e:	cb91                	beqz	a5,80007372 <pipewrite+0x62>
      release(&pi->lock);
    80007360:	fc843783          	ld	a5,-56(s0)
    80007364:	853e                	mv	a0,a5
    80007366:	ffffa097          	auipc	ra,0xffffa
    8000736a:	f76080e7          	jalr	-138(ra) # 800012dc <release>
      return -1;
    8000736e:	57fd                	li	a5,-1
    80007370:	a0ed                	j	8000745a <pipewrite+0x14a>
    }
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80007372:	fc843783          	ld	a5,-56(s0)
    80007376:	21c7a703          	lw	a4,540(a5)
    8000737a:	fc843783          	ld	a5,-56(s0)
    8000737e:	2187a783          	lw	a5,536(a5)
    80007382:	2007879b          	addiw	a5,a5,512
    80007386:	2781                	sext.w	a5,a5
    80007388:	02f71863          	bne	a4,a5,800073b8 <pipewrite+0xa8>
      wakeup(&pi->nread);
    8000738c:	fc843783          	ld	a5,-56(s0)
    80007390:	21878793          	addi	a5,a5,536
    80007394:	853e                	mv	a0,a5
    80007396:	ffffc097          	auipc	ra,0xffffc
    8000739a:	0e8080e7          	jalr	232(ra) # 8000347e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000739e:	fc843783          	ld	a5,-56(s0)
    800073a2:	21c78793          	addi	a5,a5,540
    800073a6:	fc843703          	ld	a4,-56(s0)
    800073aa:	85ba                	mv	a1,a4
    800073ac:	853e                	mv	a0,a5
    800073ae:	ffffc097          	auipc	ra,0xffffc
    800073b2:	054080e7          	jalr	84(ra) # 80003402 <sleep>
    800073b6:	a0ad                	j	80007420 <pipewrite+0x110>
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800073b8:	fe043783          	ld	a5,-32(s0)
    800073bc:	6ba8                	ld	a0,80(a5)
    800073be:	fec42703          	lw	a4,-20(s0)
    800073c2:	fc043783          	ld	a5,-64(s0)
    800073c6:	973e                	add	a4,a4,a5
    800073c8:	fdf40793          	addi	a5,s0,-33
    800073cc:	4685                	li	a3,1
    800073ce:	863a                	mv	a2,a4
    800073d0:	85be                	mv	a1,a5
    800073d2:	ffffb097          	auipc	ra,0xffffb
    800073d6:	006080e7          	jalr	6(ra) # 800023d8 <copyin>
    800073da:	87aa                	mv	a5,a0
    800073dc:	873e                	mv	a4,a5
    800073de:	57fd                	li	a5,-1
    800073e0:	04f70a63          	beq	a4,a5,80007434 <pipewrite+0x124>
        break;
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800073e4:	fc843783          	ld	a5,-56(s0)
    800073e8:	21c7a783          	lw	a5,540(a5)
    800073ec:	2781                	sext.w	a5,a5
    800073ee:	0017871b          	addiw	a4,a5,1
    800073f2:	0007069b          	sext.w	a3,a4
    800073f6:	fc843703          	ld	a4,-56(s0)
    800073fa:	20d72e23          	sw	a3,540(a4)
    800073fe:	1ff7f793          	andi	a5,a5,511
    80007402:	2781                	sext.w	a5,a5
    80007404:	fdf44703          	lbu	a4,-33(s0)
    80007408:	fc843683          	ld	a3,-56(s0)
    8000740c:	1782                	slli	a5,a5,0x20
    8000740e:	9381                	srli	a5,a5,0x20
    80007410:	97b6                	add	a5,a5,a3
    80007412:	00e78c23          	sb	a4,24(a5)
      i++;
    80007416:	fec42783          	lw	a5,-20(s0)
    8000741a:	2785                	addiw	a5,a5,1
    8000741c:	fef42623          	sw	a5,-20(s0)
  while(i < n){
    80007420:	fec42783          	lw	a5,-20(s0)
    80007424:	873e                	mv	a4,a5
    80007426:	fbc42783          	lw	a5,-68(s0)
    8000742a:	2701                	sext.w	a4,a4
    8000742c:	2781                	sext.w	a5,a5
    8000742e:	f0f74ce3          	blt	a4,a5,80007346 <pipewrite+0x36>
    80007432:	a011                	j	80007436 <pipewrite+0x126>
        break;
    80007434:	0001                	nop
    }
  }
  wakeup(&pi->nread);
    80007436:	fc843783          	ld	a5,-56(s0)
    8000743a:	21878793          	addi	a5,a5,536
    8000743e:	853e                	mv	a0,a5
    80007440:	ffffc097          	auipc	ra,0xffffc
    80007444:	03e080e7          	jalr	62(ra) # 8000347e <wakeup>
  release(&pi->lock);
    80007448:	fc843783          	ld	a5,-56(s0)
    8000744c:	853e                	mv	a0,a5
    8000744e:	ffffa097          	auipc	ra,0xffffa
    80007452:	e8e080e7          	jalr	-370(ra) # 800012dc <release>

  return i;
    80007456:	fec42783          	lw	a5,-20(s0)
}
    8000745a:	853e                	mv	a0,a5
    8000745c:	60a6                	ld	ra,72(sp)
    8000745e:	6406                	ld	s0,64(sp)
    80007460:	6161                	addi	sp,sp,80
    80007462:	8082                	ret

0000000080007464 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80007464:	715d                	addi	sp,sp,-80
    80007466:	e486                	sd	ra,72(sp)
    80007468:	e0a2                	sd	s0,64(sp)
    8000746a:	0880                	addi	s0,sp,80
    8000746c:	fca43423          	sd	a0,-56(s0)
    80007470:	fcb43023          	sd	a1,-64(s0)
    80007474:	87b2                	mv	a5,a2
    80007476:	faf42e23          	sw	a5,-68(s0)
  int i;
  struct proc *pr = myproc();
    8000747a:	ffffb097          	auipc	ra,0xffffb
    8000747e:	3c6080e7          	jalr	966(ra) # 80002840 <myproc>
    80007482:	fea43023          	sd	a0,-32(s0)
  char ch;

  acquire(&pi->lock);
    80007486:	fc843783          	ld	a5,-56(s0)
    8000748a:	853e                	mv	a0,a5
    8000748c:	ffffa097          	auipc	ra,0xffffa
    80007490:	dec080e7          	jalr	-532(ra) # 80001278 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80007494:	a835                	j	800074d0 <piperead+0x6c>
    if(killed(pr)){
    80007496:	fe043503          	ld	a0,-32(s0)
    8000749a:	ffffc097          	auipc	ra,0xffffc
    8000749e:	152080e7          	jalr	338(ra) # 800035ec <killed>
    800074a2:	87aa                	mv	a5,a0
    800074a4:	cb91                	beqz	a5,800074b8 <piperead+0x54>
      release(&pi->lock);
    800074a6:	fc843783          	ld	a5,-56(s0)
    800074aa:	853e                	mv	a0,a5
    800074ac:	ffffa097          	auipc	ra,0xffffa
    800074b0:	e30080e7          	jalr	-464(ra) # 800012dc <release>
      return -1;
    800074b4:	57fd                	li	a5,-1
    800074b6:	a8e5                	j	800075ae <piperead+0x14a>
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800074b8:	fc843783          	ld	a5,-56(s0)
    800074bc:	21878793          	addi	a5,a5,536
    800074c0:	fc843703          	ld	a4,-56(s0)
    800074c4:	85ba                	mv	a1,a4
    800074c6:	853e                	mv	a0,a5
    800074c8:	ffffc097          	auipc	ra,0xffffc
    800074cc:	f3a080e7          	jalr	-198(ra) # 80003402 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800074d0:	fc843783          	ld	a5,-56(s0)
    800074d4:	2187a703          	lw	a4,536(a5)
    800074d8:	fc843783          	ld	a5,-56(s0)
    800074dc:	21c7a783          	lw	a5,540(a5)
    800074e0:	00f71763          	bne	a4,a5,800074ee <piperead+0x8a>
    800074e4:	fc843783          	ld	a5,-56(s0)
    800074e8:	2247a783          	lw	a5,548(a5)
    800074ec:	f7cd                	bnez	a5,80007496 <piperead+0x32>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800074ee:	fe042623          	sw	zero,-20(s0)
    800074f2:	a8bd                	j	80007570 <piperead+0x10c>
    if(pi->nread == pi->nwrite)
    800074f4:	fc843783          	ld	a5,-56(s0)
    800074f8:	2187a703          	lw	a4,536(a5)
    800074fc:	fc843783          	ld	a5,-56(s0)
    80007500:	21c7a783          	lw	a5,540(a5)
    80007504:	08f70063          	beq	a4,a5,80007584 <piperead+0x120>
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    80007508:	fc843783          	ld	a5,-56(s0)
    8000750c:	2187a783          	lw	a5,536(a5)
    80007510:	2781                	sext.w	a5,a5
    80007512:	0017871b          	addiw	a4,a5,1
    80007516:	0007069b          	sext.w	a3,a4
    8000751a:	fc843703          	ld	a4,-56(s0)
    8000751e:	20d72c23          	sw	a3,536(a4)
    80007522:	1ff7f793          	andi	a5,a5,511
    80007526:	2781                	sext.w	a5,a5
    80007528:	fc843703          	ld	a4,-56(s0)
    8000752c:	1782                	slli	a5,a5,0x20
    8000752e:	9381                	srli	a5,a5,0x20
    80007530:	97ba                	add	a5,a5,a4
    80007532:	0187c783          	lbu	a5,24(a5)
    80007536:	fcf40fa3          	sb	a5,-33(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000753a:	fe043783          	ld	a5,-32(s0)
    8000753e:	6ba8                	ld	a0,80(a5)
    80007540:	fec42703          	lw	a4,-20(s0)
    80007544:	fc043783          	ld	a5,-64(s0)
    80007548:	97ba                	add	a5,a5,a4
    8000754a:	fdf40713          	addi	a4,s0,-33
    8000754e:	4685                	li	a3,1
    80007550:	863a                	mv	a2,a4
    80007552:	85be                	mv	a1,a5
    80007554:	ffffb097          	auipc	ra,0xffffb
    80007558:	db6080e7          	jalr	-586(ra) # 8000230a <copyout>
    8000755c:	87aa                	mv	a5,a0
    8000755e:	873e                	mv	a4,a5
    80007560:	57fd                	li	a5,-1
    80007562:	02f70363          	beq	a4,a5,80007588 <piperead+0x124>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80007566:	fec42783          	lw	a5,-20(s0)
    8000756a:	2785                	addiw	a5,a5,1
    8000756c:	fef42623          	sw	a5,-20(s0)
    80007570:	fec42783          	lw	a5,-20(s0)
    80007574:	873e                	mv	a4,a5
    80007576:	fbc42783          	lw	a5,-68(s0)
    8000757a:	2701                	sext.w	a4,a4
    8000757c:	2781                	sext.w	a5,a5
    8000757e:	f6f74be3          	blt	a4,a5,800074f4 <piperead+0x90>
    80007582:	a021                	j	8000758a <piperead+0x126>
      break;
    80007584:	0001                	nop
    80007586:	a011                	j	8000758a <piperead+0x126>
      break;
    80007588:	0001                	nop
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000758a:	fc843783          	ld	a5,-56(s0)
    8000758e:	21c78793          	addi	a5,a5,540
    80007592:	853e                	mv	a0,a5
    80007594:	ffffc097          	auipc	ra,0xffffc
    80007598:	eea080e7          	jalr	-278(ra) # 8000347e <wakeup>
  release(&pi->lock);
    8000759c:	fc843783          	ld	a5,-56(s0)
    800075a0:	853e                	mv	a0,a5
    800075a2:	ffffa097          	auipc	ra,0xffffa
    800075a6:	d3a080e7          	jalr	-710(ra) # 800012dc <release>
  return i;
    800075aa:	fec42783          	lw	a5,-20(s0)
}
    800075ae:	853e                	mv	a0,a5
    800075b0:	60a6                	ld	ra,72(sp)
    800075b2:	6406                	ld	s0,64(sp)
    800075b4:	6161                	addi	sp,sp,80
    800075b6:	8082                	ret

00000000800075b8 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    800075b8:	7179                	addi	sp,sp,-48
    800075ba:	f422                	sd	s0,40(sp)
    800075bc:	1800                	addi	s0,sp,48
    800075be:	87aa                	mv	a5,a0
    800075c0:	fcf42e23          	sw	a5,-36(s0)
    int perm = 0;
    800075c4:	fe042623          	sw	zero,-20(s0)
    if(flags & 0x1)
    800075c8:	fdc42783          	lw	a5,-36(s0)
    800075cc:	8b85                	andi	a5,a5,1
    800075ce:	2781                	sext.w	a5,a5
    800075d0:	c781                	beqz	a5,800075d8 <flags2perm+0x20>
      perm = PTE_X;
    800075d2:	47a1                	li	a5,8
    800075d4:	fef42623          	sw	a5,-20(s0)
    if(flags & 0x2)
    800075d8:	fdc42783          	lw	a5,-36(s0)
    800075dc:	8b89                	andi	a5,a5,2
    800075de:	2781                	sext.w	a5,a5
    800075e0:	c799                	beqz	a5,800075ee <flags2perm+0x36>
      perm |= PTE_W;
    800075e2:	fec42783          	lw	a5,-20(s0)
    800075e6:	0047e793          	ori	a5,a5,4
    800075ea:	fef42623          	sw	a5,-20(s0)
    return perm;
    800075ee:	fec42783          	lw	a5,-20(s0)
}
    800075f2:	853e                	mv	a0,a5
    800075f4:	7422                	ld	s0,40(sp)
    800075f6:	6145                	addi	sp,sp,48
    800075f8:	8082                	ret

00000000800075fa <exec>:

int
exec(char *path, char **argv)
{
    800075fa:	de010113          	addi	sp,sp,-544
    800075fe:	20113c23          	sd	ra,536(sp)
    80007602:	20813823          	sd	s0,528(sp)
    80007606:	20913423          	sd	s1,520(sp)
    8000760a:	1400                	addi	s0,sp,544
    8000760c:	dea43423          	sd	a0,-536(s0)
    80007610:	deb43023          	sd	a1,-544(s0)
  char *s, *last;
  int i, off;
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80007614:	fa043c23          	sd	zero,-72(s0)
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
    80007618:	fa043023          	sd	zero,-96(s0)
  struct proc *p = myproc();
    8000761c:	ffffb097          	auipc	ra,0xffffb
    80007620:	224080e7          	jalr	548(ra) # 80002840 <myproc>
    80007624:	f8a43c23          	sd	a0,-104(s0)

  begin_op();
    80007628:	fffff097          	auipc	ra,0xfffff
    8000762c:	f30080e7          	jalr	-208(ra) # 80006558 <begin_op>

  if((ip = namei(path)) == 0){
    80007630:	de843503          	ld	a0,-536(s0)
    80007634:	fffff097          	auipc	ra,0xfffff
    80007638:	bc0080e7          	jalr	-1088(ra) # 800061f4 <namei>
    8000763c:	faa43423          	sd	a0,-88(s0)
    80007640:	fa843783          	ld	a5,-88(s0)
    80007644:	e799                	bnez	a5,80007652 <exec+0x58>
    end_op();
    80007646:	fffff097          	auipc	ra,0xfffff
    8000764a:	fd4080e7          	jalr	-44(ra) # 8000661a <end_op>
    return -1;
    8000764e:	57fd                	li	a5,-1
    80007650:	a199                	j	80007a96 <exec+0x49c>
  }
  ilock(ip);
    80007652:	fa843503          	ld	a0,-88(s0)
    80007656:	ffffe097          	auipc	ra,0xffffe
    8000765a:	e6a080e7          	jalr	-406(ra) # 800054c0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000765e:	e3040793          	addi	a5,s0,-464
    80007662:	04000713          	li	a4,64
    80007666:	4681                	li	a3,0
    80007668:	863e                	mv	a2,a5
    8000766a:	4581                	li	a1,0
    8000766c:	fa843503          	ld	a0,-88(s0)
    80007670:	ffffe097          	auipc	ra,0xffffe
    80007674:	406080e7          	jalr	1030(ra) # 80005a76 <readi>
    80007678:	87aa                	mv	a5,a0
    8000767a:	873e                	mv	a4,a5
    8000767c:	04000793          	li	a5,64
    80007680:	3af71563          	bne	a4,a5,80007a2a <exec+0x430>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80007684:	e3042783          	lw	a5,-464(s0)
    80007688:	873e                	mv	a4,a5
    8000768a:	464c47b7          	lui	a5,0x464c4
    8000768e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80007692:	38f71e63          	bne	a4,a5,80007a2e <exec+0x434>
    goto bad;

  if((pagetable = proc_pagetable(p)) == 0)
    80007696:	f9843503          	ld	a0,-104(s0)
    8000769a:	ffffb097          	auipc	ra,0xffffb
    8000769e:	408080e7          	jalr	1032(ra) # 80002aa2 <proc_pagetable>
    800076a2:	faa43023          	sd	a0,-96(s0)
    800076a6:	fa043783          	ld	a5,-96(s0)
    800076aa:	38078463          	beqz	a5,80007a32 <exec+0x438>
    goto bad;

  // Load program into memory.
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800076ae:	fc042623          	sw	zero,-52(s0)
    800076b2:	e5043783          	ld	a5,-432(s0)
    800076b6:	fcf42423          	sw	a5,-56(s0)
    800076ba:	a0fd                	j	800077a8 <exec+0x1ae>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800076bc:	df840793          	addi	a5,s0,-520
    800076c0:	fc842683          	lw	a3,-56(s0)
    800076c4:	03800713          	li	a4,56
    800076c8:	863e                	mv	a2,a5
    800076ca:	4581                	li	a1,0
    800076cc:	fa843503          	ld	a0,-88(s0)
    800076d0:	ffffe097          	auipc	ra,0xffffe
    800076d4:	3a6080e7          	jalr	934(ra) # 80005a76 <readi>
    800076d8:	87aa                	mv	a5,a0
    800076da:	873e                	mv	a4,a5
    800076dc:	03800793          	li	a5,56
    800076e0:	34f71b63          	bne	a4,a5,80007a36 <exec+0x43c>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
    800076e4:	df842783          	lw	a5,-520(s0)
    800076e8:	873e                	mv	a4,a5
    800076ea:	4785                	li	a5,1
    800076ec:	0af71163          	bne	a4,a5,8000778e <exec+0x194>
      continue;
    if(ph.memsz < ph.filesz)
    800076f0:	e2043703          	ld	a4,-480(s0)
    800076f4:	e1843783          	ld	a5,-488(s0)
    800076f8:	34f76163          	bltu	a4,a5,80007a3a <exec+0x440>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800076fc:	e0843703          	ld	a4,-504(s0)
    80007700:	e2043783          	ld	a5,-480(s0)
    80007704:	973e                	add	a4,a4,a5
    80007706:	e0843783          	ld	a5,-504(s0)
    8000770a:	32f76a63          	bltu	a4,a5,80007a3e <exec+0x444>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
    8000770e:	e0843703          	ld	a4,-504(s0)
    80007712:	6785                	lui	a5,0x1
    80007714:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80007716:	8ff9                	and	a5,a5,a4
    80007718:	32079563          	bnez	a5,80007a42 <exec+0x448>
      goto bad;
    uint64 sz1;
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000771c:	e0843703          	ld	a4,-504(s0)
    80007720:	e2043783          	ld	a5,-480(s0)
    80007724:	00f704b3          	add	s1,a4,a5
    80007728:	dfc42783          	lw	a5,-516(s0)
    8000772c:	2781                	sext.w	a5,a5
    8000772e:	853e                	mv	a0,a5
    80007730:	00000097          	auipc	ra,0x0
    80007734:	e88080e7          	jalr	-376(ra) # 800075b8 <flags2perm>
    80007738:	87aa                	mv	a5,a0
    8000773a:	86be                	mv	a3,a5
    8000773c:	8626                	mv	a2,s1
    8000773e:	fb843583          	ld	a1,-72(s0)
    80007742:	fa043503          	ld	a0,-96(s0)
    80007746:	ffffa097          	auipc	ra,0xffffa
    8000774a:	7d8080e7          	jalr	2008(ra) # 80001f1e <uvmalloc>
    8000774e:	f6a43823          	sd	a0,-144(s0)
    80007752:	f7043783          	ld	a5,-144(s0)
    80007756:	2e078863          	beqz	a5,80007a46 <exec+0x44c>
      goto bad;
    sz = sz1;
    8000775a:	f7043783          	ld	a5,-144(s0)
    8000775e:	faf43c23          	sd	a5,-72(s0)
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80007762:	e0843783          	ld	a5,-504(s0)
    80007766:	e0043703          	ld	a4,-512(s0)
    8000776a:	0007069b          	sext.w	a3,a4
    8000776e:	e1843703          	ld	a4,-488(s0)
    80007772:	2701                	sext.w	a4,a4
    80007774:	fa843603          	ld	a2,-88(s0)
    80007778:	85be                	mv	a1,a5
    8000777a:	fa043503          	ld	a0,-96(s0)
    8000777e:	00000097          	auipc	ra,0x0
    80007782:	32c080e7          	jalr	812(ra) # 80007aaa <loadseg>
    80007786:	87aa                	mv	a5,a0
    80007788:	2c07c163          	bltz	a5,80007a4a <exec+0x450>
    8000778c:	a011                	j	80007790 <exec+0x196>
      continue;
    8000778e:	0001                	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80007790:	fcc42783          	lw	a5,-52(s0)
    80007794:	2785                	addiw	a5,a5,1
    80007796:	fcf42623          	sw	a5,-52(s0)
    8000779a:	fc842783          	lw	a5,-56(s0)
    8000779e:	0387879b          	addiw	a5,a5,56
    800077a2:	2781                	sext.w	a5,a5
    800077a4:	fcf42423          	sw	a5,-56(s0)
    800077a8:	e6845783          	lhu	a5,-408(s0)
    800077ac:	0007871b          	sext.w	a4,a5
    800077b0:	fcc42783          	lw	a5,-52(s0)
    800077b4:	2781                	sext.w	a5,a5
    800077b6:	f0e7c3e3          	blt	a5,a4,800076bc <exec+0xc2>
      goto bad;
  }
  iunlockput(ip);
    800077ba:	fa843503          	ld	a0,-88(s0)
    800077be:	ffffe097          	auipc	ra,0xffffe
    800077c2:	f60080e7          	jalr	-160(ra) # 8000571e <iunlockput>
  end_op();
    800077c6:	fffff097          	auipc	ra,0xfffff
    800077ca:	e54080e7          	jalr	-428(ra) # 8000661a <end_op>
  ip = 0;
    800077ce:	fa043423          	sd	zero,-88(s0)

  p = myproc();
    800077d2:	ffffb097          	auipc	ra,0xffffb
    800077d6:	06e080e7          	jalr	110(ra) # 80002840 <myproc>
    800077da:	f8a43c23          	sd	a0,-104(s0)
  uint64 oldsz = p->sz;
    800077de:	f9843783          	ld	a5,-104(s0)
    800077e2:	67bc                	ld	a5,72(a5)
    800077e4:	f8f43823          	sd	a5,-112(s0)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible as a stack guard.
  // Use the second as the user stack.
  sz = PGROUNDUP(sz);
    800077e8:	fb843703          	ld	a4,-72(s0)
    800077ec:	6785                	lui	a5,0x1
    800077ee:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800077f0:	973e                	add	a4,a4,a5
    800077f2:	77fd                	lui	a5,0xfffff
    800077f4:	8ff9                	and	a5,a5,a4
    800077f6:	faf43c23          	sd	a5,-72(s0)
  uint64 sz1;
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800077fa:	fb843703          	ld	a4,-72(s0)
    800077fe:	6789                	lui	a5,0x2
    80007800:	97ba                	add	a5,a5,a4
    80007802:	4691                	li	a3,4
    80007804:	863e                	mv	a2,a5
    80007806:	fb843583          	ld	a1,-72(s0)
    8000780a:	fa043503          	ld	a0,-96(s0)
    8000780e:	ffffa097          	auipc	ra,0xffffa
    80007812:	710080e7          	jalr	1808(ra) # 80001f1e <uvmalloc>
    80007816:	f8a43423          	sd	a0,-120(s0)
    8000781a:	f8843783          	ld	a5,-120(s0)
    8000781e:	22078863          	beqz	a5,80007a4e <exec+0x454>
    goto bad;
  sz = sz1;
    80007822:	f8843783          	ld	a5,-120(s0)
    80007826:	faf43c23          	sd	a5,-72(s0)
  uvmclear(pagetable, sz-2*PGSIZE);
    8000782a:	fb843703          	ld	a4,-72(s0)
    8000782e:	77f9                	lui	a5,0xffffe
    80007830:	97ba                	add	a5,a5,a4
    80007832:	85be                	mv	a1,a5
    80007834:	fa043503          	ld	a0,-96(s0)
    80007838:	ffffb097          	auipc	ra,0xffffb
    8000783c:	a7c080e7          	jalr	-1412(ra) # 800022b4 <uvmclear>
  sp = sz;
    80007840:	fb843783          	ld	a5,-72(s0)
    80007844:	faf43823          	sd	a5,-80(s0)
  stackbase = sp - PGSIZE;
    80007848:	fb043703          	ld	a4,-80(s0)
    8000784c:	77fd                	lui	a5,0xfffff
    8000784e:	97ba                	add	a5,a5,a4
    80007850:	f8f43023          	sd	a5,-128(s0)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    80007854:	fc043023          	sd	zero,-64(s0)
    80007858:	a07d                	j	80007906 <exec+0x30c>
    if(argc >= MAXARG)
    8000785a:	fc043703          	ld	a4,-64(s0)
    8000785e:	47fd                	li	a5,31
    80007860:	1ee7e963          	bltu	a5,a4,80007a52 <exec+0x458>
      goto bad;
    sp -= strlen(argv[argc]) + 1;
    80007864:	fc043783          	ld	a5,-64(s0)
    80007868:	078e                	slli	a5,a5,0x3
    8000786a:	de043703          	ld	a4,-544(s0)
    8000786e:	97ba                	add	a5,a5,a4
    80007870:	639c                	ld	a5,0(a5)
    80007872:	853e                	mv	a0,a5
    80007874:	ffffa097          	auipc	ra,0xffffa
    80007878:	f58080e7          	jalr	-168(ra) # 800017cc <strlen>
    8000787c:	87aa                	mv	a5,a0
    8000787e:	2785                	addiw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7ffda249>
    80007880:	2781                	sext.w	a5,a5
    80007882:	873e                	mv	a4,a5
    80007884:	fb043783          	ld	a5,-80(s0)
    80007888:	8f99                	sub	a5,a5,a4
    8000788a:	faf43823          	sd	a5,-80(s0)
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000788e:	fb043783          	ld	a5,-80(s0)
    80007892:	9bc1                	andi	a5,a5,-16
    80007894:	faf43823          	sd	a5,-80(s0)
    if(sp < stackbase)
    80007898:	fb043703          	ld	a4,-80(s0)
    8000789c:	f8043783          	ld	a5,-128(s0)
    800078a0:	1af76b63          	bltu	a4,a5,80007a56 <exec+0x45c>
      goto bad;
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800078a4:	fc043783          	ld	a5,-64(s0)
    800078a8:	078e                	slli	a5,a5,0x3
    800078aa:	de043703          	ld	a4,-544(s0)
    800078ae:	97ba                	add	a5,a5,a4
    800078b0:	6384                	ld	s1,0(a5)
    800078b2:	fc043783          	ld	a5,-64(s0)
    800078b6:	078e                	slli	a5,a5,0x3
    800078b8:	de043703          	ld	a4,-544(s0)
    800078bc:	97ba                	add	a5,a5,a4
    800078be:	639c                	ld	a5,0(a5)
    800078c0:	853e                	mv	a0,a5
    800078c2:	ffffa097          	auipc	ra,0xffffa
    800078c6:	f0a080e7          	jalr	-246(ra) # 800017cc <strlen>
    800078ca:	87aa                	mv	a5,a0
    800078cc:	2785                	addiw	a5,a5,1
    800078ce:	2781                	sext.w	a5,a5
    800078d0:	86be                	mv	a3,a5
    800078d2:	8626                	mv	a2,s1
    800078d4:	fb043583          	ld	a1,-80(s0)
    800078d8:	fa043503          	ld	a0,-96(s0)
    800078dc:	ffffb097          	auipc	ra,0xffffb
    800078e0:	a2e080e7          	jalr	-1490(ra) # 8000230a <copyout>
    800078e4:	87aa                	mv	a5,a0
    800078e6:	1607ca63          	bltz	a5,80007a5a <exec+0x460>
      goto bad;
    ustack[argc] = sp;
    800078ea:	fc043783          	ld	a5,-64(s0)
    800078ee:	078e                	slli	a5,a5,0x3
    800078f0:	1781                	addi	a5,a5,-32
    800078f2:	97a2                	add	a5,a5,s0
    800078f4:	fb043703          	ld	a4,-80(s0)
    800078f8:	e8e7b823          	sd	a4,-368(a5)
  for(argc = 0; argv[argc]; argc++) {
    800078fc:	fc043783          	ld	a5,-64(s0)
    80007900:	0785                	addi	a5,a5,1
    80007902:	fcf43023          	sd	a5,-64(s0)
    80007906:	fc043783          	ld	a5,-64(s0)
    8000790a:	078e                	slli	a5,a5,0x3
    8000790c:	de043703          	ld	a4,-544(s0)
    80007910:	97ba                	add	a5,a5,a4
    80007912:	639c                	ld	a5,0(a5)
    80007914:	f3b9                	bnez	a5,8000785a <exec+0x260>
  }
  ustack[argc] = 0;
    80007916:	fc043783          	ld	a5,-64(s0)
    8000791a:	078e                	slli	a5,a5,0x3
    8000791c:	1781                	addi	a5,a5,-32
    8000791e:	97a2                	add	a5,a5,s0
    80007920:	e807b823          	sd	zero,-368(a5)

  // push the array of argv[] pointers.
  sp -= (argc+1) * sizeof(uint64);
    80007924:	fc043783          	ld	a5,-64(s0)
    80007928:	0785                	addi	a5,a5,1
    8000792a:	078e                	slli	a5,a5,0x3
    8000792c:	fb043703          	ld	a4,-80(s0)
    80007930:	40f707b3          	sub	a5,a4,a5
    80007934:	faf43823          	sd	a5,-80(s0)
  sp -= sp % 16;
    80007938:	fb043783          	ld	a5,-80(s0)
    8000793c:	9bc1                	andi	a5,a5,-16
    8000793e:	faf43823          	sd	a5,-80(s0)
  if(sp < stackbase)
    80007942:	fb043703          	ld	a4,-80(s0)
    80007946:	f8043783          	ld	a5,-128(s0)
    8000794a:	10f76a63          	bltu	a4,a5,80007a5e <exec+0x464>
    goto bad;
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000794e:	fc043783          	ld	a5,-64(s0)
    80007952:	0785                	addi	a5,a5,1
    80007954:	00379713          	slli	a4,a5,0x3
    80007958:	e7040793          	addi	a5,s0,-400
    8000795c:	86ba                	mv	a3,a4
    8000795e:	863e                	mv	a2,a5
    80007960:	fb043583          	ld	a1,-80(s0)
    80007964:	fa043503          	ld	a0,-96(s0)
    80007968:	ffffb097          	auipc	ra,0xffffb
    8000796c:	9a2080e7          	jalr	-1630(ra) # 8000230a <copyout>
    80007970:	87aa                	mv	a5,a0
    80007972:	0e07c863          	bltz	a5,80007a62 <exec+0x468>
    goto bad;

  // arguments to user main(argc, argv)
  // argc is returned via the system call return
  // value, which goes in a0.
  p->trapframe->a1 = sp;
    80007976:	f9843783          	ld	a5,-104(s0)
    8000797a:	6fbc                	ld	a5,88(a5)
    8000797c:	fb043703          	ld	a4,-80(s0)
    80007980:	ffb8                	sd	a4,120(a5)

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    80007982:	de843783          	ld	a5,-536(s0)
    80007986:	fcf43c23          	sd	a5,-40(s0)
    8000798a:	fd843783          	ld	a5,-40(s0)
    8000798e:	fcf43823          	sd	a5,-48(s0)
    80007992:	a025                	j	800079ba <exec+0x3c0>
    if(*s == '/')
    80007994:	fd843783          	ld	a5,-40(s0)
    80007998:	0007c783          	lbu	a5,0(a5)
    8000799c:	873e                	mv	a4,a5
    8000799e:	02f00793          	li	a5,47
    800079a2:	00f71763          	bne	a4,a5,800079b0 <exec+0x3b6>
      last = s+1;
    800079a6:	fd843783          	ld	a5,-40(s0)
    800079aa:	0785                	addi	a5,a5,1
    800079ac:	fcf43823          	sd	a5,-48(s0)
  for(last=s=path; *s; s++)
    800079b0:	fd843783          	ld	a5,-40(s0)
    800079b4:	0785                	addi	a5,a5,1
    800079b6:	fcf43c23          	sd	a5,-40(s0)
    800079ba:	fd843783          	ld	a5,-40(s0)
    800079be:	0007c783          	lbu	a5,0(a5)
    800079c2:	fbe9                	bnez	a5,80007994 <exec+0x39a>
  safestrcpy(p->name, last, sizeof(p->name));
    800079c4:	f9843783          	ld	a5,-104(s0)
    800079c8:	15878793          	addi	a5,a5,344
    800079cc:	4641                	li	a2,16
    800079ce:	fd043583          	ld	a1,-48(s0)
    800079d2:	853e                	mv	a0,a5
    800079d4:	ffffa097          	auipc	ra,0xffffa
    800079d8:	d7c080e7          	jalr	-644(ra) # 80001750 <safestrcpy>
    
  // Commit to the user image.
  oldpagetable = p->pagetable;
    800079dc:	f9843783          	ld	a5,-104(s0)
    800079e0:	6bbc                	ld	a5,80(a5)
    800079e2:	f6f43c23          	sd	a5,-136(s0)
  p->pagetable = pagetable;
    800079e6:	f9843783          	ld	a5,-104(s0)
    800079ea:	fa043703          	ld	a4,-96(s0)
    800079ee:	ebb8                	sd	a4,80(a5)
  p->sz = sz;
    800079f0:	f9843783          	ld	a5,-104(s0)
    800079f4:	fb843703          	ld	a4,-72(s0)
    800079f8:	e7b8                	sd	a4,72(a5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800079fa:	f9843783          	ld	a5,-104(s0)
    800079fe:	6fbc                	ld	a5,88(a5)
    80007a00:	e4843703          	ld	a4,-440(s0)
    80007a04:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80007a06:	f9843783          	ld	a5,-104(s0)
    80007a0a:	6fbc                	ld	a5,88(a5)
    80007a0c:	fb043703          	ld	a4,-80(s0)
    80007a10:	fb98                	sd	a4,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80007a12:	f9043583          	ld	a1,-112(s0)
    80007a16:	f7843503          	ld	a0,-136(s0)
    80007a1a:	ffffb097          	auipc	ra,0xffffb
    80007a1e:	148080e7          	jalr	328(ra) # 80002b62 <proc_freepagetable>

  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80007a22:	fc043783          	ld	a5,-64(s0)
    80007a26:	2781                	sext.w	a5,a5
    80007a28:	a0bd                	j	80007a96 <exec+0x49c>
    goto bad;
    80007a2a:	0001                	nop
    80007a2c:	a825                	j	80007a64 <exec+0x46a>
    goto bad;
    80007a2e:	0001                	nop
    80007a30:	a815                	j	80007a64 <exec+0x46a>
    goto bad;
    80007a32:	0001                	nop
    80007a34:	a805                	j	80007a64 <exec+0x46a>
      goto bad;
    80007a36:	0001                	nop
    80007a38:	a035                	j	80007a64 <exec+0x46a>
      goto bad;
    80007a3a:	0001                	nop
    80007a3c:	a025                	j	80007a64 <exec+0x46a>
      goto bad;
    80007a3e:	0001                	nop
    80007a40:	a015                	j	80007a64 <exec+0x46a>
      goto bad;
    80007a42:	0001                	nop
    80007a44:	a005                	j	80007a64 <exec+0x46a>
      goto bad;
    80007a46:	0001                	nop
    80007a48:	a831                	j	80007a64 <exec+0x46a>
      goto bad;
    80007a4a:	0001                	nop
    80007a4c:	a821                	j	80007a64 <exec+0x46a>
    goto bad;
    80007a4e:	0001                	nop
    80007a50:	a811                	j	80007a64 <exec+0x46a>
      goto bad;
    80007a52:	0001                	nop
    80007a54:	a801                	j	80007a64 <exec+0x46a>
      goto bad;
    80007a56:	0001                	nop
    80007a58:	a031                	j	80007a64 <exec+0x46a>
      goto bad;
    80007a5a:	0001                	nop
    80007a5c:	a021                	j	80007a64 <exec+0x46a>
    goto bad;
    80007a5e:	0001                	nop
    80007a60:	a011                	j	80007a64 <exec+0x46a>
    goto bad;
    80007a62:	0001                	nop

 bad:
  if(pagetable)
    80007a64:	fa043783          	ld	a5,-96(s0)
    80007a68:	cb89                	beqz	a5,80007a7a <exec+0x480>
    proc_freepagetable(pagetable, sz);
    80007a6a:	fb843583          	ld	a1,-72(s0)
    80007a6e:	fa043503          	ld	a0,-96(s0)
    80007a72:	ffffb097          	auipc	ra,0xffffb
    80007a76:	0f0080e7          	jalr	240(ra) # 80002b62 <proc_freepagetable>
  if(ip){
    80007a7a:	fa843783          	ld	a5,-88(s0)
    80007a7e:	cb99                	beqz	a5,80007a94 <exec+0x49a>
    iunlockput(ip);
    80007a80:	fa843503          	ld	a0,-88(s0)
    80007a84:	ffffe097          	auipc	ra,0xffffe
    80007a88:	c9a080e7          	jalr	-870(ra) # 8000571e <iunlockput>
    end_op();
    80007a8c:	fffff097          	auipc	ra,0xfffff
    80007a90:	b8e080e7          	jalr	-1138(ra) # 8000661a <end_op>
  }
  return -1;
    80007a94:	57fd                	li	a5,-1
}
    80007a96:	853e                	mv	a0,a5
    80007a98:	21813083          	ld	ra,536(sp)
    80007a9c:	21013403          	ld	s0,528(sp)
    80007aa0:	20813483          	ld	s1,520(sp)
    80007aa4:	22010113          	addi	sp,sp,544
    80007aa8:	8082                	ret

0000000080007aaa <loadseg>:
// va must be page-aligned
// and the pages from va to va+sz must already be mapped.
// Returns 0 on success, -1 on failure.
static int
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
    80007aaa:	7139                	addi	sp,sp,-64
    80007aac:	fc06                	sd	ra,56(sp)
    80007aae:	f822                	sd	s0,48(sp)
    80007ab0:	0080                	addi	s0,sp,64
    80007ab2:	fca43c23          	sd	a0,-40(s0)
    80007ab6:	fcb43823          	sd	a1,-48(s0)
    80007aba:	fcc43423          	sd	a2,-56(s0)
    80007abe:	87b6                	mv	a5,a3
    80007ac0:	fcf42223          	sw	a5,-60(s0)
    80007ac4:	87ba                	mv	a5,a4
    80007ac6:	fcf42023          	sw	a5,-64(s0)
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80007aca:	fe042623          	sw	zero,-20(s0)
    80007ace:	a07d                	j	80007b7c <loadseg+0xd2>
    pa = walkaddr(pagetable, va + i);
    80007ad0:	fec46703          	lwu	a4,-20(s0)
    80007ad4:	fd043783          	ld	a5,-48(s0)
    80007ad8:	97ba                	add	a5,a5,a4
    80007ada:	85be                	mv	a1,a5
    80007adc:	fd843503          	ld	a0,-40(s0)
    80007ae0:	ffffa097          	auipc	ra,0xffffa
    80007ae4:	0ca080e7          	jalr	202(ra) # 80001baa <walkaddr>
    80007ae8:	fea43023          	sd	a0,-32(s0)
    if(pa == 0)
    80007aec:	fe043783          	ld	a5,-32(s0)
    80007af0:	eb89                	bnez	a5,80007b02 <loadseg+0x58>
      panic("loadseg: address should exist");
    80007af2:	00004517          	auipc	a0,0x4
    80007af6:	b1650513          	addi	a0,a0,-1258 # 8000b608 <etext+0x608>
    80007afa:	ffff9097          	auipc	ra,0xffff9
    80007afe:	190080e7          	jalr	400(ra) # 80000c8a <panic>
    if(sz - i < PGSIZE)
    80007b02:	fc042783          	lw	a5,-64(s0)
    80007b06:	873e                	mv	a4,a5
    80007b08:	fec42783          	lw	a5,-20(s0)
    80007b0c:	40f707bb          	subw	a5,a4,a5
    80007b10:	2781                	sext.w	a5,a5
    80007b12:	873e                	mv	a4,a5
    80007b14:	6785                	lui	a5,0x1
    80007b16:	00f77c63          	bgeu	a4,a5,80007b2e <loadseg+0x84>
      n = sz - i;
    80007b1a:	fc042783          	lw	a5,-64(s0)
    80007b1e:	873e                	mv	a4,a5
    80007b20:	fec42783          	lw	a5,-20(s0)
    80007b24:	40f707bb          	subw	a5,a4,a5
    80007b28:	fef42423          	sw	a5,-24(s0)
    80007b2c:	a021                	j	80007b34 <loadseg+0x8a>
    else
      n = PGSIZE;
    80007b2e:	6785                	lui	a5,0x1
    80007b30:	fef42423          	sw	a5,-24(s0)
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80007b34:	fc442783          	lw	a5,-60(s0)
    80007b38:	873e                	mv	a4,a5
    80007b3a:	fec42783          	lw	a5,-20(s0)
    80007b3e:	9fb9                	addw	a5,a5,a4
    80007b40:	2781                	sext.w	a5,a5
    80007b42:	fe842703          	lw	a4,-24(s0)
    80007b46:	86be                	mv	a3,a5
    80007b48:	fe043603          	ld	a2,-32(s0)
    80007b4c:	4581                	li	a1,0
    80007b4e:	fc843503          	ld	a0,-56(s0)
    80007b52:	ffffe097          	auipc	ra,0xffffe
    80007b56:	f24080e7          	jalr	-220(ra) # 80005a76 <readi>
    80007b5a:	87aa                	mv	a5,a0
    80007b5c:	0007871b          	sext.w	a4,a5
    80007b60:	fe842783          	lw	a5,-24(s0)
    80007b64:	2781                	sext.w	a5,a5
    80007b66:	00e78463          	beq	a5,a4,80007b6e <loadseg+0xc4>
      return -1;
    80007b6a:	57fd                	li	a5,-1
    80007b6c:	a015                	j	80007b90 <loadseg+0xe6>
  for(i = 0; i < sz; i += PGSIZE){
    80007b6e:	fec42783          	lw	a5,-20(s0)
    80007b72:	873e                	mv	a4,a5
    80007b74:	6785                	lui	a5,0x1
    80007b76:	9fb9                	addw	a5,a5,a4
    80007b78:	fef42623          	sw	a5,-20(s0)
    80007b7c:	fec42783          	lw	a5,-20(s0)
    80007b80:	873e                	mv	a4,a5
    80007b82:	fc042783          	lw	a5,-64(s0)
    80007b86:	2701                	sext.w	a4,a4
    80007b88:	2781                	sext.w	a5,a5
    80007b8a:	f4f763e3          	bltu	a4,a5,80007ad0 <loadseg+0x26>
  }
  
  return 0;
    80007b8e:	4781                	li	a5,0
}
    80007b90:	853e                	mv	a0,a5
    80007b92:	70e2                	ld	ra,56(sp)
    80007b94:	7442                	ld	s0,48(sp)
    80007b96:	6121                	addi	sp,sp,64
    80007b98:	8082                	ret

0000000080007b9a <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80007b9a:	7139                	addi	sp,sp,-64
    80007b9c:	fc06                	sd	ra,56(sp)
    80007b9e:	f822                	sd	s0,48(sp)
    80007ba0:	0080                	addi	s0,sp,64
    80007ba2:	87aa                	mv	a5,a0
    80007ba4:	fcb43823          	sd	a1,-48(s0)
    80007ba8:	fcc43423          	sd	a2,-56(s0)
    80007bac:	fcf42e23          	sw	a5,-36(s0)
  int fd;
  struct file *f;

  argint(n, &fd);
    80007bb0:	fe440713          	addi	a4,s0,-28
    80007bb4:	fdc42783          	lw	a5,-36(s0)
    80007bb8:	85ba                	mv	a1,a4
    80007bba:	853e                	mv	a0,a5
    80007bbc:	ffffd097          	auipc	ra,0xffffd
    80007bc0:	8c8080e7          	jalr	-1848(ra) # 80004484 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80007bc4:	fe442783          	lw	a5,-28(s0)
    80007bc8:	0207c863          	bltz	a5,80007bf8 <argfd+0x5e>
    80007bcc:	fe442783          	lw	a5,-28(s0)
    80007bd0:	873e                	mv	a4,a5
    80007bd2:	47bd                	li	a5,15
    80007bd4:	02e7c263          	blt	a5,a4,80007bf8 <argfd+0x5e>
    80007bd8:	ffffb097          	auipc	ra,0xffffb
    80007bdc:	c68080e7          	jalr	-920(ra) # 80002840 <myproc>
    80007be0:	872a                	mv	a4,a0
    80007be2:	fe442783          	lw	a5,-28(s0)
    80007be6:	07e9                	addi	a5,a5,26 # 101a <_entry-0x7fffefe6>
    80007be8:	078e                	slli	a5,a5,0x3
    80007bea:	97ba                	add	a5,a5,a4
    80007bec:	639c                	ld	a5,0(a5)
    80007bee:	fef43423          	sd	a5,-24(s0)
    80007bf2:	fe843783          	ld	a5,-24(s0)
    80007bf6:	e399                	bnez	a5,80007bfc <argfd+0x62>
    return -1;
    80007bf8:	57fd                	li	a5,-1
    80007bfa:	a015                	j	80007c1e <argfd+0x84>
  if(pfd)
    80007bfc:	fd043783          	ld	a5,-48(s0)
    80007c00:	c791                	beqz	a5,80007c0c <argfd+0x72>
    *pfd = fd;
    80007c02:	fe442703          	lw	a4,-28(s0)
    80007c06:	fd043783          	ld	a5,-48(s0)
    80007c0a:	c398                	sw	a4,0(a5)
  if(pf)
    80007c0c:	fc843783          	ld	a5,-56(s0)
    80007c10:	c791                	beqz	a5,80007c1c <argfd+0x82>
    *pf = f;
    80007c12:	fc843783          	ld	a5,-56(s0)
    80007c16:	fe843703          	ld	a4,-24(s0)
    80007c1a:	e398                	sd	a4,0(a5)
  return 0;
    80007c1c:	4781                	li	a5,0
}
    80007c1e:	853e                	mv	a0,a5
    80007c20:	70e2                	ld	ra,56(sp)
    80007c22:	7442                	ld	s0,48(sp)
    80007c24:	6121                	addi	sp,sp,64
    80007c26:	8082                	ret

0000000080007c28 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80007c28:	7179                	addi	sp,sp,-48
    80007c2a:	f406                	sd	ra,40(sp)
    80007c2c:	f022                	sd	s0,32(sp)
    80007c2e:	1800                	addi	s0,sp,48
    80007c30:	fca43c23          	sd	a0,-40(s0)
  int fd;
  struct proc *p = myproc();
    80007c34:	ffffb097          	auipc	ra,0xffffb
    80007c38:	c0c080e7          	jalr	-1012(ra) # 80002840 <myproc>
    80007c3c:	fea43023          	sd	a0,-32(s0)

  for(fd = 0; fd < NOFILE; fd++){
    80007c40:	fe042623          	sw	zero,-20(s0)
    80007c44:	a825                	j	80007c7c <fdalloc+0x54>
    if(p->ofile[fd] == 0){
    80007c46:	fe043703          	ld	a4,-32(s0)
    80007c4a:	fec42783          	lw	a5,-20(s0)
    80007c4e:	07e9                	addi	a5,a5,26
    80007c50:	078e                	slli	a5,a5,0x3
    80007c52:	97ba                	add	a5,a5,a4
    80007c54:	639c                	ld	a5,0(a5)
    80007c56:	ef91                	bnez	a5,80007c72 <fdalloc+0x4a>
      p->ofile[fd] = f;
    80007c58:	fe043703          	ld	a4,-32(s0)
    80007c5c:	fec42783          	lw	a5,-20(s0)
    80007c60:	07e9                	addi	a5,a5,26
    80007c62:	078e                	slli	a5,a5,0x3
    80007c64:	97ba                	add	a5,a5,a4
    80007c66:	fd843703          	ld	a4,-40(s0)
    80007c6a:	e398                	sd	a4,0(a5)
      return fd;
    80007c6c:	fec42783          	lw	a5,-20(s0)
    80007c70:	a831                	j	80007c8c <fdalloc+0x64>
  for(fd = 0; fd < NOFILE; fd++){
    80007c72:	fec42783          	lw	a5,-20(s0)
    80007c76:	2785                	addiw	a5,a5,1
    80007c78:	fef42623          	sw	a5,-20(s0)
    80007c7c:	fec42783          	lw	a5,-20(s0)
    80007c80:	0007871b          	sext.w	a4,a5
    80007c84:	47bd                	li	a5,15
    80007c86:	fce7d0e3          	bge	a5,a4,80007c46 <fdalloc+0x1e>
    }
  }
  return -1;
    80007c8a:	57fd                	li	a5,-1
}
    80007c8c:	853e                	mv	a0,a5
    80007c8e:	70a2                	ld	ra,40(sp)
    80007c90:	7402                	ld	s0,32(sp)
    80007c92:	6145                	addi	sp,sp,48
    80007c94:	8082                	ret

0000000080007c96 <sys_hello>:

uint64
sys_hello(void)
{
    80007c96:	1141                	addi	sp,sp,-16
    80007c98:	e406                	sd	ra,8(sp)
    80007c9a:	e022                	sd	s0,0(sp)
    80007c9c:	0800                	addi	s0,sp,16
	printf("Hello world\n");
    80007c9e:	00004517          	auipc	a0,0x4
    80007ca2:	98a50513          	addi	a0,a0,-1654 # 8000b628 <etext+0x628>
    80007ca6:	ffff9097          	auipc	ra,0xffff9
    80007caa:	d8e080e7          	jalr	-626(ra) # 80000a34 <printf>
	return 0;
    80007cae:	4781                	li	a5,0
}
    80007cb0:	853e                	mv	a0,a5
    80007cb2:	60a2                	ld	ra,8(sp)
    80007cb4:	6402                	ld	s0,0(sp)
    80007cb6:	0141                	addi	sp,sp,16
    80007cb8:	8082                	ret

0000000080007cba <sys_dup>:

uint64
sys_dup(void)
{
    80007cba:	1101                	addi	sp,sp,-32
    80007cbc:	ec06                	sd	ra,24(sp)
    80007cbe:	e822                	sd	s0,16(sp)
    80007cc0:	1000                	addi	s0,sp,32
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
    80007cc2:	fe040793          	addi	a5,s0,-32
    80007cc6:	863e                	mv	a2,a5
    80007cc8:	4581                	li	a1,0
    80007cca:	4501                	li	a0,0
    80007ccc:	00000097          	auipc	ra,0x0
    80007cd0:	ece080e7          	jalr	-306(ra) # 80007b9a <argfd>
    80007cd4:	87aa                	mv	a5,a0
    80007cd6:	0007d463          	bgez	a5,80007cde <sys_dup+0x24>
    return -1;
    80007cda:	57fd                	li	a5,-1
    80007cdc:	a81d                	j	80007d12 <sys_dup+0x58>
  if((fd=fdalloc(f)) < 0)
    80007cde:	fe043783          	ld	a5,-32(s0)
    80007ce2:	853e                	mv	a0,a5
    80007ce4:	00000097          	auipc	ra,0x0
    80007ce8:	f44080e7          	jalr	-188(ra) # 80007c28 <fdalloc>
    80007cec:	87aa                	mv	a5,a0
    80007cee:	fef42623          	sw	a5,-20(s0)
    80007cf2:	fec42783          	lw	a5,-20(s0)
    80007cf6:	2781                	sext.w	a5,a5
    80007cf8:	0007d463          	bgez	a5,80007d00 <sys_dup+0x46>
    return -1;
    80007cfc:	57fd                	li	a5,-1
    80007cfe:	a811                	j	80007d12 <sys_dup+0x58>
  filedup(f);
    80007d00:	fe043783          	ld	a5,-32(s0)
    80007d04:	853e                	mv	a0,a5
    80007d06:	fffff097          	auipc	ra,0xfffff
    80007d0a:	e86080e7          	jalr	-378(ra) # 80006b8c <filedup>
  return fd;
    80007d0e:	fec42783          	lw	a5,-20(s0)
}
    80007d12:	853e                	mv	a0,a5
    80007d14:	60e2                	ld	ra,24(sp)
    80007d16:	6442                	ld	s0,16(sp)
    80007d18:	6105                	addi	sp,sp,32
    80007d1a:	8082                	ret

0000000080007d1c <sys_read>:

uint64
sys_read(void)
{
    80007d1c:	7179                	addi	sp,sp,-48
    80007d1e:	f406                	sd	ra,40(sp)
    80007d20:	f022                	sd	s0,32(sp)
    80007d22:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;

  argaddr(1, &p);
    80007d24:	fd840793          	addi	a5,s0,-40
    80007d28:	85be                	mv	a1,a5
    80007d2a:	4505                	li	a0,1
    80007d2c:	ffffc097          	auipc	ra,0xffffc
    80007d30:	78e080e7          	jalr	1934(ra) # 800044ba <argaddr>
  argint(2, &n);
    80007d34:	fe440793          	addi	a5,s0,-28
    80007d38:	85be                	mv	a1,a5
    80007d3a:	4509                	li	a0,2
    80007d3c:	ffffc097          	auipc	ra,0xffffc
    80007d40:	748080e7          	jalr	1864(ra) # 80004484 <argint>
  if(argfd(0, 0, &f) < 0)
    80007d44:	fe840793          	addi	a5,s0,-24
    80007d48:	863e                	mv	a2,a5
    80007d4a:	4581                	li	a1,0
    80007d4c:	4501                	li	a0,0
    80007d4e:	00000097          	auipc	ra,0x0
    80007d52:	e4c080e7          	jalr	-436(ra) # 80007b9a <argfd>
    80007d56:	87aa                	mv	a5,a0
    80007d58:	0007d463          	bgez	a5,80007d60 <sys_read+0x44>
    return -1;
    80007d5c:	57fd                	li	a5,-1
    80007d5e:	a839                	j	80007d7c <sys_read+0x60>
  return fileread(f, p, n);
    80007d60:	fe843783          	ld	a5,-24(s0)
    80007d64:	fd843703          	ld	a4,-40(s0)
    80007d68:	fe442683          	lw	a3,-28(s0)
    80007d6c:	8636                	mv	a2,a3
    80007d6e:	85ba                	mv	a1,a4
    80007d70:	853e                	mv	a0,a5
    80007d72:	fffff097          	auipc	ra,0xfffff
    80007d76:	02c080e7          	jalr	44(ra) # 80006d9e <fileread>
    80007d7a:	87aa                	mv	a5,a0
}
    80007d7c:	853e                	mv	a0,a5
    80007d7e:	70a2                	ld	ra,40(sp)
    80007d80:	7402                	ld	s0,32(sp)
    80007d82:	6145                	addi	sp,sp,48
    80007d84:	8082                	ret

0000000080007d86 <sys_write>:

uint64
sys_write(void)
{
    80007d86:	7179                	addi	sp,sp,-48
    80007d88:	f406                	sd	ra,40(sp)
    80007d8a:	f022                	sd	s0,32(sp)
    80007d8c:	1800                	addi	s0,sp,48
  struct file *f;
  int n;
  uint64 p;
  
  argaddr(1, &p);
    80007d8e:	fd840793          	addi	a5,s0,-40
    80007d92:	85be                	mv	a1,a5
    80007d94:	4505                	li	a0,1
    80007d96:	ffffc097          	auipc	ra,0xffffc
    80007d9a:	724080e7          	jalr	1828(ra) # 800044ba <argaddr>
  argint(2, &n);
    80007d9e:	fe440793          	addi	a5,s0,-28
    80007da2:	85be                	mv	a1,a5
    80007da4:	4509                	li	a0,2
    80007da6:	ffffc097          	auipc	ra,0xffffc
    80007daa:	6de080e7          	jalr	1758(ra) # 80004484 <argint>
  if(argfd(0, 0, &f) < 0)
    80007dae:	fe840793          	addi	a5,s0,-24
    80007db2:	863e                	mv	a2,a5
    80007db4:	4581                	li	a1,0
    80007db6:	4501                	li	a0,0
    80007db8:	00000097          	auipc	ra,0x0
    80007dbc:	de2080e7          	jalr	-542(ra) # 80007b9a <argfd>
    80007dc0:	87aa                	mv	a5,a0
    80007dc2:	0007d463          	bgez	a5,80007dca <sys_write+0x44>
    return -1;
    80007dc6:	57fd                	li	a5,-1
    80007dc8:	a839                	j	80007de6 <sys_write+0x60>

  return filewrite(f, p, n);
    80007dca:	fe843783          	ld	a5,-24(s0)
    80007dce:	fd843703          	ld	a4,-40(s0)
    80007dd2:	fe442683          	lw	a3,-28(s0)
    80007dd6:	8636                	mv	a2,a3
    80007dd8:	85ba                	mv	a1,a4
    80007dda:	853e                	mv	a0,a5
    80007ddc:	fffff097          	auipc	ra,0xfffff
    80007de0:	128080e7          	jalr	296(ra) # 80006f04 <filewrite>
    80007de4:	87aa                	mv	a5,a0
}
    80007de6:	853e                	mv	a0,a5
    80007de8:	70a2                	ld	ra,40(sp)
    80007dea:	7402                	ld	s0,32(sp)
    80007dec:	6145                	addi	sp,sp,48
    80007dee:	8082                	ret

0000000080007df0 <sys_close>:

uint64
sys_close(void)
{
    80007df0:	1101                	addi	sp,sp,-32
    80007df2:	ec06                	sd	ra,24(sp)
    80007df4:	e822                	sd	s0,16(sp)
    80007df6:	1000                	addi	s0,sp,32
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    80007df8:	fe040713          	addi	a4,s0,-32
    80007dfc:	fec40793          	addi	a5,s0,-20
    80007e00:	863a                	mv	a2,a4
    80007e02:	85be                	mv	a1,a5
    80007e04:	4501                	li	a0,0
    80007e06:	00000097          	auipc	ra,0x0
    80007e0a:	d94080e7          	jalr	-620(ra) # 80007b9a <argfd>
    80007e0e:	87aa                	mv	a5,a0
    80007e10:	0007d463          	bgez	a5,80007e18 <sys_close+0x28>
    return -1;
    80007e14:	57fd                	li	a5,-1
    80007e16:	a02d                	j	80007e40 <sys_close+0x50>
  myproc()->ofile[fd] = 0;
    80007e18:	ffffb097          	auipc	ra,0xffffb
    80007e1c:	a28080e7          	jalr	-1496(ra) # 80002840 <myproc>
    80007e20:	872a                	mv	a4,a0
    80007e22:	fec42783          	lw	a5,-20(s0)
    80007e26:	07e9                	addi	a5,a5,26
    80007e28:	078e                	slli	a5,a5,0x3
    80007e2a:	97ba                	add	a5,a5,a4
    80007e2c:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80007e30:	fe043783          	ld	a5,-32(s0)
    80007e34:	853e                	mv	a0,a5
    80007e36:	fffff097          	auipc	ra,0xfffff
    80007e3a:	dbc080e7          	jalr	-580(ra) # 80006bf2 <fileclose>
  return 0;
    80007e3e:	4781                	li	a5,0
}
    80007e40:	853e                	mv	a0,a5
    80007e42:	60e2                	ld	ra,24(sp)
    80007e44:	6442                	ld	s0,16(sp)
    80007e46:	6105                	addi	sp,sp,32
    80007e48:	8082                	ret

0000000080007e4a <sys_fstat>:

uint64
sys_fstat(void)
{
    80007e4a:	1101                	addi	sp,sp,-32
    80007e4c:	ec06                	sd	ra,24(sp)
    80007e4e:	e822                	sd	s0,16(sp)
    80007e50:	1000                	addi	s0,sp,32
  struct file *f;
  uint64 st; // user pointer to struct stat

  argaddr(1, &st);
    80007e52:	fe040793          	addi	a5,s0,-32
    80007e56:	85be                	mv	a1,a5
    80007e58:	4505                	li	a0,1
    80007e5a:	ffffc097          	auipc	ra,0xffffc
    80007e5e:	660080e7          	jalr	1632(ra) # 800044ba <argaddr>
  if(argfd(0, 0, &f) < 0)
    80007e62:	fe840793          	addi	a5,s0,-24
    80007e66:	863e                	mv	a2,a5
    80007e68:	4581                	li	a1,0
    80007e6a:	4501                	li	a0,0
    80007e6c:	00000097          	auipc	ra,0x0
    80007e70:	d2e080e7          	jalr	-722(ra) # 80007b9a <argfd>
    80007e74:	87aa                	mv	a5,a0
    80007e76:	0007d463          	bgez	a5,80007e7e <sys_fstat+0x34>
    return -1;
    80007e7a:	57fd                	li	a5,-1
    80007e7c:	a821                	j	80007e94 <sys_fstat+0x4a>
  return filestat(f, st);
    80007e7e:	fe843783          	ld	a5,-24(s0)
    80007e82:	fe043703          	ld	a4,-32(s0)
    80007e86:	85ba                	mv	a1,a4
    80007e88:	853e                	mv	a0,a5
    80007e8a:	fffff097          	auipc	ra,0xfffff
    80007e8e:	e70080e7          	jalr	-400(ra) # 80006cfa <filestat>
    80007e92:	87aa                	mv	a5,a0
}
    80007e94:	853e                	mv	a0,a5
    80007e96:	60e2                	ld	ra,24(sp)
    80007e98:	6442                	ld	s0,16(sp)
    80007e9a:	6105                	addi	sp,sp,32
    80007e9c:	8082                	ret

0000000080007e9e <sys_link>:

// Create the path new as a link to the same inode as old.
uint64
sys_link(void)
{
    80007e9e:	7169                	addi	sp,sp,-304
    80007ea0:	f606                	sd	ra,296(sp)
    80007ea2:	f222                	sd	s0,288(sp)
    80007ea4:	1a00                	addi	s0,sp,304
  char name[DIRSIZ], new[MAXPATH], old[MAXPATH];
  struct inode *dp, *ip;

  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80007ea6:	ed040793          	addi	a5,s0,-304
    80007eaa:	08000613          	li	a2,128
    80007eae:	85be                	mv	a1,a5
    80007eb0:	4501                	li	a0,0
    80007eb2:	ffffc097          	auipc	ra,0xffffc
    80007eb6:	63a080e7          	jalr	1594(ra) # 800044ec <argstr>
    80007eba:	87aa                	mv	a5,a0
    80007ebc:	0007cf63          	bltz	a5,80007eda <sys_link+0x3c>
    80007ec0:	f5040793          	addi	a5,s0,-176
    80007ec4:	08000613          	li	a2,128
    80007ec8:	85be                	mv	a1,a5
    80007eca:	4505                	li	a0,1
    80007ecc:	ffffc097          	auipc	ra,0xffffc
    80007ed0:	620080e7          	jalr	1568(ra) # 800044ec <argstr>
    80007ed4:	87aa                	mv	a5,a0
    80007ed6:	0007d463          	bgez	a5,80007ede <sys_link+0x40>
    return -1;
    80007eda:	57fd                	li	a5,-1
    80007edc:	aab5                	j	80008058 <sys_link+0x1ba>

  begin_op();
    80007ede:	ffffe097          	auipc	ra,0xffffe
    80007ee2:	67a080e7          	jalr	1658(ra) # 80006558 <begin_op>
  if((ip = namei(old)) == 0){
    80007ee6:	ed040793          	addi	a5,s0,-304
    80007eea:	853e                	mv	a0,a5
    80007eec:	ffffe097          	auipc	ra,0xffffe
    80007ef0:	308080e7          	jalr	776(ra) # 800061f4 <namei>
    80007ef4:	fea43423          	sd	a0,-24(s0)
    80007ef8:	fe843783          	ld	a5,-24(s0)
    80007efc:	e799                	bnez	a5,80007f0a <sys_link+0x6c>
    end_op();
    80007efe:	ffffe097          	auipc	ra,0xffffe
    80007f02:	71c080e7          	jalr	1820(ra) # 8000661a <end_op>
    return -1;
    80007f06:	57fd                	li	a5,-1
    80007f08:	aa81                	j	80008058 <sys_link+0x1ba>
  }

  ilock(ip);
    80007f0a:	fe843503          	ld	a0,-24(s0)
    80007f0e:	ffffd097          	auipc	ra,0xffffd
    80007f12:	5b2080e7          	jalr	1458(ra) # 800054c0 <ilock>
  if(ip->type == T_DIR){
    80007f16:	fe843783          	ld	a5,-24(s0)
    80007f1a:	04479783          	lh	a5,68(a5)
    80007f1e:	0007871b          	sext.w	a4,a5
    80007f22:	4785                	li	a5,1
    80007f24:	00f71e63          	bne	a4,a5,80007f40 <sys_link+0xa2>
    iunlockput(ip);
    80007f28:	fe843503          	ld	a0,-24(s0)
    80007f2c:	ffffd097          	auipc	ra,0xffffd
    80007f30:	7f2080e7          	jalr	2034(ra) # 8000571e <iunlockput>
    end_op();
    80007f34:	ffffe097          	auipc	ra,0xffffe
    80007f38:	6e6080e7          	jalr	1766(ra) # 8000661a <end_op>
    return -1;
    80007f3c:	57fd                	li	a5,-1
    80007f3e:	aa29                	j	80008058 <sys_link+0x1ba>
  }

  ip->nlink++;
    80007f40:	fe843783          	ld	a5,-24(s0)
    80007f44:	04a79783          	lh	a5,74(a5)
    80007f48:	17c2                	slli	a5,a5,0x30
    80007f4a:	93c1                	srli	a5,a5,0x30
    80007f4c:	2785                	addiw	a5,a5,1
    80007f4e:	17c2                	slli	a5,a5,0x30
    80007f50:	93c1                	srli	a5,a5,0x30
    80007f52:	0107971b          	slliw	a4,a5,0x10
    80007f56:	4107571b          	sraiw	a4,a4,0x10
    80007f5a:	fe843783          	ld	a5,-24(s0)
    80007f5e:	04e79523          	sh	a4,74(a5)
  iupdate(ip);
    80007f62:	fe843503          	ld	a0,-24(s0)
    80007f66:	ffffd097          	auipc	ra,0xffffd
    80007f6a:	30a080e7          	jalr	778(ra) # 80005270 <iupdate>
  iunlock(ip);
    80007f6e:	fe843503          	ld	a0,-24(s0)
    80007f72:	ffffd097          	auipc	ra,0xffffd
    80007f76:	682080e7          	jalr	1666(ra) # 800055f4 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
    80007f7a:	fd040713          	addi	a4,s0,-48
    80007f7e:	f5040793          	addi	a5,s0,-176
    80007f82:	85ba                	mv	a1,a4
    80007f84:	853e                	mv	a0,a5
    80007f86:	ffffe097          	auipc	ra,0xffffe
    80007f8a:	29a080e7          	jalr	666(ra) # 80006220 <nameiparent>
    80007f8e:	fea43023          	sd	a0,-32(s0)
    80007f92:	fe043783          	ld	a5,-32(s0)
    80007f96:	cba5                	beqz	a5,80008006 <sys_link+0x168>
    goto bad;
  ilock(dp);
    80007f98:	fe043503          	ld	a0,-32(s0)
    80007f9c:	ffffd097          	auipc	ra,0xffffd
    80007fa0:	524080e7          	jalr	1316(ra) # 800054c0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80007fa4:	fe043783          	ld	a5,-32(s0)
    80007fa8:	4398                	lw	a4,0(a5)
    80007faa:	fe843783          	ld	a5,-24(s0)
    80007fae:	439c                	lw	a5,0(a5)
    80007fb0:	02f71263          	bne	a4,a5,80007fd4 <sys_link+0x136>
    80007fb4:	fe843783          	ld	a5,-24(s0)
    80007fb8:	43d8                	lw	a4,4(a5)
    80007fba:	fd040793          	addi	a5,s0,-48
    80007fbe:	863a                	mv	a2,a4
    80007fc0:	85be                	mv	a1,a5
    80007fc2:	fe043503          	ld	a0,-32(s0)
    80007fc6:	ffffe097          	auipc	ra,0xffffe
    80007fca:	f20080e7          	jalr	-224(ra) # 80005ee6 <dirlink>
    80007fce:	87aa                	mv	a5,a0
    80007fd0:	0007d963          	bgez	a5,80007fe2 <sys_link+0x144>
    iunlockput(dp);
    80007fd4:	fe043503          	ld	a0,-32(s0)
    80007fd8:	ffffd097          	auipc	ra,0xffffd
    80007fdc:	746080e7          	jalr	1862(ra) # 8000571e <iunlockput>
    goto bad;
    80007fe0:	a025                	j	80008008 <sys_link+0x16a>
  }
  iunlockput(dp);
    80007fe2:	fe043503          	ld	a0,-32(s0)
    80007fe6:	ffffd097          	auipc	ra,0xffffd
    80007fea:	738080e7          	jalr	1848(ra) # 8000571e <iunlockput>
  iput(ip);
    80007fee:	fe843503          	ld	a0,-24(s0)
    80007ff2:	ffffd097          	auipc	ra,0xffffd
    80007ff6:	65c080e7          	jalr	1628(ra) # 8000564e <iput>

  end_op();
    80007ffa:	ffffe097          	auipc	ra,0xffffe
    80007ffe:	620080e7          	jalr	1568(ra) # 8000661a <end_op>

  return 0;
    80008002:	4781                	li	a5,0
    80008004:	a891                	j	80008058 <sys_link+0x1ba>
    goto bad;
    80008006:	0001                	nop

bad:
  ilock(ip);
    80008008:	fe843503          	ld	a0,-24(s0)
    8000800c:	ffffd097          	auipc	ra,0xffffd
    80008010:	4b4080e7          	jalr	1204(ra) # 800054c0 <ilock>
  ip->nlink--;
    80008014:	fe843783          	ld	a5,-24(s0)
    80008018:	04a79783          	lh	a5,74(a5)
    8000801c:	17c2                	slli	a5,a5,0x30
    8000801e:	93c1                	srli	a5,a5,0x30
    80008020:	37fd                	addiw	a5,a5,-1
    80008022:	17c2                	slli	a5,a5,0x30
    80008024:	93c1                	srli	a5,a5,0x30
    80008026:	0107971b          	slliw	a4,a5,0x10
    8000802a:	4107571b          	sraiw	a4,a4,0x10
    8000802e:	fe843783          	ld	a5,-24(s0)
    80008032:	04e79523          	sh	a4,74(a5)
  iupdate(ip);
    80008036:	fe843503          	ld	a0,-24(s0)
    8000803a:	ffffd097          	auipc	ra,0xffffd
    8000803e:	236080e7          	jalr	566(ra) # 80005270 <iupdate>
  iunlockput(ip);
    80008042:	fe843503          	ld	a0,-24(s0)
    80008046:	ffffd097          	auipc	ra,0xffffd
    8000804a:	6d8080e7          	jalr	1752(ra) # 8000571e <iunlockput>
  end_op();
    8000804e:	ffffe097          	auipc	ra,0xffffe
    80008052:	5cc080e7          	jalr	1484(ra) # 8000661a <end_op>
  return -1;
    80008056:	57fd                	li	a5,-1
}
    80008058:	853e                	mv	a0,a5
    8000805a:	70b2                	ld	ra,296(sp)
    8000805c:	7412                	ld	s0,288(sp)
    8000805e:	6155                	addi	sp,sp,304
    80008060:	8082                	ret

0000000080008062 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
    80008062:	7139                	addi	sp,sp,-64
    80008064:	fc06                	sd	ra,56(sp)
    80008066:	f822                	sd	s0,48(sp)
    80008068:	0080                	addi	s0,sp,64
    8000806a:	fca43423          	sd	a0,-56(s0)
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000806e:	02000793          	li	a5,32
    80008072:	fef42623          	sw	a5,-20(s0)
    80008076:	a0b1                	j	800080c2 <isdirempty+0x60>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80008078:	fd840793          	addi	a5,s0,-40
    8000807c:	fec42683          	lw	a3,-20(s0)
    80008080:	4741                	li	a4,16
    80008082:	863e                	mv	a2,a5
    80008084:	4581                	li	a1,0
    80008086:	fc843503          	ld	a0,-56(s0)
    8000808a:	ffffe097          	auipc	ra,0xffffe
    8000808e:	9ec080e7          	jalr	-1556(ra) # 80005a76 <readi>
    80008092:	87aa                	mv	a5,a0
    80008094:	873e                	mv	a4,a5
    80008096:	47c1                	li	a5,16
    80008098:	00f70a63          	beq	a4,a5,800080ac <isdirempty+0x4a>
      panic("isdirempty: readi");
    8000809c:	00003517          	auipc	a0,0x3
    800080a0:	59c50513          	addi	a0,a0,1436 # 8000b638 <etext+0x638>
    800080a4:	ffff9097          	auipc	ra,0xffff9
    800080a8:	be6080e7          	jalr	-1050(ra) # 80000c8a <panic>
    if(de.inum != 0)
    800080ac:	fd845783          	lhu	a5,-40(s0)
    800080b0:	c399                	beqz	a5,800080b6 <isdirempty+0x54>
      return 0;
    800080b2:	4781                	li	a5,0
    800080b4:	a839                	j	800080d2 <isdirempty+0x70>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800080b6:	fec42783          	lw	a5,-20(s0)
    800080ba:	27c1                	addiw	a5,a5,16
    800080bc:	2781                	sext.w	a5,a5
    800080be:	fef42623          	sw	a5,-20(s0)
    800080c2:	fc843783          	ld	a5,-56(s0)
    800080c6:	47f8                	lw	a4,76(a5)
    800080c8:	fec42783          	lw	a5,-20(s0)
    800080cc:	fae7e6e3          	bltu	a5,a4,80008078 <isdirempty+0x16>
  }
  return 1;
    800080d0:	4785                	li	a5,1
}
    800080d2:	853e                	mv	a0,a5
    800080d4:	70e2                	ld	ra,56(sp)
    800080d6:	7442                	ld	s0,48(sp)
    800080d8:	6121                	addi	sp,sp,64
    800080da:	8082                	ret

00000000800080dc <sys_unlink>:

uint64
sys_unlink(void)
{
    800080dc:	7155                	addi	sp,sp,-208
    800080de:	e586                	sd	ra,200(sp)
    800080e0:	e1a2                	sd	s0,192(sp)
    800080e2:	0980                	addi	s0,sp,208
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], path[MAXPATH];
  uint off;

  if(argstr(0, path, MAXPATH) < 0)
    800080e4:	f4040793          	addi	a5,s0,-192
    800080e8:	08000613          	li	a2,128
    800080ec:	85be                	mv	a1,a5
    800080ee:	4501                	li	a0,0
    800080f0:	ffffc097          	auipc	ra,0xffffc
    800080f4:	3fc080e7          	jalr	1020(ra) # 800044ec <argstr>
    800080f8:	87aa                	mv	a5,a0
    800080fa:	0007d463          	bgez	a5,80008102 <sys_unlink+0x26>
    return -1;
    800080fe:	57fd                	li	a5,-1
    80008100:	a2ed                	j	800082ea <sys_unlink+0x20e>

  begin_op();
    80008102:	ffffe097          	auipc	ra,0xffffe
    80008106:	456080e7          	jalr	1110(ra) # 80006558 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000810a:	fc040713          	addi	a4,s0,-64
    8000810e:	f4040793          	addi	a5,s0,-192
    80008112:	85ba                	mv	a1,a4
    80008114:	853e                	mv	a0,a5
    80008116:	ffffe097          	auipc	ra,0xffffe
    8000811a:	10a080e7          	jalr	266(ra) # 80006220 <nameiparent>
    8000811e:	fea43423          	sd	a0,-24(s0)
    80008122:	fe843783          	ld	a5,-24(s0)
    80008126:	e799                	bnez	a5,80008134 <sys_unlink+0x58>
    end_op();
    80008128:	ffffe097          	auipc	ra,0xffffe
    8000812c:	4f2080e7          	jalr	1266(ra) # 8000661a <end_op>
    return -1;
    80008130:	57fd                	li	a5,-1
    80008132:	aa65                	j	800082ea <sys_unlink+0x20e>
  }

  ilock(dp);
    80008134:	fe843503          	ld	a0,-24(s0)
    80008138:	ffffd097          	auipc	ra,0xffffd
    8000813c:	388080e7          	jalr	904(ra) # 800054c0 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80008140:	fc040793          	addi	a5,s0,-64
    80008144:	00003597          	auipc	a1,0x3
    80008148:	50c58593          	addi	a1,a1,1292 # 8000b650 <etext+0x650>
    8000814c:	853e                	mv	a0,a5
    8000814e:	ffffe097          	auipc	ra,0xffffe
    80008152:	c82080e7          	jalr	-894(ra) # 80005dd0 <namecmp>
    80008156:	87aa                	mv	a5,a0
    80008158:	16078b63          	beqz	a5,800082ce <sys_unlink+0x1f2>
    8000815c:	fc040793          	addi	a5,s0,-64
    80008160:	00003597          	auipc	a1,0x3
    80008164:	4f858593          	addi	a1,a1,1272 # 8000b658 <etext+0x658>
    80008168:	853e                	mv	a0,a5
    8000816a:	ffffe097          	auipc	ra,0xffffe
    8000816e:	c66080e7          	jalr	-922(ra) # 80005dd0 <namecmp>
    80008172:	87aa                	mv	a5,a0
    80008174:	14078d63          	beqz	a5,800082ce <sys_unlink+0x1f2>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    80008178:	f3c40713          	addi	a4,s0,-196
    8000817c:	fc040793          	addi	a5,s0,-64
    80008180:	863a                	mv	a2,a4
    80008182:	85be                	mv	a1,a5
    80008184:	fe843503          	ld	a0,-24(s0)
    80008188:	ffffe097          	auipc	ra,0xffffe
    8000818c:	c76080e7          	jalr	-906(ra) # 80005dfe <dirlookup>
    80008190:	fea43023          	sd	a0,-32(s0)
    80008194:	fe043783          	ld	a5,-32(s0)
    80008198:	12078d63          	beqz	a5,800082d2 <sys_unlink+0x1f6>
    goto bad;
  ilock(ip);
    8000819c:	fe043503          	ld	a0,-32(s0)
    800081a0:	ffffd097          	auipc	ra,0xffffd
    800081a4:	320080e7          	jalr	800(ra) # 800054c0 <ilock>

  if(ip->nlink < 1)
    800081a8:	fe043783          	ld	a5,-32(s0)
    800081ac:	04a79783          	lh	a5,74(a5)
    800081b0:	2781                	sext.w	a5,a5
    800081b2:	00f04a63          	bgtz	a5,800081c6 <sys_unlink+0xea>
    panic("unlink: nlink < 1");
    800081b6:	00003517          	auipc	a0,0x3
    800081ba:	4aa50513          	addi	a0,a0,1194 # 8000b660 <etext+0x660>
    800081be:	ffff9097          	auipc	ra,0xffff9
    800081c2:	acc080e7          	jalr	-1332(ra) # 80000c8a <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800081c6:	fe043783          	ld	a5,-32(s0)
    800081ca:	04479783          	lh	a5,68(a5)
    800081ce:	0007871b          	sext.w	a4,a5
    800081d2:	4785                	li	a5,1
    800081d4:	02f71163          	bne	a4,a5,800081f6 <sys_unlink+0x11a>
    800081d8:	fe043503          	ld	a0,-32(s0)
    800081dc:	00000097          	auipc	ra,0x0
    800081e0:	e86080e7          	jalr	-378(ra) # 80008062 <isdirempty>
    800081e4:	87aa                	mv	a5,a0
    800081e6:	eb81                	bnez	a5,800081f6 <sys_unlink+0x11a>
    iunlockput(ip);
    800081e8:	fe043503          	ld	a0,-32(s0)
    800081ec:	ffffd097          	auipc	ra,0xffffd
    800081f0:	532080e7          	jalr	1330(ra) # 8000571e <iunlockput>
    goto bad;
    800081f4:	a0c5                	j	800082d4 <sys_unlink+0x1f8>
  }

  memset(&de, 0, sizeof(de));
    800081f6:	fd040793          	addi	a5,s0,-48
    800081fa:	4641                	li	a2,16
    800081fc:	4581                	li	a1,0
    800081fe:	853e                	mv	a0,a5
    80008200:	ffff9097          	auipc	ra,0xffff9
    80008204:	24c080e7          	jalr	588(ra) # 8000144c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80008208:	fd040793          	addi	a5,s0,-48
    8000820c:	f3c42683          	lw	a3,-196(s0)
    80008210:	4741                	li	a4,16
    80008212:	863e                	mv	a2,a5
    80008214:	4581                	li	a1,0
    80008216:	fe843503          	ld	a0,-24(s0)
    8000821a:	ffffe097          	auipc	ra,0xffffe
    8000821e:	9fa080e7          	jalr	-1542(ra) # 80005c14 <writei>
    80008222:	87aa                	mv	a5,a0
    80008224:	873e                	mv	a4,a5
    80008226:	47c1                	li	a5,16
    80008228:	00f70a63          	beq	a4,a5,8000823c <sys_unlink+0x160>
    panic("unlink: writei");
    8000822c:	00003517          	auipc	a0,0x3
    80008230:	44c50513          	addi	a0,a0,1100 # 8000b678 <etext+0x678>
    80008234:	ffff9097          	auipc	ra,0xffff9
    80008238:	a56080e7          	jalr	-1450(ra) # 80000c8a <panic>
  if(ip->type == T_DIR){
    8000823c:	fe043783          	ld	a5,-32(s0)
    80008240:	04479783          	lh	a5,68(a5)
    80008244:	0007871b          	sext.w	a4,a5
    80008248:	4785                	li	a5,1
    8000824a:	02f71963          	bne	a4,a5,8000827c <sys_unlink+0x1a0>
    dp->nlink--;
    8000824e:	fe843783          	ld	a5,-24(s0)
    80008252:	04a79783          	lh	a5,74(a5)
    80008256:	17c2                	slli	a5,a5,0x30
    80008258:	93c1                	srli	a5,a5,0x30
    8000825a:	37fd                	addiw	a5,a5,-1
    8000825c:	17c2                	slli	a5,a5,0x30
    8000825e:	93c1                	srli	a5,a5,0x30
    80008260:	0107971b          	slliw	a4,a5,0x10
    80008264:	4107571b          	sraiw	a4,a4,0x10
    80008268:	fe843783          	ld	a5,-24(s0)
    8000826c:	04e79523          	sh	a4,74(a5)
    iupdate(dp);
    80008270:	fe843503          	ld	a0,-24(s0)
    80008274:	ffffd097          	auipc	ra,0xffffd
    80008278:	ffc080e7          	jalr	-4(ra) # 80005270 <iupdate>
  }
  iunlockput(dp);
    8000827c:	fe843503          	ld	a0,-24(s0)
    80008280:	ffffd097          	auipc	ra,0xffffd
    80008284:	49e080e7          	jalr	1182(ra) # 8000571e <iunlockput>

  ip->nlink--;
    80008288:	fe043783          	ld	a5,-32(s0)
    8000828c:	04a79783          	lh	a5,74(a5)
    80008290:	17c2                	slli	a5,a5,0x30
    80008292:	93c1                	srli	a5,a5,0x30
    80008294:	37fd                	addiw	a5,a5,-1
    80008296:	17c2                	slli	a5,a5,0x30
    80008298:	93c1                	srli	a5,a5,0x30
    8000829a:	0107971b          	slliw	a4,a5,0x10
    8000829e:	4107571b          	sraiw	a4,a4,0x10
    800082a2:	fe043783          	ld	a5,-32(s0)
    800082a6:	04e79523          	sh	a4,74(a5)
  iupdate(ip);
    800082aa:	fe043503          	ld	a0,-32(s0)
    800082ae:	ffffd097          	auipc	ra,0xffffd
    800082b2:	fc2080e7          	jalr	-62(ra) # 80005270 <iupdate>
  iunlockput(ip);
    800082b6:	fe043503          	ld	a0,-32(s0)
    800082ba:	ffffd097          	auipc	ra,0xffffd
    800082be:	464080e7          	jalr	1124(ra) # 8000571e <iunlockput>

  end_op();
    800082c2:	ffffe097          	auipc	ra,0xffffe
    800082c6:	358080e7          	jalr	856(ra) # 8000661a <end_op>

  return 0;
    800082ca:	4781                	li	a5,0
    800082cc:	a839                	j	800082ea <sys_unlink+0x20e>
    goto bad;
    800082ce:	0001                	nop
    800082d0:	a011                	j	800082d4 <sys_unlink+0x1f8>
    goto bad;
    800082d2:	0001                	nop

bad:
  iunlockput(dp);
    800082d4:	fe843503          	ld	a0,-24(s0)
    800082d8:	ffffd097          	auipc	ra,0xffffd
    800082dc:	446080e7          	jalr	1094(ra) # 8000571e <iunlockput>
  end_op();
    800082e0:	ffffe097          	auipc	ra,0xffffe
    800082e4:	33a080e7          	jalr	826(ra) # 8000661a <end_op>
  return -1;
    800082e8:	57fd                	li	a5,-1
}
    800082ea:	853e                	mv	a0,a5
    800082ec:	60ae                	ld	ra,200(sp)
    800082ee:	640e                	ld	s0,192(sp)
    800082f0:	6169                	addi	sp,sp,208
    800082f2:	8082                	ret

00000000800082f4 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
    800082f4:	7139                	addi	sp,sp,-64
    800082f6:	fc06                	sd	ra,56(sp)
    800082f8:	f822                	sd	s0,48(sp)
    800082fa:	0080                	addi	s0,sp,64
    800082fc:	fca43423          	sd	a0,-56(s0)
    80008300:	87ae                	mv	a5,a1
    80008302:	8736                	mv	a4,a3
    80008304:	fcf41323          	sh	a5,-58(s0)
    80008308:	87b2                	mv	a5,a2
    8000830a:	fcf41223          	sh	a5,-60(s0)
    8000830e:	87ba                	mv	a5,a4
    80008310:	fcf41123          	sh	a5,-62(s0)
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80008314:	fd040793          	addi	a5,s0,-48
    80008318:	85be                	mv	a1,a5
    8000831a:	fc843503          	ld	a0,-56(s0)
    8000831e:	ffffe097          	auipc	ra,0xffffe
    80008322:	f02080e7          	jalr	-254(ra) # 80006220 <nameiparent>
    80008326:	fea43423          	sd	a0,-24(s0)
    8000832a:	fe843783          	ld	a5,-24(s0)
    8000832e:	e399                	bnez	a5,80008334 <create+0x40>
    return 0;
    80008330:	4781                	li	a5,0
    80008332:	a2ed                	j	8000851c <create+0x228>

  ilock(dp);
    80008334:	fe843503          	ld	a0,-24(s0)
    80008338:	ffffd097          	auipc	ra,0xffffd
    8000833c:	188080e7          	jalr	392(ra) # 800054c0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80008340:	fd040793          	addi	a5,s0,-48
    80008344:	4601                	li	a2,0
    80008346:	85be                	mv	a1,a5
    80008348:	fe843503          	ld	a0,-24(s0)
    8000834c:	ffffe097          	auipc	ra,0xffffe
    80008350:	ab2080e7          	jalr	-1358(ra) # 80005dfe <dirlookup>
    80008354:	fea43023          	sd	a0,-32(s0)
    80008358:	fe043783          	ld	a5,-32(s0)
    8000835c:	c3ad                	beqz	a5,800083be <create+0xca>
    iunlockput(dp);
    8000835e:	fe843503          	ld	a0,-24(s0)
    80008362:	ffffd097          	auipc	ra,0xffffd
    80008366:	3bc080e7          	jalr	956(ra) # 8000571e <iunlockput>
    ilock(ip);
    8000836a:	fe043503          	ld	a0,-32(s0)
    8000836e:	ffffd097          	auipc	ra,0xffffd
    80008372:	152080e7          	jalr	338(ra) # 800054c0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80008376:	fc641783          	lh	a5,-58(s0)
    8000837a:	0007871b          	sext.w	a4,a5
    8000837e:	4789                	li	a5,2
    80008380:	02f71763          	bne	a4,a5,800083ae <create+0xba>
    80008384:	fe043783          	ld	a5,-32(s0)
    80008388:	04479783          	lh	a5,68(a5)
    8000838c:	0007871b          	sext.w	a4,a5
    80008390:	4789                	li	a5,2
    80008392:	00f70b63          	beq	a4,a5,800083a8 <create+0xb4>
    80008396:	fe043783          	ld	a5,-32(s0)
    8000839a:	04479783          	lh	a5,68(a5)
    8000839e:	0007871b          	sext.w	a4,a5
    800083a2:	478d                	li	a5,3
    800083a4:	00f71563          	bne	a4,a5,800083ae <create+0xba>
      return ip;
    800083a8:	fe043783          	ld	a5,-32(s0)
    800083ac:	aa85                	j	8000851c <create+0x228>
    iunlockput(ip);
    800083ae:	fe043503          	ld	a0,-32(s0)
    800083b2:	ffffd097          	auipc	ra,0xffffd
    800083b6:	36c080e7          	jalr	876(ra) # 8000571e <iunlockput>
    return 0;
    800083ba:	4781                	li	a5,0
    800083bc:	a285                	j	8000851c <create+0x228>
  }

  if((ip = ialloc(dp->dev, type)) == 0){
    800083be:	fe843783          	ld	a5,-24(s0)
    800083c2:	439c                	lw	a5,0(a5)
    800083c4:	fc641703          	lh	a4,-58(s0)
    800083c8:	85ba                	mv	a1,a4
    800083ca:	853e                	mv	a0,a5
    800083cc:	ffffd097          	auipc	ra,0xffffd
    800083d0:	da6080e7          	jalr	-602(ra) # 80005172 <ialloc>
    800083d4:	fea43023          	sd	a0,-32(s0)
    800083d8:	fe043783          	ld	a5,-32(s0)
    800083dc:	eb89                	bnez	a5,800083ee <create+0xfa>
    iunlockput(dp);
    800083de:	fe843503          	ld	a0,-24(s0)
    800083e2:	ffffd097          	auipc	ra,0xffffd
    800083e6:	33c080e7          	jalr	828(ra) # 8000571e <iunlockput>
    return 0;
    800083ea:	4781                	li	a5,0
    800083ec:	aa05                	j	8000851c <create+0x228>
  }

  ilock(ip);
    800083ee:	fe043503          	ld	a0,-32(s0)
    800083f2:	ffffd097          	auipc	ra,0xffffd
    800083f6:	0ce080e7          	jalr	206(ra) # 800054c0 <ilock>
  ip->major = major;
    800083fa:	fe043783          	ld	a5,-32(s0)
    800083fe:	fc445703          	lhu	a4,-60(s0)
    80008402:	04e79323          	sh	a4,70(a5)
  ip->minor = minor;
    80008406:	fe043783          	ld	a5,-32(s0)
    8000840a:	fc245703          	lhu	a4,-62(s0)
    8000840e:	04e79423          	sh	a4,72(a5)
  ip->nlink = 1;
    80008412:	fe043783          	ld	a5,-32(s0)
    80008416:	4705                	li	a4,1
    80008418:	04e79523          	sh	a4,74(a5)
  iupdate(ip);
    8000841c:	fe043503          	ld	a0,-32(s0)
    80008420:	ffffd097          	auipc	ra,0xffffd
    80008424:	e50080e7          	jalr	-432(ra) # 80005270 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
    80008428:	fc641783          	lh	a5,-58(s0)
    8000842c:	0007871b          	sext.w	a4,a5
    80008430:	4785                	li	a5,1
    80008432:	04f71463          	bne	a4,a5,8000847a <create+0x186>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80008436:	fe043783          	ld	a5,-32(s0)
    8000843a:	43dc                	lw	a5,4(a5)
    8000843c:	863e                	mv	a2,a5
    8000843e:	00003597          	auipc	a1,0x3
    80008442:	21258593          	addi	a1,a1,530 # 8000b650 <etext+0x650>
    80008446:	fe043503          	ld	a0,-32(s0)
    8000844a:	ffffe097          	auipc	ra,0xffffe
    8000844e:	a9c080e7          	jalr	-1380(ra) # 80005ee6 <dirlink>
    80008452:	87aa                	mv	a5,a0
    80008454:	0807ca63          	bltz	a5,800084e8 <create+0x1f4>
    80008458:	fe843783          	ld	a5,-24(s0)
    8000845c:	43dc                	lw	a5,4(a5)
    8000845e:	863e                	mv	a2,a5
    80008460:	00003597          	auipc	a1,0x3
    80008464:	1f858593          	addi	a1,a1,504 # 8000b658 <etext+0x658>
    80008468:	fe043503          	ld	a0,-32(s0)
    8000846c:	ffffe097          	auipc	ra,0xffffe
    80008470:	a7a080e7          	jalr	-1414(ra) # 80005ee6 <dirlink>
    80008474:	87aa                	mv	a5,a0
    80008476:	0607c963          	bltz	a5,800084e8 <create+0x1f4>
      goto fail;
  }

  if(dirlink(dp, name, ip->inum) < 0)
    8000847a:	fe043783          	ld	a5,-32(s0)
    8000847e:	43d8                	lw	a4,4(a5)
    80008480:	fd040793          	addi	a5,s0,-48
    80008484:	863a                	mv	a2,a4
    80008486:	85be                	mv	a1,a5
    80008488:	fe843503          	ld	a0,-24(s0)
    8000848c:	ffffe097          	auipc	ra,0xffffe
    80008490:	a5a080e7          	jalr	-1446(ra) # 80005ee6 <dirlink>
    80008494:	87aa                	mv	a5,a0
    80008496:	0407cb63          	bltz	a5,800084ec <create+0x1f8>
    goto fail;

  if(type == T_DIR){
    8000849a:	fc641783          	lh	a5,-58(s0)
    8000849e:	0007871b          	sext.w	a4,a5
    800084a2:	4785                	li	a5,1
    800084a4:	02f71963          	bne	a4,a5,800084d6 <create+0x1e2>
    // now that success is guaranteed:
    dp->nlink++;  // for ".."
    800084a8:	fe843783          	ld	a5,-24(s0)
    800084ac:	04a79783          	lh	a5,74(a5)
    800084b0:	17c2                	slli	a5,a5,0x30
    800084b2:	93c1                	srli	a5,a5,0x30
    800084b4:	2785                	addiw	a5,a5,1
    800084b6:	17c2                	slli	a5,a5,0x30
    800084b8:	93c1                	srli	a5,a5,0x30
    800084ba:	0107971b          	slliw	a4,a5,0x10
    800084be:	4107571b          	sraiw	a4,a4,0x10
    800084c2:	fe843783          	ld	a5,-24(s0)
    800084c6:	04e79523          	sh	a4,74(a5)
    iupdate(dp);
    800084ca:	fe843503          	ld	a0,-24(s0)
    800084ce:	ffffd097          	auipc	ra,0xffffd
    800084d2:	da2080e7          	jalr	-606(ra) # 80005270 <iupdate>
  }

  iunlockput(dp);
    800084d6:	fe843503          	ld	a0,-24(s0)
    800084da:	ffffd097          	auipc	ra,0xffffd
    800084de:	244080e7          	jalr	580(ra) # 8000571e <iunlockput>

  return ip;
    800084e2:	fe043783          	ld	a5,-32(s0)
    800084e6:	a81d                	j	8000851c <create+0x228>
      goto fail;
    800084e8:	0001                	nop
    800084ea:	a011                	j	800084ee <create+0x1fa>
    goto fail;
    800084ec:	0001                	nop

 fail:
  // something went wrong. de-allocate ip.
  ip->nlink = 0;
    800084ee:	fe043783          	ld	a5,-32(s0)
    800084f2:	04079523          	sh	zero,74(a5)
  iupdate(ip);
    800084f6:	fe043503          	ld	a0,-32(s0)
    800084fa:	ffffd097          	auipc	ra,0xffffd
    800084fe:	d76080e7          	jalr	-650(ra) # 80005270 <iupdate>
  iunlockput(ip);
    80008502:	fe043503          	ld	a0,-32(s0)
    80008506:	ffffd097          	auipc	ra,0xffffd
    8000850a:	218080e7          	jalr	536(ra) # 8000571e <iunlockput>
  iunlockput(dp);
    8000850e:	fe843503          	ld	a0,-24(s0)
    80008512:	ffffd097          	auipc	ra,0xffffd
    80008516:	20c080e7          	jalr	524(ra) # 8000571e <iunlockput>
  return 0;
    8000851a:	4781                	li	a5,0
}
    8000851c:	853e                	mv	a0,a5
    8000851e:	70e2                	ld	ra,56(sp)
    80008520:	7442                	ld	s0,48(sp)
    80008522:	6121                	addi	sp,sp,64
    80008524:	8082                	ret

0000000080008526 <sys_open>:

uint64
sys_open(void)
{
    80008526:	7131                	addi	sp,sp,-192
    80008528:	fd06                	sd	ra,184(sp)
    8000852a:	f922                	sd	s0,176(sp)
    8000852c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000852e:	f4c40793          	addi	a5,s0,-180
    80008532:	85be                	mv	a1,a5
    80008534:	4505                	li	a0,1
    80008536:	ffffc097          	auipc	ra,0xffffc
    8000853a:	f4e080e7          	jalr	-178(ra) # 80004484 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000853e:	f5040793          	addi	a5,s0,-176
    80008542:	08000613          	li	a2,128
    80008546:	85be                	mv	a1,a5
    80008548:	4501                	li	a0,0
    8000854a:	ffffc097          	auipc	ra,0xffffc
    8000854e:	fa2080e7          	jalr	-94(ra) # 800044ec <argstr>
    80008552:	87aa                	mv	a5,a0
    80008554:	fef42223          	sw	a5,-28(s0)
    80008558:	fe442783          	lw	a5,-28(s0)
    8000855c:	2781                	sext.w	a5,a5
    8000855e:	0007d463          	bgez	a5,80008566 <sys_open+0x40>
    return -1;
    80008562:	57fd                	li	a5,-1
    80008564:	a429                	j	8000876e <sys_open+0x248>

  begin_op();
    80008566:	ffffe097          	auipc	ra,0xffffe
    8000856a:	ff2080e7          	jalr	-14(ra) # 80006558 <begin_op>

  if(omode & O_CREATE){
    8000856e:	f4c42783          	lw	a5,-180(s0)
    80008572:	2007f793          	andi	a5,a5,512
    80008576:	2781                	sext.w	a5,a5
    80008578:	c795                	beqz	a5,800085a4 <sys_open+0x7e>
    ip = create(path, T_FILE, 0, 0);
    8000857a:	f5040793          	addi	a5,s0,-176
    8000857e:	4681                	li	a3,0
    80008580:	4601                	li	a2,0
    80008582:	4589                	li	a1,2
    80008584:	853e                	mv	a0,a5
    80008586:	00000097          	auipc	ra,0x0
    8000858a:	d6e080e7          	jalr	-658(ra) # 800082f4 <create>
    8000858e:	fea43423          	sd	a0,-24(s0)
    if(ip == 0){
    80008592:	fe843783          	ld	a5,-24(s0)
    80008596:	e7bd                	bnez	a5,80008604 <sys_open+0xde>
      end_op();
    80008598:	ffffe097          	auipc	ra,0xffffe
    8000859c:	082080e7          	jalr	130(ra) # 8000661a <end_op>
      return -1;
    800085a0:	57fd                	li	a5,-1
    800085a2:	a2f1                	j	8000876e <sys_open+0x248>
    }
  } else {
    if((ip = namei(path)) == 0){
    800085a4:	f5040793          	addi	a5,s0,-176
    800085a8:	853e                	mv	a0,a5
    800085aa:	ffffe097          	auipc	ra,0xffffe
    800085ae:	c4a080e7          	jalr	-950(ra) # 800061f4 <namei>
    800085b2:	fea43423          	sd	a0,-24(s0)
    800085b6:	fe843783          	ld	a5,-24(s0)
    800085ba:	e799                	bnez	a5,800085c8 <sys_open+0xa2>
      end_op();
    800085bc:	ffffe097          	auipc	ra,0xffffe
    800085c0:	05e080e7          	jalr	94(ra) # 8000661a <end_op>
      return -1;
    800085c4:	57fd                	li	a5,-1
    800085c6:	a265                	j	8000876e <sys_open+0x248>
    }
    ilock(ip);
    800085c8:	fe843503          	ld	a0,-24(s0)
    800085cc:	ffffd097          	auipc	ra,0xffffd
    800085d0:	ef4080e7          	jalr	-268(ra) # 800054c0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800085d4:	fe843783          	ld	a5,-24(s0)
    800085d8:	04479783          	lh	a5,68(a5)
    800085dc:	0007871b          	sext.w	a4,a5
    800085e0:	4785                	li	a5,1
    800085e2:	02f71163          	bne	a4,a5,80008604 <sys_open+0xde>
    800085e6:	f4c42783          	lw	a5,-180(s0)
    800085ea:	cf89                	beqz	a5,80008604 <sys_open+0xde>
      iunlockput(ip);
    800085ec:	fe843503          	ld	a0,-24(s0)
    800085f0:	ffffd097          	auipc	ra,0xffffd
    800085f4:	12e080e7          	jalr	302(ra) # 8000571e <iunlockput>
      end_op();
    800085f8:	ffffe097          	auipc	ra,0xffffe
    800085fc:	022080e7          	jalr	34(ra) # 8000661a <end_op>
      return -1;
    80008600:	57fd                	li	a5,-1
    80008602:	a2b5                	j	8000876e <sys_open+0x248>
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80008604:	fe843783          	ld	a5,-24(s0)
    80008608:	04479783          	lh	a5,68(a5)
    8000860c:	0007871b          	sext.w	a4,a5
    80008610:	478d                	li	a5,3
    80008612:	02f71e63          	bne	a4,a5,8000864e <sys_open+0x128>
    80008616:	fe843783          	ld	a5,-24(s0)
    8000861a:	04679783          	lh	a5,70(a5)
    8000861e:	2781                	sext.w	a5,a5
    80008620:	0007cb63          	bltz	a5,80008636 <sys_open+0x110>
    80008624:	fe843783          	ld	a5,-24(s0)
    80008628:	04679783          	lh	a5,70(a5)
    8000862c:	0007871b          	sext.w	a4,a5
    80008630:	47a5                	li	a5,9
    80008632:	00e7de63          	bge	a5,a4,8000864e <sys_open+0x128>
    iunlockput(ip);
    80008636:	fe843503          	ld	a0,-24(s0)
    8000863a:	ffffd097          	auipc	ra,0xffffd
    8000863e:	0e4080e7          	jalr	228(ra) # 8000571e <iunlockput>
    end_op();
    80008642:	ffffe097          	auipc	ra,0xffffe
    80008646:	fd8080e7          	jalr	-40(ra) # 8000661a <end_op>
    return -1;
    8000864a:	57fd                	li	a5,-1
    8000864c:	a20d                	j	8000876e <sys_open+0x248>
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000864e:	ffffe097          	auipc	ra,0xffffe
    80008652:	4ba080e7          	jalr	1210(ra) # 80006b08 <filealloc>
    80008656:	fca43c23          	sd	a0,-40(s0)
    8000865a:	fd843783          	ld	a5,-40(s0)
    8000865e:	cf99                	beqz	a5,8000867c <sys_open+0x156>
    80008660:	fd843503          	ld	a0,-40(s0)
    80008664:	fffff097          	auipc	ra,0xfffff
    80008668:	5c4080e7          	jalr	1476(ra) # 80007c28 <fdalloc>
    8000866c:	87aa                	mv	a5,a0
    8000866e:	fcf42a23          	sw	a5,-44(s0)
    80008672:	fd442783          	lw	a5,-44(s0)
    80008676:	2781                	sext.w	a5,a5
    80008678:	0207d763          	bgez	a5,800086a6 <sys_open+0x180>
    if(f)
    8000867c:	fd843783          	ld	a5,-40(s0)
    80008680:	c799                	beqz	a5,8000868e <sys_open+0x168>
      fileclose(f);
    80008682:	fd843503          	ld	a0,-40(s0)
    80008686:	ffffe097          	auipc	ra,0xffffe
    8000868a:	56c080e7          	jalr	1388(ra) # 80006bf2 <fileclose>
    iunlockput(ip);
    8000868e:	fe843503          	ld	a0,-24(s0)
    80008692:	ffffd097          	auipc	ra,0xffffd
    80008696:	08c080e7          	jalr	140(ra) # 8000571e <iunlockput>
    end_op();
    8000869a:	ffffe097          	auipc	ra,0xffffe
    8000869e:	f80080e7          	jalr	-128(ra) # 8000661a <end_op>
    return -1;
    800086a2:	57fd                	li	a5,-1
    800086a4:	a0e9                	j	8000876e <sys_open+0x248>
  }

  if(ip->type == T_DEVICE){
    800086a6:	fe843783          	ld	a5,-24(s0)
    800086aa:	04479783          	lh	a5,68(a5)
    800086ae:	0007871b          	sext.w	a4,a5
    800086b2:	478d                	li	a5,3
    800086b4:	00f71f63          	bne	a4,a5,800086d2 <sys_open+0x1ac>
    f->type = FD_DEVICE;
    800086b8:	fd843783          	ld	a5,-40(s0)
    800086bc:	470d                	li	a4,3
    800086be:	c398                	sw	a4,0(a5)
    f->major = ip->major;
    800086c0:	fe843783          	ld	a5,-24(s0)
    800086c4:	04679703          	lh	a4,70(a5)
    800086c8:	fd843783          	ld	a5,-40(s0)
    800086cc:	02e79223          	sh	a4,36(a5)
    800086d0:	a809                	j	800086e2 <sys_open+0x1bc>
  } else {
    f->type = FD_INODE;
    800086d2:	fd843783          	ld	a5,-40(s0)
    800086d6:	4709                	li	a4,2
    800086d8:	c398                	sw	a4,0(a5)
    f->off = 0;
    800086da:	fd843783          	ld	a5,-40(s0)
    800086de:	0207a023          	sw	zero,32(a5)
  }
  f->ip = ip;
    800086e2:	fd843783          	ld	a5,-40(s0)
    800086e6:	fe843703          	ld	a4,-24(s0)
    800086ea:	ef98                	sd	a4,24(a5)
  f->readable = !(omode & O_WRONLY);
    800086ec:	f4c42783          	lw	a5,-180(s0)
    800086f0:	8b85                	andi	a5,a5,1
    800086f2:	2781                	sext.w	a5,a5
    800086f4:	0017b793          	seqz	a5,a5
    800086f8:	0ff7f793          	zext.b	a5,a5
    800086fc:	873e                	mv	a4,a5
    800086fe:	fd843783          	ld	a5,-40(s0)
    80008702:	00e78423          	sb	a4,8(a5)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80008706:	f4c42783          	lw	a5,-180(s0)
    8000870a:	8b85                	andi	a5,a5,1
    8000870c:	2781                	sext.w	a5,a5
    8000870e:	e791                	bnez	a5,8000871a <sys_open+0x1f4>
    80008710:	f4c42783          	lw	a5,-180(s0)
    80008714:	8b89                	andi	a5,a5,2
    80008716:	2781                	sext.w	a5,a5
    80008718:	c399                	beqz	a5,8000871e <sys_open+0x1f8>
    8000871a:	4785                	li	a5,1
    8000871c:	a011                	j	80008720 <sys_open+0x1fa>
    8000871e:	4781                	li	a5,0
    80008720:	0ff7f713          	zext.b	a4,a5
    80008724:	fd843783          	ld	a5,-40(s0)
    80008728:	00e784a3          	sb	a4,9(a5)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000872c:	f4c42783          	lw	a5,-180(s0)
    80008730:	4007f793          	andi	a5,a5,1024
    80008734:	2781                	sext.w	a5,a5
    80008736:	c385                	beqz	a5,80008756 <sys_open+0x230>
    80008738:	fe843783          	ld	a5,-24(s0)
    8000873c:	04479783          	lh	a5,68(a5)
    80008740:	0007871b          	sext.w	a4,a5
    80008744:	4789                	li	a5,2
    80008746:	00f71863          	bne	a4,a5,80008756 <sys_open+0x230>
    itrunc(ip);
    8000874a:	fe843503          	ld	a0,-24(s0)
    8000874e:	ffffd097          	auipc	ra,0xffffd
    80008752:	17a080e7          	jalr	378(ra) # 800058c8 <itrunc>
  }

  iunlock(ip);
    80008756:	fe843503          	ld	a0,-24(s0)
    8000875a:	ffffd097          	auipc	ra,0xffffd
    8000875e:	e9a080e7          	jalr	-358(ra) # 800055f4 <iunlock>
  end_op();
    80008762:	ffffe097          	auipc	ra,0xffffe
    80008766:	eb8080e7          	jalr	-328(ra) # 8000661a <end_op>

  return fd;
    8000876a:	fd442783          	lw	a5,-44(s0)
}
    8000876e:	853e                	mv	a0,a5
    80008770:	70ea                	ld	ra,184(sp)
    80008772:	744a                	ld	s0,176(sp)
    80008774:	6129                	addi	sp,sp,192
    80008776:	8082                	ret

0000000080008778 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80008778:	7135                	addi	sp,sp,-160
    8000877a:	ed06                	sd	ra,152(sp)
    8000877c:	e922                	sd	s0,144(sp)
    8000877e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80008780:	ffffe097          	auipc	ra,0xffffe
    80008784:	dd8080e7          	jalr	-552(ra) # 80006558 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80008788:	f6840793          	addi	a5,s0,-152
    8000878c:	08000613          	li	a2,128
    80008790:	85be                	mv	a1,a5
    80008792:	4501                	li	a0,0
    80008794:	ffffc097          	auipc	ra,0xffffc
    80008798:	d58080e7          	jalr	-680(ra) # 800044ec <argstr>
    8000879c:	87aa                	mv	a5,a0
    8000879e:	0207c163          	bltz	a5,800087c0 <sys_mkdir+0x48>
    800087a2:	f6840793          	addi	a5,s0,-152
    800087a6:	4681                	li	a3,0
    800087a8:	4601                	li	a2,0
    800087aa:	4585                	li	a1,1
    800087ac:	853e                	mv	a0,a5
    800087ae:	00000097          	auipc	ra,0x0
    800087b2:	b46080e7          	jalr	-1210(ra) # 800082f4 <create>
    800087b6:	fea43423          	sd	a0,-24(s0)
    800087ba:	fe843783          	ld	a5,-24(s0)
    800087be:	e799                	bnez	a5,800087cc <sys_mkdir+0x54>
    end_op();
    800087c0:	ffffe097          	auipc	ra,0xffffe
    800087c4:	e5a080e7          	jalr	-422(ra) # 8000661a <end_op>
    return -1;
    800087c8:	57fd                	li	a5,-1
    800087ca:	a821                	j	800087e2 <sys_mkdir+0x6a>
  }
  iunlockput(ip);
    800087cc:	fe843503          	ld	a0,-24(s0)
    800087d0:	ffffd097          	auipc	ra,0xffffd
    800087d4:	f4e080e7          	jalr	-178(ra) # 8000571e <iunlockput>
  end_op();
    800087d8:	ffffe097          	auipc	ra,0xffffe
    800087dc:	e42080e7          	jalr	-446(ra) # 8000661a <end_op>
  return 0;
    800087e0:	4781                	li	a5,0
}
    800087e2:	853e                	mv	a0,a5
    800087e4:	60ea                	ld	ra,152(sp)
    800087e6:	644a                	ld	s0,144(sp)
    800087e8:	610d                	addi	sp,sp,160
    800087ea:	8082                	ret

00000000800087ec <sys_mknod>:

uint64
sys_mknod(void)
{
    800087ec:	7135                	addi	sp,sp,-160
    800087ee:	ed06                	sd	ra,152(sp)
    800087f0:	e922                	sd	s0,144(sp)
    800087f2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800087f4:	ffffe097          	auipc	ra,0xffffe
    800087f8:	d64080e7          	jalr	-668(ra) # 80006558 <begin_op>
  argint(1, &major);
    800087fc:	f6440793          	addi	a5,s0,-156
    80008800:	85be                	mv	a1,a5
    80008802:	4505                	li	a0,1
    80008804:	ffffc097          	auipc	ra,0xffffc
    80008808:	c80080e7          	jalr	-896(ra) # 80004484 <argint>
  argint(2, &minor);
    8000880c:	f6040793          	addi	a5,s0,-160
    80008810:	85be                	mv	a1,a5
    80008812:	4509                	li	a0,2
    80008814:	ffffc097          	auipc	ra,0xffffc
    80008818:	c70080e7          	jalr	-912(ra) # 80004484 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000881c:	f6840793          	addi	a5,s0,-152
    80008820:	08000613          	li	a2,128
    80008824:	85be                	mv	a1,a5
    80008826:	4501                	li	a0,0
    80008828:	ffffc097          	auipc	ra,0xffffc
    8000882c:	cc4080e7          	jalr	-828(ra) # 800044ec <argstr>
    80008830:	87aa                	mv	a5,a0
    80008832:	0207cc63          	bltz	a5,8000886a <sys_mknod+0x7e>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80008836:	f6442783          	lw	a5,-156(s0)
    8000883a:	0107971b          	slliw	a4,a5,0x10
    8000883e:	4107571b          	sraiw	a4,a4,0x10
    80008842:	f6042783          	lw	a5,-160(s0)
    80008846:	0107969b          	slliw	a3,a5,0x10
    8000884a:	4106d69b          	sraiw	a3,a3,0x10
    8000884e:	f6840793          	addi	a5,s0,-152
    80008852:	863a                	mv	a2,a4
    80008854:	458d                	li	a1,3
    80008856:	853e                	mv	a0,a5
    80008858:	00000097          	auipc	ra,0x0
    8000885c:	a9c080e7          	jalr	-1380(ra) # 800082f4 <create>
    80008860:	fea43423          	sd	a0,-24(s0)
  if((argstr(0, path, MAXPATH)) < 0 ||
    80008864:	fe843783          	ld	a5,-24(s0)
    80008868:	e799                	bnez	a5,80008876 <sys_mknod+0x8a>
    end_op();
    8000886a:	ffffe097          	auipc	ra,0xffffe
    8000886e:	db0080e7          	jalr	-592(ra) # 8000661a <end_op>
    return -1;
    80008872:	57fd                	li	a5,-1
    80008874:	a821                	j	8000888c <sys_mknod+0xa0>
  }
  iunlockput(ip);
    80008876:	fe843503          	ld	a0,-24(s0)
    8000887a:	ffffd097          	auipc	ra,0xffffd
    8000887e:	ea4080e7          	jalr	-348(ra) # 8000571e <iunlockput>
  end_op();
    80008882:	ffffe097          	auipc	ra,0xffffe
    80008886:	d98080e7          	jalr	-616(ra) # 8000661a <end_op>
  return 0;
    8000888a:	4781                	li	a5,0
}
    8000888c:	853e                	mv	a0,a5
    8000888e:	60ea                	ld	ra,152(sp)
    80008890:	644a                	ld	s0,144(sp)
    80008892:	610d                	addi	sp,sp,160
    80008894:	8082                	ret

0000000080008896 <sys_chdir>:

uint64
sys_chdir(void)
{
    80008896:	7135                	addi	sp,sp,-160
    80008898:	ed06                	sd	ra,152(sp)
    8000889a:	e922                	sd	s0,144(sp)
    8000889c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000889e:	ffffa097          	auipc	ra,0xffffa
    800088a2:	fa2080e7          	jalr	-94(ra) # 80002840 <myproc>
    800088a6:	fea43423          	sd	a0,-24(s0)
  
  begin_op();
    800088aa:	ffffe097          	auipc	ra,0xffffe
    800088ae:	cae080e7          	jalr	-850(ra) # 80006558 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800088b2:	f6040793          	addi	a5,s0,-160
    800088b6:	08000613          	li	a2,128
    800088ba:	85be                	mv	a1,a5
    800088bc:	4501                	li	a0,0
    800088be:	ffffc097          	auipc	ra,0xffffc
    800088c2:	c2e080e7          	jalr	-978(ra) # 800044ec <argstr>
    800088c6:	87aa                	mv	a5,a0
    800088c8:	0007ce63          	bltz	a5,800088e4 <sys_chdir+0x4e>
    800088cc:	f6040793          	addi	a5,s0,-160
    800088d0:	853e                	mv	a0,a5
    800088d2:	ffffe097          	auipc	ra,0xffffe
    800088d6:	922080e7          	jalr	-1758(ra) # 800061f4 <namei>
    800088da:	fea43023          	sd	a0,-32(s0)
    800088de:	fe043783          	ld	a5,-32(s0)
    800088e2:	e799                	bnez	a5,800088f0 <sys_chdir+0x5a>
    end_op();
    800088e4:	ffffe097          	auipc	ra,0xffffe
    800088e8:	d36080e7          	jalr	-714(ra) # 8000661a <end_op>
    return -1;
    800088ec:	57fd                	li	a5,-1
    800088ee:	a0b5                	j	8000895a <sys_chdir+0xc4>
  }
  ilock(ip);
    800088f0:	fe043503          	ld	a0,-32(s0)
    800088f4:	ffffd097          	auipc	ra,0xffffd
    800088f8:	bcc080e7          	jalr	-1076(ra) # 800054c0 <ilock>
  if(ip->type != T_DIR){
    800088fc:	fe043783          	ld	a5,-32(s0)
    80008900:	04479783          	lh	a5,68(a5)
    80008904:	0007871b          	sext.w	a4,a5
    80008908:	4785                	li	a5,1
    8000890a:	00f70e63          	beq	a4,a5,80008926 <sys_chdir+0x90>
    iunlockput(ip);
    8000890e:	fe043503          	ld	a0,-32(s0)
    80008912:	ffffd097          	auipc	ra,0xffffd
    80008916:	e0c080e7          	jalr	-500(ra) # 8000571e <iunlockput>
    end_op();
    8000891a:	ffffe097          	auipc	ra,0xffffe
    8000891e:	d00080e7          	jalr	-768(ra) # 8000661a <end_op>
    return -1;
    80008922:	57fd                	li	a5,-1
    80008924:	a81d                	j	8000895a <sys_chdir+0xc4>
  }
  iunlock(ip);
    80008926:	fe043503          	ld	a0,-32(s0)
    8000892a:	ffffd097          	auipc	ra,0xffffd
    8000892e:	cca080e7          	jalr	-822(ra) # 800055f4 <iunlock>
  iput(p->cwd);
    80008932:	fe843783          	ld	a5,-24(s0)
    80008936:	1507b783          	ld	a5,336(a5)
    8000893a:	853e                	mv	a0,a5
    8000893c:	ffffd097          	auipc	ra,0xffffd
    80008940:	d12080e7          	jalr	-750(ra) # 8000564e <iput>
  end_op();
    80008944:	ffffe097          	auipc	ra,0xffffe
    80008948:	cd6080e7          	jalr	-810(ra) # 8000661a <end_op>
  p->cwd = ip;
    8000894c:	fe843783          	ld	a5,-24(s0)
    80008950:	fe043703          	ld	a4,-32(s0)
    80008954:	14e7b823          	sd	a4,336(a5)
  return 0;
    80008958:	4781                	li	a5,0
}
    8000895a:	853e                	mv	a0,a5
    8000895c:	60ea                	ld	ra,152(sp)
    8000895e:	644a                	ld	s0,144(sp)
    80008960:	610d                	addi	sp,sp,160
    80008962:	8082                	ret

0000000080008964 <sys_exec>:

uint64
sys_exec(void)
{
    80008964:	7161                	addi	sp,sp,-432
    80008966:	f706                	sd	ra,424(sp)
    80008968:	f322                	sd	s0,416(sp)
    8000896a:	1b00                	addi	s0,sp,432
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000896c:	e6040793          	addi	a5,s0,-416
    80008970:	85be                	mv	a1,a5
    80008972:	4505                	li	a0,1
    80008974:	ffffc097          	auipc	ra,0xffffc
    80008978:	b46080e7          	jalr	-1210(ra) # 800044ba <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000897c:	f6840793          	addi	a5,s0,-152
    80008980:	08000613          	li	a2,128
    80008984:	85be                	mv	a1,a5
    80008986:	4501                	li	a0,0
    80008988:	ffffc097          	auipc	ra,0xffffc
    8000898c:	b64080e7          	jalr	-1180(ra) # 800044ec <argstr>
    80008990:	87aa                	mv	a5,a0
    80008992:	0007d463          	bgez	a5,8000899a <sys_exec+0x36>
    return -1;
    80008996:	57fd                	li	a5,-1
    80008998:	aa8d                	j	80008b0a <sys_exec+0x1a6>
  }
  memset(argv, 0, sizeof(argv));
    8000899a:	e6840793          	addi	a5,s0,-408
    8000899e:	10000613          	li	a2,256
    800089a2:	4581                	li	a1,0
    800089a4:	853e                	mv	a0,a5
    800089a6:	ffff9097          	auipc	ra,0xffff9
    800089aa:	aa6080e7          	jalr	-1370(ra) # 8000144c <memset>
  for(i=0;; i++){
    800089ae:	fe042623          	sw	zero,-20(s0)
    if(i >= NELEM(argv)){
    800089b2:	fec42783          	lw	a5,-20(s0)
    800089b6:	873e                	mv	a4,a5
    800089b8:	47fd                	li	a5,31
    800089ba:	0ee7ee63          	bltu	a5,a4,80008ab6 <sys_exec+0x152>
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800089be:	fec42783          	lw	a5,-20(s0)
    800089c2:	00379713          	slli	a4,a5,0x3
    800089c6:	e6043783          	ld	a5,-416(s0)
    800089ca:	97ba                	add	a5,a5,a4
    800089cc:	e5840713          	addi	a4,s0,-424
    800089d0:	85ba                	mv	a1,a4
    800089d2:	853e                	mv	a0,a5
    800089d4:	ffffc097          	auipc	ra,0xffffc
    800089d8:	93e080e7          	jalr	-1730(ra) # 80004312 <fetchaddr>
    800089dc:	87aa                	mv	a5,a0
    800089de:	0c07ce63          	bltz	a5,80008aba <sys_exec+0x156>
      goto bad;
    }
    if(uarg == 0){
    800089e2:	e5843783          	ld	a5,-424(s0)
    800089e6:	eb8d                	bnez	a5,80008a18 <sys_exec+0xb4>
      argv[i] = 0;
    800089e8:	fec42783          	lw	a5,-20(s0)
    800089ec:	078e                	slli	a5,a5,0x3
    800089ee:	17c1                	addi	a5,a5,-16
    800089f0:	97a2                	add	a5,a5,s0
    800089f2:	e607bc23          	sd	zero,-392(a5)
      break;
    800089f6:	0001                	nop
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
      goto bad;
  }

  int ret = exec(path, argv);
    800089f8:	e6840713          	addi	a4,s0,-408
    800089fc:	f6840793          	addi	a5,s0,-152
    80008a00:	85ba                	mv	a1,a4
    80008a02:	853e                	mv	a0,a5
    80008a04:	fffff097          	auipc	ra,0xfffff
    80008a08:	bf6080e7          	jalr	-1034(ra) # 800075fa <exec>
    80008a0c:	87aa                	mv	a5,a0
    80008a0e:	fef42423          	sw	a5,-24(s0)

  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80008a12:	fe042623          	sw	zero,-20(s0)
    80008a16:	a8bd                	j	80008a94 <sys_exec+0x130>
    argv[i] = kalloc();
    80008a18:	ffff8097          	auipc	ra,0xffff8
    80008a1c:	70c080e7          	jalr	1804(ra) # 80001124 <kalloc>
    80008a20:	872a                	mv	a4,a0
    80008a22:	fec42783          	lw	a5,-20(s0)
    80008a26:	078e                	slli	a5,a5,0x3
    80008a28:	17c1                	addi	a5,a5,-16
    80008a2a:	97a2                	add	a5,a5,s0
    80008a2c:	e6e7bc23          	sd	a4,-392(a5)
    if(argv[i] == 0)
    80008a30:	fec42783          	lw	a5,-20(s0)
    80008a34:	078e                	slli	a5,a5,0x3
    80008a36:	17c1                	addi	a5,a5,-16
    80008a38:	97a2                	add	a5,a5,s0
    80008a3a:	e787b783          	ld	a5,-392(a5)
    80008a3e:	c3c1                	beqz	a5,80008abe <sys_exec+0x15a>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80008a40:	e5843703          	ld	a4,-424(s0)
    80008a44:	fec42783          	lw	a5,-20(s0)
    80008a48:	078e                	slli	a5,a5,0x3
    80008a4a:	17c1                	addi	a5,a5,-16
    80008a4c:	97a2                	add	a5,a5,s0
    80008a4e:	e787b783          	ld	a5,-392(a5)
    80008a52:	6605                	lui	a2,0x1
    80008a54:	85be                	mv	a1,a5
    80008a56:	853a                	mv	a0,a4
    80008a58:	ffffc097          	auipc	ra,0xffffc
    80008a5c:	928080e7          	jalr	-1752(ra) # 80004380 <fetchstr>
    80008a60:	87aa                	mv	a5,a0
    80008a62:	0607c063          	bltz	a5,80008ac2 <sys_exec+0x15e>
  for(i=0;; i++){
    80008a66:	fec42783          	lw	a5,-20(s0)
    80008a6a:	2785                	addiw	a5,a5,1
    80008a6c:	fef42623          	sw	a5,-20(s0)
    if(i >= NELEM(argv)){
    80008a70:	b789                	j	800089b2 <sys_exec+0x4e>
    kfree(argv[i]);
    80008a72:	fec42783          	lw	a5,-20(s0)
    80008a76:	078e                	slli	a5,a5,0x3
    80008a78:	17c1                	addi	a5,a5,-16
    80008a7a:	97a2                	add	a5,a5,s0
    80008a7c:	e787b783          	ld	a5,-392(a5)
    80008a80:	853e                	mv	a0,a5
    80008a82:	ffff8097          	auipc	ra,0xffff8
    80008a86:	5fe080e7          	jalr	1534(ra) # 80001080 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80008a8a:	fec42783          	lw	a5,-20(s0)
    80008a8e:	2785                	addiw	a5,a5,1
    80008a90:	fef42623          	sw	a5,-20(s0)
    80008a94:	fec42783          	lw	a5,-20(s0)
    80008a98:	873e                	mv	a4,a5
    80008a9a:	47fd                	li	a5,31
    80008a9c:	00e7ea63          	bltu	a5,a4,80008ab0 <sys_exec+0x14c>
    80008aa0:	fec42783          	lw	a5,-20(s0)
    80008aa4:	078e                	slli	a5,a5,0x3
    80008aa6:	17c1                	addi	a5,a5,-16
    80008aa8:	97a2                	add	a5,a5,s0
    80008aaa:	e787b783          	ld	a5,-392(a5)
    80008aae:	f3f1                	bnez	a5,80008a72 <sys_exec+0x10e>

  return ret;
    80008ab0:	fe842783          	lw	a5,-24(s0)
    80008ab4:	a899                	j	80008b0a <sys_exec+0x1a6>
      goto bad;
    80008ab6:	0001                	nop
    80008ab8:	a031                	j	80008ac4 <sys_exec+0x160>
      goto bad;
    80008aba:	0001                	nop
    80008abc:	a021                	j	80008ac4 <sys_exec+0x160>
      goto bad;
    80008abe:	0001                	nop
    80008ac0:	a011                	j	80008ac4 <sys_exec+0x160>
      goto bad;
    80008ac2:	0001                	nop

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80008ac4:	fe042623          	sw	zero,-20(s0)
    80008ac8:	a015                	j	80008aec <sys_exec+0x188>
    kfree(argv[i]);
    80008aca:	fec42783          	lw	a5,-20(s0)
    80008ace:	078e                	slli	a5,a5,0x3
    80008ad0:	17c1                	addi	a5,a5,-16
    80008ad2:	97a2                	add	a5,a5,s0
    80008ad4:	e787b783          	ld	a5,-392(a5)
    80008ad8:	853e                	mv	a0,a5
    80008ada:	ffff8097          	auipc	ra,0xffff8
    80008ade:	5a6080e7          	jalr	1446(ra) # 80001080 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80008ae2:	fec42783          	lw	a5,-20(s0)
    80008ae6:	2785                	addiw	a5,a5,1
    80008ae8:	fef42623          	sw	a5,-20(s0)
    80008aec:	fec42783          	lw	a5,-20(s0)
    80008af0:	873e                	mv	a4,a5
    80008af2:	47fd                	li	a5,31
    80008af4:	00e7ea63          	bltu	a5,a4,80008b08 <sys_exec+0x1a4>
    80008af8:	fec42783          	lw	a5,-20(s0)
    80008afc:	078e                	slli	a5,a5,0x3
    80008afe:	17c1                	addi	a5,a5,-16
    80008b00:	97a2                	add	a5,a5,s0
    80008b02:	e787b783          	ld	a5,-392(a5)
    80008b06:	f3f1                	bnez	a5,80008aca <sys_exec+0x166>
  return -1;
    80008b08:	57fd                	li	a5,-1
}
    80008b0a:	853e                	mv	a0,a5
    80008b0c:	70ba                	ld	ra,424(sp)
    80008b0e:	741a                	ld	s0,416(sp)
    80008b10:	615d                	addi	sp,sp,432
    80008b12:	8082                	ret

0000000080008b14 <sys_pipe>:

uint64
sys_pipe(void)
{
    80008b14:	7139                	addi	sp,sp,-64
    80008b16:	fc06                	sd	ra,56(sp)
    80008b18:	f822                	sd	s0,48(sp)
    80008b1a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80008b1c:	ffffa097          	auipc	ra,0xffffa
    80008b20:	d24080e7          	jalr	-732(ra) # 80002840 <myproc>
    80008b24:	fea43423          	sd	a0,-24(s0)

  argaddr(0, &fdarray);
    80008b28:	fe040793          	addi	a5,s0,-32
    80008b2c:	85be                	mv	a1,a5
    80008b2e:	4501                	li	a0,0
    80008b30:	ffffc097          	auipc	ra,0xffffc
    80008b34:	98a080e7          	jalr	-1654(ra) # 800044ba <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80008b38:	fd040713          	addi	a4,s0,-48
    80008b3c:	fd840793          	addi	a5,s0,-40
    80008b40:	85ba                	mv	a1,a4
    80008b42:	853e                	mv	a0,a5
    80008b44:	ffffe097          	auipc	ra,0xffffe
    80008b48:	5d0080e7          	jalr	1488(ra) # 80007114 <pipealloc>
    80008b4c:	87aa                	mv	a5,a0
    80008b4e:	0007d463          	bgez	a5,80008b56 <sys_pipe+0x42>
    return -1;
    80008b52:	57fd                	li	a5,-1
    80008b54:	a219                	j	80008c5a <sys_pipe+0x146>
  fd0 = -1;
    80008b56:	57fd                	li	a5,-1
    80008b58:	fcf42623          	sw	a5,-52(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80008b5c:	fd843783          	ld	a5,-40(s0)
    80008b60:	853e                	mv	a0,a5
    80008b62:	fffff097          	auipc	ra,0xfffff
    80008b66:	0c6080e7          	jalr	198(ra) # 80007c28 <fdalloc>
    80008b6a:	87aa                	mv	a5,a0
    80008b6c:	fcf42623          	sw	a5,-52(s0)
    80008b70:	fcc42783          	lw	a5,-52(s0)
    80008b74:	0207c063          	bltz	a5,80008b94 <sys_pipe+0x80>
    80008b78:	fd043783          	ld	a5,-48(s0)
    80008b7c:	853e                	mv	a0,a5
    80008b7e:	fffff097          	auipc	ra,0xfffff
    80008b82:	0aa080e7          	jalr	170(ra) # 80007c28 <fdalloc>
    80008b86:	87aa                	mv	a5,a0
    80008b88:	fcf42423          	sw	a5,-56(s0)
    80008b8c:	fc842783          	lw	a5,-56(s0)
    80008b90:	0207df63          	bgez	a5,80008bce <sys_pipe+0xba>
    if(fd0 >= 0)
    80008b94:	fcc42783          	lw	a5,-52(s0)
    80008b98:	0007cb63          	bltz	a5,80008bae <sys_pipe+0x9a>
      p->ofile[fd0] = 0;
    80008b9c:	fcc42783          	lw	a5,-52(s0)
    80008ba0:	fe843703          	ld	a4,-24(s0)
    80008ba4:	07e9                	addi	a5,a5,26
    80008ba6:	078e                	slli	a5,a5,0x3
    80008ba8:	97ba                	add	a5,a5,a4
    80008baa:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80008bae:	fd843783          	ld	a5,-40(s0)
    80008bb2:	853e                	mv	a0,a5
    80008bb4:	ffffe097          	auipc	ra,0xffffe
    80008bb8:	03e080e7          	jalr	62(ra) # 80006bf2 <fileclose>
    fileclose(wf);
    80008bbc:	fd043783          	ld	a5,-48(s0)
    80008bc0:	853e                	mv	a0,a5
    80008bc2:	ffffe097          	auipc	ra,0xffffe
    80008bc6:	030080e7          	jalr	48(ra) # 80006bf2 <fileclose>
    return -1;
    80008bca:	57fd                	li	a5,-1
    80008bcc:	a079                	j	80008c5a <sys_pipe+0x146>
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80008bce:	fe843783          	ld	a5,-24(s0)
    80008bd2:	6bbc                	ld	a5,80(a5)
    80008bd4:	fe043703          	ld	a4,-32(s0)
    80008bd8:	fcc40613          	addi	a2,s0,-52
    80008bdc:	4691                	li	a3,4
    80008bde:	85ba                	mv	a1,a4
    80008be0:	853e                	mv	a0,a5
    80008be2:	ffff9097          	auipc	ra,0xffff9
    80008be6:	728080e7          	jalr	1832(ra) # 8000230a <copyout>
    80008bea:	87aa                	mv	a5,a0
    80008bec:	0207c463          	bltz	a5,80008c14 <sys_pipe+0x100>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80008bf0:	fe843783          	ld	a5,-24(s0)
    80008bf4:	6bb8                	ld	a4,80(a5)
    80008bf6:	fe043783          	ld	a5,-32(s0)
    80008bfa:	0791                	addi	a5,a5,4
    80008bfc:	fc840613          	addi	a2,s0,-56
    80008c00:	4691                	li	a3,4
    80008c02:	85be                	mv	a1,a5
    80008c04:	853a                	mv	a0,a4
    80008c06:	ffff9097          	auipc	ra,0xffff9
    80008c0a:	704080e7          	jalr	1796(ra) # 8000230a <copyout>
    80008c0e:	87aa                	mv	a5,a0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80008c10:	0407d463          	bgez	a5,80008c58 <sys_pipe+0x144>
    p->ofile[fd0] = 0;
    80008c14:	fcc42783          	lw	a5,-52(s0)
    80008c18:	fe843703          	ld	a4,-24(s0)
    80008c1c:	07e9                	addi	a5,a5,26
    80008c1e:	078e                	slli	a5,a5,0x3
    80008c20:	97ba                	add	a5,a5,a4
    80008c22:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80008c26:	fc842783          	lw	a5,-56(s0)
    80008c2a:	fe843703          	ld	a4,-24(s0)
    80008c2e:	07e9                	addi	a5,a5,26
    80008c30:	078e                	slli	a5,a5,0x3
    80008c32:	97ba                	add	a5,a5,a4
    80008c34:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80008c38:	fd843783          	ld	a5,-40(s0)
    80008c3c:	853e                	mv	a0,a5
    80008c3e:	ffffe097          	auipc	ra,0xffffe
    80008c42:	fb4080e7          	jalr	-76(ra) # 80006bf2 <fileclose>
    fileclose(wf);
    80008c46:	fd043783          	ld	a5,-48(s0)
    80008c4a:	853e                	mv	a0,a5
    80008c4c:	ffffe097          	auipc	ra,0xffffe
    80008c50:	fa6080e7          	jalr	-90(ra) # 80006bf2 <fileclose>
    return -1;
    80008c54:	57fd                	li	a5,-1
    80008c56:	a011                	j	80008c5a <sys_pipe+0x146>
  }
  return 0;
    80008c58:	4781                	li	a5,0
}
    80008c5a:	853e                	mv	a0,a5
    80008c5c:	70e2                	ld	ra,56(sp)
    80008c5e:	7442                	ld	s0,48(sp)
    80008c60:	6121                	addi	sp,sp,64
    80008c62:	8082                	ret
	...

0000000080008c70 <kernelvec>:
    80008c70:	7111                	addi	sp,sp,-256
    80008c72:	e006                	sd	ra,0(sp)
    80008c74:	e40a                	sd	sp,8(sp)
    80008c76:	e80e                	sd	gp,16(sp)
    80008c78:	ec12                	sd	tp,24(sp)
    80008c7a:	f016                	sd	t0,32(sp)
    80008c7c:	f41a                	sd	t1,40(sp)
    80008c7e:	f81e                	sd	t2,48(sp)
    80008c80:	fc22                	sd	s0,56(sp)
    80008c82:	e0a6                	sd	s1,64(sp)
    80008c84:	e4aa                	sd	a0,72(sp)
    80008c86:	e8ae                	sd	a1,80(sp)
    80008c88:	ecb2                	sd	a2,88(sp)
    80008c8a:	f0b6                	sd	a3,96(sp)
    80008c8c:	f4ba                	sd	a4,104(sp)
    80008c8e:	f8be                	sd	a5,112(sp)
    80008c90:	fcc2                	sd	a6,120(sp)
    80008c92:	e146                	sd	a7,128(sp)
    80008c94:	e54a                	sd	s2,136(sp)
    80008c96:	e94e                	sd	s3,144(sp)
    80008c98:	ed52                	sd	s4,152(sp)
    80008c9a:	f156                	sd	s5,160(sp)
    80008c9c:	f55a                	sd	s6,168(sp)
    80008c9e:	f95e                	sd	s7,176(sp)
    80008ca0:	fd62                	sd	s8,184(sp)
    80008ca2:	e1e6                	sd	s9,192(sp)
    80008ca4:	e5ea                	sd	s10,200(sp)
    80008ca6:	e9ee                	sd	s11,208(sp)
    80008ca8:	edf2                	sd	t3,216(sp)
    80008caa:	f1f6                	sd	t4,224(sp)
    80008cac:	f5fa                	sd	t5,232(sp)
    80008cae:	f9fe                	sd	t6,240(sp)
    80008cb0:	bfafb0ef          	jal	ra,800040aa <kerneltrap>
    80008cb4:	6082                	ld	ra,0(sp)
    80008cb6:	6122                	ld	sp,8(sp)
    80008cb8:	61c2                	ld	gp,16(sp)
    80008cba:	7282                	ld	t0,32(sp)
    80008cbc:	7322                	ld	t1,40(sp)
    80008cbe:	73c2                	ld	t2,48(sp)
    80008cc0:	7462                	ld	s0,56(sp)
    80008cc2:	6486                	ld	s1,64(sp)
    80008cc4:	6526                	ld	a0,72(sp)
    80008cc6:	65c6                	ld	a1,80(sp)
    80008cc8:	6666                	ld	a2,88(sp)
    80008cca:	7686                	ld	a3,96(sp)
    80008ccc:	7726                	ld	a4,104(sp)
    80008cce:	77c6                	ld	a5,112(sp)
    80008cd0:	7866                	ld	a6,120(sp)
    80008cd2:	688a                	ld	a7,128(sp)
    80008cd4:	692a                	ld	s2,136(sp)
    80008cd6:	69ca                	ld	s3,144(sp)
    80008cd8:	6a6a                	ld	s4,152(sp)
    80008cda:	7a8a                	ld	s5,160(sp)
    80008cdc:	7b2a                	ld	s6,168(sp)
    80008cde:	7bca                	ld	s7,176(sp)
    80008ce0:	7c6a                	ld	s8,184(sp)
    80008ce2:	6c8e                	ld	s9,192(sp)
    80008ce4:	6d2e                	ld	s10,200(sp)
    80008ce6:	6dce                	ld	s11,208(sp)
    80008ce8:	6e6e                	ld	t3,216(sp)
    80008cea:	7e8e                	ld	t4,224(sp)
    80008cec:	7f2e                	ld	t5,232(sp)
    80008cee:	7fce                	ld	t6,240(sp)
    80008cf0:	6111                	addi	sp,sp,256
    80008cf2:	10200073          	sret
    80008cf6:	00000013          	nop
    80008cfa:	00000013          	nop
    80008cfe:	0001                	nop

0000000080008d00 <timervec>:
    80008d00:	34051573          	csrrw	a0,mscratch,a0
    80008d04:	e10c                	sd	a1,0(a0)
    80008d06:	e510                	sd	a2,8(a0)
    80008d08:	e914                	sd	a3,16(a0)
    80008d0a:	6d0c                	ld	a1,24(a0)
    80008d0c:	7110                	ld	a2,32(a0)
    80008d0e:	6194                	ld	a3,0(a1)
    80008d10:	96b2                	add	a3,a3,a2
    80008d12:	e194                	sd	a3,0(a1)
    80008d14:	4589                	li	a1,2
    80008d16:	14459073          	csrw	sip,a1
    80008d1a:	6914                	ld	a3,16(a0)
    80008d1c:	6510                	ld	a2,8(a0)
    80008d1e:	610c                	ld	a1,0(a0)
    80008d20:	34051573          	csrrw	a0,mscratch,a0
    80008d24:	30200073          	mret
	...

0000000080008d2a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80008d2a:	1141                	addi	sp,sp,-16
    80008d2c:	e422                	sd	s0,8(sp)
    80008d2e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80008d30:	0c0007b7          	lui	a5,0xc000
    80008d34:	02878793          	addi	a5,a5,40 # c000028 <_entry-0x73ffffd8>
    80008d38:	4705                	li	a4,1
    80008d3a:	c398                	sw	a4,0(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80008d3c:	0c0007b7          	lui	a5,0xc000
    80008d40:	0791                	addi	a5,a5,4 # c000004 <_entry-0x73fffffc>
    80008d42:	4705                	li	a4,1
    80008d44:	c398                	sw	a4,0(a5)
}
    80008d46:	0001                	nop
    80008d48:	6422                	ld	s0,8(sp)
    80008d4a:	0141                	addi	sp,sp,16
    80008d4c:	8082                	ret

0000000080008d4e <plicinithart>:

void
plicinithart(void)
{
    80008d4e:	1101                	addi	sp,sp,-32
    80008d50:	ec06                	sd	ra,24(sp)
    80008d52:	e822                	sd	s0,16(sp)
    80008d54:	1000                	addi	s0,sp,32
  int hart = cpuid();
    80008d56:	ffffa097          	auipc	ra,0xffffa
    80008d5a:	a8c080e7          	jalr	-1396(ra) # 800027e2 <cpuid>
    80008d5e:	87aa                	mv	a5,a0
    80008d60:	fef42623          	sw	a5,-20(s0)
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80008d64:	fec42783          	lw	a5,-20(s0)
    80008d68:	0087979b          	slliw	a5,a5,0x8
    80008d6c:	2781                	sext.w	a5,a5
    80008d6e:	873e                	mv	a4,a5
    80008d70:	0c0027b7          	lui	a5,0xc002
    80008d74:	08078793          	addi	a5,a5,128 # c002080 <_entry-0x73ffdf80>
    80008d78:	97ba                	add	a5,a5,a4
    80008d7a:	873e                	mv	a4,a5
    80008d7c:	40200793          	li	a5,1026
    80008d80:	c31c                	sw	a5,0(a4)

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80008d82:	fec42783          	lw	a5,-20(s0)
    80008d86:	00d7979b          	slliw	a5,a5,0xd
    80008d8a:	2781                	sext.w	a5,a5
    80008d8c:	873e                	mv	a4,a5
    80008d8e:	0c2017b7          	lui	a5,0xc201
    80008d92:	97ba                	add	a5,a5,a4
    80008d94:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80008d98:	0001                	nop
    80008d9a:	60e2                	ld	ra,24(sp)
    80008d9c:	6442                	ld	s0,16(sp)
    80008d9e:	6105                	addi	sp,sp,32
    80008da0:	8082                	ret

0000000080008da2 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80008da2:	1101                	addi	sp,sp,-32
    80008da4:	ec06                	sd	ra,24(sp)
    80008da6:	e822                	sd	s0,16(sp)
    80008da8:	1000                	addi	s0,sp,32
  int hart = cpuid();
    80008daa:	ffffa097          	auipc	ra,0xffffa
    80008dae:	a38080e7          	jalr	-1480(ra) # 800027e2 <cpuid>
    80008db2:	87aa                	mv	a5,a0
    80008db4:	fef42623          	sw	a5,-20(s0)
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80008db8:	fec42783          	lw	a5,-20(s0)
    80008dbc:	00d7979b          	slliw	a5,a5,0xd
    80008dc0:	2781                	sext.w	a5,a5
    80008dc2:	873e                	mv	a4,a5
    80008dc4:	0c2017b7          	lui	a5,0xc201
    80008dc8:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80008dca:	97ba                	add	a5,a5,a4
    80008dcc:	439c                	lw	a5,0(a5)
    80008dce:	fef42423          	sw	a5,-24(s0)
  return irq;
    80008dd2:	fe842783          	lw	a5,-24(s0)
}
    80008dd6:	853e                	mv	a0,a5
    80008dd8:	60e2                	ld	ra,24(sp)
    80008dda:	6442                	ld	s0,16(sp)
    80008ddc:	6105                	addi	sp,sp,32
    80008dde:	8082                	ret

0000000080008de0 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80008de0:	7179                	addi	sp,sp,-48
    80008de2:	f406                	sd	ra,40(sp)
    80008de4:	f022                	sd	s0,32(sp)
    80008de6:	1800                	addi	s0,sp,48
    80008de8:	87aa                	mv	a5,a0
    80008dea:	fcf42e23          	sw	a5,-36(s0)
  int hart = cpuid();
    80008dee:	ffffa097          	auipc	ra,0xffffa
    80008df2:	9f4080e7          	jalr	-1548(ra) # 800027e2 <cpuid>
    80008df6:	87aa                	mv	a5,a0
    80008df8:	fef42623          	sw	a5,-20(s0)
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80008dfc:	fec42783          	lw	a5,-20(s0)
    80008e00:	00d7979b          	slliw	a5,a5,0xd
    80008e04:	2781                	sext.w	a5,a5
    80008e06:	873e                	mv	a4,a5
    80008e08:	0c2017b7          	lui	a5,0xc201
    80008e0c:	0791                	addi	a5,a5,4 # c201004 <_entry-0x73dfeffc>
    80008e0e:	97ba                	add	a5,a5,a4
    80008e10:	873e                	mv	a4,a5
    80008e12:	fdc42783          	lw	a5,-36(s0)
    80008e16:	c31c                	sw	a5,0(a4)
}
    80008e18:	0001                	nop
    80008e1a:	70a2                	ld	ra,40(sp)
    80008e1c:	7402                	ld	s0,32(sp)
    80008e1e:	6145                	addi	sp,sp,48
    80008e20:	8082                	ret

0000000080008e22 <virtio_disk_init>:
  
} disk;

void
virtio_disk_init(void)
{
    80008e22:	7179                	addi	sp,sp,-48
    80008e24:	f406                	sd	ra,40(sp)
    80008e26:	f022                	sd	s0,32(sp)
    80008e28:	1800                	addi	s0,sp,48
  uint32 status = 0;
    80008e2a:	fe042423          	sw	zero,-24(s0)

  initlock(&disk.vdisk_lock, "virtio_disk");
    80008e2e:	00003597          	auipc	a1,0x3
    80008e32:	85a58593          	addi	a1,a1,-1958 # 8000b688 <etext+0x688>
    80008e36:	0001c517          	auipc	a0,0x1c
    80008e3a:	f6a50513          	addi	a0,a0,-150 # 80024da0 <disk+0x128>
    80008e3e:	ffff8097          	auipc	ra,0xffff8
    80008e42:	40a080e7          	jalr	1034(ra) # 80001248 <initlock>

  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80008e46:	100017b7          	lui	a5,0x10001
    80008e4a:	439c                	lw	a5,0(a5)
    80008e4c:	2781                	sext.w	a5,a5
    80008e4e:	873e                	mv	a4,a5
    80008e50:	747277b7          	lui	a5,0x74727
    80008e54:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80008e58:	04f71063          	bne	a4,a5,80008e98 <virtio_disk_init+0x76>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80008e5c:	100017b7          	lui	a5,0x10001
    80008e60:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80008e62:	439c                	lw	a5,0(a5)
    80008e64:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80008e66:	873e                	mv	a4,a5
    80008e68:	4789                	li	a5,2
    80008e6a:	02f71763          	bne	a4,a5,80008e98 <virtio_disk_init+0x76>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80008e6e:	100017b7          	lui	a5,0x10001
    80008e72:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80008e74:	439c                	lw	a5,0(a5)
    80008e76:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80008e78:	873e                	mv	a4,a5
    80008e7a:	4789                	li	a5,2
    80008e7c:	00f71e63          	bne	a4,a5,80008e98 <virtio_disk_init+0x76>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80008e80:	100017b7          	lui	a5,0x10001
    80008e84:	07b1                	addi	a5,a5,12 # 1000100c <_entry-0x6fffeff4>
    80008e86:	439c                	lw	a5,0(a5)
    80008e88:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80008e8a:	873e                	mv	a4,a5
    80008e8c:	554d47b7          	lui	a5,0x554d4
    80008e90:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80008e94:	00f70a63          	beq	a4,a5,80008ea8 <virtio_disk_init+0x86>
    panic("could not find virtio disk");
    80008e98:	00003517          	auipc	a0,0x3
    80008e9c:	80050513          	addi	a0,a0,-2048 # 8000b698 <etext+0x698>
    80008ea0:	ffff8097          	auipc	ra,0xffff8
    80008ea4:	dea080e7          	jalr	-534(ra) # 80000c8a <panic>
  }
  
  // reset device
  *R(VIRTIO_MMIO_STATUS) = status;
    80008ea8:	100017b7          	lui	a5,0x10001
    80008eac:	07078793          	addi	a5,a5,112 # 10001070 <_entry-0x6fffef90>
    80008eb0:	fe842703          	lw	a4,-24(s0)
    80008eb4:	c398                	sw	a4,0(a5)

  // set ACKNOWLEDGE status bit
  status |= VIRTIO_CONFIG_S_ACKNOWLEDGE;
    80008eb6:	fe842783          	lw	a5,-24(s0)
    80008eba:	0017e793          	ori	a5,a5,1
    80008ebe:	fef42423          	sw	a5,-24(s0)
  *R(VIRTIO_MMIO_STATUS) = status;
    80008ec2:	100017b7          	lui	a5,0x10001
    80008ec6:	07078793          	addi	a5,a5,112 # 10001070 <_entry-0x6fffef90>
    80008eca:	fe842703          	lw	a4,-24(s0)
    80008ece:	c398                	sw	a4,0(a5)

  // set DRIVER status bit
  status |= VIRTIO_CONFIG_S_DRIVER;
    80008ed0:	fe842783          	lw	a5,-24(s0)
    80008ed4:	0027e793          	ori	a5,a5,2
    80008ed8:	fef42423          	sw	a5,-24(s0)
  *R(VIRTIO_MMIO_STATUS) = status;
    80008edc:	100017b7          	lui	a5,0x10001
    80008ee0:	07078793          	addi	a5,a5,112 # 10001070 <_entry-0x6fffef90>
    80008ee4:	fe842703          	lw	a4,-24(s0)
    80008ee8:	c398                	sw	a4,0(a5)

  // negotiate features
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80008eea:	100017b7          	lui	a5,0x10001
    80008eee:	07c1                	addi	a5,a5,16 # 10001010 <_entry-0x6fffeff0>
    80008ef0:	439c                	lw	a5,0(a5)
    80008ef2:	2781                	sext.w	a5,a5
    80008ef4:	1782                	slli	a5,a5,0x20
    80008ef6:	9381                	srli	a5,a5,0x20
    80008ef8:	fef43023          	sd	a5,-32(s0)
  features &= ~(1 << VIRTIO_BLK_F_RO);
    80008efc:	fe043783          	ld	a5,-32(s0)
    80008f00:	fdf7f793          	andi	a5,a5,-33
    80008f04:	fef43023          	sd	a5,-32(s0)
  features &= ~(1 << VIRTIO_BLK_F_SCSI);
    80008f08:	fe043783          	ld	a5,-32(s0)
    80008f0c:	f7f7f793          	andi	a5,a5,-129
    80008f10:	fef43023          	sd	a5,-32(s0)
  features &= ~(1 << VIRTIO_BLK_F_CONFIG_WCE);
    80008f14:	fe043703          	ld	a4,-32(s0)
    80008f18:	77fd                	lui	a5,0xfffff
    80008f1a:	7ff78793          	addi	a5,a5,2047 # fffffffffffff7ff <end+0xffffffff7ffdaa47>
    80008f1e:	8ff9                	and	a5,a5,a4
    80008f20:	fef43023          	sd	a5,-32(s0)
  features &= ~(1 << VIRTIO_BLK_F_MQ);
    80008f24:	fe043703          	ld	a4,-32(s0)
    80008f28:	77fd                	lui	a5,0xfffff
    80008f2a:	17fd                	addi	a5,a5,-1 # ffffffffffffefff <end+0xffffffff7ffda247>
    80008f2c:	8ff9                	and	a5,a5,a4
    80008f2e:	fef43023          	sd	a5,-32(s0)
  features &= ~(1 << VIRTIO_F_ANY_LAYOUT);
    80008f32:	fe043703          	ld	a4,-32(s0)
    80008f36:	f80007b7          	lui	a5,0xf8000
    80008f3a:	17fd                	addi	a5,a5,-1 # fffffffff7ffffff <end+0xffffffff77fdb247>
    80008f3c:	8ff9                	and	a5,a5,a4
    80008f3e:	fef43023          	sd	a5,-32(s0)
  features &= ~(1 << VIRTIO_RING_F_EVENT_IDX);
    80008f42:	fe043703          	ld	a4,-32(s0)
    80008f46:	e00007b7          	lui	a5,0xe0000
    80008f4a:	17fd                	addi	a5,a5,-1 # ffffffffdfffffff <end+0xffffffff5ffdb247>
    80008f4c:	8ff9                	and	a5,a5,a4
    80008f4e:	fef43023          	sd	a5,-32(s0)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80008f52:	fe043703          	ld	a4,-32(s0)
    80008f56:	f00007b7          	lui	a5,0xf0000
    80008f5a:	17fd                	addi	a5,a5,-1 # ffffffffefffffff <end+0xffffffff6ffdb247>
    80008f5c:	8ff9                	and	a5,a5,a4
    80008f5e:	fef43023          	sd	a5,-32(s0)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80008f62:	100017b7          	lui	a5,0x10001
    80008f66:	02078793          	addi	a5,a5,32 # 10001020 <_entry-0x6fffefe0>
    80008f6a:	fe043703          	ld	a4,-32(s0)
    80008f6e:	2701                	sext.w	a4,a4
    80008f70:	c398                	sw	a4,0(a5)

  // tell device that feature negotiation is complete.
  status |= VIRTIO_CONFIG_S_FEATURES_OK;
    80008f72:	fe842783          	lw	a5,-24(s0)
    80008f76:	0087e793          	ori	a5,a5,8
    80008f7a:	fef42423          	sw	a5,-24(s0)
  *R(VIRTIO_MMIO_STATUS) = status;
    80008f7e:	100017b7          	lui	a5,0x10001
    80008f82:	07078793          	addi	a5,a5,112 # 10001070 <_entry-0x6fffef90>
    80008f86:	fe842703          	lw	a4,-24(s0)
    80008f8a:	c398                	sw	a4,0(a5)

  // re-read status to ensure FEATURES_OK is set.
  status = *R(VIRTIO_MMIO_STATUS);
    80008f8c:	100017b7          	lui	a5,0x10001
    80008f90:	07078793          	addi	a5,a5,112 # 10001070 <_entry-0x6fffef90>
    80008f94:	439c                	lw	a5,0(a5)
    80008f96:	fef42423          	sw	a5,-24(s0)
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80008f9a:	fe842783          	lw	a5,-24(s0)
    80008f9e:	8ba1                	andi	a5,a5,8
    80008fa0:	2781                	sext.w	a5,a5
    80008fa2:	eb89                	bnez	a5,80008fb4 <virtio_disk_init+0x192>
    panic("virtio disk FEATURES_OK unset");
    80008fa4:	00002517          	auipc	a0,0x2
    80008fa8:	71450513          	addi	a0,a0,1812 # 8000b6b8 <etext+0x6b8>
    80008fac:	ffff8097          	auipc	ra,0xffff8
    80008fb0:	cde080e7          	jalr	-802(ra) # 80000c8a <panic>

  // initialize queue 0.
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80008fb4:	100017b7          	lui	a5,0x10001
    80008fb8:	03078793          	addi	a5,a5,48 # 10001030 <_entry-0x6fffefd0>
    80008fbc:	0007a023          	sw	zero,0(a5)

  // ensure queue 0 is not in use.
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80008fc0:	100017b7          	lui	a5,0x10001
    80008fc4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80008fc8:	439c                	lw	a5,0(a5)
    80008fca:	2781                	sext.w	a5,a5
    80008fcc:	cb89                	beqz	a5,80008fde <virtio_disk_init+0x1bc>
    panic("virtio disk should not be ready");
    80008fce:	00002517          	auipc	a0,0x2
    80008fd2:	70a50513          	addi	a0,a0,1802 # 8000b6d8 <etext+0x6d8>
    80008fd6:	ffff8097          	auipc	ra,0xffff8
    80008fda:	cb4080e7          	jalr	-844(ra) # 80000c8a <panic>

  // check maximum queue size.
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80008fde:	100017b7          	lui	a5,0x10001
    80008fe2:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80008fe6:	439c                	lw	a5,0(a5)
    80008fe8:	fcf42e23          	sw	a5,-36(s0)
  if(max == 0)
    80008fec:	fdc42783          	lw	a5,-36(s0)
    80008ff0:	2781                	sext.w	a5,a5
    80008ff2:	eb89                	bnez	a5,80009004 <virtio_disk_init+0x1e2>
    panic("virtio disk has no queue 0");
    80008ff4:	00002517          	auipc	a0,0x2
    80008ff8:	70450513          	addi	a0,a0,1796 # 8000b6f8 <etext+0x6f8>
    80008ffc:	ffff8097          	auipc	ra,0xffff8
    80009000:	c8e080e7          	jalr	-882(ra) # 80000c8a <panic>
  if(max < NUM)
    80009004:	fdc42783          	lw	a5,-36(s0)
    80009008:	0007871b          	sext.w	a4,a5
    8000900c:	479d                	li	a5,7
    8000900e:	00e7ea63          	bltu	a5,a4,80009022 <virtio_disk_init+0x200>
    panic("virtio disk max queue too short");
    80009012:	00002517          	auipc	a0,0x2
    80009016:	70650513          	addi	a0,a0,1798 # 8000b718 <etext+0x718>
    8000901a:	ffff8097          	auipc	ra,0xffff8
    8000901e:	c70080e7          	jalr	-912(ra) # 80000c8a <panic>

  // allocate and zero queue memory.
  disk.desc = kalloc();
    80009022:	ffff8097          	auipc	ra,0xffff8
    80009026:	102080e7          	jalr	258(ra) # 80001124 <kalloc>
    8000902a:	872a                	mv	a4,a0
    8000902c:	0001c797          	auipc	a5,0x1c
    80009030:	c4c78793          	addi	a5,a5,-948 # 80024c78 <disk>
    80009034:	e398                	sd	a4,0(a5)
  disk.avail = kalloc();
    80009036:	ffff8097          	auipc	ra,0xffff8
    8000903a:	0ee080e7          	jalr	238(ra) # 80001124 <kalloc>
    8000903e:	872a                	mv	a4,a0
    80009040:	0001c797          	auipc	a5,0x1c
    80009044:	c3878793          	addi	a5,a5,-968 # 80024c78 <disk>
    80009048:	e798                	sd	a4,8(a5)
  disk.used = kalloc();
    8000904a:	ffff8097          	auipc	ra,0xffff8
    8000904e:	0da080e7          	jalr	218(ra) # 80001124 <kalloc>
    80009052:	872a                	mv	a4,a0
    80009054:	0001c797          	auipc	a5,0x1c
    80009058:	c2478793          	addi	a5,a5,-988 # 80024c78 <disk>
    8000905c:	eb98                	sd	a4,16(a5)
  if(!disk.desc || !disk.avail || !disk.used)
    8000905e:	0001c797          	auipc	a5,0x1c
    80009062:	c1a78793          	addi	a5,a5,-998 # 80024c78 <disk>
    80009066:	639c                	ld	a5,0(a5)
    80009068:	cf89                	beqz	a5,80009082 <virtio_disk_init+0x260>
    8000906a:	0001c797          	auipc	a5,0x1c
    8000906e:	c0e78793          	addi	a5,a5,-1010 # 80024c78 <disk>
    80009072:	679c                	ld	a5,8(a5)
    80009074:	c799                	beqz	a5,80009082 <virtio_disk_init+0x260>
    80009076:	0001c797          	auipc	a5,0x1c
    8000907a:	c0278793          	addi	a5,a5,-1022 # 80024c78 <disk>
    8000907e:	6b9c                	ld	a5,16(a5)
    80009080:	eb89                	bnez	a5,80009092 <virtio_disk_init+0x270>
    panic("virtio disk kalloc");
    80009082:	00002517          	auipc	a0,0x2
    80009086:	6b650513          	addi	a0,a0,1718 # 8000b738 <etext+0x738>
    8000908a:	ffff8097          	auipc	ra,0xffff8
    8000908e:	c00080e7          	jalr	-1024(ra) # 80000c8a <panic>
  memset(disk.desc, 0, PGSIZE);
    80009092:	0001c797          	auipc	a5,0x1c
    80009096:	be678793          	addi	a5,a5,-1050 # 80024c78 <disk>
    8000909a:	639c                	ld	a5,0(a5)
    8000909c:	6605                	lui	a2,0x1
    8000909e:	4581                	li	a1,0
    800090a0:	853e                	mv	a0,a5
    800090a2:	ffff8097          	auipc	ra,0xffff8
    800090a6:	3aa080e7          	jalr	938(ra) # 8000144c <memset>
  memset(disk.avail, 0, PGSIZE);
    800090aa:	0001c797          	auipc	a5,0x1c
    800090ae:	bce78793          	addi	a5,a5,-1074 # 80024c78 <disk>
    800090b2:	679c                	ld	a5,8(a5)
    800090b4:	6605                	lui	a2,0x1
    800090b6:	4581                	li	a1,0
    800090b8:	853e                	mv	a0,a5
    800090ba:	ffff8097          	auipc	ra,0xffff8
    800090be:	392080e7          	jalr	914(ra) # 8000144c <memset>
  memset(disk.used, 0, PGSIZE);
    800090c2:	0001c797          	auipc	a5,0x1c
    800090c6:	bb678793          	addi	a5,a5,-1098 # 80024c78 <disk>
    800090ca:	6b9c                	ld	a5,16(a5)
    800090cc:	6605                	lui	a2,0x1
    800090ce:	4581                	li	a1,0
    800090d0:	853e                	mv	a0,a5
    800090d2:	ffff8097          	auipc	ra,0xffff8
    800090d6:	37a080e7          	jalr	890(ra) # 8000144c <memset>

  // set queue size.
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800090da:	100017b7          	lui	a5,0x10001
    800090de:	03878793          	addi	a5,a5,56 # 10001038 <_entry-0x6fffefc8>
    800090e2:	4721                	li	a4,8
    800090e4:	c398                	sw	a4,0(a5)

  // write physical addresses.
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800090e6:	0001c797          	auipc	a5,0x1c
    800090ea:	b9278793          	addi	a5,a5,-1134 # 80024c78 <disk>
    800090ee:	639c                	ld	a5,0(a5)
    800090f0:	873e                	mv	a4,a5
    800090f2:	100017b7          	lui	a5,0x10001
    800090f6:	08078793          	addi	a5,a5,128 # 10001080 <_entry-0x6fffef80>
    800090fa:	2701                	sext.w	a4,a4
    800090fc:	c398                	sw	a4,0(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800090fe:	0001c797          	auipc	a5,0x1c
    80009102:	b7a78793          	addi	a5,a5,-1158 # 80024c78 <disk>
    80009106:	639c                	ld	a5,0(a5)
    80009108:	0207d713          	srli	a4,a5,0x20
    8000910c:	100017b7          	lui	a5,0x10001
    80009110:	08478793          	addi	a5,a5,132 # 10001084 <_entry-0x6fffef7c>
    80009114:	2701                	sext.w	a4,a4
    80009116:	c398                	sw	a4,0(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80009118:	0001c797          	auipc	a5,0x1c
    8000911c:	b6078793          	addi	a5,a5,-1184 # 80024c78 <disk>
    80009120:	679c                	ld	a5,8(a5)
    80009122:	873e                	mv	a4,a5
    80009124:	100017b7          	lui	a5,0x10001
    80009128:	09078793          	addi	a5,a5,144 # 10001090 <_entry-0x6fffef70>
    8000912c:	2701                	sext.w	a4,a4
    8000912e:	c398                	sw	a4,0(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80009130:	0001c797          	auipc	a5,0x1c
    80009134:	b4878793          	addi	a5,a5,-1208 # 80024c78 <disk>
    80009138:	679c                	ld	a5,8(a5)
    8000913a:	0207d713          	srli	a4,a5,0x20
    8000913e:	100017b7          	lui	a5,0x10001
    80009142:	09478793          	addi	a5,a5,148 # 10001094 <_entry-0x6fffef6c>
    80009146:	2701                	sext.w	a4,a4
    80009148:	c398                	sw	a4,0(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000914a:	0001c797          	auipc	a5,0x1c
    8000914e:	b2e78793          	addi	a5,a5,-1234 # 80024c78 <disk>
    80009152:	6b9c                	ld	a5,16(a5)
    80009154:	873e                	mv	a4,a5
    80009156:	100017b7          	lui	a5,0x10001
    8000915a:	0a078793          	addi	a5,a5,160 # 100010a0 <_entry-0x6fffef60>
    8000915e:	2701                	sext.w	a4,a4
    80009160:	c398                	sw	a4,0(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80009162:	0001c797          	auipc	a5,0x1c
    80009166:	b1678793          	addi	a5,a5,-1258 # 80024c78 <disk>
    8000916a:	6b9c                	ld	a5,16(a5)
    8000916c:	0207d713          	srli	a4,a5,0x20
    80009170:	100017b7          	lui	a5,0x10001
    80009174:	0a478793          	addi	a5,a5,164 # 100010a4 <_entry-0x6fffef5c>
    80009178:	2701                	sext.w	a4,a4
    8000917a:	c398                	sw	a4,0(a5)

  // queue is ready.
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000917c:	100017b7          	lui	a5,0x10001
    80009180:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80009184:	4705                	li	a4,1
    80009186:	c398                	sw	a4,0(a5)

  // all NUM descriptors start out unused.
  for(int i = 0; i < NUM; i++)
    80009188:	fe042623          	sw	zero,-20(s0)
    8000918c:	a005                	j	800091ac <virtio_disk_init+0x38a>
    disk.free[i] = 1;
    8000918e:	0001c717          	auipc	a4,0x1c
    80009192:	aea70713          	addi	a4,a4,-1302 # 80024c78 <disk>
    80009196:	fec42783          	lw	a5,-20(s0)
    8000919a:	97ba                	add	a5,a5,a4
    8000919c:	4705                	li	a4,1
    8000919e:	00e78c23          	sb	a4,24(a5)
  for(int i = 0; i < NUM; i++)
    800091a2:	fec42783          	lw	a5,-20(s0)
    800091a6:	2785                	addiw	a5,a5,1
    800091a8:	fef42623          	sw	a5,-20(s0)
    800091ac:	fec42783          	lw	a5,-20(s0)
    800091b0:	0007871b          	sext.w	a4,a5
    800091b4:	479d                	li	a5,7
    800091b6:	fce7dce3          	bge	a5,a4,8000918e <virtio_disk_init+0x36c>

  // tell device we're completely ready.
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800091ba:	fe842783          	lw	a5,-24(s0)
    800091be:	0047e793          	ori	a5,a5,4
    800091c2:	fef42423          	sw	a5,-24(s0)
  *R(VIRTIO_MMIO_STATUS) = status;
    800091c6:	100017b7          	lui	a5,0x10001
    800091ca:	07078793          	addi	a5,a5,112 # 10001070 <_entry-0x6fffef90>
    800091ce:	fe842703          	lw	a4,-24(s0)
    800091d2:	c398                	sw	a4,0(a5)

  // plic.c and trap.c arrange for interrupts from VIRTIO0_IRQ.
}
    800091d4:	0001                	nop
    800091d6:	70a2                	ld	ra,40(sp)
    800091d8:	7402                	ld	s0,32(sp)
    800091da:	6145                	addi	sp,sp,48
    800091dc:	8082                	ret

00000000800091de <alloc_desc>:

// find a free descriptor, mark it non-free, return its index.
static int
alloc_desc()
{
    800091de:	1101                	addi	sp,sp,-32
    800091e0:	ec22                	sd	s0,24(sp)
    800091e2:	1000                	addi	s0,sp,32
  for(int i = 0; i < NUM; i++){
    800091e4:	fe042623          	sw	zero,-20(s0)
    800091e8:	a825                	j	80009220 <alloc_desc+0x42>
    if(disk.free[i]){
    800091ea:	0001c717          	auipc	a4,0x1c
    800091ee:	a8e70713          	addi	a4,a4,-1394 # 80024c78 <disk>
    800091f2:	fec42783          	lw	a5,-20(s0)
    800091f6:	97ba                	add	a5,a5,a4
    800091f8:	0187c783          	lbu	a5,24(a5)
    800091fc:	cf89                	beqz	a5,80009216 <alloc_desc+0x38>
      disk.free[i] = 0;
    800091fe:	0001c717          	auipc	a4,0x1c
    80009202:	a7a70713          	addi	a4,a4,-1414 # 80024c78 <disk>
    80009206:	fec42783          	lw	a5,-20(s0)
    8000920a:	97ba                	add	a5,a5,a4
    8000920c:	00078c23          	sb	zero,24(a5)
      return i;
    80009210:	fec42783          	lw	a5,-20(s0)
    80009214:	a831                	j	80009230 <alloc_desc+0x52>
  for(int i = 0; i < NUM; i++){
    80009216:	fec42783          	lw	a5,-20(s0)
    8000921a:	2785                	addiw	a5,a5,1
    8000921c:	fef42623          	sw	a5,-20(s0)
    80009220:	fec42783          	lw	a5,-20(s0)
    80009224:	0007871b          	sext.w	a4,a5
    80009228:	479d                	li	a5,7
    8000922a:	fce7d0e3          	bge	a5,a4,800091ea <alloc_desc+0xc>
    }
  }
  return -1;
    8000922e:	57fd                	li	a5,-1
}
    80009230:	853e                	mv	a0,a5
    80009232:	6462                	ld	s0,24(sp)
    80009234:	6105                	addi	sp,sp,32
    80009236:	8082                	ret

0000000080009238 <free_desc>:

// mark a descriptor as free.
static void
free_desc(int i)
{
    80009238:	1101                	addi	sp,sp,-32
    8000923a:	ec06                	sd	ra,24(sp)
    8000923c:	e822                	sd	s0,16(sp)
    8000923e:	1000                	addi	s0,sp,32
    80009240:	87aa                	mv	a5,a0
    80009242:	fef42623          	sw	a5,-20(s0)
  if(i >= NUM)
    80009246:	fec42783          	lw	a5,-20(s0)
    8000924a:	0007871b          	sext.w	a4,a5
    8000924e:	479d                	li	a5,7
    80009250:	00e7da63          	bge	a5,a4,80009264 <free_desc+0x2c>
    panic("free_desc 1");
    80009254:	00002517          	auipc	a0,0x2
    80009258:	4fc50513          	addi	a0,a0,1276 # 8000b750 <etext+0x750>
    8000925c:	ffff8097          	auipc	ra,0xffff8
    80009260:	a2e080e7          	jalr	-1490(ra) # 80000c8a <panic>
  if(disk.free[i])
    80009264:	0001c717          	auipc	a4,0x1c
    80009268:	a1470713          	addi	a4,a4,-1516 # 80024c78 <disk>
    8000926c:	fec42783          	lw	a5,-20(s0)
    80009270:	97ba                	add	a5,a5,a4
    80009272:	0187c783          	lbu	a5,24(a5)
    80009276:	cb89                	beqz	a5,80009288 <free_desc+0x50>
    panic("free_desc 2");
    80009278:	00002517          	auipc	a0,0x2
    8000927c:	4e850513          	addi	a0,a0,1256 # 8000b760 <etext+0x760>
    80009280:	ffff8097          	auipc	ra,0xffff8
    80009284:	a0a080e7          	jalr	-1526(ra) # 80000c8a <panic>
  disk.desc[i].addr = 0;
    80009288:	0001c797          	auipc	a5,0x1c
    8000928c:	9f078793          	addi	a5,a5,-1552 # 80024c78 <disk>
    80009290:	6398                	ld	a4,0(a5)
    80009292:	fec42783          	lw	a5,-20(s0)
    80009296:	0792                	slli	a5,a5,0x4
    80009298:	97ba                	add	a5,a5,a4
    8000929a:	0007b023          	sd	zero,0(a5)
  disk.desc[i].len = 0;
    8000929e:	0001c797          	auipc	a5,0x1c
    800092a2:	9da78793          	addi	a5,a5,-1574 # 80024c78 <disk>
    800092a6:	6398                	ld	a4,0(a5)
    800092a8:	fec42783          	lw	a5,-20(s0)
    800092ac:	0792                	slli	a5,a5,0x4
    800092ae:	97ba                	add	a5,a5,a4
    800092b0:	0007a423          	sw	zero,8(a5)
  disk.desc[i].flags = 0;
    800092b4:	0001c797          	auipc	a5,0x1c
    800092b8:	9c478793          	addi	a5,a5,-1596 # 80024c78 <disk>
    800092bc:	6398                	ld	a4,0(a5)
    800092be:	fec42783          	lw	a5,-20(s0)
    800092c2:	0792                	slli	a5,a5,0x4
    800092c4:	97ba                	add	a5,a5,a4
    800092c6:	00079623          	sh	zero,12(a5)
  disk.desc[i].next = 0;
    800092ca:	0001c797          	auipc	a5,0x1c
    800092ce:	9ae78793          	addi	a5,a5,-1618 # 80024c78 <disk>
    800092d2:	6398                	ld	a4,0(a5)
    800092d4:	fec42783          	lw	a5,-20(s0)
    800092d8:	0792                	slli	a5,a5,0x4
    800092da:	97ba                	add	a5,a5,a4
    800092dc:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800092e0:	0001c717          	auipc	a4,0x1c
    800092e4:	99870713          	addi	a4,a4,-1640 # 80024c78 <disk>
    800092e8:	fec42783          	lw	a5,-20(s0)
    800092ec:	97ba                	add	a5,a5,a4
    800092ee:	4705                	li	a4,1
    800092f0:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800092f4:	0001c517          	auipc	a0,0x1c
    800092f8:	99c50513          	addi	a0,a0,-1636 # 80024c90 <disk+0x18>
    800092fc:	ffffa097          	auipc	ra,0xffffa
    80009300:	182080e7          	jalr	386(ra) # 8000347e <wakeup>
}
    80009304:	0001                	nop
    80009306:	60e2                	ld	ra,24(sp)
    80009308:	6442                	ld	s0,16(sp)
    8000930a:	6105                	addi	sp,sp,32
    8000930c:	8082                	ret

000000008000930e <free_chain>:

// free a chain of descriptors.
static void
free_chain(int i)
{
    8000930e:	7179                	addi	sp,sp,-48
    80009310:	f406                	sd	ra,40(sp)
    80009312:	f022                	sd	s0,32(sp)
    80009314:	1800                	addi	s0,sp,48
    80009316:	87aa                	mv	a5,a0
    80009318:	fcf42e23          	sw	a5,-36(s0)
  while(1){
    int flag = disk.desc[i].flags;
    8000931c:	0001c797          	auipc	a5,0x1c
    80009320:	95c78793          	addi	a5,a5,-1700 # 80024c78 <disk>
    80009324:	6398                	ld	a4,0(a5)
    80009326:	fdc42783          	lw	a5,-36(s0)
    8000932a:	0792                	slli	a5,a5,0x4
    8000932c:	97ba                	add	a5,a5,a4
    8000932e:	00c7d783          	lhu	a5,12(a5)
    80009332:	fef42623          	sw	a5,-20(s0)
    int nxt = disk.desc[i].next;
    80009336:	0001c797          	auipc	a5,0x1c
    8000933a:	94278793          	addi	a5,a5,-1726 # 80024c78 <disk>
    8000933e:	6398                	ld	a4,0(a5)
    80009340:	fdc42783          	lw	a5,-36(s0)
    80009344:	0792                	slli	a5,a5,0x4
    80009346:	97ba                	add	a5,a5,a4
    80009348:	00e7d783          	lhu	a5,14(a5)
    8000934c:	fef42423          	sw	a5,-24(s0)
    free_desc(i);
    80009350:	fdc42783          	lw	a5,-36(s0)
    80009354:	853e                	mv	a0,a5
    80009356:	00000097          	auipc	ra,0x0
    8000935a:	ee2080e7          	jalr	-286(ra) # 80009238 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000935e:	fec42783          	lw	a5,-20(s0)
    80009362:	8b85                	andi	a5,a5,1
    80009364:	2781                	sext.w	a5,a5
    80009366:	c791                	beqz	a5,80009372 <free_chain+0x64>
      i = nxt;
    80009368:	fe842783          	lw	a5,-24(s0)
    8000936c:	fcf42e23          	sw	a5,-36(s0)
  while(1){
    80009370:	b775                	j	8000931c <free_chain+0xe>
    else
      break;
    80009372:	0001                	nop
  }
}
    80009374:	0001                	nop
    80009376:	70a2                	ld	ra,40(sp)
    80009378:	7402                	ld	s0,32(sp)
    8000937a:	6145                	addi	sp,sp,48
    8000937c:	8082                	ret

000000008000937e <alloc3_desc>:

// allocate three descriptors (they need not be contiguous).
// disk transfers always use three descriptors.
static int
alloc3_desc(int *idx)
{
    8000937e:	7139                	addi	sp,sp,-64
    80009380:	fc06                	sd	ra,56(sp)
    80009382:	f822                	sd	s0,48(sp)
    80009384:	f426                	sd	s1,40(sp)
    80009386:	0080                	addi	s0,sp,64
    80009388:	fca43423          	sd	a0,-56(s0)
  for(int i = 0; i < 3; i++){
    8000938c:	fc042e23          	sw	zero,-36(s0)
    80009390:	a89d                	j	80009406 <alloc3_desc+0x88>
    idx[i] = alloc_desc();
    80009392:	fdc42783          	lw	a5,-36(s0)
    80009396:	078a                	slli	a5,a5,0x2
    80009398:	fc843703          	ld	a4,-56(s0)
    8000939c:	00f704b3          	add	s1,a4,a5
    800093a0:	00000097          	auipc	ra,0x0
    800093a4:	e3e080e7          	jalr	-450(ra) # 800091de <alloc_desc>
    800093a8:	87aa                	mv	a5,a0
    800093aa:	c09c                	sw	a5,0(s1)
    if(idx[i] < 0){
    800093ac:	fdc42783          	lw	a5,-36(s0)
    800093b0:	078a                	slli	a5,a5,0x2
    800093b2:	fc843703          	ld	a4,-56(s0)
    800093b6:	97ba                	add	a5,a5,a4
    800093b8:	439c                	lw	a5,0(a5)
    800093ba:	0407d163          	bgez	a5,800093fc <alloc3_desc+0x7e>
      for(int j = 0; j < i; j++)
    800093be:	fc042c23          	sw	zero,-40(s0)
    800093c2:	a015                	j	800093e6 <alloc3_desc+0x68>
        free_desc(idx[j]);
    800093c4:	fd842783          	lw	a5,-40(s0)
    800093c8:	078a                	slli	a5,a5,0x2
    800093ca:	fc843703          	ld	a4,-56(s0)
    800093ce:	97ba                	add	a5,a5,a4
    800093d0:	439c                	lw	a5,0(a5)
    800093d2:	853e                	mv	a0,a5
    800093d4:	00000097          	auipc	ra,0x0
    800093d8:	e64080e7          	jalr	-412(ra) # 80009238 <free_desc>
      for(int j = 0; j < i; j++)
    800093dc:	fd842783          	lw	a5,-40(s0)
    800093e0:	2785                	addiw	a5,a5,1
    800093e2:	fcf42c23          	sw	a5,-40(s0)
    800093e6:	fd842783          	lw	a5,-40(s0)
    800093ea:	873e                	mv	a4,a5
    800093ec:	fdc42783          	lw	a5,-36(s0)
    800093f0:	2701                	sext.w	a4,a4
    800093f2:	2781                	sext.w	a5,a5
    800093f4:	fcf748e3          	blt	a4,a5,800093c4 <alloc3_desc+0x46>
      return -1;
    800093f8:	57fd                	li	a5,-1
    800093fa:	a831                	j	80009416 <alloc3_desc+0x98>
  for(int i = 0; i < 3; i++){
    800093fc:	fdc42783          	lw	a5,-36(s0)
    80009400:	2785                	addiw	a5,a5,1
    80009402:	fcf42e23          	sw	a5,-36(s0)
    80009406:	fdc42783          	lw	a5,-36(s0)
    8000940a:	0007871b          	sext.w	a4,a5
    8000940e:	4789                	li	a5,2
    80009410:	f8e7d1e3          	bge	a5,a4,80009392 <alloc3_desc+0x14>
    }
  }
  return 0;
    80009414:	4781                	li	a5,0
}
    80009416:	853e                	mv	a0,a5
    80009418:	70e2                	ld	ra,56(sp)
    8000941a:	7442                	ld	s0,48(sp)
    8000941c:	74a2                	ld	s1,40(sp)
    8000941e:	6121                	addi	sp,sp,64
    80009420:	8082                	ret

0000000080009422 <virtio_disk_rw>:

void
virtio_disk_rw(struct buf *b, int write)
{
    80009422:	7139                	addi	sp,sp,-64
    80009424:	fc06                	sd	ra,56(sp)
    80009426:	f822                	sd	s0,48(sp)
    80009428:	0080                	addi	s0,sp,64
    8000942a:	fca43423          	sd	a0,-56(s0)
    8000942e:	87ae                	mv	a5,a1
    80009430:	fcf42223          	sw	a5,-60(s0)
  uint64 sector = b->blockno * (BSIZE / 512);
    80009434:	fc843783          	ld	a5,-56(s0)
    80009438:	47dc                	lw	a5,12(a5)
    8000943a:	0017979b          	slliw	a5,a5,0x1
    8000943e:	2781                	sext.w	a5,a5
    80009440:	1782                	slli	a5,a5,0x20
    80009442:	9381                	srli	a5,a5,0x20
    80009444:	fef43423          	sd	a5,-24(s0)

  acquire(&disk.vdisk_lock);
    80009448:	0001c517          	auipc	a0,0x1c
    8000944c:	95850513          	addi	a0,a0,-1704 # 80024da0 <disk+0x128>
    80009450:	ffff8097          	auipc	ra,0xffff8
    80009454:	e28080e7          	jalr	-472(ra) # 80001278 <acquire>
  // data, one for a 1-byte status result.

  // allocate the three descriptors.
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
    80009458:	fd040793          	addi	a5,s0,-48
    8000945c:	853e                	mv	a0,a5
    8000945e:	00000097          	auipc	ra,0x0
    80009462:	f20080e7          	jalr	-224(ra) # 8000937e <alloc3_desc>
    80009466:	87aa                	mv	a5,a0
    80009468:	cf91                	beqz	a5,80009484 <virtio_disk_rw+0x62>
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000946a:	0001c597          	auipc	a1,0x1c
    8000946e:	93658593          	addi	a1,a1,-1738 # 80024da0 <disk+0x128>
    80009472:	0001c517          	auipc	a0,0x1c
    80009476:	81e50513          	addi	a0,a0,-2018 # 80024c90 <disk+0x18>
    8000947a:	ffffa097          	auipc	ra,0xffffa
    8000947e:	f88080e7          	jalr	-120(ra) # 80003402 <sleep>
    if(alloc3_desc(idx) == 0) {
    80009482:	bfd9                	j	80009458 <virtio_disk_rw+0x36>
      break;
    80009484:	0001                	nop
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80009486:	fd042783          	lw	a5,-48(s0)
    8000948a:	07a9                	addi	a5,a5,10
    8000948c:	00479713          	slli	a4,a5,0x4
    80009490:	0001b797          	auipc	a5,0x1b
    80009494:	7e878793          	addi	a5,a5,2024 # 80024c78 <disk>
    80009498:	97ba                	add	a5,a5,a4
    8000949a:	07a1                	addi	a5,a5,8
    8000949c:	fef43023          	sd	a5,-32(s0)

  if(write)
    800094a0:	fc442783          	lw	a5,-60(s0)
    800094a4:	2781                	sext.w	a5,a5
    800094a6:	c791                	beqz	a5,800094b2 <virtio_disk_rw+0x90>
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800094a8:	fe043783          	ld	a5,-32(s0)
    800094ac:	4705                	li	a4,1
    800094ae:	c398                	sw	a4,0(a5)
    800094b0:	a029                	j	800094ba <virtio_disk_rw+0x98>
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    800094b2:	fe043783          	ld	a5,-32(s0)
    800094b6:	0007a023          	sw	zero,0(a5)
  buf0->reserved = 0;
    800094ba:	fe043783          	ld	a5,-32(s0)
    800094be:	0007a223          	sw	zero,4(a5)
  buf0->sector = sector;
    800094c2:	fe043783          	ld	a5,-32(s0)
    800094c6:	fe843703          	ld	a4,-24(s0)
    800094ca:	e798                	sd	a4,8(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800094cc:	0001b797          	auipc	a5,0x1b
    800094d0:	7ac78793          	addi	a5,a5,1964 # 80024c78 <disk>
    800094d4:	6398                	ld	a4,0(a5)
    800094d6:	fd042783          	lw	a5,-48(s0)
    800094da:	0792                	slli	a5,a5,0x4
    800094dc:	97ba                	add	a5,a5,a4
    800094de:	fe043703          	ld	a4,-32(s0)
    800094e2:	e398                	sd	a4,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800094e4:	0001b797          	auipc	a5,0x1b
    800094e8:	79478793          	addi	a5,a5,1940 # 80024c78 <disk>
    800094ec:	6398                	ld	a4,0(a5)
    800094ee:	fd042783          	lw	a5,-48(s0)
    800094f2:	0792                	slli	a5,a5,0x4
    800094f4:	97ba                	add	a5,a5,a4
    800094f6:	4741                	li	a4,16
    800094f8:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800094fa:	0001b797          	auipc	a5,0x1b
    800094fe:	77e78793          	addi	a5,a5,1918 # 80024c78 <disk>
    80009502:	6398                	ld	a4,0(a5)
    80009504:	fd042783          	lw	a5,-48(s0)
    80009508:	0792                	slli	a5,a5,0x4
    8000950a:	97ba                	add	a5,a5,a4
    8000950c:	4705                	li	a4,1
    8000950e:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80009512:	fd442683          	lw	a3,-44(s0)
    80009516:	0001b797          	auipc	a5,0x1b
    8000951a:	76278793          	addi	a5,a5,1890 # 80024c78 <disk>
    8000951e:	6398                	ld	a4,0(a5)
    80009520:	fd042783          	lw	a5,-48(s0)
    80009524:	0792                	slli	a5,a5,0x4
    80009526:	97ba                	add	a5,a5,a4
    80009528:	03069713          	slli	a4,a3,0x30
    8000952c:	9341                	srli	a4,a4,0x30
    8000952e:	00e79723          	sh	a4,14(a5)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80009532:	fc843783          	ld	a5,-56(s0)
    80009536:	05878693          	addi	a3,a5,88
    8000953a:	0001b797          	auipc	a5,0x1b
    8000953e:	73e78793          	addi	a5,a5,1854 # 80024c78 <disk>
    80009542:	6398                	ld	a4,0(a5)
    80009544:	fd442783          	lw	a5,-44(s0)
    80009548:	0792                	slli	a5,a5,0x4
    8000954a:	97ba                	add	a5,a5,a4
    8000954c:	8736                	mv	a4,a3
    8000954e:	e398                	sd	a4,0(a5)
  disk.desc[idx[1]].len = BSIZE;
    80009550:	0001b797          	auipc	a5,0x1b
    80009554:	72878793          	addi	a5,a5,1832 # 80024c78 <disk>
    80009558:	6398                	ld	a4,0(a5)
    8000955a:	fd442783          	lw	a5,-44(s0)
    8000955e:	0792                	slli	a5,a5,0x4
    80009560:	97ba                	add	a5,a5,a4
    80009562:	40000713          	li	a4,1024
    80009566:	c798                	sw	a4,8(a5)
  if(write)
    80009568:	fc442783          	lw	a5,-60(s0)
    8000956c:	2781                	sext.w	a5,a5
    8000956e:	cf89                	beqz	a5,80009588 <virtio_disk_rw+0x166>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80009570:	0001b797          	auipc	a5,0x1b
    80009574:	70878793          	addi	a5,a5,1800 # 80024c78 <disk>
    80009578:	6398                	ld	a4,0(a5)
    8000957a:	fd442783          	lw	a5,-44(s0)
    8000957e:	0792                	slli	a5,a5,0x4
    80009580:	97ba                	add	a5,a5,a4
    80009582:	00079623          	sh	zero,12(a5)
    80009586:	a829                	j	800095a0 <virtio_disk_rw+0x17e>
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    80009588:	0001b797          	auipc	a5,0x1b
    8000958c:	6f078793          	addi	a5,a5,1776 # 80024c78 <disk>
    80009590:	6398                	ld	a4,0(a5)
    80009592:	fd442783          	lw	a5,-44(s0)
    80009596:	0792                	slli	a5,a5,0x4
    80009598:	97ba                	add	a5,a5,a4
    8000959a:	4709                	li	a4,2
    8000959c:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800095a0:	0001b797          	auipc	a5,0x1b
    800095a4:	6d878793          	addi	a5,a5,1752 # 80024c78 <disk>
    800095a8:	6398                	ld	a4,0(a5)
    800095aa:	fd442783          	lw	a5,-44(s0)
    800095ae:	0792                	slli	a5,a5,0x4
    800095b0:	97ba                	add	a5,a5,a4
    800095b2:	00c7d703          	lhu	a4,12(a5)
    800095b6:	0001b797          	auipc	a5,0x1b
    800095ba:	6c278793          	addi	a5,a5,1730 # 80024c78 <disk>
    800095be:	6394                	ld	a3,0(a5)
    800095c0:	fd442783          	lw	a5,-44(s0)
    800095c4:	0792                	slli	a5,a5,0x4
    800095c6:	97b6                	add	a5,a5,a3
    800095c8:	00176713          	ori	a4,a4,1
    800095cc:	1742                	slli	a4,a4,0x30
    800095ce:	9341                	srli	a4,a4,0x30
    800095d0:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[1]].next = idx[2];
    800095d4:	fd842683          	lw	a3,-40(s0)
    800095d8:	0001b797          	auipc	a5,0x1b
    800095dc:	6a078793          	addi	a5,a5,1696 # 80024c78 <disk>
    800095e0:	6398                	ld	a4,0(a5)
    800095e2:	fd442783          	lw	a5,-44(s0)
    800095e6:	0792                	slli	a5,a5,0x4
    800095e8:	97ba                	add	a5,a5,a4
    800095ea:	03069713          	slli	a4,a3,0x30
    800095ee:	9341                	srli	a4,a4,0x30
    800095f0:	00e79723          	sh	a4,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800095f4:	fd042783          	lw	a5,-48(s0)
    800095f8:	0001b717          	auipc	a4,0x1b
    800095fc:	68070713          	addi	a4,a4,1664 # 80024c78 <disk>
    80009600:	0789                	addi	a5,a5,2
    80009602:	0792                	slli	a5,a5,0x4
    80009604:	97ba                	add	a5,a5,a4
    80009606:	577d                	li	a4,-1
    80009608:	00e78823          	sb	a4,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000960c:	fd042783          	lw	a5,-48(s0)
    80009610:	0789                	addi	a5,a5,2
    80009612:	00479713          	slli	a4,a5,0x4
    80009616:	0001b797          	auipc	a5,0x1b
    8000961a:	66278793          	addi	a5,a5,1634 # 80024c78 <disk>
    8000961e:	97ba                	add	a5,a5,a4
    80009620:	01078693          	addi	a3,a5,16
    80009624:	0001b797          	auipc	a5,0x1b
    80009628:	65478793          	addi	a5,a5,1620 # 80024c78 <disk>
    8000962c:	6398                	ld	a4,0(a5)
    8000962e:	fd842783          	lw	a5,-40(s0)
    80009632:	0792                	slli	a5,a5,0x4
    80009634:	97ba                	add	a5,a5,a4
    80009636:	8736                	mv	a4,a3
    80009638:	e398                	sd	a4,0(a5)
  disk.desc[idx[2]].len = 1;
    8000963a:	0001b797          	auipc	a5,0x1b
    8000963e:	63e78793          	addi	a5,a5,1598 # 80024c78 <disk>
    80009642:	6398                	ld	a4,0(a5)
    80009644:	fd842783          	lw	a5,-40(s0)
    80009648:	0792                	slli	a5,a5,0x4
    8000964a:	97ba                	add	a5,a5,a4
    8000964c:	4705                	li	a4,1
    8000964e:	c798                	sw	a4,8(a5)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80009650:	0001b797          	auipc	a5,0x1b
    80009654:	62878793          	addi	a5,a5,1576 # 80024c78 <disk>
    80009658:	6398                	ld	a4,0(a5)
    8000965a:	fd842783          	lw	a5,-40(s0)
    8000965e:	0792                	slli	a5,a5,0x4
    80009660:	97ba                	add	a5,a5,a4
    80009662:	4709                	li	a4,2
    80009664:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[2]].next = 0;
    80009668:	0001b797          	auipc	a5,0x1b
    8000966c:	61078793          	addi	a5,a5,1552 # 80024c78 <disk>
    80009670:	6398                	ld	a4,0(a5)
    80009672:	fd842783          	lw	a5,-40(s0)
    80009676:	0792                	slli	a5,a5,0x4
    80009678:	97ba                	add	a5,a5,a4
    8000967a:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000967e:	fc843783          	ld	a5,-56(s0)
    80009682:	4705                	li	a4,1
    80009684:	c3d8                	sw	a4,4(a5)
  disk.info[idx[0]].b = b;
    80009686:	fd042783          	lw	a5,-48(s0)
    8000968a:	0001b717          	auipc	a4,0x1b
    8000968e:	5ee70713          	addi	a4,a4,1518 # 80024c78 <disk>
    80009692:	0789                	addi	a5,a5,2
    80009694:	0792                	slli	a5,a5,0x4
    80009696:	97ba                	add	a5,a5,a4
    80009698:	fc843703          	ld	a4,-56(s0)
    8000969c:	e798                	sd	a4,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    8000969e:	fd042703          	lw	a4,-48(s0)
    800096a2:	0001b797          	auipc	a5,0x1b
    800096a6:	5d678793          	addi	a5,a5,1494 # 80024c78 <disk>
    800096aa:	6794                	ld	a3,8(a5)
    800096ac:	0001b797          	auipc	a5,0x1b
    800096b0:	5cc78793          	addi	a5,a5,1484 # 80024c78 <disk>
    800096b4:	679c                	ld	a5,8(a5)
    800096b6:	0027d783          	lhu	a5,2(a5)
    800096ba:	2781                	sext.w	a5,a5
    800096bc:	8b9d                	andi	a5,a5,7
    800096be:	2781                	sext.w	a5,a5
    800096c0:	1742                	slli	a4,a4,0x30
    800096c2:	9341                	srli	a4,a4,0x30
    800096c4:	0786                	slli	a5,a5,0x1
    800096c6:	97b6                	add	a5,a5,a3
    800096c8:	00e79223          	sh	a4,4(a5)

  __sync_synchronize();
    800096cc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800096d0:	0001b797          	auipc	a5,0x1b
    800096d4:	5a878793          	addi	a5,a5,1448 # 80024c78 <disk>
    800096d8:	679c                	ld	a5,8(a5)
    800096da:	0027d703          	lhu	a4,2(a5)
    800096de:	0001b797          	auipc	a5,0x1b
    800096e2:	59a78793          	addi	a5,a5,1434 # 80024c78 <disk>
    800096e6:	679c                	ld	a5,8(a5)
    800096e8:	2705                	addiw	a4,a4,1
    800096ea:	1742                	slli	a4,a4,0x30
    800096ec:	9341                	srli	a4,a4,0x30
    800096ee:	00e79123          	sh	a4,2(a5)

  __sync_synchronize();
    800096f2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800096f6:	100017b7          	lui	a5,0x10001
    800096fa:	05078793          	addi	a5,a5,80 # 10001050 <_entry-0x6fffefb0>
    800096fe:	0007a023          	sw	zero,0(a5)

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80009702:	a819                	j	80009718 <virtio_disk_rw+0x2f6>
    sleep(b, &disk.vdisk_lock);
    80009704:	0001b597          	auipc	a1,0x1b
    80009708:	69c58593          	addi	a1,a1,1692 # 80024da0 <disk+0x128>
    8000970c:	fc843503          	ld	a0,-56(s0)
    80009710:	ffffa097          	auipc	ra,0xffffa
    80009714:	cf2080e7          	jalr	-782(ra) # 80003402 <sleep>
  while(b->disk == 1) {
    80009718:	fc843783          	ld	a5,-56(s0)
    8000971c:	43dc                	lw	a5,4(a5)
    8000971e:	873e                	mv	a4,a5
    80009720:	4785                	li	a5,1
    80009722:	fef701e3          	beq	a4,a5,80009704 <virtio_disk_rw+0x2e2>
  }

  disk.info[idx[0]].b = 0;
    80009726:	fd042783          	lw	a5,-48(s0)
    8000972a:	0001b717          	auipc	a4,0x1b
    8000972e:	54e70713          	addi	a4,a4,1358 # 80024c78 <disk>
    80009732:	0789                	addi	a5,a5,2
    80009734:	0792                	slli	a5,a5,0x4
    80009736:	97ba                	add	a5,a5,a4
    80009738:	0007b423          	sd	zero,8(a5)
  free_chain(idx[0]);
    8000973c:	fd042783          	lw	a5,-48(s0)
    80009740:	853e                	mv	a0,a5
    80009742:	00000097          	auipc	ra,0x0
    80009746:	bcc080e7          	jalr	-1076(ra) # 8000930e <free_chain>

  release(&disk.vdisk_lock);
    8000974a:	0001b517          	auipc	a0,0x1b
    8000974e:	65650513          	addi	a0,a0,1622 # 80024da0 <disk+0x128>
    80009752:	ffff8097          	auipc	ra,0xffff8
    80009756:	b8a080e7          	jalr	-1142(ra) # 800012dc <release>
}
    8000975a:	0001                	nop
    8000975c:	70e2                	ld	ra,56(sp)
    8000975e:	7442                	ld	s0,48(sp)
    80009760:	6121                	addi	sp,sp,64
    80009762:	8082                	ret

0000000080009764 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80009764:	1101                	addi	sp,sp,-32
    80009766:	ec06                	sd	ra,24(sp)
    80009768:	e822                	sd	s0,16(sp)
    8000976a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000976c:	0001b517          	auipc	a0,0x1b
    80009770:	63450513          	addi	a0,a0,1588 # 80024da0 <disk+0x128>
    80009774:	ffff8097          	auipc	ra,0xffff8
    80009778:	b04080e7          	jalr	-1276(ra) # 80001278 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    8000977c:	100017b7          	lui	a5,0x10001
    80009780:	06078793          	addi	a5,a5,96 # 10001060 <_entry-0x6fffefa0>
    80009784:	439c                	lw	a5,0(a5)
    80009786:	0007871b          	sext.w	a4,a5
    8000978a:	100017b7          	lui	a5,0x10001
    8000978e:	06478793          	addi	a5,a5,100 # 10001064 <_entry-0x6fffef9c>
    80009792:	8b0d                	andi	a4,a4,3
    80009794:	2701                	sext.w	a4,a4
    80009796:	c398                	sw	a4,0(a5)

  __sync_synchronize();
    80009798:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000979c:	a045                	j	8000983c <virtio_disk_intr+0xd8>
    __sync_synchronize();
    8000979e:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800097a2:	0001b797          	auipc	a5,0x1b
    800097a6:	4d678793          	addi	a5,a5,1238 # 80024c78 <disk>
    800097aa:	6b98                	ld	a4,16(a5)
    800097ac:	0001b797          	auipc	a5,0x1b
    800097b0:	4cc78793          	addi	a5,a5,1228 # 80024c78 <disk>
    800097b4:	0207d783          	lhu	a5,32(a5)
    800097b8:	2781                	sext.w	a5,a5
    800097ba:	8b9d                	andi	a5,a5,7
    800097bc:	2781                	sext.w	a5,a5
    800097be:	078e                	slli	a5,a5,0x3
    800097c0:	97ba                	add	a5,a5,a4
    800097c2:	43dc                	lw	a5,4(a5)
    800097c4:	fef42623          	sw	a5,-20(s0)

    if(disk.info[id].status != 0)
    800097c8:	0001b717          	auipc	a4,0x1b
    800097cc:	4b070713          	addi	a4,a4,1200 # 80024c78 <disk>
    800097d0:	fec42783          	lw	a5,-20(s0)
    800097d4:	0789                	addi	a5,a5,2
    800097d6:	0792                	slli	a5,a5,0x4
    800097d8:	97ba                	add	a5,a5,a4
    800097da:	0107c783          	lbu	a5,16(a5)
    800097de:	cb89                	beqz	a5,800097f0 <virtio_disk_intr+0x8c>
      panic("virtio_disk_intr status");
    800097e0:	00002517          	auipc	a0,0x2
    800097e4:	f9050513          	addi	a0,a0,-112 # 8000b770 <etext+0x770>
    800097e8:	ffff7097          	auipc	ra,0xffff7
    800097ec:	4a2080e7          	jalr	1186(ra) # 80000c8a <panic>

    struct buf *b = disk.info[id].b;
    800097f0:	0001b717          	auipc	a4,0x1b
    800097f4:	48870713          	addi	a4,a4,1160 # 80024c78 <disk>
    800097f8:	fec42783          	lw	a5,-20(s0)
    800097fc:	0789                	addi	a5,a5,2
    800097fe:	0792                	slli	a5,a5,0x4
    80009800:	97ba                	add	a5,a5,a4
    80009802:	679c                	ld	a5,8(a5)
    80009804:	fef43023          	sd	a5,-32(s0)
    b->disk = 0;   // disk is done with buf
    80009808:	fe043783          	ld	a5,-32(s0)
    8000980c:	0007a223          	sw	zero,4(a5)
    wakeup(b);
    80009810:	fe043503          	ld	a0,-32(s0)
    80009814:	ffffa097          	auipc	ra,0xffffa
    80009818:	c6a080e7          	jalr	-918(ra) # 8000347e <wakeup>

    disk.used_idx += 1;
    8000981c:	0001b797          	auipc	a5,0x1b
    80009820:	45c78793          	addi	a5,a5,1116 # 80024c78 <disk>
    80009824:	0207d783          	lhu	a5,32(a5)
    80009828:	2785                	addiw	a5,a5,1
    8000982a:	03079713          	slli	a4,a5,0x30
    8000982e:	9341                	srli	a4,a4,0x30
    80009830:	0001b797          	auipc	a5,0x1b
    80009834:	44878793          	addi	a5,a5,1096 # 80024c78 <disk>
    80009838:	02e79023          	sh	a4,32(a5)
  while(disk.used_idx != disk.used->idx){
    8000983c:	0001b797          	auipc	a5,0x1b
    80009840:	43c78793          	addi	a5,a5,1084 # 80024c78 <disk>
    80009844:	0207d703          	lhu	a4,32(a5)
    80009848:	0001b797          	auipc	a5,0x1b
    8000984c:	43078793          	addi	a5,a5,1072 # 80024c78 <disk>
    80009850:	6b9c                	ld	a5,16(a5)
    80009852:	0027d783          	lhu	a5,2(a5)
    80009856:	2701                	sext.w	a4,a4
    80009858:	2781                	sext.w	a5,a5
    8000985a:	f4f712e3          	bne	a4,a5,8000979e <virtio_disk_intr+0x3a>
  }

  release(&disk.vdisk_lock);
    8000985e:	0001b517          	auipc	a0,0x1b
    80009862:	54250513          	addi	a0,a0,1346 # 80024da0 <disk+0x128>
    80009866:	ffff8097          	auipc	ra,0xffff8
    8000986a:	a76080e7          	jalr	-1418(ra) # 800012dc <release>
}
    8000986e:	0001                	nop
    80009870:	60e2                	ld	ra,24(sp)
    80009872:	6442                	ld	s0,16(sp)
    80009874:	6105                	addi	sp,sp,32
    80009876:	8082                	ret
	...

000000008000a000 <_trampoline>:
    8000a000:	14051073          	csrw	sscratch,a0
    8000a004:	02000537          	lui	a0,0x2000
    8000a008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000a00a:	0536                	slli	a0,a0,0xd
    8000a00c:	02153423          	sd	ra,40(a0)
    8000a010:	02253823          	sd	sp,48(a0)
    8000a014:	02353c23          	sd	gp,56(a0)
    8000a018:	04453023          	sd	tp,64(a0)
    8000a01c:	04553423          	sd	t0,72(a0)
    8000a020:	04653823          	sd	t1,80(a0)
    8000a024:	04753c23          	sd	t2,88(a0)
    8000a028:	f120                	sd	s0,96(a0)
    8000a02a:	f524                	sd	s1,104(a0)
    8000a02c:	fd2c                	sd	a1,120(a0)
    8000a02e:	e150                	sd	a2,128(a0)
    8000a030:	e554                	sd	a3,136(a0)
    8000a032:	e958                	sd	a4,144(a0)
    8000a034:	ed5c                	sd	a5,152(a0)
    8000a036:	0b053023          	sd	a6,160(a0)
    8000a03a:	0b153423          	sd	a7,168(a0)
    8000a03e:	0b253823          	sd	s2,176(a0)
    8000a042:	0b353c23          	sd	s3,184(a0)
    8000a046:	0d453023          	sd	s4,192(a0)
    8000a04a:	0d553423          	sd	s5,200(a0)
    8000a04e:	0d653823          	sd	s6,208(a0)
    8000a052:	0d753c23          	sd	s7,216(a0)
    8000a056:	0f853023          	sd	s8,224(a0)
    8000a05a:	0f953423          	sd	s9,232(a0)
    8000a05e:	0fa53823          	sd	s10,240(a0)
    8000a062:	0fb53c23          	sd	s11,248(a0)
    8000a066:	11c53023          	sd	t3,256(a0)
    8000a06a:	11d53423          	sd	t4,264(a0)
    8000a06e:	11e53823          	sd	t5,272(a0)
    8000a072:	11f53c23          	sd	t6,280(a0)
    8000a076:	140022f3          	csrr	t0,sscratch
    8000a07a:	06553823          	sd	t0,112(a0)
    8000a07e:	00853103          	ld	sp,8(a0)
    8000a082:	02053203          	ld	tp,32(a0)
    8000a086:	01053283          	ld	t0,16(a0)
    8000a08a:	00053303          	ld	t1,0(a0)
    8000a08e:	12000073          	sfence.vma
    8000a092:	18031073          	csrw	satp,t1
    8000a096:	12000073          	sfence.vma
    8000a09a:	8282                	jr	t0

000000008000a09c <userret>:
    8000a09c:	12000073          	sfence.vma
    8000a0a0:	18051073          	csrw	satp,a0
    8000a0a4:	12000073          	sfence.vma
    8000a0a8:	02000537          	lui	a0,0x2000
    8000a0ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000a0ae:	0536                	slli	a0,a0,0xd
    8000a0b0:	02853083          	ld	ra,40(a0)
    8000a0b4:	03053103          	ld	sp,48(a0)
    8000a0b8:	03853183          	ld	gp,56(a0)
    8000a0bc:	04053203          	ld	tp,64(a0)
    8000a0c0:	04853283          	ld	t0,72(a0)
    8000a0c4:	05053303          	ld	t1,80(a0)
    8000a0c8:	05853383          	ld	t2,88(a0)
    8000a0cc:	7120                	ld	s0,96(a0)
    8000a0ce:	7524                	ld	s1,104(a0)
    8000a0d0:	7d2c                	ld	a1,120(a0)
    8000a0d2:	6150                	ld	a2,128(a0)
    8000a0d4:	6554                	ld	a3,136(a0)
    8000a0d6:	6958                	ld	a4,144(a0)
    8000a0d8:	6d5c                	ld	a5,152(a0)
    8000a0da:	0a053803          	ld	a6,160(a0)
    8000a0de:	0a853883          	ld	a7,168(a0)
    8000a0e2:	0b053903          	ld	s2,176(a0)
    8000a0e6:	0b853983          	ld	s3,184(a0)
    8000a0ea:	0c053a03          	ld	s4,192(a0)
    8000a0ee:	0c853a83          	ld	s5,200(a0)
    8000a0f2:	0d053b03          	ld	s6,208(a0)
    8000a0f6:	0d853b83          	ld	s7,216(a0)
    8000a0fa:	0e053c03          	ld	s8,224(a0)
    8000a0fe:	0e853c83          	ld	s9,232(a0)
    8000a102:	0f053d03          	ld	s10,240(a0)
    8000a106:	0f853d83          	ld	s11,248(a0)
    8000a10a:	10053e03          	ld	t3,256(a0)
    8000a10e:	10853e83          	ld	t4,264(a0)
    8000a112:	11053f03          	ld	t5,272(a0)
    8000a116:	11853f83          	ld	t6,280(a0)
    8000a11a:	7928                	ld	a0,112(a0)
    8000a11c:	10200073          	sret
	...
