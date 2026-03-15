
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
  48:	96c50513          	addi	a0,a0,-1684 # 9b0 <malloc+0xf0>
  4c:	00000097          	auipc	ra,0x0
  50:	7bc080e7          	jalr	1980(ra) # 808 <printf>
    exit(1);
  54:	4505                	li	a0,1
  56:	00000097          	auipc	ra,0x0
  5a:	410080e7          	jalr	1040(ra) # 466 <exit>

000000000000005e <str_hex>:

uint64 str_hex(char* str)
{
  5e:	7179                	addi	sp,sp,-48
  60:	f406                	sd	ra,40(sp)
  62:	f022                	sd	s0,32(sp)
  64:	ec26                	sd	s1,24(sp)
  66:	e84a                	sd	s2,16(sp)
  68:	e44e                	sd	s3,8(sp)
  6a:	e052                	sd	s4,0(sp)
  6c:	1800                	addi	s0,sp,48
    int start = 0;
    if (str[0] == '0' || str[1] == 'x') {
  6e:	00054683          	lbu	a3,0(a0)
  72:	03000713          	li	a4,48
	start = 2;
  76:	4789                	li	a5,2
    if (str[0] == '0' || str[1] == 'x') {
  78:	00e68a63          	beq	a3,a4,8c <str_hex+0x2e>
  7c:	00154783          	lbu	a5,1(a0)
  80:	f8878793          	addi	a5,a5,-120
  84:	0017b793          	seqz	a5,a5
  88:	0017979b          	slliw	a5,a5,0x1
    }
    char *c = str + start;
  8c:	00f50933          	add	s2,a0,a5
    int offset = -1;
    while (*c != '\0') {
  90:	00094783          	lbu	a5,0(s2)
  94:	c7a9                	beqz	a5,de <str_hex+0x80>
    char *c = str + start;
  96:	87ca                	mv	a5,s2
    int offset = -1;
  98:	54fd                	li	s1,-1
	offset++;
  9a:	2485                	addiw	s1,s1,1
	c++;
  9c:	0785                	addi	a5,a5,1
    while (*c != '\0') {
  9e:	0007c703          	lbu	a4,0(a5)
  a2:	ff65                	bnez	a4,9a <str_hex+0x3c>
    }

    uint64 num = 0;

    for (c = str + start; offset >= 0; offset--)
  a4:	0204cf63          	bltz	s1,e2 <str_hex+0x84>
    uint64 num = 0;
  a8:	4981                	li	s3,0
    for (c = str + start; offset >= 0; offset--)
  aa:	5a7d                	li	s4,-1
    {
	int val = hex_int(*c);
  ac:	00094503          	lbu	a0,0(s2)
  b0:	00000097          	auipc	ra,0x0
  b4:	f50080e7          	jalr	-176(ra) # 0 <hex_int>
	num |= val << (offset * 4);
  b8:	0024979b          	slliw	a5,s1,0x2
  bc:	00f5153b          	sllw	a0,a0,a5
  c0:	00a9e9b3          	or	s3,s3,a0
	c++;
  c4:	0905                	addi	s2,s2,1
    for (c = str + start; offset >= 0; offset--)
  c6:	34fd                	addiw	s1,s1,-1
  c8:	ff4492e3          	bne	s1,s4,ac <str_hex+0x4e>
    }
    return num;
}
  cc:	854e                	mv	a0,s3
  ce:	70a2                	ld	ra,40(sp)
  d0:	7402                	ld	s0,32(sp)
  d2:	64e2                	ld	s1,24(sp)
  d4:	6942                	ld	s2,16(sp)
  d6:	69a2                	ld	s3,8(sp)
  d8:	6a02                	ld	s4,0(sp)
  da:	6145                	addi	sp,sp,48
  dc:	8082                	ret
    uint64 num = 0;
  de:	4981                	li	s3,0
  e0:	b7f5                	j	cc <str_hex+0x6e>
  e2:	4981                	li	s3,0
    return num;
  e4:	b7e5                	j	cc <str_hex+0x6e>

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
 146:	88e50513          	addi	a0,a0,-1906 # 9d0 <malloc+0x110>
 14a:	00000097          	auipc	ra,0x0
 14e:	6be080e7          	jalr	1726(ra) # 808 <printf>
	    exit(1);
 152:	4505                	li	a0,1
 154:	00000097          	auipc	ra,0x0
 158:	312080e7          	jalr	786(ra) # 466 <exit>
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
 16a:	ec26                	sd	s1,24(sp)
 16c:	e84a                	sd	s2,16(sp)
 16e:	e44e                	sd	s3,8(sp)
 170:	1800                	addi	s0,sp,48
    if (argc < 2)
 172:	4785                	li	a5,1
 174:	04a7d163          	bge	a5,a0,1b6 <main+0x52>
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
 18c:	04f48263          	beq	s1,a5,1d0 <main+0x6c>
	pid = str_int(argv[2]);		
    }
    printf("0x%x\n", va2pa(vaddr, pid));
 190:	854e                	mv	a0,s3
 192:	00000097          	auipc	ra,0x0
 196:	38c080e7          	jalr	908(ra) # 51e <va2pa>
 19a:	85aa                	mv	a1,a0
 19c:	00001517          	auipc	a0,0x1
 1a0:	87450513          	addi	a0,a0,-1932 # a10 <malloc+0x150>
 1a4:	00000097          	auipc	ra,0x0
 1a8:	664080e7          	jalr	1636(ra) # 808 <printf>
    exit(0);
 1ac:	4501                	li	a0,0
 1ae:	00000097          	auipc	ra,0x0
 1b2:	2b8080e7          	jalr	696(ra) # 466 <exit>
	printf("Usage: vatopa virtual_address [pid]\n");
 1b6:	00001517          	auipc	a0,0x1
 1ba:	83250513          	addi	a0,a0,-1998 # 9e8 <malloc+0x128>
 1be:	00000097          	auipc	ra,0x0
 1c2:	64a080e7          	jalr	1610(ra) # 808 <printf>
	exit(1);
 1c6:	4505                	li	a0,1
 1c8:	00000097          	auipc	ra,0x0
 1cc:	29e080e7          	jalr	670(ra) # 466 <exit>
	pid = str_int(argv[2]);		
 1d0:	01093503          	ld	a0,16(s2)
 1d4:	00000097          	auipc	ra,0x0
 1d8:	f12080e7          	jalr	-238(ra) # e6 <str_int>
 1dc:	85aa                	mv	a1,a0
 1de:	bf4d                	j	190 <main+0x2c>

00000000000001e0 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 1e0:	1141                	addi	sp,sp,-16
 1e2:	e406                	sd	ra,8(sp)
 1e4:	e022                	sd	s0,0(sp)
 1e6:	0800                	addi	s0,sp,16
  extern int main();
  main();
 1e8:	00000097          	auipc	ra,0x0
 1ec:	f7c080e7          	jalr	-132(ra) # 164 <main>
  exit(0);
 1f0:	4501                	li	a0,0
 1f2:	00000097          	auipc	ra,0x0
 1f6:	274080e7          	jalr	628(ra) # 466 <exit>

00000000000001fa <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1fa:	1141                	addi	sp,sp,-16
 1fc:	e422                	sd	s0,8(sp)
 1fe:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 200:	87aa                	mv	a5,a0
 202:	0585                	addi	a1,a1,1
 204:	0785                	addi	a5,a5,1
 206:	fff5c703          	lbu	a4,-1(a1)
 20a:	fee78fa3          	sb	a4,-1(a5)
 20e:	fb75                	bnez	a4,202 <strcpy+0x8>
    ;
  return os;
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret

0000000000000216 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 21c:	00054783          	lbu	a5,0(a0)
 220:	cb91                	beqz	a5,234 <strcmp+0x1e>
 222:	0005c703          	lbu	a4,0(a1)
 226:	00f71763          	bne	a4,a5,234 <strcmp+0x1e>
    p++, q++;
 22a:	0505                	addi	a0,a0,1
 22c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 22e:	00054783          	lbu	a5,0(a0)
 232:	fbe5                	bnez	a5,222 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 234:	0005c503          	lbu	a0,0(a1)
}
 238:	40a7853b          	subw	a0,a5,a0
 23c:	6422                	ld	s0,8(sp)
 23e:	0141                	addi	sp,sp,16
 240:	8082                	ret

0000000000000242 <strlen>:

uint
strlen(const char *s)
{
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 248:	00054783          	lbu	a5,0(a0)
 24c:	cf91                	beqz	a5,268 <strlen+0x26>
 24e:	0505                	addi	a0,a0,1
 250:	87aa                	mv	a5,a0
 252:	4685                	li	a3,1
 254:	9e89                	subw	a3,a3,a0
 256:	00f6853b          	addw	a0,a3,a5
 25a:	0785                	addi	a5,a5,1
 25c:	fff7c703          	lbu	a4,-1(a5)
 260:	fb7d                	bnez	a4,256 <strlen+0x14>
    ;
  return n;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  for(n = 0; s[n]; n++)
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <strlen+0x20>

000000000000026c <memset>:

void*
memset(void *dst, int c, uint n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 272:	ca19                	beqz	a2,288 <memset+0x1c>
 274:	87aa                	mv	a5,a0
 276:	1602                	slli	a2,a2,0x20
 278:	9201                	srli	a2,a2,0x20
 27a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 27e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 282:	0785                	addi	a5,a5,1
 284:	fee79de3          	bne	a5,a4,27e <memset+0x12>
  }
  return dst;
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret

000000000000028e <strchr>:

char*
strchr(const char *s, char c)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  for(; *s; s++)
 294:	00054783          	lbu	a5,0(a0)
 298:	cb99                	beqz	a5,2ae <strchr+0x20>
    if(*s == c)
 29a:	00f58763          	beq	a1,a5,2a8 <strchr+0x1a>
  for(; *s; s++)
 29e:	0505                	addi	a0,a0,1
 2a0:	00054783          	lbu	a5,0(a0)
 2a4:	fbfd                	bnez	a5,29a <strchr+0xc>
      return (char*)s;
  return 0;
 2a6:	4501                	li	a0,0
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret
  return 0;
 2ae:	4501                	li	a0,0
 2b0:	bfe5                	j	2a8 <strchr+0x1a>

00000000000002b2 <gets>:

char*
gets(char *buf, int max)
{
 2b2:	711d                	addi	sp,sp,-96
 2b4:	ec86                	sd	ra,88(sp)
 2b6:	e8a2                	sd	s0,80(sp)
 2b8:	e4a6                	sd	s1,72(sp)
 2ba:	e0ca                	sd	s2,64(sp)
 2bc:	fc4e                	sd	s3,56(sp)
 2be:	f852                	sd	s4,48(sp)
 2c0:	f456                	sd	s5,40(sp)
 2c2:	f05a                	sd	s6,32(sp)
 2c4:	ec5e                	sd	s7,24(sp)
 2c6:	1080                	addi	s0,sp,96
 2c8:	8baa                	mv	s7,a0
 2ca:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2cc:	892a                	mv	s2,a0
 2ce:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2d0:	4aa9                	li	s5,10
 2d2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2d4:	89a6                	mv	s3,s1
 2d6:	2485                	addiw	s1,s1,1
 2d8:	0344d863          	bge	s1,s4,308 <gets+0x56>
    cc = read(0, &c, 1);
 2dc:	4605                	li	a2,1
 2de:	faf40593          	addi	a1,s0,-81
 2e2:	4501                	li	a0,0
 2e4:	00000097          	auipc	ra,0x0
 2e8:	19a080e7          	jalr	410(ra) # 47e <read>
    if(cc < 1)
 2ec:	00a05e63          	blez	a0,308 <gets+0x56>
    buf[i++] = c;
 2f0:	faf44783          	lbu	a5,-81(s0)
 2f4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f8:	01578763          	beq	a5,s5,306 <gets+0x54>
 2fc:	0905                	addi	s2,s2,1
 2fe:	fd679be3          	bne	a5,s6,2d4 <gets+0x22>
  for(i=0; i+1 < max; ){
 302:	89a6                	mv	s3,s1
 304:	a011                	j	308 <gets+0x56>
 306:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 308:	99de                	add	s3,s3,s7
 30a:	00098023          	sb	zero,0(s3)
  return buf;
}
 30e:	855e                	mv	a0,s7
 310:	60e6                	ld	ra,88(sp)
 312:	6446                	ld	s0,80(sp)
 314:	64a6                	ld	s1,72(sp)
 316:	6906                	ld	s2,64(sp)
 318:	79e2                	ld	s3,56(sp)
 31a:	7a42                	ld	s4,48(sp)
 31c:	7aa2                	ld	s5,40(sp)
 31e:	7b02                	ld	s6,32(sp)
 320:	6be2                	ld	s7,24(sp)
 322:	6125                	addi	sp,sp,96
 324:	8082                	ret

0000000000000326 <stat>:

int
stat(const char *n, struct stat *st)
{
 326:	1101                	addi	sp,sp,-32
 328:	ec06                	sd	ra,24(sp)
 32a:	e822                	sd	s0,16(sp)
 32c:	e426                	sd	s1,8(sp)
 32e:	e04a                	sd	s2,0(sp)
 330:	1000                	addi	s0,sp,32
 332:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 334:	4581                	li	a1,0
 336:	00000097          	auipc	ra,0x0
 33a:	170080e7          	jalr	368(ra) # 4a6 <open>
  if(fd < 0)
 33e:	02054563          	bltz	a0,368 <stat+0x42>
 342:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 344:	85ca                	mv	a1,s2
 346:	00000097          	auipc	ra,0x0
 34a:	178080e7          	jalr	376(ra) # 4be <fstat>
 34e:	892a                	mv	s2,a0
  close(fd);
 350:	8526                	mv	a0,s1
 352:	00000097          	auipc	ra,0x0
 356:	13c080e7          	jalr	316(ra) # 48e <close>
  return r;
}
 35a:	854a                	mv	a0,s2
 35c:	60e2                	ld	ra,24(sp)
 35e:	6442                	ld	s0,16(sp)
 360:	64a2                	ld	s1,8(sp)
 362:	6902                	ld	s2,0(sp)
 364:	6105                	addi	sp,sp,32
 366:	8082                	ret
    return -1;
 368:	597d                	li	s2,-1
 36a:	bfc5                	j	35a <stat+0x34>

000000000000036c <atoi>:

int
atoi(const char *s)
{
 36c:	1141                	addi	sp,sp,-16
 36e:	e422                	sd	s0,8(sp)
 370:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 372:	00054683          	lbu	a3,0(a0)
 376:	fd06879b          	addiw	a5,a3,-48
 37a:	0ff7f793          	zext.b	a5,a5
 37e:	4625                	li	a2,9
 380:	02f66863          	bltu	a2,a5,3b0 <atoi+0x44>
 384:	872a                	mv	a4,a0
  n = 0;
 386:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 388:	0705                	addi	a4,a4,1
 38a:	0025179b          	slliw	a5,a0,0x2
 38e:	9fa9                	addw	a5,a5,a0
 390:	0017979b          	slliw	a5,a5,0x1
 394:	9fb5                	addw	a5,a5,a3
 396:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 39a:	00074683          	lbu	a3,0(a4)
 39e:	fd06879b          	addiw	a5,a3,-48
 3a2:	0ff7f793          	zext.b	a5,a5
 3a6:	fef671e3          	bgeu	a2,a5,388 <atoi+0x1c>
  return n;
}
 3aa:	6422                	ld	s0,8(sp)
 3ac:	0141                	addi	sp,sp,16
 3ae:	8082                	ret
  n = 0;
 3b0:	4501                	li	a0,0
 3b2:	bfe5                	j	3aa <atoi+0x3e>

00000000000003b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b4:	1141                	addi	sp,sp,-16
 3b6:	e422                	sd	s0,8(sp)
 3b8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3ba:	02b57463          	bgeu	a0,a1,3e2 <memmove+0x2e>
    while(n-- > 0)
 3be:	00c05f63          	blez	a2,3dc <memmove+0x28>
 3c2:	1602                	slli	a2,a2,0x20
 3c4:	9201                	srli	a2,a2,0x20
 3c6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ca:	872a                	mv	a4,a0
      *dst++ = *src++;
 3cc:	0585                	addi	a1,a1,1
 3ce:	0705                	addi	a4,a4,1
 3d0:	fff5c683          	lbu	a3,-1(a1)
 3d4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d8:	fee79ae3          	bne	a5,a4,3cc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	addi	sp,sp,16
 3e0:	8082                	ret
    dst += n;
 3e2:	00c50733          	add	a4,a0,a2
    src += n;
 3e6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e8:	fec05ae3          	blez	a2,3dc <memmove+0x28>
 3ec:	fff6079b          	addiw	a5,a2,-1
 3f0:	1782                	slli	a5,a5,0x20
 3f2:	9381                	srli	a5,a5,0x20
 3f4:	fff7c793          	not	a5,a5
 3f8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3fa:	15fd                	addi	a1,a1,-1
 3fc:	177d                	addi	a4,a4,-1
 3fe:	0005c683          	lbu	a3,0(a1)
 402:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 406:	fee79ae3          	bne	a5,a4,3fa <memmove+0x46>
 40a:	bfc9                	j	3dc <memmove+0x28>

000000000000040c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40c:	1141                	addi	sp,sp,-16
 40e:	e422                	sd	s0,8(sp)
 410:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 412:	ca05                	beqz	a2,442 <memcmp+0x36>
 414:	fff6069b          	addiw	a3,a2,-1
 418:	1682                	slli	a3,a3,0x20
 41a:	9281                	srli	a3,a3,0x20
 41c:	0685                	addi	a3,a3,1
 41e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 420:	00054783          	lbu	a5,0(a0)
 424:	0005c703          	lbu	a4,0(a1)
 428:	00e79863          	bne	a5,a4,438 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 42c:	0505                	addi	a0,a0,1
    p2++;
 42e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 430:	fed518e3          	bne	a0,a3,420 <memcmp+0x14>
  }
  return 0;
 434:	4501                	li	a0,0
 436:	a019                	j	43c <memcmp+0x30>
      return *p1 - *p2;
 438:	40e7853b          	subw	a0,a5,a4
}
 43c:	6422                	ld	s0,8(sp)
 43e:	0141                	addi	sp,sp,16
 440:	8082                	ret
  return 0;
 442:	4501                	li	a0,0
 444:	bfe5                	j	43c <memcmp+0x30>

0000000000000446 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 446:	1141                	addi	sp,sp,-16
 448:	e406                	sd	ra,8(sp)
 44a:	e022                	sd	s0,0(sp)
 44c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 44e:	00000097          	auipc	ra,0x0
 452:	f66080e7          	jalr	-154(ra) # 3b4 <memmove>
}
 456:	60a2                	ld	ra,8(sp)
 458:	6402                	ld	s0,0(sp)
 45a:	0141                	addi	sp,sp,16
 45c:	8082                	ret

000000000000045e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 45e:	4885                	li	a7,1
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <exit>:
.global exit
exit:
 li a7, SYS_exit
 466:	4889                	li	a7,2
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <wait>:
.global wait
wait:
 li a7, SYS_wait
 46e:	488d                	li	a7,3
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 476:	4891                	li	a7,4
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <read>:
.global read
read:
 li a7, SYS_read
 47e:	4895                	li	a7,5
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <write>:
.global write
write:
 li a7, SYS_write
 486:	48c1                	li	a7,16
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <close>:
.global close
close:
 li a7, SYS_close
 48e:	48d5                	li	a7,21
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <kill>:
.global kill
kill:
 li a7, SYS_kill
 496:	4899                	li	a7,6
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <exec>:
.global exec
exec:
 li a7, SYS_exec
 49e:	489d                	li	a7,7
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <open>:
.global open
open:
 li a7, SYS_open
 4a6:	48bd                	li	a7,15
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ae:	48c5                	li	a7,17
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b6:	48c9                	li	a7,18
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4be:	48a1                	li	a7,8
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <link>:
.global link
link:
 li a7, SYS_link
 4c6:	48cd                	li	a7,19
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4ce:	48d1                	li	a7,20
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d6:	48a5                	li	a7,9
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <dup>:
.global dup
dup:
 li a7, SYS_dup
 4de:	48a9                	li	a7,10
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e6:	48ad                	li	a7,11
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ee:	48b1                	li	a7,12
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f6:	48b5                	li	a7,13
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4fe:	48b9                	li	a7,14
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <ps>:
.global ps
ps:
 li a7, SYS_ps
 506:	48d9                	li	a7,22
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 50e:	48dd                	li	a7,23
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 516:	48e1                	li	a7,24
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 51e:	48e9                	li	a7,26
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 526:	48e5                	li	a7,25
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 52e:	1101                	addi	sp,sp,-32
 530:	ec06                	sd	ra,24(sp)
 532:	e822                	sd	s0,16(sp)
 534:	1000                	addi	s0,sp,32
 536:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 53a:	4605                	li	a2,1
 53c:	fef40593          	addi	a1,s0,-17
 540:	00000097          	auipc	ra,0x0
 544:	f46080e7          	jalr	-186(ra) # 486 <write>
}
 548:	60e2                	ld	ra,24(sp)
 54a:	6442                	ld	s0,16(sp)
 54c:	6105                	addi	sp,sp,32
 54e:	8082                	ret

0000000000000550 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 550:	7139                	addi	sp,sp,-64
 552:	fc06                	sd	ra,56(sp)
 554:	f822                	sd	s0,48(sp)
 556:	f426                	sd	s1,40(sp)
 558:	f04a                	sd	s2,32(sp)
 55a:	ec4e                	sd	s3,24(sp)
 55c:	0080                	addi	s0,sp,64
 55e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 560:	c299                	beqz	a3,566 <printint+0x16>
 562:	0805c963          	bltz	a1,5f4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 566:	2581                	sext.w	a1,a1
  neg = 0;
 568:	4881                	li	a7,0
 56a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 56e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 570:	2601                	sext.w	a2,a2
 572:	00000517          	auipc	a0,0x0
 576:	50650513          	addi	a0,a0,1286 # a78 <digits>
 57a:	883a                	mv	a6,a4
 57c:	2705                	addiw	a4,a4,1
 57e:	02c5f7bb          	remuw	a5,a1,a2
 582:	1782                	slli	a5,a5,0x20
 584:	9381                	srli	a5,a5,0x20
 586:	97aa                	add	a5,a5,a0
 588:	0007c783          	lbu	a5,0(a5)
 58c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 590:	0005879b          	sext.w	a5,a1
 594:	02c5d5bb          	divuw	a1,a1,a2
 598:	0685                	addi	a3,a3,1
 59a:	fec7f0e3          	bgeu	a5,a2,57a <printint+0x2a>
  if(neg)
 59e:	00088c63          	beqz	a7,5b6 <printint+0x66>
    buf[i++] = '-';
 5a2:	fd070793          	addi	a5,a4,-48
 5a6:	00878733          	add	a4,a5,s0
 5aa:	02d00793          	li	a5,45
 5ae:	fef70823          	sb	a5,-16(a4)
 5b2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5b6:	02e05863          	blez	a4,5e6 <printint+0x96>
 5ba:	fc040793          	addi	a5,s0,-64
 5be:	00e78933          	add	s2,a5,a4
 5c2:	fff78993          	addi	s3,a5,-1
 5c6:	99ba                	add	s3,s3,a4
 5c8:	377d                	addiw	a4,a4,-1
 5ca:	1702                	slli	a4,a4,0x20
 5cc:	9301                	srli	a4,a4,0x20
 5ce:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5d2:	fff94583          	lbu	a1,-1(s2)
 5d6:	8526                	mv	a0,s1
 5d8:	00000097          	auipc	ra,0x0
 5dc:	f56080e7          	jalr	-170(ra) # 52e <putc>
  while(--i >= 0)
 5e0:	197d                	addi	s2,s2,-1
 5e2:	ff3918e3          	bne	s2,s3,5d2 <printint+0x82>
}
 5e6:	70e2                	ld	ra,56(sp)
 5e8:	7442                	ld	s0,48(sp)
 5ea:	74a2                	ld	s1,40(sp)
 5ec:	7902                	ld	s2,32(sp)
 5ee:	69e2                	ld	s3,24(sp)
 5f0:	6121                	addi	sp,sp,64
 5f2:	8082                	ret
    x = -xx;
 5f4:	40b005bb          	negw	a1,a1
    neg = 1;
 5f8:	4885                	li	a7,1
    x = -xx;
 5fa:	bf85                	j	56a <printint+0x1a>

00000000000005fc <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5fc:	7119                	addi	sp,sp,-128
 5fe:	fc86                	sd	ra,120(sp)
 600:	f8a2                	sd	s0,112(sp)
 602:	f4a6                	sd	s1,104(sp)
 604:	f0ca                	sd	s2,96(sp)
 606:	ecce                	sd	s3,88(sp)
 608:	e8d2                	sd	s4,80(sp)
 60a:	e4d6                	sd	s5,72(sp)
 60c:	e0da                	sd	s6,64(sp)
 60e:	fc5e                	sd	s7,56(sp)
 610:	f862                	sd	s8,48(sp)
 612:	f466                	sd	s9,40(sp)
 614:	f06a                	sd	s10,32(sp)
 616:	ec6e                	sd	s11,24(sp)
 618:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 61a:	0005c903          	lbu	s2,0(a1)
 61e:	18090f63          	beqz	s2,7bc <vprintf+0x1c0>
 622:	8aaa                	mv	s5,a0
 624:	8b32                	mv	s6,a2
 626:	00158493          	addi	s1,a1,1
  state = 0;
 62a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 62c:	02500a13          	li	s4,37
 630:	4c55                	li	s8,21
 632:	00000c97          	auipc	s9,0x0
 636:	3eec8c93          	addi	s9,s9,1006 # a20 <malloc+0x160>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 63a:	02800d93          	li	s11,40
  putc(fd, 'x');
 63e:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 640:	00000b97          	auipc	s7,0x0
 644:	438b8b93          	addi	s7,s7,1080 # a78 <digits>
 648:	a839                	j	666 <vprintf+0x6a>
        putc(fd, c);
 64a:	85ca                	mv	a1,s2
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	ee0080e7          	jalr	-288(ra) # 52e <putc>
 656:	a019                	j	65c <vprintf+0x60>
    } else if(state == '%'){
 658:	01498d63          	beq	s3,s4,672 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 65c:	0485                	addi	s1,s1,1
 65e:	fff4c903          	lbu	s2,-1(s1)
 662:	14090d63          	beqz	s2,7bc <vprintf+0x1c0>
    if(state == 0){
 666:	fe0999e3          	bnez	s3,658 <vprintf+0x5c>
      if(c == '%'){
 66a:	ff4910e3          	bne	s2,s4,64a <vprintf+0x4e>
        state = '%';
 66e:	89d2                	mv	s3,s4
 670:	b7f5                	j	65c <vprintf+0x60>
      if(c == 'd'){
 672:	11490c63          	beq	s2,s4,78a <vprintf+0x18e>
 676:	f9d9079b          	addiw	a5,s2,-99
 67a:	0ff7f793          	zext.b	a5,a5
 67e:	10fc6e63          	bltu	s8,a5,79a <vprintf+0x19e>
 682:	f9d9079b          	addiw	a5,s2,-99
 686:	0ff7f713          	zext.b	a4,a5
 68a:	10ec6863          	bltu	s8,a4,79a <vprintf+0x19e>
 68e:	00271793          	slli	a5,a4,0x2
 692:	97e6                	add	a5,a5,s9
 694:	439c                	lw	a5,0(a5)
 696:	97e6                	add	a5,a5,s9
 698:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 69a:	008b0913          	addi	s2,s6,8
 69e:	4685                	li	a3,1
 6a0:	4629                	li	a2,10
 6a2:	000b2583          	lw	a1,0(s6)
 6a6:	8556                	mv	a0,s5
 6a8:	00000097          	auipc	ra,0x0
 6ac:	ea8080e7          	jalr	-344(ra) # 550 <printint>
 6b0:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	b765                	j	65c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	008b0913          	addi	s2,s6,8
 6ba:	4681                	li	a3,0
 6bc:	4629                	li	a2,10
 6be:	000b2583          	lw	a1,0(s6)
 6c2:	8556                	mv	a0,s5
 6c4:	00000097          	auipc	ra,0x0
 6c8:	e8c080e7          	jalr	-372(ra) # 550 <printint>
 6cc:	8b4a                	mv	s6,s2
      state = 0;
 6ce:	4981                	li	s3,0
 6d0:	b771                	j	65c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6d2:	008b0913          	addi	s2,s6,8
 6d6:	4681                	li	a3,0
 6d8:	866a                	mv	a2,s10
 6da:	000b2583          	lw	a1,0(s6)
 6de:	8556                	mv	a0,s5
 6e0:	00000097          	auipc	ra,0x0
 6e4:	e70080e7          	jalr	-400(ra) # 550 <printint>
 6e8:	8b4a                	mv	s6,s2
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bf85                	j	65c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6ee:	008b0793          	addi	a5,s6,8
 6f2:	f8f43423          	sd	a5,-120(s0)
 6f6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6fa:	03000593          	li	a1,48
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	e2e080e7          	jalr	-466(ra) # 52e <putc>
  putc(fd, 'x');
 708:	07800593          	li	a1,120
 70c:	8556                	mv	a0,s5
 70e:	00000097          	auipc	ra,0x0
 712:	e20080e7          	jalr	-480(ra) # 52e <putc>
 716:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 718:	03c9d793          	srli	a5,s3,0x3c
 71c:	97de                	add	a5,a5,s7
 71e:	0007c583          	lbu	a1,0(a5)
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	e0a080e7          	jalr	-502(ra) # 52e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 72c:	0992                	slli	s3,s3,0x4
 72e:	397d                	addiw	s2,s2,-1
 730:	fe0914e3          	bnez	s2,718 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 734:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 738:	4981                	li	s3,0
 73a:	b70d                	j	65c <vprintf+0x60>
        s = va_arg(ap, char*);
 73c:	008b0913          	addi	s2,s6,8
 740:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 744:	02098163          	beqz	s3,766 <vprintf+0x16a>
        while(*s != 0){
 748:	0009c583          	lbu	a1,0(s3)
 74c:	c5ad                	beqz	a1,7b6 <vprintf+0x1ba>
          putc(fd, *s);
 74e:	8556                	mv	a0,s5
 750:	00000097          	auipc	ra,0x0
 754:	dde080e7          	jalr	-546(ra) # 52e <putc>
          s++;
 758:	0985                	addi	s3,s3,1
        while(*s != 0){
 75a:	0009c583          	lbu	a1,0(s3)
 75e:	f9e5                	bnez	a1,74e <vprintf+0x152>
        s = va_arg(ap, char*);
 760:	8b4a                	mv	s6,s2
      state = 0;
 762:	4981                	li	s3,0
 764:	bde5                	j	65c <vprintf+0x60>
          s = "(null)";
 766:	00000997          	auipc	s3,0x0
 76a:	2b298993          	addi	s3,s3,690 # a18 <malloc+0x158>
        while(*s != 0){
 76e:	85ee                	mv	a1,s11
 770:	bff9                	j	74e <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 772:	008b0913          	addi	s2,s6,8
 776:	000b4583          	lbu	a1,0(s6)
 77a:	8556                	mv	a0,s5
 77c:	00000097          	auipc	ra,0x0
 780:	db2080e7          	jalr	-590(ra) # 52e <putc>
 784:	8b4a                	mv	s6,s2
      state = 0;
 786:	4981                	li	s3,0
 788:	bdd1                	j	65c <vprintf+0x60>
        putc(fd, c);
 78a:	85d2                	mv	a1,s4
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	da0080e7          	jalr	-608(ra) # 52e <putc>
      state = 0;
 796:	4981                	li	s3,0
 798:	b5d1                	j	65c <vprintf+0x60>
        putc(fd, '%');
 79a:	85d2                	mv	a1,s4
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	d90080e7          	jalr	-624(ra) # 52e <putc>
        putc(fd, c);
 7a6:	85ca                	mv	a1,s2
 7a8:	8556                	mv	a0,s5
 7aa:	00000097          	auipc	ra,0x0
 7ae:	d84080e7          	jalr	-636(ra) # 52e <putc>
      state = 0;
 7b2:	4981                	li	s3,0
 7b4:	b565                	j	65c <vprintf+0x60>
        s = va_arg(ap, char*);
 7b6:	8b4a                	mv	s6,s2
      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	b54d                	j	65c <vprintf+0x60>
    }
  }
}
 7bc:	70e6                	ld	ra,120(sp)
 7be:	7446                	ld	s0,112(sp)
 7c0:	74a6                	ld	s1,104(sp)
 7c2:	7906                	ld	s2,96(sp)
 7c4:	69e6                	ld	s3,88(sp)
 7c6:	6a46                	ld	s4,80(sp)
 7c8:	6aa6                	ld	s5,72(sp)
 7ca:	6b06                	ld	s6,64(sp)
 7cc:	7be2                	ld	s7,56(sp)
 7ce:	7c42                	ld	s8,48(sp)
 7d0:	7ca2                	ld	s9,40(sp)
 7d2:	7d02                	ld	s10,32(sp)
 7d4:	6de2                	ld	s11,24(sp)
 7d6:	6109                	addi	sp,sp,128
 7d8:	8082                	ret

00000000000007da <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7da:	715d                	addi	sp,sp,-80
 7dc:	ec06                	sd	ra,24(sp)
 7de:	e822                	sd	s0,16(sp)
 7e0:	1000                	addi	s0,sp,32
 7e2:	e010                	sd	a2,0(s0)
 7e4:	e414                	sd	a3,8(s0)
 7e6:	e818                	sd	a4,16(s0)
 7e8:	ec1c                	sd	a5,24(s0)
 7ea:	03043023          	sd	a6,32(s0)
 7ee:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f6:	8622                	mv	a2,s0
 7f8:	00000097          	auipc	ra,0x0
 7fc:	e04080e7          	jalr	-508(ra) # 5fc <vprintf>
}
 800:	60e2                	ld	ra,24(sp)
 802:	6442                	ld	s0,16(sp)
 804:	6161                	addi	sp,sp,80
 806:	8082                	ret

0000000000000808 <printf>:

void
printf(const char *fmt, ...)
{
 808:	711d                	addi	sp,sp,-96
 80a:	ec06                	sd	ra,24(sp)
 80c:	e822                	sd	s0,16(sp)
 80e:	1000                	addi	s0,sp,32
 810:	e40c                	sd	a1,8(s0)
 812:	e810                	sd	a2,16(s0)
 814:	ec14                	sd	a3,24(s0)
 816:	f018                	sd	a4,32(s0)
 818:	f41c                	sd	a5,40(s0)
 81a:	03043823          	sd	a6,48(s0)
 81e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 822:	00840613          	addi	a2,s0,8
 826:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 82a:	85aa                	mv	a1,a0
 82c:	4505                	li	a0,1
 82e:	00000097          	auipc	ra,0x0
 832:	dce080e7          	jalr	-562(ra) # 5fc <vprintf>
}
 836:	60e2                	ld	ra,24(sp)
 838:	6442                	ld	s0,16(sp)
 83a:	6125                	addi	sp,sp,96
 83c:	8082                	ret

000000000000083e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83e:	1141                	addi	sp,sp,-16
 840:	e422                	sd	s0,8(sp)
 842:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 844:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 848:	00000797          	auipc	a5,0x0
 84c:	7b87b783          	ld	a5,1976(a5) # 1000 <freep>
 850:	a02d                	j	87a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 852:	4618                	lw	a4,8(a2)
 854:	9f2d                	addw	a4,a4,a1
 856:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 85a:	6398                	ld	a4,0(a5)
 85c:	6310                	ld	a2,0(a4)
 85e:	a83d                	j	89c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 860:	ff852703          	lw	a4,-8(a0)
 864:	9f31                	addw	a4,a4,a2
 866:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 868:	ff053683          	ld	a3,-16(a0)
 86c:	a091                	j	8b0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86e:	6398                	ld	a4,0(a5)
 870:	00e7e463          	bltu	a5,a4,878 <free+0x3a>
 874:	00e6ea63          	bltu	a3,a4,888 <free+0x4a>
{
 878:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87a:	fed7fae3          	bgeu	a5,a3,86e <free+0x30>
 87e:	6398                	ld	a4,0(a5)
 880:	00e6e463          	bltu	a3,a4,888 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 884:	fee7eae3          	bltu	a5,a4,878 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 888:	ff852583          	lw	a1,-8(a0)
 88c:	6390                	ld	a2,0(a5)
 88e:	02059813          	slli	a6,a1,0x20
 892:	01c85713          	srli	a4,a6,0x1c
 896:	9736                	add	a4,a4,a3
 898:	fae60de3          	beq	a2,a4,852 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 89c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8a0:	4790                	lw	a2,8(a5)
 8a2:	02061593          	slli	a1,a2,0x20
 8a6:	01c5d713          	srli	a4,a1,0x1c
 8aa:	973e                	add	a4,a4,a5
 8ac:	fae68ae3          	beq	a3,a4,860 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8b0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8b2:	00000717          	auipc	a4,0x0
 8b6:	74f73723          	sd	a5,1870(a4) # 1000 <freep>
}
 8ba:	6422                	ld	s0,8(sp)
 8bc:	0141                	addi	sp,sp,16
 8be:	8082                	ret

00000000000008c0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8c0:	7139                	addi	sp,sp,-64
 8c2:	fc06                	sd	ra,56(sp)
 8c4:	f822                	sd	s0,48(sp)
 8c6:	f426                	sd	s1,40(sp)
 8c8:	f04a                	sd	s2,32(sp)
 8ca:	ec4e                	sd	s3,24(sp)
 8cc:	e852                	sd	s4,16(sp)
 8ce:	e456                	sd	s5,8(sp)
 8d0:	e05a                	sd	s6,0(sp)
 8d2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d4:	02051493          	slli	s1,a0,0x20
 8d8:	9081                	srli	s1,s1,0x20
 8da:	04bd                	addi	s1,s1,15
 8dc:	8091                	srli	s1,s1,0x4
 8de:	0014899b          	addiw	s3,s1,1
 8e2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e4:	00000517          	auipc	a0,0x0
 8e8:	71c53503          	ld	a0,1820(a0) # 1000 <freep>
 8ec:	c515                	beqz	a0,918 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f0:	4798                	lw	a4,8(a5)
 8f2:	02977f63          	bgeu	a4,s1,930 <malloc+0x70>
 8f6:	8a4e                	mv	s4,s3
 8f8:	0009871b          	sext.w	a4,s3
 8fc:	6685                	lui	a3,0x1
 8fe:	00d77363          	bgeu	a4,a3,904 <malloc+0x44>
 902:	6a05                	lui	s4,0x1
 904:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 908:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 90c:	00000917          	auipc	s2,0x0
 910:	6f490913          	addi	s2,s2,1780 # 1000 <freep>
  if(p == (char*)-1)
 914:	5afd                	li	s5,-1
 916:	a895                	j	98a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 918:	00000797          	auipc	a5,0x0
 91c:	6f878793          	addi	a5,a5,1784 # 1010 <base>
 920:	00000717          	auipc	a4,0x0
 924:	6ef73023          	sd	a5,1760(a4) # 1000 <freep>
 928:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 92a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 92e:	b7e1                	j	8f6 <malloc+0x36>
      if(p->s.size == nunits)
 930:	02e48c63          	beq	s1,a4,968 <malloc+0xa8>
        p->s.size -= nunits;
 934:	4137073b          	subw	a4,a4,s3
 938:	c798                	sw	a4,8(a5)
        p += p->s.size;
 93a:	02071693          	slli	a3,a4,0x20
 93e:	01c6d713          	srli	a4,a3,0x1c
 942:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 944:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 948:	00000717          	auipc	a4,0x0
 94c:	6aa73c23          	sd	a0,1720(a4) # 1000 <freep>
      return (void*)(p + 1);
 950:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 954:	70e2                	ld	ra,56(sp)
 956:	7442                	ld	s0,48(sp)
 958:	74a2                	ld	s1,40(sp)
 95a:	7902                	ld	s2,32(sp)
 95c:	69e2                	ld	s3,24(sp)
 95e:	6a42                	ld	s4,16(sp)
 960:	6aa2                	ld	s5,8(sp)
 962:	6b02                	ld	s6,0(sp)
 964:	6121                	addi	sp,sp,64
 966:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 968:	6398                	ld	a4,0(a5)
 96a:	e118                	sd	a4,0(a0)
 96c:	bff1                	j	948 <malloc+0x88>
  hp->s.size = nu;
 96e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 972:	0541                	addi	a0,a0,16
 974:	00000097          	auipc	ra,0x0
 978:	eca080e7          	jalr	-310(ra) # 83e <free>
  return freep;
 97c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 980:	d971                	beqz	a0,954 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 982:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 984:	4798                	lw	a4,8(a5)
 986:	fa9775e3          	bgeu	a4,s1,930 <malloc+0x70>
    if(p == freep)
 98a:	00093703          	ld	a4,0(s2)
 98e:	853e                	mv	a0,a5
 990:	fef719e3          	bne	a4,a5,982 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 994:	8552                	mv	a0,s4
 996:	00000097          	auipc	ra,0x0
 99a:	b58080e7          	jalr	-1192(ra) # 4ee <sbrk>
  if(p == (char*)-1)
 99e:	fd5518e3          	bne	a0,s5,96e <malloc+0xae>
        return 0;
 9a2:	4501                	li	a0,0
 9a4:	bf45                	j	954 <malloc+0x94>
