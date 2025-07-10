
user/_zombie:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
    int pid = fork();
   a:	28e000ef          	jal	298 <fork>
    
    if(pid == 0) 
   e:	c115                	beqz	a0,32 <main+0x32>
        exit(0);
    } else 
    
    {
        // Parent process
        pstree();
  10:	330000ef          	jal	340 <pstree>
  14:	4495                	li	s1,5
        // Keep parent alive but responsive
        int cnt=5;
        while(1 && cnt) 
        {
            sleep(50);
  16:	03200513          	li	a0,50
  1a:	316000ef          	jal	330 <sleep>
            pstree();
  1e:	322000ef          	jal	340 <pstree>
        while(1 && cnt) 
  22:	34fd                	addiw	s1,s1,-1
  24:	f8ed                	bnez	s1,16 <main+0x16>
            cnt--;
        }
    }
    return 0;
  26:	4501                	li	a0,0
  28:	60e2                	ld	ra,24(sp)
  2a:	6442                	ld	s0,16(sp)
  2c:	64a2                	ld	s1,8(sp)
  2e:	6105                	addi	sp,sp,32
  30:	8082                	ret
        exit(0);
  32:	26e000ef          	jal	2a0 <exit>

0000000000000036 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  36:	1141                	addi	sp,sp,-16
  38:	e406                	sd	ra,8(sp)
  3a:	e022                	sd	s0,0(sp)
  3c:	0800                	addi	s0,sp,16
  extern int main();
  main();
  3e:	fc3ff0ef          	jal	0 <main>
  exit(0);
  42:	4501                	li	a0,0
  44:	25c000ef          	jal	2a0 <exit>

0000000000000048 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  48:	1141                	addi	sp,sp,-16
  4a:	e422                	sd	s0,8(sp)
  4c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  4e:	87aa                	mv	a5,a0
  50:	0585                	addi	a1,a1,1
  52:	0785                	addi	a5,a5,1
  54:	fff5c703          	lbu	a4,-1(a1)
  58:	fee78fa3          	sb	a4,-1(a5)
  5c:	fb75                	bnez	a4,50 <strcpy+0x8>
    ;
  return os;
}
  5e:	6422                	ld	s0,8(sp)
  60:	0141                	addi	sp,sp,16
  62:	8082                	ret

0000000000000064 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  64:	1141                	addi	sp,sp,-16
  66:	e422                	sd	s0,8(sp)
  68:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  6a:	00054783          	lbu	a5,0(a0)
  6e:	cb91                	beqz	a5,82 <strcmp+0x1e>
  70:	0005c703          	lbu	a4,0(a1)
  74:	00f71763          	bne	a4,a5,82 <strcmp+0x1e>
    p++, q++;
  78:	0505                	addi	a0,a0,1
  7a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  7c:	00054783          	lbu	a5,0(a0)
  80:	fbe5                	bnez	a5,70 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  82:	0005c503          	lbu	a0,0(a1)
}
  86:	40a7853b          	subw	a0,a5,a0
  8a:	6422                	ld	s0,8(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret

0000000000000090 <strlen>:

uint
strlen(const char *s)
{
  90:	1141                	addi	sp,sp,-16
  92:	e422                	sd	s0,8(sp)
  94:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  96:	00054783          	lbu	a5,0(a0)
  9a:	cf91                	beqz	a5,b6 <strlen+0x26>
  9c:	0505                	addi	a0,a0,1
  9e:	87aa                	mv	a5,a0
  a0:	86be                	mv	a3,a5
  a2:	0785                	addi	a5,a5,1
  a4:	fff7c703          	lbu	a4,-1(a5)
  a8:	ff65                	bnez	a4,a0 <strlen+0x10>
  aa:	40a6853b          	subw	a0,a3,a0
  ae:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  b0:	6422                	ld	s0,8(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret
  for(n = 0; s[n]; n++)
  b6:	4501                	li	a0,0
  b8:	bfe5                	j	b0 <strlen+0x20>

00000000000000ba <memset>:

void*
memset(void *dst, int c, uint n)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  c0:	ca19                	beqz	a2,d6 <memset+0x1c>
  c2:	87aa                	mv	a5,a0
  c4:	1602                	slli	a2,a2,0x20
  c6:	9201                	srli	a2,a2,0x20
  c8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  cc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  d0:	0785                	addi	a5,a5,1
  d2:	fee79de3          	bne	a5,a4,cc <memset+0x12>
  }
  return dst;
}
  d6:	6422                	ld	s0,8(sp)
  d8:	0141                	addi	sp,sp,16
  da:	8082                	ret

00000000000000dc <strchr>:

char*
strchr(const char *s, char c)
{
  dc:	1141                	addi	sp,sp,-16
  de:	e422                	sd	s0,8(sp)
  e0:	0800                	addi	s0,sp,16
  for(; *s; s++)
  e2:	00054783          	lbu	a5,0(a0)
  e6:	cb99                	beqz	a5,fc <strchr+0x20>
    if(*s == c)
  e8:	00f58763          	beq	a1,a5,f6 <strchr+0x1a>
  for(; *s; s++)
  ec:	0505                	addi	a0,a0,1
  ee:	00054783          	lbu	a5,0(a0)
  f2:	fbfd                	bnez	a5,e8 <strchr+0xc>
      return (char*)s;
  return 0;
  f4:	4501                	li	a0,0
}
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	addi	sp,sp,16
  fa:	8082                	ret
  return 0;
  fc:	4501                	li	a0,0
  fe:	bfe5                	j	f6 <strchr+0x1a>

0000000000000100 <gets>:

char*
gets(char *buf, int max)
{
 100:	711d                	addi	sp,sp,-96
 102:	ec86                	sd	ra,88(sp)
 104:	e8a2                	sd	s0,80(sp)
 106:	e4a6                	sd	s1,72(sp)
 108:	e0ca                	sd	s2,64(sp)
 10a:	fc4e                	sd	s3,56(sp)
 10c:	f852                	sd	s4,48(sp)
 10e:	f456                	sd	s5,40(sp)
 110:	f05a                	sd	s6,32(sp)
 112:	ec5e                	sd	s7,24(sp)
 114:	1080                	addi	s0,sp,96
 116:	8baa                	mv	s7,a0
 118:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 11a:	892a                	mv	s2,a0
 11c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 11e:	4aa9                	li	s5,10
 120:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 122:	89a6                	mv	s3,s1
 124:	2485                	addiw	s1,s1,1
 126:	0344d663          	bge	s1,s4,152 <gets+0x52>
    cc = read(0, &c, 1);
 12a:	4605                	li	a2,1
 12c:	faf40593          	addi	a1,s0,-81
 130:	4501                	li	a0,0
 132:	186000ef          	jal	2b8 <read>
    if(cc < 1)
 136:	00a05e63          	blez	a0,152 <gets+0x52>
    buf[i++] = c;
 13a:	faf44783          	lbu	a5,-81(s0)
 13e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 142:	01578763          	beq	a5,s5,150 <gets+0x50>
 146:	0905                	addi	s2,s2,1
 148:	fd679de3          	bne	a5,s6,122 <gets+0x22>
    buf[i++] = c;
 14c:	89a6                	mv	s3,s1
 14e:	a011                	j	152 <gets+0x52>
 150:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 152:	99de                	add	s3,s3,s7
 154:	00098023          	sb	zero,0(s3)
  return buf;
}
 158:	855e                	mv	a0,s7
 15a:	60e6                	ld	ra,88(sp)
 15c:	6446                	ld	s0,80(sp)
 15e:	64a6                	ld	s1,72(sp)
 160:	6906                	ld	s2,64(sp)
 162:	79e2                	ld	s3,56(sp)
 164:	7a42                	ld	s4,48(sp)
 166:	7aa2                	ld	s5,40(sp)
 168:	7b02                	ld	s6,32(sp)
 16a:	6be2                	ld	s7,24(sp)
 16c:	6125                	addi	sp,sp,96
 16e:	8082                	ret

0000000000000170 <stat>:

int
stat(const char *n, struct stat *st)
{
 170:	1101                	addi	sp,sp,-32
 172:	ec06                	sd	ra,24(sp)
 174:	e822                	sd	s0,16(sp)
 176:	e04a                	sd	s2,0(sp)
 178:	1000                	addi	s0,sp,32
 17a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 17c:	4581                	li	a1,0
 17e:	162000ef          	jal	2e0 <open>
  if(fd < 0)
 182:	02054263          	bltz	a0,1a6 <stat+0x36>
 186:	e426                	sd	s1,8(sp)
 188:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 18a:	85ca                	mv	a1,s2
 18c:	16c000ef          	jal	2f8 <fstat>
 190:	892a                	mv	s2,a0
  close(fd);
 192:	8526                	mv	a0,s1
 194:	134000ef          	jal	2c8 <close>
  return r;
 198:	64a2                	ld	s1,8(sp)
}
 19a:	854a                	mv	a0,s2
 19c:	60e2                	ld	ra,24(sp)
 19e:	6442                	ld	s0,16(sp)
 1a0:	6902                	ld	s2,0(sp)
 1a2:	6105                	addi	sp,sp,32
 1a4:	8082                	ret
    return -1;
 1a6:	597d                	li	s2,-1
 1a8:	bfcd                	j	19a <stat+0x2a>

00000000000001aa <atoi>:

int
atoi(const char *s)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1b0:	00054683          	lbu	a3,0(a0)
 1b4:	fd06879b          	addiw	a5,a3,-48
 1b8:	0ff7f793          	zext.b	a5,a5
 1bc:	4625                	li	a2,9
 1be:	02f66863          	bltu	a2,a5,1ee <atoi+0x44>
 1c2:	872a                	mv	a4,a0
  n = 0;
 1c4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1c6:	0705                	addi	a4,a4,1
 1c8:	0025179b          	slliw	a5,a0,0x2
 1cc:	9fa9                	addw	a5,a5,a0
 1ce:	0017979b          	slliw	a5,a5,0x1
 1d2:	9fb5                	addw	a5,a5,a3
 1d4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d8:	00074683          	lbu	a3,0(a4)
 1dc:	fd06879b          	addiw	a5,a3,-48
 1e0:	0ff7f793          	zext.b	a5,a5
 1e4:	fef671e3          	bgeu	a2,a5,1c6 <atoi+0x1c>
  return n;
}
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret
  n = 0;
 1ee:	4501                	li	a0,0
 1f0:	bfe5                	j	1e8 <atoi+0x3e>

00000000000001f2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1f2:	1141                	addi	sp,sp,-16
 1f4:	e422                	sd	s0,8(sp)
 1f6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f8:	02b57463          	bgeu	a0,a1,220 <memmove+0x2e>
    while(n-- > 0)
 1fc:	00c05f63          	blez	a2,21a <memmove+0x28>
 200:	1602                	slli	a2,a2,0x20
 202:	9201                	srli	a2,a2,0x20
 204:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 208:	872a                	mv	a4,a0
      *dst++ = *src++;
 20a:	0585                	addi	a1,a1,1
 20c:	0705                	addi	a4,a4,1
 20e:	fff5c683          	lbu	a3,-1(a1)
 212:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 216:	fef71ae3          	bne	a4,a5,20a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	addi	sp,sp,16
 21e:	8082                	ret
    dst += n;
 220:	00c50733          	add	a4,a0,a2
    src += n;
 224:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 226:	fec05ae3          	blez	a2,21a <memmove+0x28>
 22a:	fff6079b          	addiw	a5,a2,-1
 22e:	1782                	slli	a5,a5,0x20
 230:	9381                	srli	a5,a5,0x20
 232:	fff7c793          	not	a5,a5
 236:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 238:	15fd                	addi	a1,a1,-1
 23a:	177d                	addi	a4,a4,-1
 23c:	0005c683          	lbu	a3,0(a1)
 240:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 244:	fee79ae3          	bne	a5,a4,238 <memmove+0x46>
 248:	bfc9                	j	21a <memmove+0x28>

000000000000024a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 250:	ca05                	beqz	a2,280 <memcmp+0x36>
 252:	fff6069b          	addiw	a3,a2,-1
 256:	1682                	slli	a3,a3,0x20
 258:	9281                	srli	a3,a3,0x20
 25a:	0685                	addi	a3,a3,1
 25c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 25e:	00054783          	lbu	a5,0(a0)
 262:	0005c703          	lbu	a4,0(a1)
 266:	00e79863          	bne	a5,a4,276 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 26a:	0505                	addi	a0,a0,1
    p2++;
 26c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 26e:	fed518e3          	bne	a0,a3,25e <memcmp+0x14>
  }
  return 0;
 272:	4501                	li	a0,0
 274:	a019                	j	27a <memcmp+0x30>
      return *p1 - *p2;
 276:	40e7853b          	subw	a0,a5,a4
}
 27a:	6422                	ld	s0,8(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
  return 0;
 280:	4501                	li	a0,0
 282:	bfe5                	j	27a <memcmp+0x30>

0000000000000284 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 284:	1141                	addi	sp,sp,-16
 286:	e406                	sd	ra,8(sp)
 288:	e022                	sd	s0,0(sp)
 28a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 28c:	f67ff0ef          	jal	1f2 <memmove>
}
 290:	60a2                	ld	ra,8(sp)
 292:	6402                	ld	s0,0(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 298:	4885                	li	a7,1
 ecall
 29a:	00000073          	ecall
 ret
 29e:	8082                	ret

00000000000002a0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2a0:	4889                	li	a7,2
 ecall
 2a2:	00000073          	ecall
 ret
 2a6:	8082                	ret

00000000000002a8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2a8:	488d                	li	a7,3
 ecall
 2aa:	00000073          	ecall
 ret
 2ae:	8082                	ret

00000000000002b0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2b0:	4891                	li	a7,4
 ecall
 2b2:	00000073          	ecall
 ret
 2b6:	8082                	ret

00000000000002b8 <read>:
.global read
read:
 li a7, SYS_read
 2b8:	4895                	li	a7,5
 ecall
 2ba:	00000073          	ecall
 ret
 2be:	8082                	ret

00000000000002c0 <write>:
.global write
write:
 li a7, SYS_write
 2c0:	48c1                	li	a7,16
 ecall
 2c2:	00000073          	ecall
 ret
 2c6:	8082                	ret

00000000000002c8 <close>:
.global close
close:
 li a7, SYS_close
 2c8:	48d5                	li	a7,21
 ecall
 2ca:	00000073          	ecall
 ret
 2ce:	8082                	ret

00000000000002d0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2d0:	4899                	li	a7,6
 ecall
 2d2:	00000073          	ecall
 ret
 2d6:	8082                	ret

00000000000002d8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2d8:	489d                	li	a7,7
 ecall
 2da:	00000073          	ecall
 ret
 2de:	8082                	ret

00000000000002e0 <open>:
.global open
open:
 li a7, SYS_open
 2e0:	48bd                	li	a7,15
 ecall
 2e2:	00000073          	ecall
 ret
 2e6:	8082                	ret

00000000000002e8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2e8:	48c5                	li	a7,17
 ecall
 2ea:	00000073          	ecall
 ret
 2ee:	8082                	ret

00000000000002f0 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2f0:	48c9                	li	a7,18
 ecall
 2f2:	00000073          	ecall
 ret
 2f6:	8082                	ret

00000000000002f8 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2f8:	48a1                	li	a7,8
 ecall
 2fa:	00000073          	ecall
 ret
 2fe:	8082                	ret

0000000000000300 <link>:
.global link
link:
 li a7, SYS_link
 300:	48cd                	li	a7,19
 ecall
 302:	00000073          	ecall
 ret
 306:	8082                	ret

0000000000000308 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 308:	48d1                	li	a7,20
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 310:	48a5                	li	a7,9
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <dup>:
.global dup
dup:
 li a7, SYS_dup
 318:	48a9                	li	a7,10
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 320:	48ad                	li	a7,11
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 328:	48b1                	li	a7,12
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 330:	48b5                	li	a7,13
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 338:	48b9                	li	a7,14
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <pstree>:
.global pstree
pstree:
 li a7, SYS_pstree
 340:	48d9                	li	a7,22
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 348:	1101                	addi	sp,sp,-32
 34a:	ec06                	sd	ra,24(sp)
 34c:	e822                	sd	s0,16(sp)
 34e:	1000                	addi	s0,sp,32
 350:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 354:	4605                	li	a2,1
 356:	fef40593          	addi	a1,s0,-17
 35a:	f67ff0ef          	jal	2c0 <write>
}
 35e:	60e2                	ld	ra,24(sp)
 360:	6442                	ld	s0,16(sp)
 362:	6105                	addi	sp,sp,32
 364:	8082                	ret

0000000000000366 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 366:	7139                	addi	sp,sp,-64
 368:	fc06                	sd	ra,56(sp)
 36a:	f822                	sd	s0,48(sp)
 36c:	f426                	sd	s1,40(sp)
 36e:	0080                	addi	s0,sp,64
 370:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 372:	c299                	beqz	a3,378 <printint+0x12>
 374:	0805c963          	bltz	a1,406 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 378:	2581                	sext.w	a1,a1
  neg = 0;
 37a:	4881                	li	a7,0
 37c:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 380:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 382:	2601                	sext.w	a2,a2
 384:	00000517          	auipc	a0,0x0
 388:	4f450513          	addi	a0,a0,1268 # 878 <digits>
 38c:	883a                	mv	a6,a4
 38e:	2705                	addiw	a4,a4,1
 390:	02c5f7bb          	remuw	a5,a1,a2
 394:	1782                	slli	a5,a5,0x20
 396:	9381                	srli	a5,a5,0x20
 398:	97aa                	add	a5,a5,a0
 39a:	0007c783          	lbu	a5,0(a5)
 39e:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3a2:	0005879b          	sext.w	a5,a1
 3a6:	02c5d5bb          	divuw	a1,a1,a2
 3aa:	0685                	addi	a3,a3,1
 3ac:	fec7f0e3          	bgeu	a5,a2,38c <printint+0x26>
  if(neg)
 3b0:	00088c63          	beqz	a7,3c8 <printint+0x62>
    buf[i++] = '-';
 3b4:	fd070793          	addi	a5,a4,-48
 3b8:	00878733          	add	a4,a5,s0
 3bc:	02d00793          	li	a5,45
 3c0:	fef70823          	sb	a5,-16(a4)
 3c4:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3c8:	02e05a63          	blez	a4,3fc <printint+0x96>
 3cc:	f04a                	sd	s2,32(sp)
 3ce:	ec4e                	sd	s3,24(sp)
 3d0:	fc040793          	addi	a5,s0,-64
 3d4:	00e78933          	add	s2,a5,a4
 3d8:	fff78993          	addi	s3,a5,-1
 3dc:	99ba                	add	s3,s3,a4
 3de:	377d                	addiw	a4,a4,-1
 3e0:	1702                	slli	a4,a4,0x20
 3e2:	9301                	srli	a4,a4,0x20
 3e4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3e8:	fff94583          	lbu	a1,-1(s2)
 3ec:	8526                	mv	a0,s1
 3ee:	f5bff0ef          	jal	348 <putc>
  while(--i >= 0)
 3f2:	197d                	addi	s2,s2,-1
 3f4:	ff391ae3          	bne	s2,s3,3e8 <printint+0x82>
 3f8:	7902                	ld	s2,32(sp)
 3fa:	69e2                	ld	s3,24(sp)
}
 3fc:	70e2                	ld	ra,56(sp)
 3fe:	7442                	ld	s0,48(sp)
 400:	74a2                	ld	s1,40(sp)
 402:	6121                	addi	sp,sp,64
 404:	8082                	ret
    x = -xx;
 406:	40b005bb          	negw	a1,a1
    neg = 1;
 40a:	4885                	li	a7,1
    x = -xx;
 40c:	bf85                	j	37c <printint+0x16>

000000000000040e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 40e:	711d                	addi	sp,sp,-96
 410:	ec86                	sd	ra,88(sp)
 412:	e8a2                	sd	s0,80(sp)
 414:	e0ca                	sd	s2,64(sp)
 416:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 418:	0005c903          	lbu	s2,0(a1)
 41c:	26090863          	beqz	s2,68c <vprintf+0x27e>
 420:	e4a6                	sd	s1,72(sp)
 422:	fc4e                	sd	s3,56(sp)
 424:	f852                	sd	s4,48(sp)
 426:	f456                	sd	s5,40(sp)
 428:	f05a                	sd	s6,32(sp)
 42a:	ec5e                	sd	s7,24(sp)
 42c:	e862                	sd	s8,16(sp)
 42e:	e466                	sd	s9,8(sp)
 430:	8b2a                	mv	s6,a0
 432:	8a2e                	mv	s4,a1
 434:	8bb2                	mv	s7,a2
  state = 0;
 436:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 438:	4481                	li	s1,0
 43a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 43c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 440:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 444:	06c00c93          	li	s9,108
 448:	a005                	j	468 <vprintf+0x5a>
        putc(fd, c0);
 44a:	85ca                	mv	a1,s2
 44c:	855a                	mv	a0,s6
 44e:	efbff0ef          	jal	348 <putc>
 452:	a019                	j	458 <vprintf+0x4a>
    } else if(state == '%'){
 454:	03598263          	beq	s3,s5,478 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 458:	2485                	addiw	s1,s1,1
 45a:	8726                	mv	a4,s1
 45c:	009a07b3          	add	a5,s4,s1
 460:	0007c903          	lbu	s2,0(a5)
 464:	20090c63          	beqz	s2,67c <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 468:	0009079b          	sext.w	a5,s2
    if(state == 0){
 46c:	fe0994e3          	bnez	s3,454 <vprintf+0x46>
      if(c0 == '%'){
 470:	fd579de3          	bne	a5,s5,44a <vprintf+0x3c>
        state = '%';
 474:	89be                	mv	s3,a5
 476:	b7cd                	j	458 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 478:	00ea06b3          	add	a3,s4,a4
 47c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 480:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 482:	c681                	beqz	a3,48a <vprintf+0x7c>
 484:	9752                	add	a4,a4,s4
 486:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 48a:	03878f63          	beq	a5,s8,4c8 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 48e:	05978963          	beq	a5,s9,4e0 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 492:	07500713          	li	a4,117
 496:	0ee78363          	beq	a5,a4,57c <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 49a:	07800713          	li	a4,120
 49e:	12e78563          	beq	a5,a4,5c8 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4a2:	07000713          	li	a4,112
 4a6:	14e78a63          	beq	a5,a4,5fa <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 4aa:	07300713          	li	a4,115
 4ae:	18e78a63          	beq	a5,a4,642 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 4b2:	02500713          	li	a4,37
 4b6:	04e79563          	bne	a5,a4,500 <vprintf+0xf2>
        putc(fd, '%');
 4ba:	02500593          	li	a1,37
 4be:	855a                	mv	a0,s6
 4c0:	e89ff0ef          	jal	348 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 4c4:	4981                	li	s3,0
 4c6:	bf49                	j	458 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4c8:	008b8913          	addi	s2,s7,8
 4cc:	4685                	li	a3,1
 4ce:	4629                	li	a2,10
 4d0:	000ba583          	lw	a1,0(s7)
 4d4:	855a                	mv	a0,s6
 4d6:	e91ff0ef          	jal	366 <printint>
 4da:	8bca                	mv	s7,s2
      state = 0;
 4dc:	4981                	li	s3,0
 4de:	bfad                	j	458 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 4e0:	06400793          	li	a5,100
 4e4:	02f68963          	beq	a3,a5,516 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 4e8:	06c00793          	li	a5,108
 4ec:	04f68263          	beq	a3,a5,530 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 4f0:	07500793          	li	a5,117
 4f4:	0af68063          	beq	a3,a5,594 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 4f8:	07800793          	li	a5,120
 4fc:	0ef68263          	beq	a3,a5,5e0 <vprintf+0x1d2>
        putc(fd, '%');
 500:	02500593          	li	a1,37
 504:	855a                	mv	a0,s6
 506:	e43ff0ef          	jal	348 <putc>
        putc(fd, c0);
 50a:	85ca                	mv	a1,s2
 50c:	855a                	mv	a0,s6
 50e:	e3bff0ef          	jal	348 <putc>
      state = 0;
 512:	4981                	li	s3,0
 514:	b791                	j	458 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 516:	008b8913          	addi	s2,s7,8
 51a:	4685                	li	a3,1
 51c:	4629                	li	a2,10
 51e:	000ba583          	lw	a1,0(s7)
 522:	855a                	mv	a0,s6
 524:	e43ff0ef          	jal	366 <printint>
        i += 1;
 528:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 52a:	8bca                	mv	s7,s2
      state = 0;
 52c:	4981                	li	s3,0
        i += 1;
 52e:	b72d                	j	458 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 530:	06400793          	li	a5,100
 534:	02f60763          	beq	a2,a5,562 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 538:	07500793          	li	a5,117
 53c:	06f60963          	beq	a2,a5,5ae <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 540:	07800793          	li	a5,120
 544:	faf61ee3          	bne	a2,a5,500 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 548:	008b8913          	addi	s2,s7,8
 54c:	4681                	li	a3,0
 54e:	4641                	li	a2,16
 550:	000ba583          	lw	a1,0(s7)
 554:	855a                	mv	a0,s6
 556:	e11ff0ef          	jal	366 <printint>
        i += 2;
 55a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 55c:	8bca                	mv	s7,s2
      state = 0;
 55e:	4981                	li	s3,0
        i += 2;
 560:	bde5                	j	458 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 562:	008b8913          	addi	s2,s7,8
 566:	4685                	li	a3,1
 568:	4629                	li	a2,10
 56a:	000ba583          	lw	a1,0(s7)
 56e:	855a                	mv	a0,s6
 570:	df7ff0ef          	jal	366 <printint>
        i += 2;
 574:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 576:	8bca                	mv	s7,s2
      state = 0;
 578:	4981                	li	s3,0
        i += 2;
 57a:	bdf9                	j	458 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 57c:	008b8913          	addi	s2,s7,8
 580:	4681                	li	a3,0
 582:	4629                	li	a2,10
 584:	000ba583          	lw	a1,0(s7)
 588:	855a                	mv	a0,s6
 58a:	dddff0ef          	jal	366 <printint>
 58e:	8bca                	mv	s7,s2
      state = 0;
 590:	4981                	li	s3,0
 592:	b5d9                	j	458 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 594:	008b8913          	addi	s2,s7,8
 598:	4681                	li	a3,0
 59a:	4629                	li	a2,10
 59c:	000ba583          	lw	a1,0(s7)
 5a0:	855a                	mv	a0,s6
 5a2:	dc5ff0ef          	jal	366 <printint>
        i += 1;
 5a6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5a8:	8bca                	mv	s7,s2
      state = 0;
 5aa:	4981                	li	s3,0
        i += 1;
 5ac:	b575                	j	458 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ae:	008b8913          	addi	s2,s7,8
 5b2:	4681                	li	a3,0
 5b4:	4629                	li	a2,10
 5b6:	000ba583          	lw	a1,0(s7)
 5ba:	855a                	mv	a0,s6
 5bc:	dabff0ef          	jal	366 <printint>
        i += 2;
 5c0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c2:	8bca                	mv	s7,s2
      state = 0;
 5c4:	4981                	li	s3,0
        i += 2;
 5c6:	bd49                	j	458 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 5c8:	008b8913          	addi	s2,s7,8
 5cc:	4681                	li	a3,0
 5ce:	4641                	li	a2,16
 5d0:	000ba583          	lw	a1,0(s7)
 5d4:	855a                	mv	a0,s6
 5d6:	d91ff0ef          	jal	366 <printint>
 5da:	8bca                	mv	s7,s2
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	bdad                	j	458 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e0:	008b8913          	addi	s2,s7,8
 5e4:	4681                	li	a3,0
 5e6:	4641                	li	a2,16
 5e8:	000ba583          	lw	a1,0(s7)
 5ec:	855a                	mv	a0,s6
 5ee:	d79ff0ef          	jal	366 <printint>
        i += 1;
 5f2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f4:	8bca                	mv	s7,s2
      state = 0;
 5f6:	4981                	li	s3,0
        i += 1;
 5f8:	b585                	j	458 <vprintf+0x4a>
 5fa:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5fc:	008b8d13          	addi	s10,s7,8
 600:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 604:	03000593          	li	a1,48
 608:	855a                	mv	a0,s6
 60a:	d3fff0ef          	jal	348 <putc>
  putc(fd, 'x');
 60e:	07800593          	li	a1,120
 612:	855a                	mv	a0,s6
 614:	d35ff0ef          	jal	348 <putc>
 618:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61a:	00000b97          	auipc	s7,0x0
 61e:	25eb8b93          	addi	s7,s7,606 # 878 <digits>
 622:	03c9d793          	srli	a5,s3,0x3c
 626:	97de                	add	a5,a5,s7
 628:	0007c583          	lbu	a1,0(a5)
 62c:	855a                	mv	a0,s6
 62e:	d1bff0ef          	jal	348 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 632:	0992                	slli	s3,s3,0x4
 634:	397d                	addiw	s2,s2,-1
 636:	fe0916e3          	bnez	s2,622 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 63a:	8bea                	mv	s7,s10
      state = 0;
 63c:	4981                	li	s3,0
 63e:	6d02                	ld	s10,0(sp)
 640:	bd21                	j	458 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 642:	008b8993          	addi	s3,s7,8
 646:	000bb903          	ld	s2,0(s7)
 64a:	00090f63          	beqz	s2,668 <vprintf+0x25a>
        for(; *s; s++)
 64e:	00094583          	lbu	a1,0(s2)
 652:	c195                	beqz	a1,676 <vprintf+0x268>
          putc(fd, *s);
 654:	855a                	mv	a0,s6
 656:	cf3ff0ef          	jal	348 <putc>
        for(; *s; s++)
 65a:	0905                	addi	s2,s2,1
 65c:	00094583          	lbu	a1,0(s2)
 660:	f9f5                	bnez	a1,654 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 662:	8bce                	mv	s7,s3
      state = 0;
 664:	4981                	li	s3,0
 666:	bbcd                	j	458 <vprintf+0x4a>
          s = "(null)";
 668:	00000917          	auipc	s2,0x0
 66c:	20890913          	addi	s2,s2,520 # 870 <malloc+0xfc>
        for(; *s; s++)
 670:	02800593          	li	a1,40
 674:	b7c5                	j	654 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 676:	8bce                	mv	s7,s3
      state = 0;
 678:	4981                	li	s3,0
 67a:	bbf9                	j	458 <vprintf+0x4a>
 67c:	64a6                	ld	s1,72(sp)
 67e:	79e2                	ld	s3,56(sp)
 680:	7a42                	ld	s4,48(sp)
 682:	7aa2                	ld	s5,40(sp)
 684:	7b02                	ld	s6,32(sp)
 686:	6be2                	ld	s7,24(sp)
 688:	6c42                	ld	s8,16(sp)
 68a:	6ca2                	ld	s9,8(sp)
    }
  }
}
 68c:	60e6                	ld	ra,88(sp)
 68e:	6446                	ld	s0,80(sp)
 690:	6906                	ld	s2,64(sp)
 692:	6125                	addi	sp,sp,96
 694:	8082                	ret

0000000000000696 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 696:	715d                	addi	sp,sp,-80
 698:	ec06                	sd	ra,24(sp)
 69a:	e822                	sd	s0,16(sp)
 69c:	1000                	addi	s0,sp,32
 69e:	e010                	sd	a2,0(s0)
 6a0:	e414                	sd	a3,8(s0)
 6a2:	e818                	sd	a4,16(s0)
 6a4:	ec1c                	sd	a5,24(s0)
 6a6:	03043023          	sd	a6,32(s0)
 6aa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ae:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b2:	8622                	mv	a2,s0
 6b4:	d5bff0ef          	jal	40e <vprintf>
}
 6b8:	60e2                	ld	ra,24(sp)
 6ba:	6442                	ld	s0,16(sp)
 6bc:	6161                	addi	sp,sp,80
 6be:	8082                	ret

00000000000006c0 <printf>:

void
printf(const char *fmt, ...)
{
 6c0:	711d                	addi	sp,sp,-96
 6c2:	ec06                	sd	ra,24(sp)
 6c4:	e822                	sd	s0,16(sp)
 6c6:	1000                	addi	s0,sp,32
 6c8:	e40c                	sd	a1,8(s0)
 6ca:	e810                	sd	a2,16(s0)
 6cc:	ec14                	sd	a3,24(s0)
 6ce:	f018                	sd	a4,32(s0)
 6d0:	f41c                	sd	a5,40(s0)
 6d2:	03043823          	sd	a6,48(s0)
 6d6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6da:	00840613          	addi	a2,s0,8
 6de:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6e2:	85aa                	mv	a1,a0
 6e4:	4505                	li	a0,1
 6e6:	d29ff0ef          	jal	40e <vprintf>
}
 6ea:	60e2                	ld	ra,24(sp)
 6ec:	6442                	ld	s0,16(sp)
 6ee:	6125                	addi	sp,sp,96
 6f0:	8082                	ret

00000000000006f2 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6f2:	1141                	addi	sp,sp,-16
 6f4:	e422                	sd	s0,8(sp)
 6f6:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6f8:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6fc:	00001797          	auipc	a5,0x1
 700:	9047b783          	ld	a5,-1788(a5) # 1000 <freep>
 704:	a02d                	j	72e <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 706:	4618                	lw	a4,8(a2)
 708:	9f2d                	addw	a4,a4,a1
 70a:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 70e:	6398                	ld	a4,0(a5)
 710:	6310                	ld	a2,0(a4)
 712:	a83d                	j	750 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 714:	ff852703          	lw	a4,-8(a0)
 718:	9f31                	addw	a4,a4,a2
 71a:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 71c:	ff053683          	ld	a3,-16(a0)
 720:	a091                	j	764 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 722:	6398                	ld	a4,0(a5)
 724:	00e7e463          	bltu	a5,a4,72c <free+0x3a>
 728:	00e6ea63          	bltu	a3,a4,73c <free+0x4a>
{
 72c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 72e:	fed7fae3          	bgeu	a5,a3,722 <free+0x30>
 732:	6398                	ld	a4,0(a5)
 734:	00e6e463          	bltu	a3,a4,73c <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 738:	fee7eae3          	bltu	a5,a4,72c <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 73c:	ff852583          	lw	a1,-8(a0)
 740:	6390                	ld	a2,0(a5)
 742:	02059813          	slli	a6,a1,0x20
 746:	01c85713          	srli	a4,a6,0x1c
 74a:	9736                	add	a4,a4,a3
 74c:	fae60de3          	beq	a2,a4,706 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 750:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 754:	4790                	lw	a2,8(a5)
 756:	02061593          	slli	a1,a2,0x20
 75a:	01c5d713          	srli	a4,a1,0x1c
 75e:	973e                	add	a4,a4,a5
 760:	fae68ae3          	beq	a3,a4,714 <free+0x22>
    p->s.ptr = bp->s.ptr;
 764:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 766:	00001717          	auipc	a4,0x1
 76a:	88f73d23          	sd	a5,-1894(a4) # 1000 <freep>
}
 76e:	6422                	ld	s0,8(sp)
 770:	0141                	addi	sp,sp,16
 772:	8082                	ret

0000000000000774 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 774:	7139                	addi	sp,sp,-64
 776:	fc06                	sd	ra,56(sp)
 778:	f822                	sd	s0,48(sp)
 77a:	f426                	sd	s1,40(sp)
 77c:	ec4e                	sd	s3,24(sp)
 77e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 780:	02051493          	slli	s1,a0,0x20
 784:	9081                	srli	s1,s1,0x20
 786:	04bd                	addi	s1,s1,15
 788:	8091                	srli	s1,s1,0x4
 78a:	0014899b          	addiw	s3,s1,1
 78e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 790:	00001517          	auipc	a0,0x1
 794:	87053503          	ld	a0,-1936(a0) # 1000 <freep>
 798:	c915                	beqz	a0,7cc <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 79c:	4798                	lw	a4,8(a5)
 79e:	08977a63          	bgeu	a4,s1,832 <malloc+0xbe>
 7a2:	f04a                	sd	s2,32(sp)
 7a4:	e852                	sd	s4,16(sp)
 7a6:	e456                	sd	s5,8(sp)
 7a8:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 7aa:	8a4e                	mv	s4,s3
 7ac:	0009871b          	sext.w	a4,s3
 7b0:	6685                	lui	a3,0x1
 7b2:	00d77363          	bgeu	a4,a3,7b8 <malloc+0x44>
 7b6:	6a05                	lui	s4,0x1
 7b8:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7bc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c0:	00001917          	auipc	s2,0x1
 7c4:	84090913          	addi	s2,s2,-1984 # 1000 <freep>
  if(p == (char*)-1)
 7c8:	5afd                	li	s5,-1
 7ca:	a081                	j	80a <malloc+0x96>
 7cc:	f04a                	sd	s2,32(sp)
 7ce:	e852                	sd	s4,16(sp)
 7d0:	e456                	sd	s5,8(sp)
 7d2:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7d4:	00001797          	auipc	a5,0x1
 7d8:	83c78793          	addi	a5,a5,-1988 # 1010 <base>
 7dc:	00001717          	auipc	a4,0x1
 7e0:	82f73223          	sd	a5,-2012(a4) # 1000 <freep>
 7e4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7e6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ea:	b7c1                	j	7aa <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 7ec:	6398                	ld	a4,0(a5)
 7ee:	e118                	sd	a4,0(a0)
 7f0:	a8a9                	j	84a <malloc+0xd6>
  hp->s.size = nu;
 7f2:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7f6:	0541                	addi	a0,a0,16
 7f8:	efbff0ef          	jal	6f2 <free>
  return freep;
 7fc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 800:	c12d                	beqz	a0,862 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 802:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 804:	4798                	lw	a4,8(a5)
 806:	02977263          	bgeu	a4,s1,82a <malloc+0xb6>
    if(p == freep)
 80a:	00093703          	ld	a4,0(s2)
 80e:	853e                	mv	a0,a5
 810:	fef719e3          	bne	a4,a5,802 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 814:	8552                	mv	a0,s4
 816:	b13ff0ef          	jal	328 <sbrk>
  if(p == (char*)-1)
 81a:	fd551ce3          	bne	a0,s5,7f2 <malloc+0x7e>
        return 0;
 81e:	4501                	li	a0,0
 820:	7902                	ld	s2,32(sp)
 822:	6a42                	ld	s4,16(sp)
 824:	6aa2                	ld	s5,8(sp)
 826:	6b02                	ld	s6,0(sp)
 828:	a03d                	j	856 <malloc+0xe2>
 82a:	7902                	ld	s2,32(sp)
 82c:	6a42                	ld	s4,16(sp)
 82e:	6aa2                	ld	s5,8(sp)
 830:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 832:	fae48de3          	beq	s1,a4,7ec <malloc+0x78>
        p->s.size -= nunits;
 836:	4137073b          	subw	a4,a4,s3
 83a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 83c:	02071693          	slli	a3,a4,0x20
 840:	01c6d713          	srli	a4,a3,0x1c
 844:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 846:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 84a:	00000717          	auipc	a4,0x0
 84e:	7aa73b23          	sd	a0,1974(a4) # 1000 <freep>
      return (void*)(p + 1);
 852:	01078513          	addi	a0,a5,16
  }
}
 856:	70e2                	ld	ra,56(sp)
 858:	7442                	ld	s0,48(sp)
 85a:	74a2                	ld	s1,40(sp)
 85c:	69e2                	ld	s3,24(sp)
 85e:	6121                	addi	sp,sp,64
 860:	8082                	ret
 862:	7902                	ld	s2,32(sp)
 864:	6a42                	ld	s4,16(sp)
 866:	6aa2                	ld	s5,8(sp)
 868:	6b02                	ld	s6,0(sp)
 86a:	b7f5                	j	856 <malloc+0xe2>
