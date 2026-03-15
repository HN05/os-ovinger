
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "user/user.h"
#include "kernel/fs.h"

char*
fmtname(char *path)
{
       0:	7139                	addi	sp,sp,-64
       2:	fc06                	sd	ra,56(sp)
       4:	f822                	sd	s0,48(sp)
       6:	f426                	sd	s1,40(sp)
       8:	0080                	addi	s0,sp,64
       a:	fca43423          	sd	a0,-56(s0)
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
       e:	fc843503          	ld	a0,-56(s0)
      12:	00000097          	auipc	ra,0x0
      16:	456080e7          	jalr	1110(ra) # 468 <strlen>
      1a:	87aa                	mv	a5,a0
      1c:	2781                	sext.w	a5,a5
      1e:	1782                	slli	a5,a5,0x20
      20:	9381                	srli	a5,a5,0x20
      22:	fc843703          	ld	a4,-56(s0)
      26:	97ba                	add	a5,a5,a4
      28:	fcf43c23          	sd	a5,-40(s0)
      2c:	a031                	j	38 <fmtname+0x38>
      2e:	fd843783          	ld	a5,-40(s0)
      32:	17fd                	addi	a5,a5,-1
      34:	fcf43c23          	sd	a5,-40(s0)
      38:	fd843703          	ld	a4,-40(s0)
      3c:	fc843783          	ld	a5,-56(s0)
      40:	00f76b63          	bltu	a4,a5,56 <fmtname+0x56>
      44:	fd843783          	ld	a5,-40(s0)
      48:	0007c783          	lbu	a5,0(a5)
      4c:	873e                	mv	a4,a5
      4e:	02f00793          	li	a5,47
      52:	fcf71ee3          	bne	a4,a5,2e <fmtname+0x2e>
    ;
  p++;
      56:	fd843783          	ld	a5,-40(s0)
      5a:	0785                	addi	a5,a5,1
      5c:	fcf43c23          	sd	a5,-40(s0)

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
      60:	fd843503          	ld	a0,-40(s0)
      64:	00000097          	auipc	ra,0x0
      68:	404080e7          	jalr	1028(ra) # 468 <strlen>
      6c:	87aa                	mv	a5,a0
      6e:	2781                	sext.w	a5,a5
      70:	873e                	mv	a4,a5
      72:	47b5                	li	a5,13
      74:	00e7f563          	bgeu	a5,a4,7e <fmtname+0x7e>
    return p;
      78:	fd843783          	ld	a5,-40(s0)
      7c:	a8b5                	j	f8 <fmtname+0xf8>
  memmove(buf, p, strlen(p));
      7e:	fd843503          	ld	a0,-40(s0)
      82:	00000097          	auipc	ra,0x0
      86:	3e6080e7          	jalr	998(ra) # 468 <strlen>
      8a:	87aa                	mv	a5,a0
      8c:	2781                	sext.w	a5,a5
      8e:	2781                	sext.w	a5,a5
      90:	863e                	mv	a2,a5
      92:	fd843583          	ld	a1,-40(s0)
      96:	00002517          	auipc	a0,0x2
      9a:	f8a50513          	addi	a0,a0,-118 # 2020 <buf.0>
      9e:	00000097          	auipc	ra,0x0
      a2:	626080e7          	jalr	1574(ra) # 6c4 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
      a6:	fd843503          	ld	a0,-40(s0)
      aa:	00000097          	auipc	ra,0x0
      ae:	3be080e7          	jalr	958(ra) # 468 <strlen>
      b2:	87aa                	mv	a5,a0
      b4:	2781                	sext.w	a5,a5
      b6:	02079713          	slli	a4,a5,0x20
      ba:	9301                	srli	a4,a4,0x20
      bc:	00002797          	auipc	a5,0x2
      c0:	f6478793          	addi	a5,a5,-156 # 2020 <buf.0>
      c4:	00f704b3          	add	s1,a4,a5
      c8:	fd843503          	ld	a0,-40(s0)
      cc:	00000097          	auipc	ra,0x0
      d0:	39c080e7          	jalr	924(ra) # 468 <strlen>
      d4:	87aa                	mv	a5,a0
      d6:	2781                	sext.w	a5,a5
      d8:	4739                	li	a4,14
      da:	40f707bb          	subw	a5,a4,a5
      de:	2781                	sext.w	a5,a5
      e0:	863e                	mv	a2,a5
      e2:	02000593          	li	a1,32
      e6:	8526                	mv	a0,s1
      e8:	00000097          	auipc	ra,0x0
      ec:	3b6080e7          	jalr	950(ra) # 49e <memset>
  return buf;
      f0:	00002797          	auipc	a5,0x2
      f4:	f3078793          	addi	a5,a5,-208 # 2020 <buf.0>
}
      f8:	853e                	mv	a0,a5
      fa:	70e2                	ld	ra,56(sp)
      fc:	7442                	ld	s0,48(sp)
      fe:	74a2                	ld	s1,40(sp)
     100:	6121                	addi	sp,sp,64
     102:	8082                	ret

0000000000000104 <ls>:

void
ls(char *path)
{
     104:	da010113          	addi	sp,sp,-608
     108:	24113c23          	sd	ra,600(sp)
     10c:	24813823          	sd	s0,592(sp)
     110:	1480                	addi	s0,sp,608
     112:	daa43423          	sd	a0,-600(s0)
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, 0)) < 0){
     116:	4581                	li	a1,0
     118:	da843503          	ld	a0,-600(s0)
     11c:	00000097          	auipc	ra,0x0
     120:	76e080e7          	jalr	1902(ra) # 88a <open>
     124:	87aa                	mv	a5,a0
     126:	fef42623          	sw	a5,-20(s0)
     12a:	fec42783          	lw	a5,-20(s0)
     12e:	2781                	sext.w	a5,a5
     130:	0007de63          	bgez	a5,14c <ls+0x48>
    fprintf(2, "ls: cannot open %s\n", path);
     134:	da843603          	ld	a2,-600(s0)
     138:	00001597          	auipc	a1,0x1
     13c:	f8858593          	addi	a1,a1,-120 # 10c0 <malloc+0x13c>
     140:	4509                	li	a0,2
     142:	00001097          	auipc	ra,0x1
     146:	bf8080e7          	jalr	-1032(ra) # d3a <fprintf>
    return;
     14a:	a2d9                	j	310 <ls+0x20c>
  }

  if(fstat(fd, &st) < 0){
     14c:	db840713          	addi	a4,s0,-584
     150:	fec42783          	lw	a5,-20(s0)
     154:	85ba                	mv	a1,a4
     156:	853e                	mv	a0,a5
     158:	00000097          	auipc	ra,0x0
     15c:	74a080e7          	jalr	1866(ra) # 8a2 <fstat>
     160:	87aa                	mv	a5,a0
     162:	0207d563          	bgez	a5,18c <ls+0x88>
    fprintf(2, "ls: cannot stat %s\n", path);
     166:	da843603          	ld	a2,-600(s0)
     16a:	00001597          	auipc	a1,0x1
     16e:	f6e58593          	addi	a1,a1,-146 # 10d8 <malloc+0x154>
     172:	4509                	li	a0,2
     174:	00001097          	auipc	ra,0x1
     178:	bc6080e7          	jalr	-1082(ra) # d3a <fprintf>
    close(fd);
     17c:	fec42783          	lw	a5,-20(s0)
     180:	853e                	mv	a0,a5
     182:	00000097          	auipc	ra,0x0
     186:	6f0080e7          	jalr	1776(ra) # 872 <close>
    return;
     18a:	a259                	j	310 <ls+0x20c>
  }

  switch(st.type){
     18c:	dc041783          	lh	a5,-576(s0)
     190:	2781                	sext.w	a5,a5
     192:	86be                	mv	a3,a5
     194:	4705                	li	a4,1
     196:	04e68463          	beq	a3,a4,1de <ls+0xda>
     19a:	873e                	mv	a4,a5
     19c:	16e05363          	blez	a4,302 <ls+0x1fe>
     1a0:	2781                	sext.w	a5,a5
     1a2:	37f9                	addiw	a5,a5,-2
     1a4:	2781                	sext.w	a5,a5
     1a6:	873e                	mv	a4,a5
     1a8:	4785                	li	a5,1
     1aa:	14e7ec63          	bltu	a5,a4,302 <ls+0x1fe>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %l\n", fmtname(path), st.type, st.ino, st.size);
     1ae:	da843503          	ld	a0,-600(s0)
     1b2:	00000097          	auipc	ra,0x0
     1b6:	e4e080e7          	jalr	-434(ra) # 0 <fmtname>
     1ba:	85aa                	mv	a1,a0
     1bc:	dc041783          	lh	a5,-576(s0)
     1c0:	2781                	sext.w	a5,a5
     1c2:	dbc42683          	lw	a3,-580(s0)
     1c6:	dc843703          	ld	a4,-568(s0)
     1ca:	863e                	mv	a2,a5
     1cc:	00001517          	auipc	a0,0x1
     1d0:	f2450513          	addi	a0,a0,-220 # 10f0 <malloc+0x16c>
     1d4:	00001097          	auipc	ra,0x1
     1d8:	bbe080e7          	jalr	-1090(ra) # d92 <printf>
    break;
     1dc:	a21d                	j	302 <ls+0x1fe>

  case T_DIR:
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
     1de:	da843503          	ld	a0,-600(s0)
     1e2:	00000097          	auipc	ra,0x0
     1e6:	286080e7          	jalr	646(ra) # 468 <strlen>
     1ea:	87aa                	mv	a5,a0
     1ec:	2781                	sext.w	a5,a5
     1ee:	27c1                	addiw	a5,a5,16
     1f0:	2781                	sext.w	a5,a5
     1f2:	873e                	mv	a4,a5
     1f4:	20000793          	li	a5,512
     1f8:	00e7fb63          	bgeu	a5,a4,20e <ls+0x10a>
      printf("ls: path too long\n");
     1fc:	00001517          	auipc	a0,0x1
     200:	f0450513          	addi	a0,a0,-252 # 1100 <malloc+0x17c>
     204:	00001097          	auipc	ra,0x1
     208:	b8e080e7          	jalr	-1138(ra) # d92 <printf>
      break;
     20c:	a8dd                	j	302 <ls+0x1fe>
    }
    strcpy(buf, path);
     20e:	de040793          	addi	a5,s0,-544
     212:	da843583          	ld	a1,-600(s0)
     216:	853e                	mv	a0,a5
     218:	00000097          	auipc	ra,0x0
     21c:	1a0080e7          	jalr	416(ra) # 3b8 <strcpy>
    p = buf+strlen(buf);
     220:	de040793          	addi	a5,s0,-544
     224:	853e                	mv	a0,a5
     226:	00000097          	auipc	ra,0x0
     22a:	242080e7          	jalr	578(ra) # 468 <strlen>
     22e:	87aa                	mv	a5,a0
     230:	2781                	sext.w	a5,a5
     232:	1782                	slli	a5,a5,0x20
     234:	9381                	srli	a5,a5,0x20
     236:	de040713          	addi	a4,s0,-544
     23a:	97ba                	add	a5,a5,a4
     23c:	fef43023          	sd	a5,-32(s0)
    *p++ = '/';
     240:	fe043783          	ld	a5,-32(s0)
     244:	00178713          	addi	a4,a5,1
     248:	fee43023          	sd	a4,-32(s0)
     24c:	02f00713          	li	a4,47
     250:	00e78023          	sb	a4,0(a5)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     254:	a071                	j	2e0 <ls+0x1dc>
      if(de.inum == 0)
     256:	dd045783          	lhu	a5,-560(s0)
     25a:	e391                	bnez	a5,25e <ls+0x15a>
        continue;
     25c:	a051                	j	2e0 <ls+0x1dc>
      memmove(p, de.name, DIRSIZ);
     25e:	dd040793          	addi	a5,s0,-560
     262:	0789                	addi	a5,a5,2
     264:	4639                	li	a2,14
     266:	85be                	mv	a1,a5
     268:	fe043503          	ld	a0,-32(s0)
     26c:	00000097          	auipc	ra,0x0
     270:	458080e7          	jalr	1112(ra) # 6c4 <memmove>
      p[DIRSIZ] = 0;
     274:	fe043783          	ld	a5,-32(s0)
     278:	07b9                	addi	a5,a5,14
     27a:	00078023          	sb	zero,0(a5)
      if(stat(buf, &st) < 0){
     27e:	db840713          	addi	a4,s0,-584
     282:	de040793          	addi	a5,s0,-544
     286:	85ba                	mv	a1,a4
     288:	853e                	mv	a0,a5
     28a:	00000097          	auipc	ra,0x0
     28e:	360080e7          	jalr	864(ra) # 5ea <stat>
     292:	87aa                	mv	a5,a0
     294:	0007de63          	bgez	a5,2b0 <ls+0x1ac>
        printf("ls: cannot stat %s\n", buf);
     298:	de040793          	addi	a5,s0,-544
     29c:	85be                	mv	a1,a5
     29e:	00001517          	auipc	a0,0x1
     2a2:	e3a50513          	addi	a0,a0,-454 # 10d8 <malloc+0x154>
     2a6:	00001097          	auipc	ra,0x1
     2aa:	aec080e7          	jalr	-1300(ra) # d92 <printf>
        continue;
     2ae:	a80d                	j	2e0 <ls+0x1dc>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, st.size);
     2b0:	de040793          	addi	a5,s0,-544
     2b4:	853e                	mv	a0,a5
     2b6:	00000097          	auipc	ra,0x0
     2ba:	d4a080e7          	jalr	-694(ra) # 0 <fmtname>
     2be:	85aa                	mv	a1,a0
     2c0:	dc041783          	lh	a5,-576(s0)
     2c4:	2781                	sext.w	a5,a5
     2c6:	dbc42683          	lw	a3,-580(s0)
     2ca:	dc843703          	ld	a4,-568(s0)
     2ce:	863e                	mv	a2,a5
     2d0:	00001517          	auipc	a0,0x1
     2d4:	e4850513          	addi	a0,a0,-440 # 1118 <malloc+0x194>
     2d8:	00001097          	auipc	ra,0x1
     2dc:	aba080e7          	jalr	-1350(ra) # d92 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
     2e0:	dd040713          	addi	a4,s0,-560
     2e4:	fec42783          	lw	a5,-20(s0)
     2e8:	4641                	li	a2,16
     2ea:	85ba                	mv	a1,a4
     2ec:	853e                	mv	a0,a5
     2ee:	00000097          	auipc	ra,0x0
     2f2:	574080e7          	jalr	1396(ra) # 862 <read>
     2f6:	87aa                	mv	a5,a0
     2f8:	873e                	mv	a4,a5
     2fa:	47c1                	li	a5,16
     2fc:	f4f70de3          	beq	a4,a5,256 <ls+0x152>
    }
    break;
     300:	0001                	nop
  }
  close(fd);
     302:	fec42783          	lw	a5,-20(s0)
     306:	853e                	mv	a0,a5
     308:	00000097          	auipc	ra,0x0
     30c:	56a080e7          	jalr	1386(ra) # 872 <close>
}
     310:	25813083          	ld	ra,600(sp)
     314:	25013403          	ld	s0,592(sp)
     318:	26010113          	addi	sp,sp,608
     31c:	8082                	ret

000000000000031e <main>:

int
main(int argc, char *argv[])
{
     31e:	7179                	addi	sp,sp,-48
     320:	f406                	sd	ra,40(sp)
     322:	f022                	sd	s0,32(sp)
     324:	1800                	addi	s0,sp,48
     326:	87aa                	mv	a5,a0
     328:	fcb43823          	sd	a1,-48(s0)
     32c:	fcf42e23          	sw	a5,-36(s0)
  int i;

  if(argc < 2){
     330:	fdc42783          	lw	a5,-36(s0)
     334:	0007871b          	sext.w	a4,a5
     338:	4785                	li	a5,1
     33a:	00e7cf63          	blt	a5,a4,358 <main+0x3a>
    ls(".");
     33e:	00001517          	auipc	a0,0x1
     342:	dea50513          	addi	a0,a0,-534 # 1128 <malloc+0x1a4>
     346:	00000097          	auipc	ra,0x0
     34a:	dbe080e7          	jalr	-578(ra) # 104 <ls>
    exit(0);
     34e:	4501                	li	a0,0
     350:	00000097          	auipc	ra,0x0
     354:	4fa080e7          	jalr	1274(ra) # 84a <exit>
  }
  for(i=1; i<argc; i++)
     358:	4785                	li	a5,1
     35a:	fef42623          	sw	a5,-20(s0)
     35e:	a015                	j	382 <main+0x64>
    ls(argv[i]);
     360:	fec42783          	lw	a5,-20(s0)
     364:	078e                	slli	a5,a5,0x3
     366:	fd043703          	ld	a4,-48(s0)
     36a:	97ba                	add	a5,a5,a4
     36c:	639c                	ld	a5,0(a5)
     36e:	853e                	mv	a0,a5
     370:	00000097          	auipc	ra,0x0
     374:	d94080e7          	jalr	-620(ra) # 104 <ls>
  for(i=1; i<argc; i++)
     378:	fec42783          	lw	a5,-20(s0)
     37c:	2785                	addiw	a5,a5,1
     37e:	fef42623          	sw	a5,-20(s0)
     382:	fec42783          	lw	a5,-20(s0)
     386:	873e                	mv	a4,a5
     388:	fdc42783          	lw	a5,-36(s0)
     38c:	2701                	sext.w	a4,a4
     38e:	2781                	sext.w	a5,a5
     390:	fcf748e3          	blt	a4,a5,360 <main+0x42>
  exit(0);
     394:	4501                	li	a0,0
     396:	00000097          	auipc	ra,0x0
     39a:	4b4080e7          	jalr	1204(ra) # 84a <exit>

000000000000039e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
     39e:	1141                	addi	sp,sp,-16
     3a0:	e406                	sd	ra,8(sp)
     3a2:	e022                	sd	s0,0(sp)
     3a4:	0800                	addi	s0,sp,16
  extern int main();
  main();
     3a6:	00000097          	auipc	ra,0x0
     3aa:	f78080e7          	jalr	-136(ra) # 31e <main>
  exit(0);
     3ae:	4501                	li	a0,0
     3b0:	00000097          	auipc	ra,0x0
     3b4:	49a080e7          	jalr	1178(ra) # 84a <exit>

00000000000003b8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     3b8:	7179                	addi	sp,sp,-48
     3ba:	f422                	sd	s0,40(sp)
     3bc:	1800                	addi	s0,sp,48
     3be:	fca43c23          	sd	a0,-40(s0)
     3c2:	fcb43823          	sd	a1,-48(s0)
  char *os;

  os = s;
     3c6:	fd843783          	ld	a5,-40(s0)
     3ca:	fef43423          	sd	a5,-24(s0)
  while((*s++ = *t++) != 0)
     3ce:	0001                	nop
     3d0:	fd043703          	ld	a4,-48(s0)
     3d4:	00170793          	addi	a5,a4,1
     3d8:	fcf43823          	sd	a5,-48(s0)
     3dc:	fd843783          	ld	a5,-40(s0)
     3e0:	00178693          	addi	a3,a5,1
     3e4:	fcd43c23          	sd	a3,-40(s0)
     3e8:	00074703          	lbu	a4,0(a4)
     3ec:	00e78023          	sb	a4,0(a5)
     3f0:	0007c783          	lbu	a5,0(a5)
     3f4:	fff1                	bnez	a5,3d0 <strcpy+0x18>
    ;
  return os;
     3f6:	fe843783          	ld	a5,-24(s0)
}
     3fa:	853e                	mv	a0,a5
     3fc:	7422                	ld	s0,40(sp)
     3fe:	6145                	addi	sp,sp,48
     400:	8082                	ret

0000000000000402 <strcmp>:

int
strcmp(const char *p, const char *q)
{
     402:	1101                	addi	sp,sp,-32
     404:	ec22                	sd	s0,24(sp)
     406:	1000                	addi	s0,sp,32
     408:	fea43423          	sd	a0,-24(s0)
     40c:	feb43023          	sd	a1,-32(s0)
  while(*p && *p == *q)
     410:	a819                	j	426 <strcmp+0x24>
    p++, q++;
     412:	fe843783          	ld	a5,-24(s0)
     416:	0785                	addi	a5,a5,1
     418:	fef43423          	sd	a5,-24(s0)
     41c:	fe043783          	ld	a5,-32(s0)
     420:	0785                	addi	a5,a5,1
     422:	fef43023          	sd	a5,-32(s0)
  while(*p && *p == *q)
     426:	fe843783          	ld	a5,-24(s0)
     42a:	0007c783          	lbu	a5,0(a5)
     42e:	cb99                	beqz	a5,444 <strcmp+0x42>
     430:	fe843783          	ld	a5,-24(s0)
     434:	0007c703          	lbu	a4,0(a5)
     438:	fe043783          	ld	a5,-32(s0)
     43c:	0007c783          	lbu	a5,0(a5)
     440:	fcf709e3          	beq	a4,a5,412 <strcmp+0x10>
  return (uchar)*p - (uchar)*q;
     444:	fe843783          	ld	a5,-24(s0)
     448:	0007c783          	lbu	a5,0(a5)
     44c:	0007871b          	sext.w	a4,a5
     450:	fe043783          	ld	a5,-32(s0)
     454:	0007c783          	lbu	a5,0(a5)
     458:	2781                	sext.w	a5,a5
     45a:	40f707bb          	subw	a5,a4,a5
     45e:	2781                	sext.w	a5,a5
}
     460:	853e                	mv	a0,a5
     462:	6462                	ld	s0,24(sp)
     464:	6105                	addi	sp,sp,32
     466:	8082                	ret

0000000000000468 <strlen>:

uint
strlen(const char *s)
{
     468:	7179                	addi	sp,sp,-48
     46a:	f422                	sd	s0,40(sp)
     46c:	1800                	addi	s0,sp,48
     46e:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
     472:	fe042623          	sw	zero,-20(s0)
     476:	a031                	j	482 <strlen+0x1a>
     478:	fec42783          	lw	a5,-20(s0)
     47c:	2785                	addiw	a5,a5,1
     47e:	fef42623          	sw	a5,-20(s0)
     482:	fec42783          	lw	a5,-20(s0)
     486:	fd843703          	ld	a4,-40(s0)
     48a:	97ba                	add	a5,a5,a4
     48c:	0007c783          	lbu	a5,0(a5)
     490:	f7e5                	bnez	a5,478 <strlen+0x10>
    ;
  return n;
     492:	fec42783          	lw	a5,-20(s0)
}
     496:	853e                	mv	a0,a5
     498:	7422                	ld	s0,40(sp)
     49a:	6145                	addi	sp,sp,48
     49c:	8082                	ret

000000000000049e <memset>:

void*
memset(void *dst, int c, uint n)
{
     49e:	7179                	addi	sp,sp,-48
     4a0:	f422                	sd	s0,40(sp)
     4a2:	1800                	addi	s0,sp,48
     4a4:	fca43c23          	sd	a0,-40(s0)
     4a8:	87ae                	mv	a5,a1
     4aa:	8732                	mv	a4,a2
     4ac:	fcf42a23          	sw	a5,-44(s0)
     4b0:	87ba                	mv	a5,a4
     4b2:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
     4b6:	fd843783          	ld	a5,-40(s0)
     4ba:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
     4be:	fe042623          	sw	zero,-20(s0)
     4c2:	a00d                	j	4e4 <memset+0x46>
    cdst[i] = c;
     4c4:	fec42783          	lw	a5,-20(s0)
     4c8:	fe043703          	ld	a4,-32(s0)
     4cc:	97ba                	add	a5,a5,a4
     4ce:	fd442703          	lw	a4,-44(s0)
     4d2:	0ff77713          	zext.b	a4,a4
     4d6:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
     4da:	fec42783          	lw	a5,-20(s0)
     4de:	2785                	addiw	a5,a5,1
     4e0:	fef42623          	sw	a5,-20(s0)
     4e4:	fec42703          	lw	a4,-20(s0)
     4e8:	fd042783          	lw	a5,-48(s0)
     4ec:	2781                	sext.w	a5,a5
     4ee:	fcf76be3          	bltu	a4,a5,4c4 <memset+0x26>
  }
  return dst;
     4f2:	fd843783          	ld	a5,-40(s0)
}
     4f6:	853e                	mv	a0,a5
     4f8:	7422                	ld	s0,40(sp)
     4fa:	6145                	addi	sp,sp,48
     4fc:	8082                	ret

00000000000004fe <strchr>:

char*
strchr(const char *s, char c)
{
     4fe:	1101                	addi	sp,sp,-32
     500:	ec22                	sd	s0,24(sp)
     502:	1000                	addi	s0,sp,32
     504:	fea43423          	sd	a0,-24(s0)
     508:	87ae                	mv	a5,a1
     50a:	fef403a3          	sb	a5,-25(s0)
  for(; *s; s++)
     50e:	a01d                	j	534 <strchr+0x36>
    if(*s == c)
     510:	fe843783          	ld	a5,-24(s0)
     514:	0007c703          	lbu	a4,0(a5)
     518:	fe744783          	lbu	a5,-25(s0)
     51c:	0ff7f793          	zext.b	a5,a5
     520:	00e79563          	bne	a5,a4,52a <strchr+0x2c>
      return (char*)s;
     524:	fe843783          	ld	a5,-24(s0)
     528:	a821                	j	540 <strchr+0x42>
  for(; *s; s++)
     52a:	fe843783          	ld	a5,-24(s0)
     52e:	0785                	addi	a5,a5,1
     530:	fef43423          	sd	a5,-24(s0)
     534:	fe843783          	ld	a5,-24(s0)
     538:	0007c783          	lbu	a5,0(a5)
     53c:	fbf1                	bnez	a5,510 <strchr+0x12>
  return 0;
     53e:	4781                	li	a5,0
}
     540:	853e                	mv	a0,a5
     542:	6462                	ld	s0,24(sp)
     544:	6105                	addi	sp,sp,32
     546:	8082                	ret

0000000000000548 <gets>:

char*
gets(char *buf, int max)
{
     548:	7179                	addi	sp,sp,-48
     54a:	f406                	sd	ra,40(sp)
     54c:	f022                	sd	s0,32(sp)
     54e:	1800                	addi	s0,sp,48
     550:	fca43c23          	sd	a0,-40(s0)
     554:	87ae                	mv	a5,a1
     556:	fcf42a23          	sw	a5,-44(s0)
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     55a:	fe042623          	sw	zero,-20(s0)
     55e:	a8a1                	j	5b6 <gets+0x6e>
    cc = read(0, &c, 1);
     560:	fe740793          	addi	a5,s0,-25
     564:	4605                	li	a2,1
     566:	85be                	mv	a1,a5
     568:	4501                	li	a0,0
     56a:	00000097          	auipc	ra,0x0
     56e:	2f8080e7          	jalr	760(ra) # 862 <read>
     572:	87aa                	mv	a5,a0
     574:	fef42423          	sw	a5,-24(s0)
    if(cc < 1)
     578:	fe842783          	lw	a5,-24(s0)
     57c:	2781                	sext.w	a5,a5
     57e:	04f05763          	blez	a5,5cc <gets+0x84>
      break;
    buf[i++] = c;
     582:	fec42783          	lw	a5,-20(s0)
     586:	0017871b          	addiw	a4,a5,1
     58a:	fee42623          	sw	a4,-20(s0)
     58e:	873e                	mv	a4,a5
     590:	fd843783          	ld	a5,-40(s0)
     594:	97ba                	add	a5,a5,a4
     596:	fe744703          	lbu	a4,-25(s0)
     59a:	00e78023          	sb	a4,0(a5)
    if(c == '\n' || c == '\r')
     59e:	fe744783          	lbu	a5,-25(s0)
     5a2:	873e                	mv	a4,a5
     5a4:	47a9                	li	a5,10
     5a6:	02f70463          	beq	a4,a5,5ce <gets+0x86>
     5aa:	fe744783          	lbu	a5,-25(s0)
     5ae:	873e                	mv	a4,a5
     5b0:	47b5                	li	a5,13
     5b2:	00f70e63          	beq	a4,a5,5ce <gets+0x86>
  for(i=0; i+1 < max; ){
     5b6:	fec42783          	lw	a5,-20(s0)
     5ba:	2785                	addiw	a5,a5,1
     5bc:	0007871b          	sext.w	a4,a5
     5c0:	fd442783          	lw	a5,-44(s0)
     5c4:	2781                	sext.w	a5,a5
     5c6:	f8f74de3          	blt	a4,a5,560 <gets+0x18>
     5ca:	a011                	j	5ce <gets+0x86>
      break;
     5cc:	0001                	nop
      break;
  }
  buf[i] = '\0';
     5ce:	fec42783          	lw	a5,-20(s0)
     5d2:	fd843703          	ld	a4,-40(s0)
     5d6:	97ba                	add	a5,a5,a4
     5d8:	00078023          	sb	zero,0(a5)
  return buf;
     5dc:	fd843783          	ld	a5,-40(s0)
}
     5e0:	853e                	mv	a0,a5
     5e2:	70a2                	ld	ra,40(sp)
     5e4:	7402                	ld	s0,32(sp)
     5e6:	6145                	addi	sp,sp,48
     5e8:	8082                	ret

00000000000005ea <stat>:

int
stat(const char *n, struct stat *st)
{
     5ea:	7179                	addi	sp,sp,-48
     5ec:	f406                	sd	ra,40(sp)
     5ee:	f022                	sd	s0,32(sp)
     5f0:	1800                	addi	s0,sp,48
     5f2:	fca43c23          	sd	a0,-40(s0)
     5f6:	fcb43823          	sd	a1,-48(s0)
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     5fa:	4581                	li	a1,0
     5fc:	fd843503          	ld	a0,-40(s0)
     600:	00000097          	auipc	ra,0x0
     604:	28a080e7          	jalr	650(ra) # 88a <open>
     608:	87aa                	mv	a5,a0
     60a:	fef42623          	sw	a5,-20(s0)
  if(fd < 0)
     60e:	fec42783          	lw	a5,-20(s0)
     612:	2781                	sext.w	a5,a5
     614:	0007d463          	bgez	a5,61c <stat+0x32>
    return -1;
     618:	57fd                	li	a5,-1
     61a:	a035                	j	646 <stat+0x5c>
  r = fstat(fd, st);
     61c:	fec42783          	lw	a5,-20(s0)
     620:	fd043583          	ld	a1,-48(s0)
     624:	853e                	mv	a0,a5
     626:	00000097          	auipc	ra,0x0
     62a:	27c080e7          	jalr	636(ra) # 8a2 <fstat>
     62e:	87aa                	mv	a5,a0
     630:	fef42423          	sw	a5,-24(s0)
  close(fd);
     634:	fec42783          	lw	a5,-20(s0)
     638:	853e                	mv	a0,a5
     63a:	00000097          	auipc	ra,0x0
     63e:	238080e7          	jalr	568(ra) # 872 <close>
  return r;
     642:	fe842783          	lw	a5,-24(s0)
}
     646:	853e                	mv	a0,a5
     648:	70a2                	ld	ra,40(sp)
     64a:	7402                	ld	s0,32(sp)
     64c:	6145                	addi	sp,sp,48
     64e:	8082                	ret

0000000000000650 <atoi>:

int
atoi(const char *s)
{
     650:	7179                	addi	sp,sp,-48
     652:	f422                	sd	s0,40(sp)
     654:	1800                	addi	s0,sp,48
     656:	fca43c23          	sd	a0,-40(s0)
  int n;

  n = 0;
     65a:	fe042623          	sw	zero,-20(s0)
  while('0' <= *s && *s <= '9')
     65e:	a81d                	j	694 <atoi+0x44>
    n = n*10 + *s++ - '0';
     660:	fec42783          	lw	a5,-20(s0)
     664:	873e                	mv	a4,a5
     666:	87ba                	mv	a5,a4
     668:	0027979b          	slliw	a5,a5,0x2
     66c:	9fb9                	addw	a5,a5,a4
     66e:	0017979b          	slliw	a5,a5,0x1
     672:	0007871b          	sext.w	a4,a5
     676:	fd843783          	ld	a5,-40(s0)
     67a:	00178693          	addi	a3,a5,1
     67e:	fcd43c23          	sd	a3,-40(s0)
     682:	0007c783          	lbu	a5,0(a5)
     686:	2781                	sext.w	a5,a5
     688:	9fb9                	addw	a5,a5,a4
     68a:	2781                	sext.w	a5,a5
     68c:	fd07879b          	addiw	a5,a5,-48
     690:	fef42623          	sw	a5,-20(s0)
  while('0' <= *s && *s <= '9')
     694:	fd843783          	ld	a5,-40(s0)
     698:	0007c783          	lbu	a5,0(a5)
     69c:	873e                	mv	a4,a5
     69e:	02f00793          	li	a5,47
     6a2:	00e7fb63          	bgeu	a5,a4,6b8 <atoi+0x68>
     6a6:	fd843783          	ld	a5,-40(s0)
     6aa:	0007c783          	lbu	a5,0(a5)
     6ae:	873e                	mv	a4,a5
     6b0:	03900793          	li	a5,57
     6b4:	fae7f6e3          	bgeu	a5,a4,660 <atoi+0x10>
  return n;
     6b8:	fec42783          	lw	a5,-20(s0)
}
     6bc:	853e                	mv	a0,a5
     6be:	7422                	ld	s0,40(sp)
     6c0:	6145                	addi	sp,sp,48
     6c2:	8082                	ret

00000000000006c4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     6c4:	7139                	addi	sp,sp,-64
     6c6:	fc22                	sd	s0,56(sp)
     6c8:	0080                	addi	s0,sp,64
     6ca:	fca43c23          	sd	a0,-40(s0)
     6ce:	fcb43823          	sd	a1,-48(s0)
     6d2:	87b2                	mv	a5,a2
     6d4:	fcf42623          	sw	a5,-52(s0)
  char *dst;
  const char *src;

  dst = vdst;
     6d8:	fd843783          	ld	a5,-40(s0)
     6dc:	fef43423          	sd	a5,-24(s0)
  src = vsrc;
     6e0:	fd043783          	ld	a5,-48(s0)
     6e4:	fef43023          	sd	a5,-32(s0)
  if (src > dst) {
     6e8:	fe043703          	ld	a4,-32(s0)
     6ec:	fe843783          	ld	a5,-24(s0)
     6f0:	02e7fc63          	bgeu	a5,a4,728 <memmove+0x64>
    while(n-- > 0)
     6f4:	a00d                	j	716 <memmove+0x52>
      *dst++ = *src++;
     6f6:	fe043703          	ld	a4,-32(s0)
     6fa:	00170793          	addi	a5,a4,1
     6fe:	fef43023          	sd	a5,-32(s0)
     702:	fe843783          	ld	a5,-24(s0)
     706:	00178693          	addi	a3,a5,1
     70a:	fed43423          	sd	a3,-24(s0)
     70e:	00074703          	lbu	a4,0(a4)
     712:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
     716:	fcc42783          	lw	a5,-52(s0)
     71a:	fff7871b          	addiw	a4,a5,-1
     71e:	fce42623          	sw	a4,-52(s0)
     722:	fcf04ae3          	bgtz	a5,6f6 <memmove+0x32>
     726:	a891                	j	77a <memmove+0xb6>
  } else {
    dst += n;
     728:	fcc42783          	lw	a5,-52(s0)
     72c:	fe843703          	ld	a4,-24(s0)
     730:	97ba                	add	a5,a5,a4
     732:	fef43423          	sd	a5,-24(s0)
    src += n;
     736:	fcc42783          	lw	a5,-52(s0)
     73a:	fe043703          	ld	a4,-32(s0)
     73e:	97ba                	add	a5,a5,a4
     740:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
     744:	a01d                	j	76a <memmove+0xa6>
      *--dst = *--src;
     746:	fe043783          	ld	a5,-32(s0)
     74a:	17fd                	addi	a5,a5,-1
     74c:	fef43023          	sd	a5,-32(s0)
     750:	fe843783          	ld	a5,-24(s0)
     754:	17fd                	addi	a5,a5,-1
     756:	fef43423          	sd	a5,-24(s0)
     75a:	fe043783          	ld	a5,-32(s0)
     75e:	0007c703          	lbu	a4,0(a5)
     762:	fe843783          	ld	a5,-24(s0)
     766:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
     76a:	fcc42783          	lw	a5,-52(s0)
     76e:	fff7871b          	addiw	a4,a5,-1
     772:	fce42623          	sw	a4,-52(s0)
     776:	fcf048e3          	bgtz	a5,746 <memmove+0x82>
  }
  return vdst;
     77a:	fd843783          	ld	a5,-40(s0)
}
     77e:	853e                	mv	a0,a5
     780:	7462                	ld	s0,56(sp)
     782:	6121                	addi	sp,sp,64
     784:	8082                	ret

0000000000000786 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     786:	7139                	addi	sp,sp,-64
     788:	fc22                	sd	s0,56(sp)
     78a:	0080                	addi	s0,sp,64
     78c:	fca43c23          	sd	a0,-40(s0)
     790:	fcb43823          	sd	a1,-48(s0)
     794:	87b2                	mv	a5,a2
     796:	fcf42623          	sw	a5,-52(s0)
  const char *p1 = s1, *p2 = s2;
     79a:	fd843783          	ld	a5,-40(s0)
     79e:	fef43423          	sd	a5,-24(s0)
     7a2:	fd043783          	ld	a5,-48(s0)
     7a6:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
     7aa:	a0a1                	j	7f2 <memcmp+0x6c>
    if (*p1 != *p2) {
     7ac:	fe843783          	ld	a5,-24(s0)
     7b0:	0007c703          	lbu	a4,0(a5)
     7b4:	fe043783          	ld	a5,-32(s0)
     7b8:	0007c783          	lbu	a5,0(a5)
     7bc:	02f70163          	beq	a4,a5,7de <memcmp+0x58>
      return *p1 - *p2;
     7c0:	fe843783          	ld	a5,-24(s0)
     7c4:	0007c783          	lbu	a5,0(a5)
     7c8:	0007871b          	sext.w	a4,a5
     7cc:	fe043783          	ld	a5,-32(s0)
     7d0:	0007c783          	lbu	a5,0(a5)
     7d4:	2781                	sext.w	a5,a5
     7d6:	40f707bb          	subw	a5,a4,a5
     7da:	2781                	sext.w	a5,a5
     7dc:	a01d                	j	802 <memcmp+0x7c>
    }
    p1++;
     7de:	fe843783          	ld	a5,-24(s0)
     7e2:	0785                	addi	a5,a5,1
     7e4:	fef43423          	sd	a5,-24(s0)
    p2++;
     7e8:	fe043783          	ld	a5,-32(s0)
     7ec:	0785                	addi	a5,a5,1
     7ee:	fef43023          	sd	a5,-32(s0)
  while (n-- > 0) {
     7f2:	fcc42783          	lw	a5,-52(s0)
     7f6:	fff7871b          	addiw	a4,a5,-1
     7fa:	fce42623          	sw	a4,-52(s0)
     7fe:	f7dd                	bnez	a5,7ac <memcmp+0x26>
  }
  return 0;
     800:	4781                	li	a5,0
}
     802:	853e                	mv	a0,a5
     804:	7462                	ld	s0,56(sp)
     806:	6121                	addi	sp,sp,64
     808:	8082                	ret

000000000000080a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     80a:	7179                	addi	sp,sp,-48
     80c:	f406                	sd	ra,40(sp)
     80e:	f022                	sd	s0,32(sp)
     810:	1800                	addi	s0,sp,48
     812:	fea43423          	sd	a0,-24(s0)
     816:	feb43023          	sd	a1,-32(s0)
     81a:	87b2                	mv	a5,a2
     81c:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
     820:	fdc42783          	lw	a5,-36(s0)
     824:	863e                	mv	a2,a5
     826:	fe043583          	ld	a1,-32(s0)
     82a:	fe843503          	ld	a0,-24(s0)
     82e:	00000097          	auipc	ra,0x0
     832:	e96080e7          	jalr	-362(ra) # 6c4 <memmove>
     836:	87aa                	mv	a5,a0
}
     838:	853e                	mv	a0,a5
     83a:	70a2                	ld	ra,40(sp)
     83c:	7402                	ld	s0,32(sp)
     83e:	6145                	addi	sp,sp,48
     840:	8082                	ret

0000000000000842 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     842:	4885                	li	a7,1
 ecall
     844:	00000073          	ecall
 ret
     848:	8082                	ret

000000000000084a <exit>:
.global exit
exit:
 li a7, SYS_exit
     84a:	4889                	li	a7,2
 ecall
     84c:	00000073          	ecall
 ret
     850:	8082                	ret

0000000000000852 <wait>:
.global wait
wait:
 li a7, SYS_wait
     852:	488d                	li	a7,3
 ecall
     854:	00000073          	ecall
 ret
     858:	8082                	ret

000000000000085a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     85a:	4891                	li	a7,4
 ecall
     85c:	00000073          	ecall
 ret
     860:	8082                	ret

0000000000000862 <read>:
.global read
read:
 li a7, SYS_read
     862:	4895                	li	a7,5
 ecall
     864:	00000073          	ecall
 ret
     868:	8082                	ret

000000000000086a <write>:
.global write
write:
 li a7, SYS_write
     86a:	48c1                	li	a7,16
 ecall
     86c:	00000073          	ecall
 ret
     870:	8082                	ret

0000000000000872 <close>:
.global close
close:
 li a7, SYS_close
     872:	48d5                	li	a7,21
 ecall
     874:	00000073          	ecall
 ret
     878:	8082                	ret

000000000000087a <kill>:
.global kill
kill:
 li a7, SYS_kill
     87a:	4899                	li	a7,6
 ecall
     87c:	00000073          	ecall
 ret
     880:	8082                	ret

0000000000000882 <exec>:
.global exec
exec:
 li a7, SYS_exec
     882:	489d                	li	a7,7
 ecall
     884:	00000073          	ecall
 ret
     888:	8082                	ret

000000000000088a <open>:
.global open
open:
 li a7, SYS_open
     88a:	48bd                	li	a7,15
 ecall
     88c:	00000073          	ecall
 ret
     890:	8082                	ret

0000000000000892 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     892:	48c5                	li	a7,17
 ecall
     894:	00000073          	ecall
 ret
     898:	8082                	ret

000000000000089a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     89a:	48c9                	li	a7,18
 ecall
     89c:	00000073          	ecall
 ret
     8a0:	8082                	ret

00000000000008a2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     8a2:	48a1                	li	a7,8
 ecall
     8a4:	00000073          	ecall
 ret
     8a8:	8082                	ret

00000000000008aa <link>:
.global link
link:
 li a7, SYS_link
     8aa:	48cd                	li	a7,19
 ecall
     8ac:	00000073          	ecall
 ret
     8b0:	8082                	ret

00000000000008b2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     8b2:	48d1                	li	a7,20
 ecall
     8b4:	00000073          	ecall
 ret
     8b8:	8082                	ret

00000000000008ba <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     8ba:	48a5                	li	a7,9
 ecall
     8bc:	00000073          	ecall
 ret
     8c0:	8082                	ret

00000000000008c2 <dup>:
.global dup
dup:
 li a7, SYS_dup
     8c2:	48a9                	li	a7,10
 ecall
     8c4:	00000073          	ecall
 ret
     8c8:	8082                	ret

00000000000008ca <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     8ca:	48ad                	li	a7,11
 ecall
     8cc:	00000073          	ecall
 ret
     8d0:	8082                	ret

00000000000008d2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     8d2:	48b1                	li	a7,12
 ecall
     8d4:	00000073          	ecall
 ret
     8d8:	8082                	ret

00000000000008da <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     8da:	48b5                	li	a7,13
 ecall
     8dc:	00000073          	ecall
 ret
     8e0:	8082                	ret

00000000000008e2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     8e2:	48b9                	li	a7,14
 ecall
     8e4:	00000073          	ecall
 ret
     8e8:	8082                	ret

00000000000008ea <hello>:
.global hello
hello:
 li a7, SYS_hello
     8ea:	48d9                	li	a7,22
 ecall
     8ec:	00000073          	ecall
 ret
     8f0:	8082                	ret

00000000000008f2 <ps>:
.global ps
ps:
 li a7, SYS_ps
     8f2:	48e1                	li	a7,24
 ecall
     8f4:	00000073          	ecall
 ret
     8f8:	8082                	ret

00000000000008fa <getproc>:
.global getproc
getproc:
 li a7, SYS_getproc
     8fa:	48dd                	li	a7,23
 ecall
     8fc:	00000073          	ecall
 ret
     900:	8082                	ret

0000000000000902 <proctree>:
.global proctree
proctree:
 li a7, SYS_proctree
     902:	48e5                	li	a7,25
 ecall
     904:	00000073          	ecall
 ret
     908:	8082                	ret

000000000000090a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     90a:	1101                	addi	sp,sp,-32
     90c:	ec06                	sd	ra,24(sp)
     90e:	e822                	sd	s0,16(sp)
     910:	1000                	addi	s0,sp,32
     912:	87aa                	mv	a5,a0
     914:	872e                	mv	a4,a1
     916:	fef42623          	sw	a5,-20(s0)
     91a:	87ba                	mv	a5,a4
     91c:	fef405a3          	sb	a5,-21(s0)
  write(fd, &c, 1);
     920:	feb40713          	addi	a4,s0,-21
     924:	fec42783          	lw	a5,-20(s0)
     928:	4605                	li	a2,1
     92a:	85ba                	mv	a1,a4
     92c:	853e                	mv	a0,a5
     92e:	00000097          	auipc	ra,0x0
     932:	f3c080e7          	jalr	-196(ra) # 86a <write>
}
     936:	0001                	nop
     938:	60e2                	ld	ra,24(sp)
     93a:	6442                	ld	s0,16(sp)
     93c:	6105                	addi	sp,sp,32
     93e:	8082                	ret

0000000000000940 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     940:	7139                	addi	sp,sp,-64
     942:	fc06                	sd	ra,56(sp)
     944:	f822                	sd	s0,48(sp)
     946:	0080                	addi	s0,sp,64
     948:	87aa                	mv	a5,a0
     94a:	8736                	mv	a4,a3
     94c:	fcf42623          	sw	a5,-52(s0)
     950:	87ae                	mv	a5,a1
     952:	fcf42423          	sw	a5,-56(s0)
     956:	87b2                	mv	a5,a2
     958:	fcf42223          	sw	a5,-60(s0)
     95c:	87ba                	mv	a5,a4
     95e:	fcf42023          	sw	a5,-64(s0)
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
     962:	fe042423          	sw	zero,-24(s0)
  if(sgn && xx < 0){
     966:	fc042783          	lw	a5,-64(s0)
     96a:	2781                	sext.w	a5,a5
     96c:	c38d                	beqz	a5,98e <printint+0x4e>
     96e:	fc842783          	lw	a5,-56(s0)
     972:	2781                	sext.w	a5,a5
     974:	0007dd63          	bgez	a5,98e <printint+0x4e>
    neg = 1;
     978:	4785                	li	a5,1
     97a:	fef42423          	sw	a5,-24(s0)
    x = -xx;
     97e:	fc842783          	lw	a5,-56(s0)
     982:	40f007bb          	negw	a5,a5
     986:	2781                	sext.w	a5,a5
     988:	fef42223          	sw	a5,-28(s0)
     98c:	a029                	j	996 <printint+0x56>
  } else {
    x = xx;
     98e:	fc842783          	lw	a5,-56(s0)
     992:	fef42223          	sw	a5,-28(s0)
  }

  i = 0;
     996:	fe042623          	sw	zero,-20(s0)
  do{
    buf[i++] = digits[x % base];
     99a:	fc442783          	lw	a5,-60(s0)
     99e:	fe442703          	lw	a4,-28(s0)
     9a2:	02f777bb          	remuw	a5,a4,a5
     9a6:	0007861b          	sext.w	a2,a5
     9aa:	fec42783          	lw	a5,-20(s0)
     9ae:	0017871b          	addiw	a4,a5,1
     9b2:	fee42623          	sw	a4,-20(s0)
     9b6:	00001697          	auipc	a3,0x1
     9ba:	64a68693          	addi	a3,a3,1610 # 2000 <digits>
     9be:	02061713          	slli	a4,a2,0x20
     9c2:	9301                	srli	a4,a4,0x20
     9c4:	9736                	add	a4,a4,a3
     9c6:	00074703          	lbu	a4,0(a4)
     9ca:	17c1                	addi	a5,a5,-16
     9cc:	97a2                	add	a5,a5,s0
     9ce:	fee78023          	sb	a4,-32(a5)
  }while((x /= base) != 0);
     9d2:	fc442783          	lw	a5,-60(s0)
     9d6:	fe442703          	lw	a4,-28(s0)
     9da:	02f757bb          	divuw	a5,a4,a5
     9de:	fef42223          	sw	a5,-28(s0)
     9e2:	fe442783          	lw	a5,-28(s0)
     9e6:	2781                	sext.w	a5,a5
     9e8:	fbcd                	bnez	a5,99a <printint+0x5a>
  if(neg)
     9ea:	fe842783          	lw	a5,-24(s0)
     9ee:	2781                	sext.w	a5,a5
     9f0:	cf85                	beqz	a5,a28 <printint+0xe8>
    buf[i++] = '-';
     9f2:	fec42783          	lw	a5,-20(s0)
     9f6:	0017871b          	addiw	a4,a5,1
     9fa:	fee42623          	sw	a4,-20(s0)
     9fe:	17c1                	addi	a5,a5,-16
     a00:	97a2                	add	a5,a5,s0
     a02:	02d00713          	li	a4,45
     a06:	fee78023          	sb	a4,-32(a5)

  while(--i >= 0)
     a0a:	a839                	j	a28 <printint+0xe8>
    putc(fd, buf[i]);
     a0c:	fec42783          	lw	a5,-20(s0)
     a10:	17c1                	addi	a5,a5,-16
     a12:	97a2                	add	a5,a5,s0
     a14:	fe07c703          	lbu	a4,-32(a5)
     a18:	fcc42783          	lw	a5,-52(s0)
     a1c:	85ba                	mv	a1,a4
     a1e:	853e                	mv	a0,a5
     a20:	00000097          	auipc	ra,0x0
     a24:	eea080e7          	jalr	-278(ra) # 90a <putc>
  while(--i >= 0)
     a28:	fec42783          	lw	a5,-20(s0)
     a2c:	37fd                	addiw	a5,a5,-1
     a2e:	fef42623          	sw	a5,-20(s0)
     a32:	fec42783          	lw	a5,-20(s0)
     a36:	2781                	sext.w	a5,a5
     a38:	fc07dae3          	bgez	a5,a0c <printint+0xcc>
}
     a3c:	0001                	nop
     a3e:	0001                	nop
     a40:	70e2                	ld	ra,56(sp)
     a42:	7442                	ld	s0,48(sp)
     a44:	6121                	addi	sp,sp,64
     a46:	8082                	ret

0000000000000a48 <printptr>:

static void
printptr(int fd, uint64 x) {
     a48:	7179                	addi	sp,sp,-48
     a4a:	f406                	sd	ra,40(sp)
     a4c:	f022                	sd	s0,32(sp)
     a4e:	1800                	addi	s0,sp,48
     a50:	87aa                	mv	a5,a0
     a52:	fcb43823          	sd	a1,-48(s0)
     a56:	fcf42e23          	sw	a5,-36(s0)
  int i;
  putc(fd, '0');
     a5a:	fdc42783          	lw	a5,-36(s0)
     a5e:	03000593          	li	a1,48
     a62:	853e                	mv	a0,a5
     a64:	00000097          	auipc	ra,0x0
     a68:	ea6080e7          	jalr	-346(ra) # 90a <putc>
  putc(fd, 'x');
     a6c:	fdc42783          	lw	a5,-36(s0)
     a70:	07800593          	li	a1,120
     a74:	853e                	mv	a0,a5
     a76:	00000097          	auipc	ra,0x0
     a7a:	e94080e7          	jalr	-364(ra) # 90a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     a7e:	fe042623          	sw	zero,-20(s0)
     a82:	a82d                	j	abc <printptr+0x74>
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     a84:	fd043783          	ld	a5,-48(s0)
     a88:	93f1                	srli	a5,a5,0x3c
     a8a:	00001717          	auipc	a4,0x1
     a8e:	57670713          	addi	a4,a4,1398 # 2000 <digits>
     a92:	97ba                	add	a5,a5,a4
     a94:	0007c703          	lbu	a4,0(a5)
     a98:	fdc42783          	lw	a5,-36(s0)
     a9c:	85ba                	mv	a1,a4
     a9e:	853e                	mv	a0,a5
     aa0:	00000097          	auipc	ra,0x0
     aa4:	e6a080e7          	jalr	-406(ra) # 90a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     aa8:	fec42783          	lw	a5,-20(s0)
     aac:	2785                	addiw	a5,a5,1
     aae:	fef42623          	sw	a5,-20(s0)
     ab2:	fd043783          	ld	a5,-48(s0)
     ab6:	0792                	slli	a5,a5,0x4
     ab8:	fcf43823          	sd	a5,-48(s0)
     abc:	fec42783          	lw	a5,-20(s0)
     ac0:	873e                	mv	a4,a5
     ac2:	47bd                	li	a5,15
     ac4:	fce7f0e3          	bgeu	a5,a4,a84 <printptr+0x3c>
}
     ac8:	0001                	nop
     aca:	0001                	nop
     acc:	70a2                	ld	ra,40(sp)
     ace:	7402                	ld	s0,32(sp)
     ad0:	6145                	addi	sp,sp,48
     ad2:	8082                	ret

0000000000000ad4 <vprintf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     ad4:	715d                	addi	sp,sp,-80
     ad6:	e486                	sd	ra,72(sp)
     ad8:	e0a2                	sd	s0,64(sp)
     ada:	0880                	addi	s0,sp,80
     adc:	87aa                	mv	a5,a0
     ade:	fcb43023          	sd	a1,-64(s0)
     ae2:	fac43c23          	sd	a2,-72(s0)
     ae6:	fcf42623          	sw	a5,-52(s0)
  char *s;
  int c, i, state;

  state = 0;
     aea:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
     aee:	fe042223          	sw	zero,-28(s0)
     af2:	a42d                	j	d1c <vprintf+0x248>
    c = fmt[i] & 0xff;
     af4:	fe442783          	lw	a5,-28(s0)
     af8:	fc043703          	ld	a4,-64(s0)
     afc:	97ba                	add	a5,a5,a4
     afe:	0007c783          	lbu	a5,0(a5)
     b02:	fcf42e23          	sw	a5,-36(s0)
    if(state == 0){
     b06:	fe042783          	lw	a5,-32(s0)
     b0a:	2781                	sext.w	a5,a5
     b0c:	eb9d                	bnez	a5,b42 <vprintf+0x6e>
      if(c == '%'){
     b0e:	fdc42783          	lw	a5,-36(s0)
     b12:	0007871b          	sext.w	a4,a5
     b16:	02500793          	li	a5,37
     b1a:	00f71763          	bne	a4,a5,b28 <vprintf+0x54>
        state = '%';
     b1e:	02500793          	li	a5,37
     b22:	fef42023          	sw	a5,-32(s0)
     b26:	a2f5                	j	d12 <vprintf+0x23e>
      } else {
        putc(fd, c);
     b28:	fdc42783          	lw	a5,-36(s0)
     b2c:	0ff7f713          	zext.b	a4,a5
     b30:	fcc42783          	lw	a5,-52(s0)
     b34:	85ba                	mv	a1,a4
     b36:	853e                	mv	a0,a5
     b38:	00000097          	auipc	ra,0x0
     b3c:	dd2080e7          	jalr	-558(ra) # 90a <putc>
     b40:	aac9                	j	d12 <vprintf+0x23e>
      }
    } else if(state == '%'){
     b42:	fe042783          	lw	a5,-32(s0)
     b46:	0007871b          	sext.w	a4,a5
     b4a:	02500793          	li	a5,37
     b4e:	1cf71263          	bne	a4,a5,d12 <vprintf+0x23e>
      if(c == 'd'){
     b52:	fdc42783          	lw	a5,-36(s0)
     b56:	0007871b          	sext.w	a4,a5
     b5a:	06400793          	li	a5,100
     b5e:	02f71463          	bne	a4,a5,b86 <vprintf+0xb2>
        printint(fd, va_arg(ap, int), 10, 1);
     b62:	fb843783          	ld	a5,-72(s0)
     b66:	00878713          	addi	a4,a5,8
     b6a:	fae43c23          	sd	a4,-72(s0)
     b6e:	4398                	lw	a4,0(a5)
     b70:	fcc42783          	lw	a5,-52(s0)
     b74:	4685                	li	a3,1
     b76:	4629                	li	a2,10
     b78:	85ba                	mv	a1,a4
     b7a:	853e                	mv	a0,a5
     b7c:	00000097          	auipc	ra,0x0
     b80:	dc4080e7          	jalr	-572(ra) # 940 <printint>
     b84:	a269                	j	d0e <vprintf+0x23a>
      } else if(c == 'l') {
     b86:	fdc42783          	lw	a5,-36(s0)
     b8a:	0007871b          	sext.w	a4,a5
     b8e:	06c00793          	li	a5,108
     b92:	02f71663          	bne	a4,a5,bbe <vprintf+0xea>
        printint(fd, va_arg(ap, uint64), 10, 0);
     b96:	fb843783          	ld	a5,-72(s0)
     b9a:	00878713          	addi	a4,a5,8
     b9e:	fae43c23          	sd	a4,-72(s0)
     ba2:	639c                	ld	a5,0(a5)
     ba4:	0007871b          	sext.w	a4,a5
     ba8:	fcc42783          	lw	a5,-52(s0)
     bac:	4681                	li	a3,0
     bae:	4629                	li	a2,10
     bb0:	85ba                	mv	a1,a4
     bb2:	853e                	mv	a0,a5
     bb4:	00000097          	auipc	ra,0x0
     bb8:	d8c080e7          	jalr	-628(ra) # 940 <printint>
     bbc:	aa89                	j	d0e <vprintf+0x23a>
      } else if(c == 'x') {
     bbe:	fdc42783          	lw	a5,-36(s0)
     bc2:	0007871b          	sext.w	a4,a5
     bc6:	07800793          	li	a5,120
     bca:	02f71463          	bne	a4,a5,bf2 <vprintf+0x11e>
        printint(fd, va_arg(ap, int), 16, 0);
     bce:	fb843783          	ld	a5,-72(s0)
     bd2:	00878713          	addi	a4,a5,8
     bd6:	fae43c23          	sd	a4,-72(s0)
     bda:	4398                	lw	a4,0(a5)
     bdc:	fcc42783          	lw	a5,-52(s0)
     be0:	4681                	li	a3,0
     be2:	4641                	li	a2,16
     be4:	85ba                	mv	a1,a4
     be6:	853e                	mv	a0,a5
     be8:	00000097          	auipc	ra,0x0
     bec:	d58080e7          	jalr	-680(ra) # 940 <printint>
     bf0:	aa39                	j	d0e <vprintf+0x23a>
      } else if(c == 'p') {
     bf2:	fdc42783          	lw	a5,-36(s0)
     bf6:	0007871b          	sext.w	a4,a5
     bfa:	07000793          	li	a5,112
     bfe:	02f71263          	bne	a4,a5,c22 <vprintf+0x14e>
        printptr(fd, va_arg(ap, uint64));
     c02:	fb843783          	ld	a5,-72(s0)
     c06:	00878713          	addi	a4,a5,8
     c0a:	fae43c23          	sd	a4,-72(s0)
     c0e:	6398                	ld	a4,0(a5)
     c10:	fcc42783          	lw	a5,-52(s0)
     c14:	85ba                	mv	a1,a4
     c16:	853e                	mv	a0,a5
     c18:	00000097          	auipc	ra,0x0
     c1c:	e30080e7          	jalr	-464(ra) # a48 <printptr>
     c20:	a0fd                	j	d0e <vprintf+0x23a>
      } else if(c == 's'){
     c22:	fdc42783          	lw	a5,-36(s0)
     c26:	0007871b          	sext.w	a4,a5
     c2a:	07300793          	li	a5,115
     c2e:	04f71c63          	bne	a4,a5,c86 <vprintf+0x1b2>
        s = va_arg(ap, char*);
     c32:	fb843783          	ld	a5,-72(s0)
     c36:	00878713          	addi	a4,a5,8
     c3a:	fae43c23          	sd	a4,-72(s0)
     c3e:	639c                	ld	a5,0(a5)
     c40:	fef43423          	sd	a5,-24(s0)
        if(s == 0)
     c44:	fe843783          	ld	a5,-24(s0)
     c48:	eb8d                	bnez	a5,c7a <vprintf+0x1a6>
          s = "(null)";
     c4a:	00000797          	auipc	a5,0x0
     c4e:	4e678793          	addi	a5,a5,1254 # 1130 <malloc+0x1ac>
     c52:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
     c56:	a015                	j	c7a <vprintf+0x1a6>
          putc(fd, *s);
     c58:	fe843783          	ld	a5,-24(s0)
     c5c:	0007c703          	lbu	a4,0(a5)
     c60:	fcc42783          	lw	a5,-52(s0)
     c64:	85ba                	mv	a1,a4
     c66:	853e                	mv	a0,a5
     c68:	00000097          	auipc	ra,0x0
     c6c:	ca2080e7          	jalr	-862(ra) # 90a <putc>
          s++;
     c70:	fe843783          	ld	a5,-24(s0)
     c74:	0785                	addi	a5,a5,1
     c76:	fef43423          	sd	a5,-24(s0)
        while(*s != 0){
     c7a:	fe843783          	ld	a5,-24(s0)
     c7e:	0007c783          	lbu	a5,0(a5)
     c82:	fbf9                	bnez	a5,c58 <vprintf+0x184>
     c84:	a069                	j	d0e <vprintf+0x23a>
        }
      } else if(c == 'c'){
     c86:	fdc42783          	lw	a5,-36(s0)
     c8a:	0007871b          	sext.w	a4,a5
     c8e:	06300793          	li	a5,99
     c92:	02f71463          	bne	a4,a5,cba <vprintf+0x1e6>
        putc(fd, va_arg(ap, uint));
     c96:	fb843783          	ld	a5,-72(s0)
     c9a:	00878713          	addi	a4,a5,8
     c9e:	fae43c23          	sd	a4,-72(s0)
     ca2:	439c                	lw	a5,0(a5)
     ca4:	0ff7f713          	zext.b	a4,a5
     ca8:	fcc42783          	lw	a5,-52(s0)
     cac:	85ba                	mv	a1,a4
     cae:	853e                	mv	a0,a5
     cb0:	00000097          	auipc	ra,0x0
     cb4:	c5a080e7          	jalr	-934(ra) # 90a <putc>
     cb8:	a899                	j	d0e <vprintf+0x23a>
      } else if(c == '%'){
     cba:	fdc42783          	lw	a5,-36(s0)
     cbe:	0007871b          	sext.w	a4,a5
     cc2:	02500793          	li	a5,37
     cc6:	00f71f63          	bne	a4,a5,ce4 <vprintf+0x210>
        putc(fd, c);
     cca:	fdc42783          	lw	a5,-36(s0)
     cce:	0ff7f713          	zext.b	a4,a5
     cd2:	fcc42783          	lw	a5,-52(s0)
     cd6:	85ba                	mv	a1,a4
     cd8:	853e                	mv	a0,a5
     cda:	00000097          	auipc	ra,0x0
     cde:	c30080e7          	jalr	-976(ra) # 90a <putc>
     ce2:	a035                	j	d0e <vprintf+0x23a>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     ce4:	fcc42783          	lw	a5,-52(s0)
     ce8:	02500593          	li	a1,37
     cec:	853e                	mv	a0,a5
     cee:	00000097          	auipc	ra,0x0
     cf2:	c1c080e7          	jalr	-996(ra) # 90a <putc>
        putc(fd, c);
     cf6:	fdc42783          	lw	a5,-36(s0)
     cfa:	0ff7f713          	zext.b	a4,a5
     cfe:	fcc42783          	lw	a5,-52(s0)
     d02:	85ba                	mv	a1,a4
     d04:	853e                	mv	a0,a5
     d06:	00000097          	auipc	ra,0x0
     d0a:	c04080e7          	jalr	-1020(ra) # 90a <putc>
      }
      state = 0;
     d0e:	fe042023          	sw	zero,-32(s0)
  for(i = 0; fmt[i]; i++){
     d12:	fe442783          	lw	a5,-28(s0)
     d16:	2785                	addiw	a5,a5,1
     d18:	fef42223          	sw	a5,-28(s0)
     d1c:	fe442783          	lw	a5,-28(s0)
     d20:	fc043703          	ld	a4,-64(s0)
     d24:	97ba                	add	a5,a5,a4
     d26:	0007c783          	lbu	a5,0(a5)
     d2a:	dc0795e3          	bnez	a5,af4 <vprintf+0x20>
    }
  }
}
     d2e:	0001                	nop
     d30:	0001                	nop
     d32:	60a6                	ld	ra,72(sp)
     d34:	6406                	ld	s0,64(sp)
     d36:	6161                	addi	sp,sp,80
     d38:	8082                	ret

0000000000000d3a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     d3a:	7159                	addi	sp,sp,-112
     d3c:	fc06                	sd	ra,56(sp)
     d3e:	f822                	sd	s0,48(sp)
     d40:	0080                	addi	s0,sp,64
     d42:	fcb43823          	sd	a1,-48(s0)
     d46:	e010                	sd	a2,0(s0)
     d48:	e414                	sd	a3,8(s0)
     d4a:	e818                	sd	a4,16(s0)
     d4c:	ec1c                	sd	a5,24(s0)
     d4e:	03043023          	sd	a6,32(s0)
     d52:	03143423          	sd	a7,40(s0)
     d56:	87aa                	mv	a5,a0
     d58:	fcf42e23          	sw	a5,-36(s0)
  va_list ap;

  va_start(ap, fmt);
     d5c:	03040793          	addi	a5,s0,48
     d60:	fcf43423          	sd	a5,-56(s0)
     d64:	fc843783          	ld	a5,-56(s0)
     d68:	fd078793          	addi	a5,a5,-48
     d6c:	fef43423          	sd	a5,-24(s0)
  vprintf(fd, fmt, ap);
     d70:	fe843703          	ld	a4,-24(s0)
     d74:	fdc42783          	lw	a5,-36(s0)
     d78:	863a                	mv	a2,a4
     d7a:	fd043583          	ld	a1,-48(s0)
     d7e:	853e                	mv	a0,a5
     d80:	00000097          	auipc	ra,0x0
     d84:	d54080e7          	jalr	-684(ra) # ad4 <vprintf>
}
     d88:	0001                	nop
     d8a:	70e2                	ld	ra,56(sp)
     d8c:	7442                	ld	s0,48(sp)
     d8e:	6165                	addi	sp,sp,112
     d90:	8082                	ret

0000000000000d92 <printf>:

void
printf(const char *fmt, ...)
{
     d92:	7159                	addi	sp,sp,-112
     d94:	f406                	sd	ra,40(sp)
     d96:	f022                	sd	s0,32(sp)
     d98:	1800                	addi	s0,sp,48
     d9a:	fca43c23          	sd	a0,-40(s0)
     d9e:	e40c                	sd	a1,8(s0)
     da0:	e810                	sd	a2,16(s0)
     da2:	ec14                	sd	a3,24(s0)
     da4:	f018                	sd	a4,32(s0)
     da6:	f41c                	sd	a5,40(s0)
     da8:	03043823          	sd	a6,48(s0)
     dac:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     db0:	04040793          	addi	a5,s0,64
     db4:	fcf43823          	sd	a5,-48(s0)
     db8:	fd043783          	ld	a5,-48(s0)
     dbc:	fc878793          	addi	a5,a5,-56
     dc0:	fef43423          	sd	a5,-24(s0)
  vprintf(1, fmt, ap);
     dc4:	fe843783          	ld	a5,-24(s0)
     dc8:	863e                	mv	a2,a5
     dca:	fd843583          	ld	a1,-40(s0)
     dce:	4505                	li	a0,1
     dd0:	00000097          	auipc	ra,0x0
     dd4:	d04080e7          	jalr	-764(ra) # ad4 <vprintf>
}
     dd8:	0001                	nop
     dda:	70a2                	ld	ra,40(sp)
     ddc:	7402                	ld	s0,32(sp)
     dde:	6165                	addi	sp,sp,112
     de0:	8082                	ret

0000000000000de2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     de2:	7179                	addi	sp,sp,-48
     de4:	f422                	sd	s0,40(sp)
     de6:	1800                	addi	s0,sp,48
     de8:	fca43c23          	sd	a0,-40(s0)
  Header *bp, *p;

  bp = (Header*)ap - 1;
     dec:	fd843783          	ld	a5,-40(s0)
     df0:	17c1                	addi	a5,a5,-16
     df2:	fef43023          	sd	a5,-32(s0)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     df6:	00001797          	auipc	a5,0x1
     dfa:	24a78793          	addi	a5,a5,586 # 2040 <freep>
     dfe:	639c                	ld	a5,0(a5)
     e00:	fef43423          	sd	a5,-24(s0)
     e04:	a815                	j	e38 <free+0x56>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     e06:	fe843783          	ld	a5,-24(s0)
     e0a:	639c                	ld	a5,0(a5)
     e0c:	fe843703          	ld	a4,-24(s0)
     e10:	00f76f63          	bltu	a4,a5,e2e <free+0x4c>
     e14:	fe043703          	ld	a4,-32(s0)
     e18:	fe843783          	ld	a5,-24(s0)
     e1c:	02e7eb63          	bltu	a5,a4,e52 <free+0x70>
     e20:	fe843783          	ld	a5,-24(s0)
     e24:	639c                	ld	a5,0(a5)
     e26:	fe043703          	ld	a4,-32(s0)
     e2a:	02f76463          	bltu	a4,a5,e52 <free+0x70>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     e2e:	fe843783          	ld	a5,-24(s0)
     e32:	639c                	ld	a5,0(a5)
     e34:	fef43423          	sd	a5,-24(s0)
     e38:	fe043703          	ld	a4,-32(s0)
     e3c:	fe843783          	ld	a5,-24(s0)
     e40:	fce7f3e3          	bgeu	a5,a4,e06 <free+0x24>
     e44:	fe843783          	ld	a5,-24(s0)
     e48:	639c                	ld	a5,0(a5)
     e4a:	fe043703          	ld	a4,-32(s0)
     e4e:	faf77ce3          	bgeu	a4,a5,e06 <free+0x24>
      break;
  if(bp + bp->s.size == p->s.ptr){
     e52:	fe043783          	ld	a5,-32(s0)
     e56:	479c                	lw	a5,8(a5)
     e58:	1782                	slli	a5,a5,0x20
     e5a:	9381                	srli	a5,a5,0x20
     e5c:	0792                	slli	a5,a5,0x4
     e5e:	fe043703          	ld	a4,-32(s0)
     e62:	973e                	add	a4,a4,a5
     e64:	fe843783          	ld	a5,-24(s0)
     e68:	639c                	ld	a5,0(a5)
     e6a:	02f71763          	bne	a4,a5,e98 <free+0xb6>
    bp->s.size += p->s.ptr->s.size;
     e6e:	fe043783          	ld	a5,-32(s0)
     e72:	4798                	lw	a4,8(a5)
     e74:	fe843783          	ld	a5,-24(s0)
     e78:	639c                	ld	a5,0(a5)
     e7a:	479c                	lw	a5,8(a5)
     e7c:	9fb9                	addw	a5,a5,a4
     e7e:	0007871b          	sext.w	a4,a5
     e82:	fe043783          	ld	a5,-32(s0)
     e86:	c798                	sw	a4,8(a5)
    bp->s.ptr = p->s.ptr->s.ptr;
     e88:	fe843783          	ld	a5,-24(s0)
     e8c:	639c                	ld	a5,0(a5)
     e8e:	6398                	ld	a4,0(a5)
     e90:	fe043783          	ld	a5,-32(s0)
     e94:	e398                	sd	a4,0(a5)
     e96:	a039                	j	ea4 <free+0xc2>
  } else
    bp->s.ptr = p->s.ptr;
     e98:	fe843783          	ld	a5,-24(s0)
     e9c:	6398                	ld	a4,0(a5)
     e9e:	fe043783          	ld	a5,-32(s0)
     ea2:	e398                	sd	a4,0(a5)
  if(p + p->s.size == bp){
     ea4:	fe843783          	ld	a5,-24(s0)
     ea8:	479c                	lw	a5,8(a5)
     eaa:	1782                	slli	a5,a5,0x20
     eac:	9381                	srli	a5,a5,0x20
     eae:	0792                	slli	a5,a5,0x4
     eb0:	fe843703          	ld	a4,-24(s0)
     eb4:	97ba                	add	a5,a5,a4
     eb6:	fe043703          	ld	a4,-32(s0)
     eba:	02f71563          	bne	a4,a5,ee4 <free+0x102>
    p->s.size += bp->s.size;
     ebe:	fe843783          	ld	a5,-24(s0)
     ec2:	4798                	lw	a4,8(a5)
     ec4:	fe043783          	ld	a5,-32(s0)
     ec8:	479c                	lw	a5,8(a5)
     eca:	9fb9                	addw	a5,a5,a4
     ecc:	0007871b          	sext.w	a4,a5
     ed0:	fe843783          	ld	a5,-24(s0)
     ed4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
     ed6:	fe043783          	ld	a5,-32(s0)
     eda:	6398                	ld	a4,0(a5)
     edc:	fe843783          	ld	a5,-24(s0)
     ee0:	e398                	sd	a4,0(a5)
     ee2:	a031                	j	eee <free+0x10c>
  } else
    p->s.ptr = bp;
     ee4:	fe843783          	ld	a5,-24(s0)
     ee8:	fe043703          	ld	a4,-32(s0)
     eec:	e398                	sd	a4,0(a5)
  freep = p;
     eee:	00001797          	auipc	a5,0x1
     ef2:	15278793          	addi	a5,a5,338 # 2040 <freep>
     ef6:	fe843703          	ld	a4,-24(s0)
     efa:	e398                	sd	a4,0(a5)
}
     efc:	0001                	nop
     efe:	7422                	ld	s0,40(sp)
     f00:	6145                	addi	sp,sp,48
     f02:	8082                	ret

0000000000000f04 <morecore>:

static Header*
morecore(uint nu)
{
     f04:	7179                	addi	sp,sp,-48
     f06:	f406                	sd	ra,40(sp)
     f08:	f022                	sd	s0,32(sp)
     f0a:	1800                	addi	s0,sp,48
     f0c:	87aa                	mv	a5,a0
     f0e:	fcf42e23          	sw	a5,-36(s0)
  char *p;
  Header *hp;

  if(nu < 4096)
     f12:	fdc42783          	lw	a5,-36(s0)
     f16:	0007871b          	sext.w	a4,a5
     f1a:	6785                	lui	a5,0x1
     f1c:	00f77563          	bgeu	a4,a5,f26 <morecore+0x22>
    nu = 4096;
     f20:	6785                	lui	a5,0x1
     f22:	fcf42e23          	sw	a5,-36(s0)
  p = sbrk(nu * sizeof(Header));
     f26:	fdc42783          	lw	a5,-36(s0)
     f2a:	0047979b          	slliw	a5,a5,0x4
     f2e:	2781                	sext.w	a5,a5
     f30:	2781                	sext.w	a5,a5
     f32:	853e                	mv	a0,a5
     f34:	00000097          	auipc	ra,0x0
     f38:	99e080e7          	jalr	-1634(ra) # 8d2 <sbrk>
     f3c:	fea43423          	sd	a0,-24(s0)
  if(p == (char*)-1)
     f40:	fe843703          	ld	a4,-24(s0)
     f44:	57fd                	li	a5,-1
     f46:	00f71463          	bne	a4,a5,f4e <morecore+0x4a>
    return 0;
     f4a:	4781                	li	a5,0
     f4c:	a03d                	j	f7a <morecore+0x76>
  hp = (Header*)p;
     f4e:	fe843783          	ld	a5,-24(s0)
     f52:	fef43023          	sd	a5,-32(s0)
  hp->s.size = nu;
     f56:	fe043783          	ld	a5,-32(s0)
     f5a:	fdc42703          	lw	a4,-36(s0)
     f5e:	c798                	sw	a4,8(a5)
  free((void*)(hp + 1));
     f60:	fe043783          	ld	a5,-32(s0)
     f64:	07c1                	addi	a5,a5,16 # 1010 <malloc+0x8c>
     f66:	853e                	mv	a0,a5
     f68:	00000097          	auipc	ra,0x0
     f6c:	e7a080e7          	jalr	-390(ra) # de2 <free>
  return freep;
     f70:	00001797          	auipc	a5,0x1
     f74:	0d078793          	addi	a5,a5,208 # 2040 <freep>
     f78:	639c                	ld	a5,0(a5)
}
     f7a:	853e                	mv	a0,a5
     f7c:	70a2                	ld	ra,40(sp)
     f7e:	7402                	ld	s0,32(sp)
     f80:	6145                	addi	sp,sp,48
     f82:	8082                	ret

0000000000000f84 <malloc>:

void*
malloc(uint nbytes)
{
     f84:	7139                	addi	sp,sp,-64
     f86:	fc06                	sd	ra,56(sp)
     f88:	f822                	sd	s0,48(sp)
     f8a:	0080                	addi	s0,sp,64
     f8c:	87aa                	mv	a5,a0
     f8e:	fcf42623          	sw	a5,-52(s0)
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
     f92:	fcc46783          	lwu	a5,-52(s0)
     f96:	07bd                	addi	a5,a5,15
     f98:	8391                	srli	a5,a5,0x4
     f9a:	2781                	sext.w	a5,a5
     f9c:	2785                	addiw	a5,a5,1
     f9e:	fcf42e23          	sw	a5,-36(s0)
  if((prevp = freep) == 0){
     fa2:	00001797          	auipc	a5,0x1
     fa6:	09e78793          	addi	a5,a5,158 # 2040 <freep>
     faa:	639c                	ld	a5,0(a5)
     fac:	fef43023          	sd	a5,-32(s0)
     fb0:	fe043783          	ld	a5,-32(s0)
     fb4:	ef95                	bnez	a5,ff0 <malloc+0x6c>
    base.s.ptr = freep = prevp = &base;
     fb6:	00001797          	auipc	a5,0x1
     fba:	07a78793          	addi	a5,a5,122 # 2030 <base>
     fbe:	fef43023          	sd	a5,-32(s0)
     fc2:	00001797          	auipc	a5,0x1
     fc6:	07e78793          	addi	a5,a5,126 # 2040 <freep>
     fca:	fe043703          	ld	a4,-32(s0)
     fce:	e398                	sd	a4,0(a5)
     fd0:	00001797          	auipc	a5,0x1
     fd4:	07078793          	addi	a5,a5,112 # 2040 <freep>
     fd8:	6398                	ld	a4,0(a5)
     fda:	00001797          	auipc	a5,0x1
     fde:	05678793          	addi	a5,a5,86 # 2030 <base>
     fe2:	e398                	sd	a4,0(a5)
    base.s.size = 0;
     fe4:	00001797          	auipc	a5,0x1
     fe8:	04c78793          	addi	a5,a5,76 # 2030 <base>
     fec:	0007a423          	sw	zero,8(a5)
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
     ff0:	fe043783          	ld	a5,-32(s0)
     ff4:	639c                	ld	a5,0(a5)
     ff6:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
     ffa:	fe843783          	ld	a5,-24(s0)
     ffe:	4798                	lw	a4,8(a5)
    1000:	fdc42783          	lw	a5,-36(s0)
    1004:	2781                	sext.w	a5,a5
    1006:	06f76763          	bltu	a4,a5,1074 <malloc+0xf0>
      if(p->s.size == nunits)
    100a:	fe843783          	ld	a5,-24(s0)
    100e:	4798                	lw	a4,8(a5)
    1010:	fdc42783          	lw	a5,-36(s0)
    1014:	2781                	sext.w	a5,a5
    1016:	00e79963          	bne	a5,a4,1028 <malloc+0xa4>
        prevp->s.ptr = p->s.ptr;
    101a:	fe843783          	ld	a5,-24(s0)
    101e:	6398                	ld	a4,0(a5)
    1020:	fe043783          	ld	a5,-32(s0)
    1024:	e398                	sd	a4,0(a5)
    1026:	a825                	j	105e <malloc+0xda>
      else {
        p->s.size -= nunits;
    1028:	fe843783          	ld	a5,-24(s0)
    102c:	479c                	lw	a5,8(a5)
    102e:	fdc42703          	lw	a4,-36(s0)
    1032:	9f99                	subw	a5,a5,a4
    1034:	0007871b          	sext.w	a4,a5
    1038:	fe843783          	ld	a5,-24(s0)
    103c:	c798                	sw	a4,8(a5)
        p += p->s.size;
    103e:	fe843783          	ld	a5,-24(s0)
    1042:	479c                	lw	a5,8(a5)
    1044:	1782                	slli	a5,a5,0x20
    1046:	9381                	srli	a5,a5,0x20
    1048:	0792                	slli	a5,a5,0x4
    104a:	fe843703          	ld	a4,-24(s0)
    104e:	97ba                	add	a5,a5,a4
    1050:	fef43423          	sd	a5,-24(s0)
        p->s.size = nunits;
    1054:	fe843783          	ld	a5,-24(s0)
    1058:	fdc42703          	lw	a4,-36(s0)
    105c:	c798                	sw	a4,8(a5)
      }
      freep = prevp;
    105e:	00001797          	auipc	a5,0x1
    1062:	fe278793          	addi	a5,a5,-30 # 2040 <freep>
    1066:	fe043703          	ld	a4,-32(s0)
    106a:	e398                	sd	a4,0(a5)
      return (void*)(p + 1);
    106c:	fe843783          	ld	a5,-24(s0)
    1070:	07c1                	addi	a5,a5,16
    1072:	a091                	j	10b6 <malloc+0x132>
    }
    if(p == freep)
    1074:	00001797          	auipc	a5,0x1
    1078:	fcc78793          	addi	a5,a5,-52 # 2040 <freep>
    107c:	639c                	ld	a5,0(a5)
    107e:	fe843703          	ld	a4,-24(s0)
    1082:	02f71063          	bne	a4,a5,10a2 <malloc+0x11e>
      if((p = morecore(nunits)) == 0)
    1086:	fdc42783          	lw	a5,-36(s0)
    108a:	853e                	mv	a0,a5
    108c:	00000097          	auipc	ra,0x0
    1090:	e78080e7          	jalr	-392(ra) # f04 <morecore>
    1094:	fea43423          	sd	a0,-24(s0)
    1098:	fe843783          	ld	a5,-24(s0)
    109c:	e399                	bnez	a5,10a2 <malloc+0x11e>
        return 0;
    109e:	4781                	li	a5,0
    10a0:	a819                	j	10b6 <malloc+0x132>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10a2:	fe843783          	ld	a5,-24(s0)
    10a6:	fef43023          	sd	a5,-32(s0)
    10aa:	fe843783          	ld	a5,-24(s0)
    10ae:	639c                	ld	a5,0(a5)
    10b0:	fef43423          	sd	a5,-24(s0)
    if(p->s.size >= nunits){
    10b4:	b799                	j	ffa <malloc+0x76>
  }
}
    10b6:	853e                	mv	a0,a5
    10b8:	70e2                	ld	ra,56(sp)
    10ba:	7442                	ld	s0,48(sp)
    10bc:	6121                	addi	sp,sp,64
    10be:	8082                	ret
