
user/_testps:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <basic_test>:
#define DEPTH 5
#define ITERATIONS 100
#define N_FORKS 10

// Basic functionality tests
void basic_test() {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    printf("\n### TEST 1: Basic Process Tree ###\n");
   8:	00001517          	auipc	a0,0x1
   c:	a5850513          	addi	a0,a0,-1448 # a60 <malloc+0x100>
  10:	09d000ef          	jal	8ac <printf>
    printf("Expected: At least init, sh, and test_pstree\n");
  14:	00001517          	auipc	a0,0x1
  18:	a7c50513          	addi	a0,a0,-1412 # a90 <malloc+0x130>
  1c:	091000ef          	jal	8ac <printf>
    pstree();
  20:	50c000ef          	jal	52c <pstree>
}
  24:	60a2                	ld	ra,8(sp)
  26:	6402                	ld	s0,0(sp)
  28:	0141                	addi	sp,sp,16
  2a:	8082                	ret

000000000000002c <fork_test>:

// Fork hierarchy test
void fork_test() {
  2c:	1101                	addi	sp,sp,-32
  2e:	ec06                	sd	ra,24(sp)
  30:	e822                	sd	s0,16(sp)
  32:	e426                	sd	s1,8(sp)
  34:	e04a                	sd	s2,0(sp)
  36:	1000                	addi	s0,sp,32
    printf("\n### TEST 2: Fork Hierarchy ###\n");
  38:	00001517          	auipc	a0,0x1
  3c:	a8850513          	addi	a0,a0,-1400 # ac0 <malloc+0x160>
  40:	06d000ef          	jal	8ac <printf>
    printf("Creating %d-level process tree...\n", DEPTH);
  44:	4595                	li	a1,5
  46:	00001517          	auipc	a0,0x1
  4a:	aa250513          	addi	a0,a0,-1374 # ae8 <malloc+0x188>
  4e:	05f000ef          	jal	8ac <printf>
  52:	4495                	li	s1,5
    
    for (int i = 0; i < DEPTH; i++) {
        if (fork() == 0) {
            printf("Child %d created\n", getpid());
  54:	00001917          	auipc	s2,0x1
  58:	abc90913          	addi	s2,s2,-1348 # b10 <malloc+0x1b0>
        if (fork() == 0) {
  5c:	428000ef          	jal	484 <fork>
  60:	e10d                	bnez	a0,82 <fork_test+0x56>
            printf("Child %d created\n", getpid());
  62:	4aa000ef          	jal	50c <getpid>
  66:	85aa                	mv	a1,a0
  68:	854a                	mv	a0,s2
  6a:	043000ef          	jal	8ac <printf>
    for (int i = 0; i < DEPTH; i++) {
  6e:	34fd                	addiw	s1,s1,-1
  70:	f4f5                	bnez	s1,5c <fork_test+0x30>
        } else {
            wait(0);
            break;
        }
    }
    pstree();
  72:	4ba000ef          	jal	52c <pstree>
}
  76:	60e2                	ld	ra,24(sp)
  78:	6442                	ld	s0,16(sp)
  7a:	64a2                	ld	s1,8(sp)
  7c:	6902                	ld	s2,0(sp)
  7e:	6105                	addi	sp,sp,32
  80:	8082                	ret
            wait(0);
  82:	4501                	li	a0,0
  84:	410000ef          	jal	494 <wait>
            break;
  88:	b7ed                	j	72 <fork_test+0x46>

000000000000008a <zombie_test>:

// Zombie process test
void zombie_test() {
  8a:	1141                	addi	sp,sp,-16
  8c:	e406                	sd	ra,8(sp)
  8e:	e022                	sd	s0,0(sp)
  90:	0800                	addi	s0,sp,16
    printf("\n### TEST 3: Zombie Processes ###\n");
  92:	00001517          	auipc	a0,0x1
  96:	a9650513          	addi	a0,a0,-1386 # b28 <malloc+0x1c8>
  9a:	013000ef          	jal	8ac <printf>
    int pid = fork();
  9e:	3e6000ef          	jal	484 <fork>
    if (pid == 0) {
  a2:	c515                	beqz	a0,ce <zombie_test+0x44>
        printf("Child %d exiting (will become zombie)\n", getpid());
        exit(0);
    } else {
        sleep(5); // Allow child to become zombie
  a4:	4515                	li	a0,5
  a6:	476000ef          	jal	51c <sleep>
        printf("Parent %d not waiting (zombie child should appear)\n", getpid());
  aa:	462000ef          	jal	50c <getpid>
  ae:	85aa                	mv	a1,a0
  b0:	00001517          	auipc	a0,0x1
  b4:	ac850513          	addi	a0,a0,-1336 # b78 <malloc+0x218>
  b8:	7f4000ef          	jal	8ac <printf>
        pstree();
  bc:	470000ef          	jal	52c <pstree>
        wait(0); // Clean up zombie
  c0:	4501                	li	a0,0
  c2:	3d2000ef          	jal	494 <wait>
    }
}
  c6:	60a2                	ld	ra,8(sp)
  c8:	6402                	ld	s0,0(sp)
  ca:	0141                	addi	sp,sp,16
  cc:	8082                	ret
        printf("Child %d exiting (will become zombie)\n", getpid());
  ce:	43e000ef          	jal	50c <getpid>
  d2:	85aa                	mv	a1,a0
  d4:	00001517          	auipc	a0,0x1
  d8:	a7c50513          	addi	a0,a0,-1412 # b50 <malloc+0x1f0>
  dc:	7d0000ef          	jal	8ac <printf>
        exit(0);
  e0:	4501                	li	a0,0
  e2:	3aa000ef          	jal	48c <exit>

00000000000000e6 <stress_test>:

// Stress test
void stress_test() {
  e6:	711d                	addi	sp,sp,-96
  e8:	ec86                	sd	ra,88(sp)
  ea:	e8a2                	sd	s0,80(sp)
  ec:	e4a6                	sd	s1,72(sp)
  ee:	e0ca                	sd	s2,64(sp)
  f0:	fc4e                	sd	s3,56(sp)
  f2:	1080                	addi	s0,sp,96
    printf("\n### TEST 4: Stress Test (%d processes) ###\n", N_FORKS);
  f4:	45a9                	li	a1,10
  f6:	00001517          	auipc	a0,0x1
  fa:	aba50513          	addi	a0,a0,-1350 # bb0 <malloc+0x250>
  fe:	7ae000ef          	jal	8ac <printf>
    int pids[N_FORKS];
    
    for (int i = 0; i < N_FORKS; i++) {
 102:	fa840493          	addi	s1,s0,-88
 106:	fd040993          	addi	s3,s0,-48
    printf("\n### TEST 4: Stress Test (%d processes) ###\n", N_FORKS);
 10a:	8926                	mv	s2,s1
        pids[i] = fork();
 10c:	378000ef          	jal	484 <fork>
 110:	00a92023          	sw	a0,0(s2)
        if (pids[i] == 0) {
 114:	c90d                	beqz	a0,146 <stress_test+0x60>
    for (int i = 0; i < N_FORKS; i++) {
 116:	0911                	addi	s2,s2,4
 118:	ff391ae3          	bne	s2,s3,10c <stress_test+0x26>
            sleep(100); // Child stays alive
            exit(0);
        }
    }
    
    pstree();
 11c:	410000ef          	jal	52c <pstree>
    
    // Cleanup
    for (int i = 0; i < N_FORKS; i++) {
        kill(pids[i]);
 120:	4088                	lw	a0,0(s1)
 122:	39a000ef          	jal	4bc <kill>
    for (int i = 0; i < N_FORKS; i++) {
 126:	0491                	addi	s1,s1,4
 128:	ff349ce3          	bne	s1,s3,120 <stress_test+0x3a>
    }
    while (wait(0) != -1);
 12c:	54fd                	li	s1,-1
 12e:	4501                	li	a0,0
 130:	364000ef          	jal	494 <wait>
 134:	fe951de3          	bne	a0,s1,12e <stress_test+0x48>
}
 138:	60e6                	ld	ra,88(sp)
 13a:	6446                	ld	s0,80(sp)
 13c:	64a6                	ld	s1,72(sp)
 13e:	6906                	ld	s2,64(sp)
 140:	79e2                	ld	s3,56(sp)
 142:	6125                	addi	sp,sp,96
 144:	8082                	ret
            sleep(100); // Child stays alive
 146:	06400513          	li	a0,100
 14a:	3d2000ef          	jal	51c <sleep>
            exit(0);
 14e:	4501                	li	a0,0
 150:	33c000ef          	jal	48c <exit>

0000000000000154 <benchmark>:

// Performance benchmark
void benchmark() {
 154:	1101                	addi	sp,sp,-32
 156:	ec06                	sd	ra,24(sp)
 158:	e822                	sd	s0,16(sp)
 15a:	e426                	sd	s1,8(sp)
 15c:	e04a                	sd	s2,0(sp)
 15e:	1000                	addi	s0,sp,32
    printf("\n### TEST 5: Performance Benchmark ###\n");
 160:	00001517          	auipc	a0,0x1
 164:	a8050513          	addi	a0,a0,-1408 # be0 <malloc+0x280>
 168:	744000ef          	jal	8ac <printf>
    printf("Running pstree %d times...\n", ITERATIONS);
 16c:	06400593          	li	a1,100
 170:	00001517          	auipc	a0,0x1
 174:	a9850513          	addi	a0,a0,-1384 # c08 <malloc+0x2a8>
 178:	734000ef          	jal	8ac <printf>
    
    uint start = uptime();
 17c:	3a8000ef          	jal	524 <uptime>
 180:	0005091b          	sext.w	s2,a0
 184:	06400493          	li	s1,100
    for (int i = 0; i < ITERATIONS; i++) {
        pstree();
 188:	3a4000ef          	jal	52c <pstree>
    for (int i = 0; i < ITERATIONS; i++) {
 18c:	34fd                	addiw	s1,s1,-1
 18e:	fced                	bnez	s1,188 <benchmark+0x34>
    }
    uint end = uptime();
 190:	394000ef          	jal	524 <uptime>
    uint total_ticks = end - start;
 194:	412504bb          	subw	s1,a0,s2
 198:	0004891b          	sext.w	s2,s1
    uint num = total_ticks / ITERATIONS;
    uint frac = (total_ticks % ITERATIONS) * 1000 / ITERATIONS;
    printf("Results:\n");
 19c:	00001517          	auipc	a0,0x1
 1a0:	a8c50513          	addi	a0,a0,-1396 # c28 <malloc+0x2c8>
 1a4:	708000ef          	jal	8ac <printf>
    printf("- Total ticks: %d\n", end-start);
 1a8:	85ca                	mv	a1,s2
 1aa:	00001517          	auipc	a0,0x1
 1ae:	a8e50513          	addi	a0,a0,-1394 # c38 <malloc+0x2d8>
 1b2:	6fa000ef          	jal	8ac <printf>
    uint frac = (total_ticks % ITERATIONS) * 1000 / ITERATIONS;
 1b6:	06400593          	li	a1,100
 1ba:	02b4f63b          	remuw	a2,s1,a1
 1be:	3e800793          	li	a5,1000
 1c2:	02f6063b          	mulw	a2,a2,a5
 1c6:	02b6563b          	divuw	a2,a2,a1
    printf("- Average ticks per call: %d.%d ms\n", num, frac);
 1ca:	2601                	sext.w	a2,a2
 1cc:	02b4d5bb          	divuw	a1,s1,a1
 1d0:	00001517          	auipc	a0,0x1
 1d4:	a8050513          	addi	a0,a0,-1408 # c50 <malloc+0x2f0>
 1d8:	6d4000ef          	jal	8ac <printf>
}
 1dc:	60e2                	ld	ra,24(sp)
 1de:	6442                	ld	s0,16(sp)
 1e0:	64a2                	ld	s1,8(sp)
 1e2:	6902                	ld	s2,0(sp)
 1e4:	6105                	addi	sp,sp,32
 1e6:	8082                	ret

00000000000001e8 <main>:

// Main test runner
int main() {
 1e8:	1141                	addi	sp,sp,-16
 1ea:	e406                	sd	ra,8(sp)
 1ec:	e022                	sd	s0,0(sp)
 1ee:	0800                	addi	s0,sp,16
    printf("Starting pstree syscall evaluation\n");
 1f0:	00001517          	auipc	a0,0x1
 1f4:	a8850513          	addi	a0,a0,-1400 # c78 <malloc+0x318>
 1f8:	6b4000ef          	jal	8ac <printf>
    
    basic_test();
 1fc:	e05ff0ef          	jal	0 <basic_test>
    fork_test();
 200:	e2dff0ef          	jal	2c <fork_test>
    zombie_test();
 204:	e87ff0ef          	jal	8a <zombie_test>
    stress_test();
 208:	edfff0ef          	jal	e6 <stress_test>
    benchmark(); 
 20c:	f49ff0ef          	jal	154 <benchmark>
    
    printf("\nAll tests completed!\n");
 210:	00001517          	auipc	a0,0x1
 214:	a9050513          	addi	a0,a0,-1392 # ca0 <malloc+0x340>
 218:	694000ef          	jal	8ac <printf>
    exit(0);
 21c:	4501                	li	a0,0
 21e:	26e000ef          	jal	48c <exit>

0000000000000222 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
 222:	1141                	addi	sp,sp,-16
 224:	e406                	sd	ra,8(sp)
 226:	e022                	sd	s0,0(sp)
 228:	0800                	addi	s0,sp,16
  extern int main();
  main();
 22a:	fbfff0ef          	jal	1e8 <main>
  exit(0);
 22e:	4501                	li	a0,0
 230:	25c000ef          	jal	48c <exit>

0000000000000234 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 234:	1141                	addi	sp,sp,-16
 236:	e422                	sd	s0,8(sp)
 238:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 23a:	87aa                	mv	a5,a0
 23c:	0585                	addi	a1,a1,1
 23e:	0785                	addi	a5,a5,1
 240:	fff5c703          	lbu	a4,-1(a1)
 244:	fee78fa3          	sb	a4,-1(a5)
 248:	fb75                	bnez	a4,23c <strcpy+0x8>
    ;
  return os;
}
 24a:	6422                	ld	s0,8(sp)
 24c:	0141                	addi	sp,sp,16
 24e:	8082                	ret

0000000000000250 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 250:	1141                	addi	sp,sp,-16
 252:	e422                	sd	s0,8(sp)
 254:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 256:	00054783          	lbu	a5,0(a0)
 25a:	cb91                	beqz	a5,26e <strcmp+0x1e>
 25c:	0005c703          	lbu	a4,0(a1)
 260:	00f71763          	bne	a4,a5,26e <strcmp+0x1e>
    p++, q++;
 264:	0505                	addi	a0,a0,1
 266:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 268:	00054783          	lbu	a5,0(a0)
 26c:	fbe5                	bnez	a5,25c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 26e:	0005c503          	lbu	a0,0(a1)
}
 272:	40a7853b          	subw	a0,a5,a0
 276:	6422                	ld	s0,8(sp)
 278:	0141                	addi	sp,sp,16
 27a:	8082                	ret

000000000000027c <strlen>:

uint
strlen(const char *s)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 282:	00054783          	lbu	a5,0(a0)
 286:	cf91                	beqz	a5,2a2 <strlen+0x26>
 288:	0505                	addi	a0,a0,1
 28a:	87aa                	mv	a5,a0
 28c:	86be                	mv	a3,a5
 28e:	0785                	addi	a5,a5,1
 290:	fff7c703          	lbu	a4,-1(a5)
 294:	ff65                	bnez	a4,28c <strlen+0x10>
 296:	40a6853b          	subw	a0,a3,a0
 29a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 29c:	6422                	ld	s0,8(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret
  for(n = 0; s[n]; n++)
 2a2:	4501                	li	a0,0
 2a4:	bfe5                	j	29c <strlen+0x20>

00000000000002a6 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e422                	sd	s0,8(sp)
 2aa:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2ac:	ca19                	beqz	a2,2c2 <memset+0x1c>
 2ae:	87aa                	mv	a5,a0
 2b0:	1602                	slli	a2,a2,0x20
 2b2:	9201                	srli	a2,a2,0x20
 2b4:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2b8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2bc:	0785                	addi	a5,a5,1
 2be:	fee79de3          	bne	a5,a4,2b8 <memset+0x12>
  }
  return dst;
}
 2c2:	6422                	ld	s0,8(sp)
 2c4:	0141                	addi	sp,sp,16
 2c6:	8082                	ret

00000000000002c8 <strchr>:

char*
strchr(const char *s, char c)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2ce:	00054783          	lbu	a5,0(a0)
 2d2:	cb99                	beqz	a5,2e8 <strchr+0x20>
    if(*s == c)
 2d4:	00f58763          	beq	a1,a5,2e2 <strchr+0x1a>
  for(; *s; s++)
 2d8:	0505                	addi	a0,a0,1
 2da:	00054783          	lbu	a5,0(a0)
 2de:	fbfd                	bnez	a5,2d4 <strchr+0xc>
      return (char*)s;
  return 0;
 2e0:	4501                	li	a0,0
}
 2e2:	6422                	ld	s0,8(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret
  return 0;
 2e8:	4501                	li	a0,0
 2ea:	bfe5                	j	2e2 <strchr+0x1a>

00000000000002ec <gets>:

char*
gets(char *buf, int max)
{
 2ec:	711d                	addi	sp,sp,-96
 2ee:	ec86                	sd	ra,88(sp)
 2f0:	e8a2                	sd	s0,80(sp)
 2f2:	e4a6                	sd	s1,72(sp)
 2f4:	e0ca                	sd	s2,64(sp)
 2f6:	fc4e                	sd	s3,56(sp)
 2f8:	f852                	sd	s4,48(sp)
 2fa:	f456                	sd	s5,40(sp)
 2fc:	f05a                	sd	s6,32(sp)
 2fe:	ec5e                	sd	s7,24(sp)
 300:	1080                	addi	s0,sp,96
 302:	8baa                	mv	s7,a0
 304:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 306:	892a                	mv	s2,a0
 308:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 30a:	4aa9                	li	s5,10
 30c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 30e:	89a6                	mv	s3,s1
 310:	2485                	addiw	s1,s1,1
 312:	0344d663          	bge	s1,s4,33e <gets+0x52>
    cc = read(0, &c, 1);
 316:	4605                	li	a2,1
 318:	faf40593          	addi	a1,s0,-81
 31c:	4501                	li	a0,0
 31e:	186000ef          	jal	4a4 <read>
    if(cc < 1)
 322:	00a05e63          	blez	a0,33e <gets+0x52>
    buf[i++] = c;
 326:	faf44783          	lbu	a5,-81(s0)
 32a:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 32e:	01578763          	beq	a5,s5,33c <gets+0x50>
 332:	0905                	addi	s2,s2,1
 334:	fd679de3          	bne	a5,s6,30e <gets+0x22>
    buf[i++] = c;
 338:	89a6                	mv	s3,s1
 33a:	a011                	j	33e <gets+0x52>
 33c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 33e:	99de                	add	s3,s3,s7
 340:	00098023          	sb	zero,0(s3)
  return buf;
}
 344:	855e                	mv	a0,s7
 346:	60e6                	ld	ra,88(sp)
 348:	6446                	ld	s0,80(sp)
 34a:	64a6                	ld	s1,72(sp)
 34c:	6906                	ld	s2,64(sp)
 34e:	79e2                	ld	s3,56(sp)
 350:	7a42                	ld	s4,48(sp)
 352:	7aa2                	ld	s5,40(sp)
 354:	7b02                	ld	s6,32(sp)
 356:	6be2                	ld	s7,24(sp)
 358:	6125                	addi	sp,sp,96
 35a:	8082                	ret

000000000000035c <stat>:

int
stat(const char *n, struct stat *st)
{
 35c:	1101                	addi	sp,sp,-32
 35e:	ec06                	sd	ra,24(sp)
 360:	e822                	sd	s0,16(sp)
 362:	e04a                	sd	s2,0(sp)
 364:	1000                	addi	s0,sp,32
 366:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 368:	4581                	li	a1,0
 36a:	162000ef          	jal	4cc <open>
  if(fd < 0)
 36e:	02054263          	bltz	a0,392 <stat+0x36>
 372:	e426                	sd	s1,8(sp)
 374:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 376:	85ca                	mv	a1,s2
 378:	16c000ef          	jal	4e4 <fstat>
 37c:	892a                	mv	s2,a0
  close(fd);
 37e:	8526                	mv	a0,s1
 380:	134000ef          	jal	4b4 <close>
  return r;
 384:	64a2                	ld	s1,8(sp)
}
 386:	854a                	mv	a0,s2
 388:	60e2                	ld	ra,24(sp)
 38a:	6442                	ld	s0,16(sp)
 38c:	6902                	ld	s2,0(sp)
 38e:	6105                	addi	sp,sp,32
 390:	8082                	ret
    return -1;
 392:	597d                	li	s2,-1
 394:	bfcd                	j	386 <stat+0x2a>

0000000000000396 <atoi>:

int
atoi(const char *s)
{
 396:	1141                	addi	sp,sp,-16
 398:	e422                	sd	s0,8(sp)
 39a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 39c:	00054683          	lbu	a3,0(a0)
 3a0:	fd06879b          	addiw	a5,a3,-48
 3a4:	0ff7f793          	zext.b	a5,a5
 3a8:	4625                	li	a2,9
 3aa:	02f66863          	bltu	a2,a5,3da <atoi+0x44>
 3ae:	872a                	mv	a4,a0
  n = 0;
 3b0:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3b2:	0705                	addi	a4,a4,1
 3b4:	0025179b          	slliw	a5,a0,0x2
 3b8:	9fa9                	addw	a5,a5,a0
 3ba:	0017979b          	slliw	a5,a5,0x1
 3be:	9fb5                	addw	a5,a5,a3
 3c0:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3c4:	00074683          	lbu	a3,0(a4)
 3c8:	fd06879b          	addiw	a5,a3,-48
 3cc:	0ff7f793          	zext.b	a5,a5
 3d0:	fef671e3          	bgeu	a2,a5,3b2 <atoi+0x1c>
  return n;
}
 3d4:	6422                	ld	s0,8(sp)
 3d6:	0141                	addi	sp,sp,16
 3d8:	8082                	ret
  n = 0;
 3da:	4501                	li	a0,0
 3dc:	bfe5                	j	3d4 <atoi+0x3e>

00000000000003de <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3e4:	02b57463          	bgeu	a0,a1,40c <memmove+0x2e>
    while(n-- > 0)
 3e8:	00c05f63          	blez	a2,406 <memmove+0x28>
 3ec:	1602                	slli	a2,a2,0x20
 3ee:	9201                	srli	a2,a2,0x20
 3f0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3f4:	872a                	mv	a4,a0
      *dst++ = *src++;
 3f6:	0585                	addi	a1,a1,1
 3f8:	0705                	addi	a4,a4,1
 3fa:	fff5c683          	lbu	a3,-1(a1)
 3fe:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 402:	fef71ae3          	bne	a4,a5,3f6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 406:	6422                	ld	s0,8(sp)
 408:	0141                	addi	sp,sp,16
 40a:	8082                	ret
    dst += n;
 40c:	00c50733          	add	a4,a0,a2
    src += n;
 410:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 412:	fec05ae3          	blez	a2,406 <memmove+0x28>
 416:	fff6079b          	addiw	a5,a2,-1
 41a:	1782                	slli	a5,a5,0x20
 41c:	9381                	srli	a5,a5,0x20
 41e:	fff7c793          	not	a5,a5
 422:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 424:	15fd                	addi	a1,a1,-1
 426:	177d                	addi	a4,a4,-1
 428:	0005c683          	lbu	a3,0(a1)
 42c:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 430:	fee79ae3          	bne	a5,a4,424 <memmove+0x46>
 434:	bfc9                	j	406 <memmove+0x28>

0000000000000436 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 436:	1141                	addi	sp,sp,-16
 438:	e422                	sd	s0,8(sp)
 43a:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 43c:	ca05                	beqz	a2,46c <memcmp+0x36>
 43e:	fff6069b          	addiw	a3,a2,-1
 442:	1682                	slli	a3,a3,0x20
 444:	9281                	srli	a3,a3,0x20
 446:	0685                	addi	a3,a3,1
 448:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 44a:	00054783          	lbu	a5,0(a0)
 44e:	0005c703          	lbu	a4,0(a1)
 452:	00e79863          	bne	a5,a4,462 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 456:	0505                	addi	a0,a0,1
    p2++;
 458:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 45a:	fed518e3          	bne	a0,a3,44a <memcmp+0x14>
  }
  return 0;
 45e:	4501                	li	a0,0
 460:	a019                	j	466 <memcmp+0x30>
      return *p1 - *p2;
 462:	40e7853b          	subw	a0,a5,a4
}
 466:	6422                	ld	s0,8(sp)
 468:	0141                	addi	sp,sp,16
 46a:	8082                	ret
  return 0;
 46c:	4501                	li	a0,0
 46e:	bfe5                	j	466 <memcmp+0x30>

0000000000000470 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 470:	1141                	addi	sp,sp,-16
 472:	e406                	sd	ra,8(sp)
 474:	e022                	sd	s0,0(sp)
 476:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 478:	f67ff0ef          	jal	3de <memmove>
}
 47c:	60a2                	ld	ra,8(sp)
 47e:	6402                	ld	s0,0(sp)
 480:	0141                	addi	sp,sp,16
 482:	8082                	ret

0000000000000484 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 484:	4885                	li	a7,1
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <exit>:
.global exit
exit:
 li a7, SYS_exit
 48c:	4889                	li	a7,2
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <wait>:
.global wait
wait:
 li a7, SYS_wait
 494:	488d                	li	a7,3
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 49c:	4891                	li	a7,4
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <read>:
.global read
read:
 li a7, SYS_read
 4a4:	4895                	li	a7,5
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <write>:
.global write
write:
 li a7, SYS_write
 4ac:	48c1                	li	a7,16
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <close>:
.global close
close:
 li a7, SYS_close
 4b4:	48d5                	li	a7,21
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <kill>:
.global kill
kill:
 li a7, SYS_kill
 4bc:	4899                	li	a7,6
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c4:	489d                	li	a7,7
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <open>:
.global open
open:
 li a7, SYS_open
 4cc:	48bd                	li	a7,15
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d4:	48c5                	li	a7,17
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4dc:	48c9                	li	a7,18
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e4:	48a1                	li	a7,8
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <link>:
.global link
link:
 li a7, SYS_link
 4ec:	48cd                	li	a7,19
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f4:	48d1                	li	a7,20
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4fc:	48a5                	li	a7,9
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <dup>:
.global dup
dup:
 li a7, SYS_dup
 504:	48a9                	li	a7,10
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 50c:	48ad                	li	a7,11
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 514:	48b1                	li	a7,12
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 51c:	48b5                	li	a7,13
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 524:	48b9                	li	a7,14
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <pstree>:
.global pstree
pstree:
 li a7, SYS_pstree
 52c:	48d9                	li	a7,22
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
 546:	f67ff0ef          	jal	4ac <write>
}
 54a:	60e2                	ld	ra,24(sp)
 54c:	6442                	ld	s0,16(sp)
 54e:	6105                	addi	sp,sp,32
 550:	8082                	ret

0000000000000552 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 552:	7139                	addi	sp,sp,-64
 554:	fc06                	sd	ra,56(sp)
 556:	f822                	sd	s0,48(sp)
 558:	f426                	sd	s1,40(sp)
 55a:	0080                	addi	s0,sp,64
 55c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 55e:	c299                	beqz	a3,564 <printint+0x12>
 560:	0805c963          	bltz	a1,5f2 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 564:	2581                	sext.w	a1,a1
  neg = 0;
 566:	4881                	li	a7,0
 568:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 56c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 56e:	2601                	sext.w	a2,a2
 570:	00000517          	auipc	a0,0x0
 574:	75050513          	addi	a0,a0,1872 # cc0 <digits>
 578:	883a                	mv	a6,a4
 57a:	2705                	addiw	a4,a4,1
 57c:	02c5f7bb          	remuw	a5,a1,a2
 580:	1782                	slli	a5,a5,0x20
 582:	9381                	srli	a5,a5,0x20
 584:	97aa                	add	a5,a5,a0
 586:	0007c783          	lbu	a5,0(a5)
 58a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 58e:	0005879b          	sext.w	a5,a1
 592:	02c5d5bb          	divuw	a1,a1,a2
 596:	0685                	addi	a3,a3,1
 598:	fec7f0e3          	bgeu	a5,a2,578 <printint+0x26>
  if(neg)
 59c:	00088c63          	beqz	a7,5b4 <printint+0x62>
    buf[i++] = '-';
 5a0:	fd070793          	addi	a5,a4,-48
 5a4:	00878733          	add	a4,a5,s0
 5a8:	02d00793          	li	a5,45
 5ac:	fef70823          	sb	a5,-16(a4)
 5b0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5b4:	02e05a63          	blez	a4,5e8 <printint+0x96>
 5b8:	f04a                	sd	s2,32(sp)
 5ba:	ec4e                	sd	s3,24(sp)
 5bc:	fc040793          	addi	a5,s0,-64
 5c0:	00e78933          	add	s2,a5,a4
 5c4:	fff78993          	addi	s3,a5,-1
 5c8:	99ba                	add	s3,s3,a4
 5ca:	377d                	addiw	a4,a4,-1
 5cc:	1702                	slli	a4,a4,0x20
 5ce:	9301                	srli	a4,a4,0x20
 5d0:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5d4:	fff94583          	lbu	a1,-1(s2)
 5d8:	8526                	mv	a0,s1
 5da:	f5bff0ef          	jal	534 <putc>
  while(--i >= 0)
 5de:	197d                	addi	s2,s2,-1
 5e0:	ff391ae3          	bne	s2,s3,5d4 <printint+0x82>
 5e4:	7902                	ld	s2,32(sp)
 5e6:	69e2                	ld	s3,24(sp)
}
 5e8:	70e2                	ld	ra,56(sp)
 5ea:	7442                	ld	s0,48(sp)
 5ec:	74a2                	ld	s1,40(sp)
 5ee:	6121                	addi	sp,sp,64
 5f0:	8082                	ret
    x = -xx;
 5f2:	40b005bb          	negw	a1,a1
    neg = 1;
 5f6:	4885                	li	a7,1
    x = -xx;
 5f8:	bf85                	j	568 <printint+0x16>

00000000000005fa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5fa:	711d                	addi	sp,sp,-96
 5fc:	ec86                	sd	ra,88(sp)
 5fe:	e8a2                	sd	s0,80(sp)
 600:	e0ca                	sd	s2,64(sp)
 602:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 604:	0005c903          	lbu	s2,0(a1)
 608:	26090863          	beqz	s2,878 <vprintf+0x27e>
 60c:	e4a6                	sd	s1,72(sp)
 60e:	fc4e                	sd	s3,56(sp)
 610:	f852                	sd	s4,48(sp)
 612:	f456                	sd	s5,40(sp)
 614:	f05a                	sd	s6,32(sp)
 616:	ec5e                	sd	s7,24(sp)
 618:	e862                	sd	s8,16(sp)
 61a:	e466                	sd	s9,8(sp)
 61c:	8b2a                	mv	s6,a0
 61e:	8a2e                	mv	s4,a1
 620:	8bb2                	mv	s7,a2
  state = 0;
 622:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 624:	4481                	li	s1,0
 626:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 628:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 62c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 630:	06c00c93          	li	s9,108
 634:	a005                	j	654 <vprintf+0x5a>
        putc(fd, c0);
 636:	85ca                	mv	a1,s2
 638:	855a                	mv	a0,s6
 63a:	efbff0ef          	jal	534 <putc>
 63e:	a019                	j	644 <vprintf+0x4a>
    } else if(state == '%'){
 640:	03598263          	beq	s3,s5,664 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 644:	2485                	addiw	s1,s1,1
 646:	8726                	mv	a4,s1
 648:	009a07b3          	add	a5,s4,s1
 64c:	0007c903          	lbu	s2,0(a5)
 650:	20090c63          	beqz	s2,868 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 654:	0009079b          	sext.w	a5,s2
    if(state == 0){
 658:	fe0994e3          	bnez	s3,640 <vprintf+0x46>
      if(c0 == '%'){
 65c:	fd579de3          	bne	a5,s5,636 <vprintf+0x3c>
        state = '%';
 660:	89be                	mv	s3,a5
 662:	b7cd                	j	644 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 664:	00ea06b3          	add	a3,s4,a4
 668:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 66c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 66e:	c681                	beqz	a3,676 <vprintf+0x7c>
 670:	9752                	add	a4,a4,s4
 672:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 676:	03878f63          	beq	a5,s8,6b4 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 67a:	05978963          	beq	a5,s9,6cc <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 67e:	07500713          	li	a4,117
 682:	0ee78363          	beq	a5,a4,768 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 686:	07800713          	li	a4,120
 68a:	12e78563          	beq	a5,a4,7b4 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 68e:	07000713          	li	a4,112
 692:	14e78a63          	beq	a5,a4,7e6 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 696:	07300713          	li	a4,115
 69a:	18e78a63          	beq	a5,a4,82e <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 69e:	02500713          	li	a4,37
 6a2:	04e79563          	bne	a5,a4,6ec <vprintf+0xf2>
        putc(fd, '%');
 6a6:	02500593          	li	a1,37
 6aa:	855a                	mv	a0,s6
 6ac:	e89ff0ef          	jal	534 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 6b0:	4981                	li	s3,0
 6b2:	bf49                	j	644 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6b4:	008b8913          	addi	s2,s7,8
 6b8:	4685                	li	a3,1
 6ba:	4629                	li	a2,10
 6bc:	000ba583          	lw	a1,0(s7)
 6c0:	855a                	mv	a0,s6
 6c2:	e91ff0ef          	jal	552 <printint>
 6c6:	8bca                	mv	s7,s2
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	bfad                	j	644 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 6cc:	06400793          	li	a5,100
 6d0:	02f68963          	beq	a3,a5,702 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 6d4:	06c00793          	li	a5,108
 6d8:	04f68263          	beq	a3,a5,71c <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 6dc:	07500793          	li	a5,117
 6e0:	0af68063          	beq	a3,a5,780 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 6e4:	07800793          	li	a5,120
 6e8:	0ef68263          	beq	a3,a5,7cc <vprintf+0x1d2>
        putc(fd, '%');
 6ec:	02500593          	li	a1,37
 6f0:	855a                	mv	a0,s6
 6f2:	e43ff0ef          	jal	534 <putc>
        putc(fd, c0);
 6f6:	85ca                	mv	a1,s2
 6f8:	855a                	mv	a0,s6
 6fa:	e3bff0ef          	jal	534 <putc>
      state = 0;
 6fe:	4981                	li	s3,0
 700:	b791                	j	644 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 702:	008b8913          	addi	s2,s7,8
 706:	4685                	li	a3,1
 708:	4629                	li	a2,10
 70a:	000ba583          	lw	a1,0(s7)
 70e:	855a                	mv	a0,s6
 710:	e43ff0ef          	jal	552 <printint>
        i += 1;
 714:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 716:	8bca                	mv	s7,s2
      state = 0;
 718:	4981                	li	s3,0
        i += 1;
 71a:	b72d                	j	644 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 71c:	06400793          	li	a5,100
 720:	02f60763          	beq	a2,a5,74e <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 724:	07500793          	li	a5,117
 728:	06f60963          	beq	a2,a5,79a <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 72c:	07800793          	li	a5,120
 730:	faf61ee3          	bne	a2,a5,6ec <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 734:	008b8913          	addi	s2,s7,8
 738:	4681                	li	a3,0
 73a:	4641                	li	a2,16
 73c:	000ba583          	lw	a1,0(s7)
 740:	855a                	mv	a0,s6
 742:	e11ff0ef          	jal	552 <printint>
        i += 2;
 746:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 748:	8bca                	mv	s7,s2
      state = 0;
 74a:	4981                	li	s3,0
        i += 2;
 74c:	bde5                	j	644 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 74e:	008b8913          	addi	s2,s7,8
 752:	4685                	li	a3,1
 754:	4629                	li	a2,10
 756:	000ba583          	lw	a1,0(s7)
 75a:	855a                	mv	a0,s6
 75c:	df7ff0ef          	jal	552 <printint>
        i += 2;
 760:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 762:	8bca                	mv	s7,s2
      state = 0;
 764:	4981                	li	s3,0
        i += 2;
 766:	bdf9                	j	644 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 768:	008b8913          	addi	s2,s7,8
 76c:	4681                	li	a3,0
 76e:	4629                	li	a2,10
 770:	000ba583          	lw	a1,0(s7)
 774:	855a                	mv	a0,s6
 776:	dddff0ef          	jal	552 <printint>
 77a:	8bca                	mv	s7,s2
      state = 0;
 77c:	4981                	li	s3,0
 77e:	b5d9                	j	644 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 780:	008b8913          	addi	s2,s7,8
 784:	4681                	li	a3,0
 786:	4629                	li	a2,10
 788:	000ba583          	lw	a1,0(s7)
 78c:	855a                	mv	a0,s6
 78e:	dc5ff0ef          	jal	552 <printint>
        i += 1;
 792:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 794:	8bca                	mv	s7,s2
      state = 0;
 796:	4981                	li	s3,0
        i += 1;
 798:	b575                	j	644 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 79a:	008b8913          	addi	s2,s7,8
 79e:	4681                	li	a3,0
 7a0:	4629                	li	a2,10
 7a2:	000ba583          	lw	a1,0(s7)
 7a6:	855a                	mv	a0,s6
 7a8:	dabff0ef          	jal	552 <printint>
        i += 2;
 7ac:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ae:	8bca                	mv	s7,s2
      state = 0;
 7b0:	4981                	li	s3,0
        i += 2;
 7b2:	bd49                	j	644 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 7b4:	008b8913          	addi	s2,s7,8
 7b8:	4681                	li	a3,0
 7ba:	4641                	li	a2,16
 7bc:	000ba583          	lw	a1,0(s7)
 7c0:	855a                	mv	a0,s6
 7c2:	d91ff0ef          	jal	552 <printint>
 7c6:	8bca                	mv	s7,s2
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	bdad                	j	644 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7cc:	008b8913          	addi	s2,s7,8
 7d0:	4681                	li	a3,0
 7d2:	4641                	li	a2,16
 7d4:	000ba583          	lw	a1,0(s7)
 7d8:	855a                	mv	a0,s6
 7da:	d79ff0ef          	jal	552 <printint>
        i += 1;
 7de:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 7e0:	8bca                	mv	s7,s2
      state = 0;
 7e2:	4981                	li	s3,0
        i += 1;
 7e4:	b585                	j	644 <vprintf+0x4a>
 7e6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 7e8:	008b8d13          	addi	s10,s7,8
 7ec:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 7f0:	03000593          	li	a1,48
 7f4:	855a                	mv	a0,s6
 7f6:	d3fff0ef          	jal	534 <putc>
  putc(fd, 'x');
 7fa:	07800593          	li	a1,120
 7fe:	855a                	mv	a0,s6
 800:	d35ff0ef          	jal	534 <putc>
 804:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 806:	00000b97          	auipc	s7,0x0
 80a:	4bab8b93          	addi	s7,s7,1210 # cc0 <digits>
 80e:	03c9d793          	srli	a5,s3,0x3c
 812:	97de                	add	a5,a5,s7
 814:	0007c583          	lbu	a1,0(a5)
 818:	855a                	mv	a0,s6
 81a:	d1bff0ef          	jal	534 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 81e:	0992                	slli	s3,s3,0x4
 820:	397d                	addiw	s2,s2,-1
 822:	fe0916e3          	bnez	s2,80e <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 826:	8bea                	mv	s7,s10
      state = 0;
 828:	4981                	li	s3,0
 82a:	6d02                	ld	s10,0(sp)
 82c:	bd21                	j	644 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 82e:	008b8993          	addi	s3,s7,8
 832:	000bb903          	ld	s2,0(s7)
 836:	00090f63          	beqz	s2,854 <vprintf+0x25a>
        for(; *s; s++)
 83a:	00094583          	lbu	a1,0(s2)
 83e:	c195                	beqz	a1,862 <vprintf+0x268>
          putc(fd, *s);
 840:	855a                	mv	a0,s6
 842:	cf3ff0ef          	jal	534 <putc>
        for(; *s; s++)
 846:	0905                	addi	s2,s2,1
 848:	00094583          	lbu	a1,0(s2)
 84c:	f9f5                	bnez	a1,840 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 84e:	8bce                	mv	s7,s3
      state = 0;
 850:	4981                	li	s3,0
 852:	bbcd                	j	644 <vprintf+0x4a>
          s = "(null)";
 854:	00000917          	auipc	s2,0x0
 858:	46490913          	addi	s2,s2,1124 # cb8 <malloc+0x358>
        for(; *s; s++)
 85c:	02800593          	li	a1,40
 860:	b7c5                	j	840 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 862:	8bce                	mv	s7,s3
      state = 0;
 864:	4981                	li	s3,0
 866:	bbf9                	j	644 <vprintf+0x4a>
 868:	64a6                	ld	s1,72(sp)
 86a:	79e2                	ld	s3,56(sp)
 86c:	7a42                	ld	s4,48(sp)
 86e:	7aa2                	ld	s5,40(sp)
 870:	7b02                	ld	s6,32(sp)
 872:	6be2                	ld	s7,24(sp)
 874:	6c42                	ld	s8,16(sp)
 876:	6ca2                	ld	s9,8(sp)
    }
  }
}
 878:	60e6                	ld	ra,88(sp)
 87a:	6446                	ld	s0,80(sp)
 87c:	6906                	ld	s2,64(sp)
 87e:	6125                	addi	sp,sp,96
 880:	8082                	ret

0000000000000882 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 882:	715d                	addi	sp,sp,-80
 884:	ec06                	sd	ra,24(sp)
 886:	e822                	sd	s0,16(sp)
 888:	1000                	addi	s0,sp,32
 88a:	e010                	sd	a2,0(s0)
 88c:	e414                	sd	a3,8(s0)
 88e:	e818                	sd	a4,16(s0)
 890:	ec1c                	sd	a5,24(s0)
 892:	03043023          	sd	a6,32(s0)
 896:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 89a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 89e:	8622                	mv	a2,s0
 8a0:	d5bff0ef          	jal	5fa <vprintf>
}
 8a4:	60e2                	ld	ra,24(sp)
 8a6:	6442                	ld	s0,16(sp)
 8a8:	6161                	addi	sp,sp,80
 8aa:	8082                	ret

00000000000008ac <printf>:

void
printf(const char *fmt, ...)
{
 8ac:	711d                	addi	sp,sp,-96
 8ae:	ec06                	sd	ra,24(sp)
 8b0:	e822                	sd	s0,16(sp)
 8b2:	1000                	addi	s0,sp,32
 8b4:	e40c                	sd	a1,8(s0)
 8b6:	e810                	sd	a2,16(s0)
 8b8:	ec14                	sd	a3,24(s0)
 8ba:	f018                	sd	a4,32(s0)
 8bc:	f41c                	sd	a5,40(s0)
 8be:	03043823          	sd	a6,48(s0)
 8c2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 8c6:	00840613          	addi	a2,s0,8
 8ca:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 8ce:	85aa                	mv	a1,a0
 8d0:	4505                	li	a0,1
 8d2:	d29ff0ef          	jal	5fa <vprintf>
}
 8d6:	60e2                	ld	ra,24(sp)
 8d8:	6442                	ld	s0,16(sp)
 8da:	6125                	addi	sp,sp,96
 8dc:	8082                	ret

00000000000008de <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 8de:	1141                	addi	sp,sp,-16
 8e0:	e422                	sd	s0,8(sp)
 8e2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 8e4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 8e8:	00001797          	auipc	a5,0x1
 8ec:	7187b783          	ld	a5,1816(a5) # 2000 <freep>
 8f0:	a02d                	j	91a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 8f2:	4618                	lw	a4,8(a2)
 8f4:	9f2d                	addw	a4,a4,a1
 8f6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8fa:	6398                	ld	a4,0(a5)
 8fc:	6310                	ld	a2,0(a4)
 8fe:	a83d                	j	93c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 900:	ff852703          	lw	a4,-8(a0)
 904:	9f31                	addw	a4,a4,a2
 906:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 908:	ff053683          	ld	a3,-16(a0)
 90c:	a091                	j	950 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 90e:	6398                	ld	a4,0(a5)
 910:	00e7e463          	bltu	a5,a4,918 <free+0x3a>
 914:	00e6ea63          	bltu	a3,a4,928 <free+0x4a>
{
 918:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 91a:	fed7fae3          	bgeu	a5,a3,90e <free+0x30>
 91e:	6398                	ld	a4,0(a5)
 920:	00e6e463          	bltu	a3,a4,928 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 924:	fee7eae3          	bltu	a5,a4,918 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 928:	ff852583          	lw	a1,-8(a0)
 92c:	6390                	ld	a2,0(a5)
 92e:	02059813          	slli	a6,a1,0x20
 932:	01c85713          	srli	a4,a6,0x1c
 936:	9736                	add	a4,a4,a3
 938:	fae60de3          	beq	a2,a4,8f2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 93c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 940:	4790                	lw	a2,8(a5)
 942:	02061593          	slli	a1,a2,0x20
 946:	01c5d713          	srli	a4,a1,0x1c
 94a:	973e                	add	a4,a4,a5
 94c:	fae68ae3          	beq	a3,a4,900 <free+0x22>
    p->s.ptr = bp->s.ptr;
 950:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 952:	00001717          	auipc	a4,0x1
 956:	6af73723          	sd	a5,1710(a4) # 2000 <freep>
}
 95a:	6422                	ld	s0,8(sp)
 95c:	0141                	addi	sp,sp,16
 95e:	8082                	ret

0000000000000960 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 960:	7139                	addi	sp,sp,-64
 962:	fc06                	sd	ra,56(sp)
 964:	f822                	sd	s0,48(sp)
 966:	f426                	sd	s1,40(sp)
 968:	ec4e                	sd	s3,24(sp)
 96a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 96c:	02051493          	slli	s1,a0,0x20
 970:	9081                	srli	s1,s1,0x20
 972:	04bd                	addi	s1,s1,15
 974:	8091                	srli	s1,s1,0x4
 976:	0014899b          	addiw	s3,s1,1
 97a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 97c:	00001517          	auipc	a0,0x1
 980:	68453503          	ld	a0,1668(a0) # 2000 <freep>
 984:	c915                	beqz	a0,9b8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 986:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 988:	4798                	lw	a4,8(a5)
 98a:	08977a63          	bgeu	a4,s1,a1e <malloc+0xbe>
 98e:	f04a                	sd	s2,32(sp)
 990:	e852                	sd	s4,16(sp)
 992:	e456                	sd	s5,8(sp)
 994:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 996:	8a4e                	mv	s4,s3
 998:	0009871b          	sext.w	a4,s3
 99c:	6685                	lui	a3,0x1
 99e:	00d77363          	bgeu	a4,a3,9a4 <malloc+0x44>
 9a2:	6a05                	lui	s4,0x1
 9a4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 9a8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 9ac:	00001917          	auipc	s2,0x1
 9b0:	65490913          	addi	s2,s2,1620 # 2000 <freep>
  if(p == (char*)-1)
 9b4:	5afd                	li	s5,-1
 9b6:	a081                	j	9f6 <malloc+0x96>
 9b8:	f04a                	sd	s2,32(sp)
 9ba:	e852                	sd	s4,16(sp)
 9bc:	e456                	sd	s5,8(sp)
 9be:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 9c0:	00001797          	auipc	a5,0x1
 9c4:	65078793          	addi	a5,a5,1616 # 2010 <base>
 9c8:	00001717          	auipc	a4,0x1
 9cc:	62f73c23          	sd	a5,1592(a4) # 2000 <freep>
 9d0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 9d2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 9d6:	b7c1                	j	996 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 9d8:	6398                	ld	a4,0(a5)
 9da:	e118                	sd	a4,0(a0)
 9dc:	a8a9                	j	a36 <malloc+0xd6>
  hp->s.size = nu;
 9de:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 9e2:	0541                	addi	a0,a0,16
 9e4:	efbff0ef          	jal	8de <free>
  return freep;
 9e8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 9ec:	c12d                	beqz	a0,a4e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9ee:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9f0:	4798                	lw	a4,8(a5)
 9f2:	02977263          	bgeu	a4,s1,a16 <malloc+0xb6>
    if(p == freep)
 9f6:	00093703          	ld	a4,0(s2)
 9fa:	853e                	mv	a0,a5
 9fc:	fef719e3          	bne	a4,a5,9ee <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a00:	8552                	mv	a0,s4
 a02:	b13ff0ef          	jal	514 <sbrk>
  if(p == (char*)-1)
 a06:	fd551ce3          	bne	a0,s5,9de <malloc+0x7e>
        return 0;
 a0a:	4501                	li	a0,0
 a0c:	7902                	ld	s2,32(sp)
 a0e:	6a42                	ld	s4,16(sp)
 a10:	6aa2                	ld	s5,8(sp)
 a12:	6b02                	ld	s6,0(sp)
 a14:	a03d                	j	a42 <malloc+0xe2>
 a16:	7902                	ld	s2,32(sp)
 a18:	6a42                	ld	s4,16(sp)
 a1a:	6aa2                	ld	s5,8(sp)
 a1c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a1e:	fae48de3          	beq	s1,a4,9d8 <malloc+0x78>
        p->s.size -= nunits;
 a22:	4137073b          	subw	a4,a4,s3
 a26:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a28:	02071693          	slli	a3,a4,0x20
 a2c:	01c6d713          	srli	a4,a3,0x1c
 a30:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a32:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a36:	00001717          	auipc	a4,0x1
 a3a:	5ca73523          	sd	a0,1482(a4) # 2000 <freep>
      return (void*)(p + 1);
 a3e:	01078513          	addi	a0,a5,16
  }
}
 a42:	70e2                	ld	ra,56(sp)
 a44:	7442                	ld	s0,48(sp)
 a46:	74a2                	ld	s1,40(sp)
 a48:	69e2                	ld	s3,24(sp)
 a4a:	6121                	addi	sp,sp,64
 a4c:	8082                	ret
 a4e:	7902                	ld	s2,32(sp)
 a50:	6a42                	ld	s4,16(sp)
 a52:	6aa2                	ld	s5,8(sp)
 a54:	6b02                	ld	s6,0(sp)
 a56:	b7f5                	j	a42 <malloc+0xe2>
