
user/_vatopa:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <hex_int>:
#include "kernel/types.h"
#include "user/user.h"

int hex_int(char c)
{
    if (c >= '0' && c <= '9')
   0:	fd05079b          	addiw	a5,a0,-48
   4:	0ff7f793          	zext.b	a5,a5
   8:	4725                	li	a4,9
   a:	02f77363          	bgeu	a4,a5,30 <hex_int+0x30>
    {
	return c - '0';
    }
    else if (c >= 'a' && c <= 'f')
   e:	f9f5079b          	addiw	a5,a0,-97
  12:	0ff7f793          	zext.b	a5,a5
  16:	4715                	li	a4,5
  18:	00f77f63          	bgeu	a4,a5,36 <hex_int+0x36>
    {
	return c - 'a';
    }
    else if (c >= 'A' && c <= 'F')
  1c:	fbf5079b          	addiw	a5,a0,-65
  20:	0ff7f793          	zext.b	a5,a5
  24:	4715                	li	a4,5
  26:	00f76b63          	bltu	a4,a5,3c <hex_int+0x3c>
    {
	return c - 'A';
  2a:	fbf5051b          	addiw	a0,a0,-65
    }
    printf("virtual address must be in hex\n");
    exit(1);
}
  2e:	8082                	ret
	return c - '0';
  30:	fd05051b          	addiw	a0,a0,-48
  34:	8082                	ret
	return c - 'a';
  36:	f9f5051b          	addiw	a0,a0,-97
  3a:	8082                	ret
{
  3c:	1141                	addi	sp,sp,-16
  3e:	e406                	sd	ra,8(sp)
  40:	e022                	sd	s0,0(sp)
  42:	0800                	addi	s0,sp,16
    printf("virtual address must be in hex\n");
  44:	00001517          	auipc	a0,0x1
  48:	97c50513          	addi	a0,a0,-1668 # 9c0 <malloc+0x10c>
  4c:	00000097          	auipc	ra,0x0
  50:	7b0080e7          	jalr	1968(ra) # 7fc <printf>
    exit(1);
  54:	4505                	li	a0,1
  56:	00000097          	auipc	ra,0x0
  5a:	416080e7          	jalr	1046(ra) # 46c <exit>

000000000000005e <str_hex>:

uint64 str_hex(char* str)
{
  5e:	7179                	addi	sp,sp,-48
  60:	f406                	sd	ra,40(sp)
  62:	f022                	sd	s0,32(sp)
  64:	e84a                	sd	s2,16(sp)
  66:	e44e                	sd	s3,8(sp)
  68:	1800                	addi	s0,sp,48
    int start = 0;
    if (str[0] == '0' || str[1] == 'x') {
  6a:	00054683          	lbu	a3,0(a0)
  6e:	03000713          	li	a4,48
	start = 2;
  72:	4789                	li	a5,2
    if (str[0] == '0' || str[1] == 'x') {
  74:	00e68963          	beq	a3,a4,86 <str_hex+0x28>
  78:	00154783          	lbu	a5,1(a0)
  7c:	f8878793          	addi	a5,a5,-120
  80:	0017b793          	seqz	a5,a5
  84:	0786                	slli	a5,a5,0x1
    }
    char *c = str + start;
  86:	00f50933          	add	s2,a0,a5
    int offset = -1;
    while (*c != '\0') {
  8a:	00094783          	lbu	a5,0(s2)
  8e:	c7b9                	beqz	a5,dc <str_hex+0x7e>
  90:	ec26                	sd	s1,24(sp)
    char *c = str + start;
  92:	87ca                	mv	a5,s2
    int offset = -1;
  94:	54fd                	li	s1,-1
	offset++;
  96:	2485                	addiw	s1,s1,1
	c++;
  98:	0785                	addi	a5,a5,1
    while (*c != '\0') {
  9a:	0007c703          	lbu	a4,0(a5)
  9e:	ff65                	bnez	a4,96 <str_hex+0x38>
    }

    uint64 num = 0;

    for (c = str + start; offset >= 0; offset--)
  a0:	0404c063          	bltz	s1,e0 <str_hex+0x82>
  a4:	e052                	sd	s4,0(sp)
    uint64 num = 0;
  a6:	4981                	li	s3,0
    for (c = str + start; offset >= 0; offset--)
  a8:	5a7d                	li	s4,-1
    {
	int val = hex_int(*c);
  aa:	00094503          	lbu	a0,0(s2)
  ae:	00000097          	auipc	ra,0x0
  b2:	f52080e7          	jalr	-174(ra) # 0 <hex_int>
	num |= val << (offset * 4);
  b6:	0024979b          	slliw	a5,s1,0x2
  ba:	00f5153b          	sllw	a0,a0,a5
  be:	00a9e9b3          	or	s3,s3,a0
	c++;
  c2:	0905                	addi	s2,s2,1
    for (c = str + start; offset >= 0; offset--)
  c4:	34fd                	addiw	s1,s1,-1
  c6:	ff4492e3          	bne	s1,s4,aa <str_hex+0x4c>
  ca:	64e2                	ld	s1,24(sp)
  cc:	6a02                	ld	s4,0(sp)
    }
    return num;
}
  ce:	854e                	mv	a0,s3
  d0:	70a2                	ld	ra,40(sp)
  d2:	7402                	ld	s0,32(sp)
  d4:	6942                	ld	s2,16(sp)
  d6:	69a2                	ld	s3,8(sp)
  d8:	6145                	addi	sp,sp,48
  da:	8082                	ret
    uint64 num = 0;
  dc:	4981                	li	s3,0
  de:	bfc5                	j	ce <str_hex+0x70>
  e0:	4981                	li	s3,0
  e2:	64e2                	ld	s1,24(sp)
    return num;
  e4:	b7ed                	j	ce <str_hex+0x70>

00000000000000e6 <str_int>:

int str_int(char* str)
{
    char *c = str;
    int offset = -1;
    while (*c != '\0') {
  e6:	00054783          	lbu	a5,0(a0)
  ea:	cbad                	beqz	a5,15c <str_int+0x76>
  ec:	86aa                	mv	a3,a0
    char *c = str;
  ee:	862a                	mv	a2,a0
    int offset = -1;
  f0:	577d                	li	a4,-1
	offset++;
  f2:	87ba                	mv	a5,a4
  f4:	2705                	addiw	a4,a4,1
	c++;
  f6:	0605                	addi	a2,a2,1
    while (*c != '\0') {
  f8:	00064583          	lbu	a1,0(a2)
  fc:	f9fd                	bnez	a1,f2 <str_int+0xc>
    }

    int num = 0;
    for (c = str; offset >= 0; offset--)
  fe:	06074163          	bltz	a4,160 <str_int+0x7a>
 102:	0027861b          	addiw	a2,a5,2
 106:	1602                	slli	a2,a2,0x20
 108:	9201                	srli	a2,a2,0x20
 10a:	9636                	add	a2,a2,a3
    int num = 0;
 10c:	4501                	li	a0,0
    {
	if (*c > '9' || *c < '0')
 10e:	45a5                	li	a1,9
 110:	0006c703          	lbu	a4,0(a3)
 114:	fd07079b          	addiw	a5,a4,-48
 118:	0ff7f793          	zext.b	a5,a5
 11c:	00f5ef63          	bltu	a1,a5,13a <str_int+0x54>
	{
	    printf("pid must be a num\n");
	    exit(1);
	}
	int val = *c - '0';
	num *= 10;
 120:	0025179b          	slliw	a5,a0,0x2
 124:	9fa9                	addw	a5,a5,a0
 126:	0017979b          	slliw	a5,a5,0x1
	int val = *c - '0';
 12a:	fd07071b          	addiw	a4,a4,-48
	num += val;
 12e:	00f7053b          	addw	a0,a4,a5
	c++;
 132:	0685                	addi	a3,a3,1
    for (c = str; offset >= 0; offset--)
 134:	fcd61ee3          	bne	a2,a3,110 <str_int+0x2a>
 138:	8082                	ret
{
 13a:	1141                	addi	sp,sp,-16
 13c:	e406                	sd	ra,8(sp)
 13e:	e022                	sd	s0,0(sp)
 140:	0800                	addi	s0,sp,16
	    printf("pid must be a num\n");
 142:	00001517          	auipc	a0,0x1
 146:	89e50513          	addi	a0,a0,-1890 # 9e0 <malloc+0x12c>
 14a:	00000097          	auipc	ra,0x0
 14e:	6b2080e7          	jalr	1714(ra) # 7fc <printf>
	    exit(1);
 152:	4505                	li	a0,1
 154:	00000097          	auipc	ra,0x0
 158:	318080e7          	jalr	792(ra) # 46c <exit>
    int num = 0;
 15c:	4501                	li	a0,0
 15e:	8082                	ret
 160:	4501                	li	a0,0
    }
    return num;
}
 162:	8082                	ret

0000000000000164 <main>:

int main(int argc, char *argv[])
{
 164:	7179                	addi	sp,sp,-48
 166:	f406                	sd	ra,40(sp)
 168:	f022                	sd	s0,32(sp)
 16a:	1800                	addi	s0,sp,48
    if (argc < 2)
 16c:	4785                	li	a5,1
 16e:	04a7d463          	bge	a5,a0,1b6 <main+0x52>
 172:	ec26                	sd	s1,24(sp)
 174:	e84a                	sd	s2,16(sp)
 176:	e44e                	sd	s3,8(sp)
 178:	84aa                	mv	s1,a0
 17a:	892e                	mv	s2,a1
    {
	printf("Usage: vatopa virtual_address [pid]\n");
	exit(1);
    }

    uint64 vaddr = str_hex(argv[1]);
 17c:	6588                	ld	a0,8(a1)
 17e:	00000097          	auipc	ra,0x0
 182:	ee0080e7          	jalr	-288(ra) # 5e <str_hex>
 186:	89aa                	mv	s3,a0

    int pid = 0;
    if (argc == 3) {
 188:	478d                	li	a5,3
    int pid = 0;
 18a:	4581                	li	a1,0
    if (argc == 3) {
 18c:	04f48563          	beq	s1,a5,1d6 <main+0x72>
	pid = str_int(argv[2]);		
    }
    printf("0x%x\n", va2pa(vaddr, pid));
 190:	854e                	mv	a0,s3
 192:	00000097          	auipc	ra,0x0
 196:	392080e7          	jalr	914(ra) # 524 <va2pa>
 19a:	85aa                	mv	a1,a0
 19c:	00001517          	auipc	a0,0x1
 1a0:	88450513          	addi	a0,a0,-1916 # a20 <malloc+0x16c>
 1a4:	00000097          	auipc	ra,0x0
 1a8:	658080e7          	jalr	1624(ra) # 7fc <printf>
    exit(0);
 1ac:	4501                	li	a0,0
 1ae:	00000097          	auipc	ra,0x0
 1b2:	2be080e7          	jalr	702(ra) # 46c <exit>
 1b6:	ec26                	sd	s1,24(sp)
 1b8:	e84a                	sd	s2,16(sp)
 1ba:	e44e                	sd	s3,8(sp)
	printf("Usage: vatopa virtual_address [pid]\n");
 1bc:	00001517          	auipc	a0,0x1
 1c0:	83c50513          	addi	a0,a0,-1988 # 9f8 <malloc+0x144>
 1c4:	00000097          	auipc	ra,0x0
 1c8:	638080e7          	jalr	1592(ra) # 7fc <printf>
	exit(1);
 1cc:	4505                	li	a0,1
 1ce:	00000097          	auipc	ra,0x0
 1d2:	29e080e7          	jalr	670(ra) # 46c <exit>
	pid = str_int(argv[2]);		
 1d6:	01093503          	ld	a0,16(s2)
 1da:	00000097          	auipc	ra,0x0
 1de:	f0c080e7          	jalr	-244(ra) # e6 <str_int>
 1e2:	85aa                	mv	a1,a0
 1e4:	b775                	j	190 <main+0x2c>

00000000000001e6 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1e6:	1141                	addi	sp,sp,-16
 1e8:	e406                	sd	ra,8(sp)
 1ea:	e022                	sd	s0,0(sp)
 1ec:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1ee:	00000097          	auipc	ra,0x0
 1f2:	f76080e7          	jalr	-138(ra) # 164 <main>
  exit(0);
 1f6:	4501                	li	a0,0
 1f8:	00000097          	auipc	ra,0x0
 1fc:	274080e7          	jalr	628(ra) # 46c <exit>

0000000000000200 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 200:	1141                	addi	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 206:	87aa                	mv	a5,a0
 208:	0585                	addi	a1,a1,1
 20a:	0785                	addi	a5,a5,1
 20c:	fff5c703          	lbu	a4,-1(a1)
 210:	fee78fa3          	sb	a4,-1(a5)
 214:	fb75                	bnez	a4,208 <strcpy+0x8>
    ;
  return os;
}
 216:	6422                	ld	s0,8(sp)
 218:	0141                	addi	sp,sp,16
 21a:	8082                	ret

000000000000021c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 222:	00054783          	lbu	a5,0(a0)
 226:	cb91                	beqz	a5,23a <strcmp+0x1e>
 228:	0005c703          	lbu	a4,0(a1)
 22c:	00f71763          	bne	a4,a5,23a <strcmp+0x1e>
    p++, q++;
 230:	0505                	addi	a0,a0,1
 232:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 234:	00054783          	lbu	a5,0(a0)
 238:	fbe5                	bnez	a5,228 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 23a:	0005c503          	lbu	a0,0(a1)
}
 23e:	40a7853b          	subw	a0,a5,a0
 242:	6422                	ld	s0,8(sp)
 244:	0141                	addi	sp,sp,16
 246:	8082                	ret

0000000000000248 <strlen>:

uint
strlen(const char *s)
{
 248:	1141                	addi	sp,sp,-16
 24a:	e422                	sd	s0,8(sp)
 24c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 24e:	00054783          	lbu	a5,0(a0)
 252:	cf91                	beqz	a5,26e <strlen+0x26>
 254:	0505                	addi	a0,a0,1
 256:	87aa                	mv	a5,a0
 258:	86be                	mv	a3,a5
 25a:	0785                	addi	a5,a5,1
 25c:	fff7c703          	lbu	a4,-1(a5)
 260:	ff65                	bnez	a4,258 <strlen+0x10>
 262:	40a6853b          	subw	a0,a3,a0
 266:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 268:	6422                	ld	s0,8(sp)
 26a:	0141                	addi	sp,sp,16
 26c:	8082                	ret
  for(n = 0; s[n]; n++)
 26e:	4501                	li	a0,0
 270:	bfe5                	j	268 <strlen+0x20>

0000000000000272 <memset>:

void*
memset(void *dst, int c, uint n)
{
 272:	1141                	addi	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 278:	ca19                	beqz	a2,28e <memset+0x1c>
 27a:	87aa                	mv	a5,a0
 27c:	1602                	slli	a2,a2,0x20
 27e:	9201                	srli	a2,a2,0x20
 280:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 284:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 288:	0785                	addi	a5,a5,1
 28a:	fee79de3          	bne	a5,a4,284 <memset+0x12>
  }
  return dst;
}
 28e:	6422                	ld	s0,8(sp)
 290:	0141                	addi	sp,sp,16
 292:	8082                	ret

0000000000000294 <strchr>:

char*
strchr(const char *s, char c)
{
 294:	1141                	addi	sp,sp,-16
 296:	e422                	sd	s0,8(sp)
 298:	0800                	addi	s0,sp,16
  for(; *s; s++)
 29a:	00054783          	lbu	a5,0(a0)
 29e:	cb99                	beqz	a5,2b4 <strchr+0x20>
    if(*s == c)
 2a0:	00f58763          	beq	a1,a5,2ae <strchr+0x1a>
  for(; *s; s++)
 2a4:	0505                	addi	a0,a0,1
 2a6:	00054783          	lbu	a5,0(a0)
 2aa:	fbfd                	bnez	a5,2a0 <strchr+0xc>
      return (char*)s;
  return 0;
 2ac:	4501                	li	a0,0
}
 2ae:	6422                	ld	s0,8(sp)
 2b0:	0141                	addi	sp,sp,16
 2b2:	8082                	ret
  return 0;
 2b4:	4501                	li	a0,0
 2b6:	bfe5                	j	2ae <strchr+0x1a>

00000000000002b8 <gets>:

char*
gets(char *buf, int max)
{
 2b8:	711d                	addi	sp,sp,-96
 2ba:	ec86                	sd	ra,88(sp)
 2bc:	e8a2                	sd	s0,80(sp)
 2be:	e4a6                	sd	s1,72(sp)
 2c0:	e0ca                	sd	s2,64(sp)
 2c2:	fc4e                	sd	s3,56(sp)
 2c4:	f852                	sd	s4,48(sp)
 2c6:	f456                	sd	s5,40(sp)
 2c8:	f05a                	sd	s6,32(sp)
 2ca:	ec5e                	sd	s7,24(sp)
 2cc:	1080                	addi	s0,sp,96
 2ce:	8baa                	mv	s7,a0
 2d0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2d2:	892a                	mv	s2,a0
 2d4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2d6:	4aa9                	li	s5,10
 2d8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2da:	89a6                	mv	s3,s1
 2dc:	2485                	addiw	s1,s1,1
 2de:	0344d863          	bge	s1,s4,30e <gets+0x56>
    cc = read(0, &c, 1);
 2e2:	4605                	li	a2,1
 2e4:	faf40593          	addi	a1,s0,-81
 2e8:	4501                	li	a0,0
 2ea:	00000097          	auipc	ra,0x0
 2ee:	19a080e7          	jalr	410(ra) # 484 <read>
    if(cc < 1)
 2f2:	00a05e63          	blez	a0,30e <gets+0x56>
    buf[i++] = c;
 2f6:	faf44783          	lbu	a5,-81(s0)
 2fa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2fe:	01578763          	beq	a5,s5,30c <gets+0x54>
 302:	0905                	addi	s2,s2,1
 304:	fd679be3          	bne	a5,s6,2da <gets+0x22>
    buf[i++] = c;
 308:	89a6                	mv	s3,s1
 30a:	a011                	j	30e <gets+0x56>
 30c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 30e:	99de                	add	s3,s3,s7
 310:	00098023          	sb	zero,0(s3)
  return buf;
}
 314:	855e                	mv	a0,s7
 316:	60e6                	ld	ra,88(sp)
 318:	6446                	ld	s0,80(sp)
 31a:	64a6                	ld	s1,72(sp)
 31c:	6906                	ld	s2,64(sp)
 31e:	79e2                	ld	s3,56(sp)
 320:	7a42                	ld	s4,48(sp)
 322:	7aa2                	ld	s5,40(sp)
 324:	7b02                	ld	s6,32(sp)
 326:	6be2                	ld	s7,24(sp)
 328:	6125                	addi	sp,sp,96
 32a:	8082                	ret

000000000000032c <stat>:

int
stat(const char *n, struct stat *st)
{
 32c:	1101                	addi	sp,sp,-32
 32e:	ec06                	sd	ra,24(sp)
 330:	e822                	sd	s0,16(sp)
 332:	e04a                	sd	s2,0(sp)
 334:	1000                	addi	s0,sp,32
 336:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 338:	4581                	li	a1,0
 33a:	00000097          	auipc	ra,0x0
 33e:	172080e7          	jalr	370(ra) # 4ac <open>
  if(fd < 0)
 342:	02054663          	bltz	a0,36e <stat+0x42>
 346:	e426                	sd	s1,8(sp)
 348:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 34a:	85ca                	mv	a1,s2
 34c:	00000097          	auipc	ra,0x0
 350:	178080e7          	jalr	376(ra) # 4c4 <fstat>
 354:	892a                	mv	s2,a0
  close(fd);
 356:	8526                	mv	a0,s1
 358:	00000097          	auipc	ra,0x0
 35c:	13c080e7          	jalr	316(ra) # 494 <close>
  return r;
 360:	64a2                	ld	s1,8(sp)
}
 362:	854a                	mv	a0,s2
 364:	60e2                	ld	ra,24(sp)
 366:	6442                	ld	s0,16(sp)
 368:	6902                	ld	s2,0(sp)
 36a:	6105                	addi	sp,sp,32
 36c:	8082                	ret
    return -1;
 36e:	597d                	li	s2,-1
 370:	bfcd                	j	362 <stat+0x36>

0000000000000372 <atoi>:

int
atoi(const char *s)
{
 372:	1141                	addi	sp,sp,-16
 374:	e422                	sd	s0,8(sp)
 376:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 378:	00054683          	lbu	a3,0(a0)
 37c:	fd06879b          	addiw	a5,a3,-48
 380:	0ff7f793          	zext.b	a5,a5
 384:	4625                	li	a2,9
 386:	02f66863          	bltu	a2,a5,3b6 <atoi+0x44>
 38a:	872a                	mv	a4,a0
  n = 0;
 38c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 38e:	0705                	addi	a4,a4,1
 390:	0025179b          	slliw	a5,a0,0x2
 394:	9fa9                	addw	a5,a5,a0
 396:	0017979b          	slliw	a5,a5,0x1
 39a:	9fb5                	addw	a5,a5,a3
 39c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3a0:	00074683          	lbu	a3,0(a4)
 3a4:	fd06879b          	addiw	a5,a3,-48
 3a8:	0ff7f793          	zext.b	a5,a5
 3ac:	fef671e3          	bgeu	a2,a5,38e <atoi+0x1c>
  return n;
}
 3b0:	6422                	ld	s0,8(sp)
 3b2:	0141                	addi	sp,sp,16
 3b4:	8082                	ret
  n = 0;
 3b6:	4501                	li	a0,0
 3b8:	bfe5                	j	3b0 <atoi+0x3e>

00000000000003ba <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3ba:	1141                	addi	sp,sp,-16
 3bc:	e422                	sd	s0,8(sp)
 3be:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3c0:	02b57463          	bgeu	a0,a1,3e8 <memmove+0x2e>
    while(n-- > 0)
 3c4:	00c05f63          	blez	a2,3e2 <memmove+0x28>
 3c8:	1602                	slli	a2,a2,0x20
 3ca:	9201                	srli	a2,a2,0x20
 3cc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3d0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3d2:	0585                	addi	a1,a1,1
 3d4:	0705                	addi	a4,a4,1
 3d6:	fff5c683          	lbu	a3,-1(a1)
 3da:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3de:	fef71ae3          	bne	a4,a5,3d2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3e2:	6422                	ld	s0,8(sp)
 3e4:	0141                	addi	sp,sp,16
 3e6:	8082                	ret
    dst += n;
 3e8:	00c50733          	add	a4,a0,a2
    src += n;
 3ec:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3ee:	fec05ae3          	blez	a2,3e2 <memmove+0x28>
 3f2:	fff6079b          	addiw	a5,a2,-1
 3f6:	1782                	slli	a5,a5,0x20
 3f8:	9381                	srli	a5,a5,0x20
 3fa:	fff7c793          	not	a5,a5
 3fe:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 400:	15fd                	addi	a1,a1,-1
 402:	177d                	addi	a4,a4,-1
 404:	0005c683          	lbu	a3,0(a1)
 408:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 40c:	fee79ae3          	bne	a5,a4,400 <memmove+0x46>
 410:	bfc9                	j	3e2 <memmove+0x28>

0000000000000412 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 412:	1141                	addi	sp,sp,-16
 414:	e422                	sd	s0,8(sp)
 416:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 418:	ca05                	beqz	a2,448 <memcmp+0x36>
 41a:	fff6069b          	addiw	a3,a2,-1
 41e:	1682                	slli	a3,a3,0x20
 420:	9281                	srli	a3,a3,0x20
 422:	0685                	addi	a3,a3,1
 424:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 426:	00054783          	lbu	a5,0(a0)
 42a:	0005c703          	lbu	a4,0(a1)
 42e:	00e79863          	bne	a5,a4,43e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 432:	0505                	addi	a0,a0,1
    p2++;
 434:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 436:	fed518e3          	bne	a0,a3,426 <memcmp+0x14>
  }
  return 0;
 43a:	4501                	li	a0,0
 43c:	a019                	j	442 <memcmp+0x30>
      return *p1 - *p2;
 43e:	40e7853b          	subw	a0,a5,a4
}
 442:	6422                	ld	s0,8(sp)
 444:	0141                	addi	sp,sp,16
 446:	8082                	ret
  return 0;
 448:	4501                	li	a0,0
 44a:	bfe5                	j	442 <memcmp+0x30>

000000000000044c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 44c:	1141                	addi	sp,sp,-16
 44e:	e406                	sd	ra,8(sp)
 450:	e022                	sd	s0,0(sp)
 452:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 454:	00000097          	auipc	ra,0x0
 458:	f66080e7          	jalr	-154(ra) # 3ba <memmove>
}
 45c:	60a2                	ld	ra,8(sp)
 45e:	6402                	ld	s0,0(sp)
 460:	0141                	addi	sp,sp,16
 462:	8082                	ret

0000000000000464 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 464:	4885                	li	a7,1
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <exit>:
.global exit
exit:
 li a7, SYS_exit
 46c:	4889                	li	a7,2
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <wait>:
.global wait
wait:
 li a7, SYS_wait
 474:	488d                	li	a7,3
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 47c:	4891                	li	a7,4
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <read>:
.global read
read:
 li a7, SYS_read
 484:	4895                	li	a7,5
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <write>:
.global write
write:
 li a7, SYS_write
 48c:	48c1                	li	a7,16
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <close>:
.global close
close:
 li a7, SYS_close
 494:	48d5                	li	a7,21
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <kill>:
.global kill
kill:
 li a7, SYS_kill
 49c:	4899                	li	a7,6
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4a4:	489d                	li	a7,7
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <open>:
.global open
open:
 li a7, SYS_open
 4ac:	48bd                	li	a7,15
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4b4:	48c5                	li	a7,17
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4bc:	48c9                	li	a7,18
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4c4:	48a1                	li	a7,8
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <link>:
.global link
link:
 li a7, SYS_link
 4cc:	48cd                	li	a7,19
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4d4:	48d1                	li	a7,20
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4dc:	48a5                	li	a7,9
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4e4:	48a9                	li	a7,10
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4ec:	48ad                	li	a7,11
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4f4:	48b1                	li	a7,12
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4fc:	48b5                	li	a7,13
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 504:	48b9                	li	a7,14
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <ps>:
.global ps
ps:
 li a7, SYS_ps
 50c:	48d9                	li	a7,22
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 514:	48dd                	li	a7,23
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 51c:	48e1                	li	a7,24
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 524:	48e9                	li	a7,26
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 52c:	48e5                	li	a7,25
 ecall
 52e:	00000073          	ecall
 ret
 532:	8082                	ret

0000000000000534 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 534:	1101                	addi	sp,sp,-32
 536:	ec06                	sd	ra,24(sp)
 538:	e822                	sd	s0,16(sp)
 53a:	1000                	addi	s0,sp,32
 53c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 540:	4605                	li	a2,1
 542:	fef40593          	addi	a1,s0,-17
 546:	00000097          	auipc	ra,0x0
 54a:	f46080e7          	jalr	-186(ra) # 48c <write>
}
 54e:	60e2                	ld	ra,24(sp)
 550:	6442                	ld	s0,16(sp)
 552:	6105                	addi	sp,sp,32
 554:	8082                	ret

0000000000000556 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 556:	7139                	addi	sp,sp,-64
 558:	fc06                	sd	ra,56(sp)
 55a:	f822                	sd	s0,48(sp)
 55c:	f426                	sd	s1,40(sp)
 55e:	0080                	addi	s0,sp,64
 560:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 562:	c299                	beqz	a3,568 <printint+0x12>
 564:	0805cb63          	bltz	a1,5fa <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 568:	2581                	sext.w	a1,a1
  neg = 0;
 56a:	4881                	li	a7,0
 56c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 570:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 572:	2601                	sext.w	a2,a2
 574:	00000517          	auipc	a0,0x0
 578:	51450513          	addi	a0,a0,1300 # a88 <digits>
 57c:	883a                	mv	a6,a4
 57e:	2705                	addiw	a4,a4,1
 580:	02c5f7bb          	remuw	a5,a1,a2
 584:	1782                	slli	a5,a5,0x20
 586:	9381                	srli	a5,a5,0x20
 588:	97aa                	add	a5,a5,a0
 58a:	0007c783          	lbu	a5,0(a5)
 58e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 592:	0005879b          	sext.w	a5,a1
 596:	02c5d5bb          	divuw	a1,a1,a2
 59a:	0685                	addi	a3,a3,1
 59c:	fec7f0e3          	bgeu	a5,a2,57c <printint+0x26>
  if(neg)
 5a0:	00088c63          	beqz	a7,5b8 <printint+0x62>
    buf[i++] = '-';
 5a4:	fd070793          	addi	a5,a4,-48
 5a8:	00878733          	add	a4,a5,s0
 5ac:	02d00793          	li	a5,45
 5b0:	fef70823          	sb	a5,-16(a4)
 5b4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5b8:	02e05c63          	blez	a4,5f0 <printint+0x9a>
 5bc:	f04a                	sd	s2,32(sp)
 5be:	ec4e                	sd	s3,24(sp)
 5c0:	fc040793          	addi	a5,s0,-64
 5c4:	00e78933          	add	s2,a5,a4
 5c8:	fff78993          	addi	s3,a5,-1
 5cc:	99ba                	add	s3,s3,a4
 5ce:	377d                	addiw	a4,a4,-1
 5d0:	1702                	slli	a4,a4,0x20
 5d2:	9301                	srli	a4,a4,0x20
 5d4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5d8:	fff94583          	lbu	a1,-1(s2)
 5dc:	8526                	mv	a0,s1
 5de:	00000097          	auipc	ra,0x0
 5e2:	f56080e7          	jalr	-170(ra) # 534 <putc>
  while(--i >= 0)
 5e6:	197d                	addi	s2,s2,-1
 5e8:	ff3918e3          	bne	s2,s3,5d8 <printint+0x82>
 5ec:	7902                	ld	s2,32(sp)
 5ee:	69e2                	ld	s3,24(sp)
}
 5f0:	70e2                	ld	ra,56(sp)
 5f2:	7442                	ld	s0,48(sp)
 5f4:	74a2                	ld	s1,40(sp)
 5f6:	6121                	addi	sp,sp,64
 5f8:	8082                	ret
    x = -xx;
 5fa:	40b005bb          	negw	a1,a1
    neg = 1;
 5fe:	4885                	li	a7,1
    x = -xx;
 600:	b7b5                	j	56c <printint+0x16>

0000000000000602 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 602:	715d                	addi	sp,sp,-80
 604:	e486                	sd	ra,72(sp)
 606:	e0a2                	sd	s0,64(sp)
 608:	f84a                	sd	s2,48(sp)
 60a:	0880                	addi	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 60c:	0005c903          	lbu	s2,0(a1)
 610:	1a090a63          	beqz	s2,7c4 <vprintf+0x1c2>
 614:	fc26                	sd	s1,56(sp)
 616:	f44e                	sd	s3,40(sp)
 618:	f052                	sd	s4,32(sp)
 61a:	ec56                	sd	s5,24(sp)
 61c:	e85a                	sd	s6,16(sp)
 61e:	e45e                	sd	s7,8(sp)
 620:	8aaa                	mv	s5,a0
 622:	8bb2                	mv	s7,a2
 624:	00158493          	addi	s1,a1,1
  state = 0;
 628:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 62a:	02500a13          	li	s4,37
 62e:	4b55                	li	s6,21
 630:	a839                	j	64e <vprintf+0x4c>
        putc(fd, c);
 632:	85ca                	mv	a1,s2
 634:	8556                	mv	a0,s5
 636:	00000097          	auipc	ra,0x0
 63a:	efe080e7          	jalr	-258(ra) # 534 <putc>
 63e:	a019                	j	644 <vprintf+0x42>
    } else if(state == '%'){
 640:	01498d63          	beq	s3,s4,65a <vprintf+0x58>
  for(i = 0; fmt[i]; i++){
 644:	0485                	addi	s1,s1,1
 646:	fff4c903          	lbu	s2,-1(s1)
 64a:	16090763          	beqz	s2,7b8 <vprintf+0x1b6>
    if(state == 0){
 64e:	fe0999e3          	bnez	s3,640 <vprintf+0x3e>
      if(c == '%'){
 652:	ff4910e3          	bne	s2,s4,632 <vprintf+0x30>
        state = '%';
 656:	89d2                	mv	s3,s4
 658:	b7f5                	j	644 <vprintf+0x42>
      if(c == 'd'){
 65a:	13490463          	beq	s2,s4,782 <vprintf+0x180>
 65e:	f9d9079b          	addiw	a5,s2,-99
 662:	0ff7f793          	zext.b	a5,a5
 666:	12fb6763          	bltu	s6,a5,794 <vprintf+0x192>
 66a:	f9d9079b          	addiw	a5,s2,-99
 66e:	0ff7f713          	zext.b	a4,a5
 672:	12eb6163          	bltu	s6,a4,794 <vprintf+0x192>
 676:	00271793          	slli	a5,a4,0x2
 67a:	00000717          	auipc	a4,0x0
 67e:	3b670713          	addi	a4,a4,950 # a30 <malloc+0x17c>
 682:	97ba                	add	a5,a5,a4
 684:	439c                	lw	a5,0(a5)
 686:	97ba                	add	a5,a5,a4
 688:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 68a:	008b8913          	addi	s2,s7,8
 68e:	4685                	li	a3,1
 690:	4629                	li	a2,10
 692:	000ba583          	lw	a1,0(s7)
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	ebe080e7          	jalr	-322(ra) # 556 <printint>
 6a0:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b745                	j	644 <vprintf+0x42>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000ba583          	lw	a1,0(s7)
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	ea2080e7          	jalr	-350(ra) # 556 <printint>
 6bc:	8bca                	mv	s7,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b751                	j	644 <vprintf+0x42>
        printint(fd, va_arg(ap, int), 16, 0);
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	4681                	li	a3,0
 6c8:	4641                	li	a2,16
 6ca:	000ba583          	lw	a1,0(s7)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e86080e7          	jalr	-378(ra) # 556 <printint>
 6d8:	8bca                	mv	s7,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	b7a5                	j	644 <vprintf+0x42>
 6de:	e062                	sd	s8,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6e0:	008b8c13          	addi	s8,s7,8
 6e4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6e8:	03000593          	li	a1,48
 6ec:	8556                	mv	a0,s5
 6ee:	00000097          	auipc	ra,0x0
 6f2:	e46080e7          	jalr	-442(ra) # 534 <putc>
  putc(fd, 'x');
 6f6:	07800593          	li	a1,120
 6fa:	8556                	mv	a0,s5
 6fc:	00000097          	auipc	ra,0x0
 700:	e38080e7          	jalr	-456(ra) # 534 <putc>
 704:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 706:	00000b97          	auipc	s7,0x0
 70a:	382b8b93          	addi	s7,s7,898 # a88 <digits>
 70e:	03c9d793          	srli	a5,s3,0x3c
 712:	97de                	add	a5,a5,s7
 714:	0007c583          	lbu	a1,0(a5)
 718:	8556                	mv	a0,s5
 71a:	00000097          	auipc	ra,0x0
 71e:	e1a080e7          	jalr	-486(ra) # 534 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 722:	0992                	slli	s3,s3,0x4
 724:	397d                	addiw	s2,s2,-1
 726:	fe0914e3          	bnez	s2,70e <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 72a:	8be2                	mv	s7,s8
      state = 0;
 72c:	4981                	li	s3,0
 72e:	6c02                	ld	s8,0(sp)
 730:	bf11                	j	644 <vprintf+0x42>
        s = va_arg(ap, char*);
 732:	008b8993          	addi	s3,s7,8
 736:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 73a:	02090163          	beqz	s2,75c <vprintf+0x15a>
        while(*s != 0){
 73e:	00094583          	lbu	a1,0(s2)
 742:	c9a5                	beqz	a1,7b2 <vprintf+0x1b0>
          putc(fd, *s);
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	dee080e7          	jalr	-530(ra) # 534 <putc>
          s++;
 74e:	0905                	addi	s2,s2,1
        while(*s != 0){
 750:	00094583          	lbu	a1,0(s2)
 754:	f9e5                	bnez	a1,744 <vprintf+0x142>
        s = va_arg(ap, char*);
 756:	8bce                	mv	s7,s3
      state = 0;
 758:	4981                	li	s3,0
 75a:	b5ed                	j	644 <vprintf+0x42>
          s = "(null)";
 75c:	00000917          	auipc	s2,0x0
 760:	2cc90913          	addi	s2,s2,716 # a28 <malloc+0x174>
        while(*s != 0){
 764:	02800593          	li	a1,40
 768:	bff1                	j	744 <vprintf+0x142>
        putc(fd, va_arg(ap, uint));
 76a:	008b8913          	addi	s2,s7,8
 76e:	000bc583          	lbu	a1,0(s7)
 772:	8556                	mv	a0,s5
 774:	00000097          	auipc	ra,0x0
 778:	dc0080e7          	jalr	-576(ra) # 534 <putc>
 77c:	8bca                	mv	s7,s2
      state = 0;
 77e:	4981                	li	s3,0
 780:	b5d1                	j	644 <vprintf+0x42>
        putc(fd, c);
 782:	02500593          	li	a1,37
 786:	8556                	mv	a0,s5
 788:	00000097          	auipc	ra,0x0
 78c:	dac080e7          	jalr	-596(ra) # 534 <putc>
      state = 0;
 790:	4981                	li	s3,0
 792:	bd4d                	j	644 <vprintf+0x42>
        putc(fd, '%');
 794:	02500593          	li	a1,37
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	d9a080e7          	jalr	-614(ra) # 534 <putc>
        putc(fd, c);
 7a2:	85ca                	mv	a1,s2
 7a4:	8556                	mv	a0,s5
 7a6:	00000097          	auipc	ra,0x0
 7aa:	d8e080e7          	jalr	-626(ra) # 534 <putc>
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	bd51                	j	644 <vprintf+0x42>
        s = va_arg(ap, char*);
 7b2:	8bce                	mv	s7,s3
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	b579                	j	644 <vprintf+0x42>
 7b8:	74e2                	ld	s1,56(sp)
 7ba:	79a2                	ld	s3,40(sp)
 7bc:	7a02                	ld	s4,32(sp)
 7be:	6ae2                	ld	s5,24(sp)
 7c0:	6b42                	ld	s6,16(sp)
 7c2:	6ba2                	ld	s7,8(sp)
    }
  }
}
 7c4:	60a6                	ld	ra,72(sp)
 7c6:	6406                	ld	s0,64(sp)
 7c8:	7942                	ld	s2,48(sp)
 7ca:	6161                	addi	sp,sp,80
 7cc:	8082                	ret

00000000000007ce <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ce:	715d                	addi	sp,sp,-80
 7d0:	ec06                	sd	ra,24(sp)
 7d2:	e822                	sd	s0,16(sp)
 7d4:	1000                	addi	s0,sp,32
 7d6:	e010                	sd	a2,0(s0)
 7d8:	e414                	sd	a3,8(s0)
 7da:	e818                	sd	a4,16(s0)
 7dc:	ec1c                	sd	a5,24(s0)
 7de:	03043023          	sd	a6,32(s0)
 7e2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ea:	8622                	mv	a2,s0
 7ec:	00000097          	auipc	ra,0x0
 7f0:	e16080e7          	jalr	-490(ra) # 602 <vprintf>
}
 7f4:	60e2                	ld	ra,24(sp)
 7f6:	6442                	ld	s0,16(sp)
 7f8:	6161                	addi	sp,sp,80
 7fa:	8082                	ret

00000000000007fc <printf>:

void
printf(const char *fmt, ...)
{
 7fc:	711d                	addi	sp,sp,-96
 7fe:	ec06                	sd	ra,24(sp)
 800:	e822                	sd	s0,16(sp)
 802:	1000                	addi	s0,sp,32
 804:	e40c                	sd	a1,8(s0)
 806:	e810                	sd	a2,16(s0)
 808:	ec14                	sd	a3,24(s0)
 80a:	f018                	sd	a4,32(s0)
 80c:	f41c                	sd	a5,40(s0)
 80e:	03043823          	sd	a6,48(s0)
 812:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 816:	00840613          	addi	a2,s0,8
 81a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81e:	85aa                	mv	a1,a0
 820:	4505                	li	a0,1
 822:	00000097          	auipc	ra,0x0
 826:	de0080e7          	jalr	-544(ra) # 602 <vprintf>
}
 82a:	60e2                	ld	ra,24(sp)
 82c:	6442                	ld	s0,16(sp)
 82e:	6125                	addi	sp,sp,96
 830:	8082                	ret

0000000000000832 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 832:	1141                	addi	sp,sp,-16
 834:	e422                	sd	s0,8(sp)
 836:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 838:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83c:	00001797          	auipc	a5,0x1
 840:	c347b783          	ld	a5,-972(a5) # 1470 <freep>
 844:	a02d                	j	86e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 846:	4618                	lw	a4,8(a2)
 848:	9f2d                	addw	a4,a4,a1
 84a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 84e:	6398                	ld	a4,0(a5)
 850:	6310                	ld	a2,0(a4)
 852:	a83d                	j	890 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 854:	ff852703          	lw	a4,-8(a0)
 858:	9f31                	addw	a4,a4,a2
 85a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 85c:	ff053683          	ld	a3,-16(a0)
 860:	a091                	j	8a4 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 862:	6398                	ld	a4,0(a5)
 864:	00e7e463          	bltu	a5,a4,86c <free+0x3a>
 868:	00e6ea63          	bltu	a3,a4,87c <free+0x4a>
{
 86c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86e:	fed7fae3          	bgeu	a5,a3,862 <free+0x30>
 872:	6398                	ld	a4,0(a5)
 874:	00e6e463          	bltu	a3,a4,87c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 878:	fee7eae3          	bltu	a5,a4,86c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 87c:	ff852583          	lw	a1,-8(a0)
 880:	6390                	ld	a2,0(a5)
 882:	02059813          	slli	a6,a1,0x20
 886:	01c85713          	srli	a4,a6,0x1c
 88a:	9736                	add	a4,a4,a3
 88c:	fae60de3          	beq	a2,a4,846 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 890:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 894:	4790                	lw	a2,8(a5)
 896:	02061593          	slli	a1,a2,0x20
 89a:	01c5d713          	srli	a4,a1,0x1c
 89e:	973e                	add	a4,a4,a5
 8a0:	fae68ae3          	beq	a3,a4,854 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a6:	00001717          	auipc	a4,0x1
 8aa:	bcf73523          	sd	a5,-1078(a4) # 1470 <freep>
}
 8ae:	6422                	ld	s0,8(sp)
 8b0:	0141                	addi	sp,sp,16
 8b2:	8082                	ret

00000000000008b4 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b4:	7139                	addi	sp,sp,-64
 8b6:	fc06                	sd	ra,56(sp)
 8b8:	f822                	sd	s0,48(sp)
 8ba:	f426                	sd	s1,40(sp)
 8bc:	ec4e                	sd	s3,24(sp)
 8be:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c0:	02051493          	slli	s1,a0,0x20
 8c4:	9081                	srli	s1,s1,0x20
 8c6:	04bd                	addi	s1,s1,15
 8c8:	8091                	srli	s1,s1,0x4
 8ca:	0014899b          	addiw	s3,s1,1
 8ce:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d0:	00001517          	auipc	a0,0x1
 8d4:	ba053503          	ld	a0,-1120(a0) # 1470 <freep>
 8d8:	c915                	beqz	a0,90c <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8da:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8dc:	4798                	lw	a4,8(a5)
 8de:	08977e63          	bgeu	a4,s1,97a <malloc+0xc6>
 8e2:	f04a                	sd	s2,32(sp)
 8e4:	e852                	sd	s4,16(sp)
 8e6:	e456                	sd	s5,8(sp)
 8e8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8ea:	8a4e                	mv	s4,s3
 8ec:	0009871b          	sext.w	a4,s3
 8f0:	6685                	lui	a3,0x1
 8f2:	00d77363          	bgeu	a4,a3,8f8 <malloc+0x44>
 8f6:	6a05                	lui	s4,0x1
 8f8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8fc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 900:	00001917          	auipc	s2,0x1
 904:	b7090913          	addi	s2,s2,-1168 # 1470 <freep>
  if(p == (char*)-1)
 908:	5afd                	li	s5,-1
 90a:	a091                	j	94e <malloc+0x9a>
 90c:	f04a                	sd	s2,32(sp)
 90e:	e852                	sd	s4,16(sp)
 910:	e456                	sd	s5,8(sp)
 912:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 914:	00001797          	auipc	a5,0x1
 918:	b6c78793          	addi	a5,a5,-1172 # 1480 <base>
 91c:	00001717          	auipc	a4,0x1
 920:	b4f73a23          	sd	a5,-1196(a4) # 1470 <freep>
 924:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 926:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92a:	b7c1                	j	8ea <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 92c:	6398                	ld	a4,0(a5)
 92e:	e118                	sd	a4,0(a0)
 930:	a08d                	j	992 <malloc+0xde>
  hp->s.size = nu;
 932:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 936:	0541                	addi	a0,a0,16
 938:	00000097          	auipc	ra,0x0
 93c:	efa080e7          	jalr	-262(ra) # 832 <free>
  return freep;
 940:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 944:	c13d                	beqz	a0,9aa <malloc+0xf6>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 946:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 948:	4798                	lw	a4,8(a5)
 94a:	02977463          	bgeu	a4,s1,972 <malloc+0xbe>
    if(p == freep)
 94e:	00093703          	ld	a4,0(s2)
 952:	853e                	mv	a0,a5
 954:	fef719e3          	bne	a4,a5,946 <malloc+0x92>
  p = sbrk(nu * sizeof(Header));
 958:	8552                	mv	a0,s4
 95a:	00000097          	auipc	ra,0x0
 95e:	b9a080e7          	jalr	-1126(ra) # 4f4 <sbrk>
  if(p == (char*)-1)
 962:	fd5518e3          	bne	a0,s5,932 <malloc+0x7e>
        return 0;
 966:	4501                	li	a0,0
 968:	7902                	ld	s2,32(sp)
 96a:	6a42                	ld	s4,16(sp)
 96c:	6aa2                	ld	s5,8(sp)
 96e:	6b02                	ld	s6,0(sp)
 970:	a03d                	j	99e <malloc+0xea>
 972:	7902                	ld	s2,32(sp)
 974:	6a42                	ld	s4,16(sp)
 976:	6aa2                	ld	s5,8(sp)
 978:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 97a:	fae489e3          	beq	s1,a4,92c <malloc+0x78>
        p->s.size -= nunits;
 97e:	4137073b          	subw	a4,a4,s3
 982:	c798                	sw	a4,8(a5)
        p += p->s.size;
 984:	02071693          	slli	a3,a4,0x20
 988:	01c6d713          	srli	a4,a3,0x1c
 98c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 992:	00001717          	auipc	a4,0x1
 996:	aca73f23          	sd	a0,-1314(a4) # 1470 <freep>
      return (void*)(p + 1);
 99a:	01078513          	addi	a0,a5,16
  }
}
 99e:	70e2                	ld	ra,56(sp)
 9a0:	7442                	ld	s0,48(sp)
 9a2:	74a2                	ld	s1,40(sp)
 9a4:	69e2                	ld	s3,24(sp)
 9a6:	6121                	addi	sp,sp,64
 9a8:	8082                	ret
 9aa:	7902                	ld	s2,32(sp)
 9ac:	6a42                	ld	s4,16(sp)
 9ae:	6aa2                	ld	s5,8(sp)
 9b0:	6b02                	ld	s6,0(sp)
 9b2:	b7f5                	j	99e <malloc+0xea>
