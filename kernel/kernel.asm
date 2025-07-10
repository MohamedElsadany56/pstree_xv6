
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	3f013103          	ld	sp,1008(sp) # 8000a3f0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd5267>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	1a2020ef          	jal	8000229c <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00012517          	auipc	a0,0x12
    80000158:	2fc50513          	addi	a0,a0,764 # 80012450 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	2f048493          	addi	s1,s1,752 # 80012450 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	38090913          	addi	s2,s2,896 # 800124e8 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	7ab010ef          	jal	8000212e <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	525010ef          	jal	80001eb2 <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00012717          	auipc	a4,0x12
    800001a4:	2b070713          	addi	a4,a4,688 # 80012450 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	080020ef          	jal	80002252 <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00012517          	auipc	a0,0x12
    800001ee:	26650513          	addi	a0,a0,614 # 80012450 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00012717          	auipc	a4,0x12
    80000218:	2cf72a23          	sw	a5,724(a4) # 800124e8 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	22650513          	addi	a0,a0,550 # 80012450 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	00012517          	auipc	a0,0x12
    80000282:	1d250513          	addi	a0,a0,466 # 80012450 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	046020ef          	jal	800022e6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	00012517          	auipc	a0,0x12
    800002a8:	1ac50513          	addi	a0,a0,428 # 80012450 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	00012717          	auipc	a4,0x12
    800002c6:	18e70713          	addi	a4,a4,398 # 80012450 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	00012797          	auipc	a5,0x12
    800002ec:	16878793          	addi	a5,a5,360 # 80012450 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	00012797          	auipc	a5,0x12
    8000031a:	1d27a783          	lw	a5,466(a5) # 800124e8 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00012717          	auipc	a4,0x12
    80000330:	12470713          	addi	a4,a4,292 # 80012450 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00012497          	auipc	s1,0x12
    80000340:	11448493          	addi	s1,s1,276 # 80012450 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	00012717          	auipc	a4,0x12
    80000382:	0d270713          	addi	a4,a4,210 # 80012450 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00012717          	auipc	a4,0x12
    80000398:	14f72e23          	sw	a5,348(a4) # 800124f0 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	00012797          	auipc	a5,0x12
    800003b6:	09e78793          	addi	a5,a5,158 # 80012450 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00012797          	auipc	a5,0x12
    800003da:	10c7ab23          	sw	a2,278(a5) # 800124ec <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00012517          	auipc	a0,0x12
    800003e2:	10a50513          	addi	a0,a0,266 # 800124e8 <cons+0x98>
    800003e6:	319010ef          	jal	80001efe <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	00012517          	auipc	a0,0x12
    80000400:	05450513          	addi	a0,a0,84 # 80012450 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00028797          	auipc	a5,0x28
    80000410:	ff478793          	addi	a5,a5,-12 # 80028400 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	41a60613          	addi	a2,a2,1050 # 80007860 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	00012797          	auipc	a5,0x12
    800004e4:	0307a783          	lw	a5,48(a5) # 80012510 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	00012517          	auipc	a0,0x12
    80000530:	fcc50513          	addi	a0,a0,-52 # 800124f8 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	174b8b93          	addi	s7,s7,372 # 80007860 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	00012517          	auipc	a0,0x12
    8000078a:	d7250513          	addi	a0,a0,-654 # 800124f8 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	00012797          	auipc	a5,0x12
    800007a4:	d607a823          	sw	zero,-656(a5) # 80012510 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	0000a717          	auipc	a4,0xa
    800007c8:	c4f72623          	sw	a5,-948(a4) # 8000a410 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	00012497          	auipc	s1,0x12
    800007dc:	d2048493          	addi	s1,s1,-736 # 800124f8 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	00012517          	auipc	a0,0x12
    80000844:	cd850513          	addi	a0,a0,-808 # 80012518 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	0000a797          	auipc	a5,0xa
    80000868:	bac7a783          	lw	a5,-1108(a5) # 8000a410 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	0000a797          	auipc	a5,0xa
    8000089e:	b7e7b783          	ld	a5,-1154(a5) # 8000a418 <uart_tx_r>
    800008a2:	0000a717          	auipc	a4,0xa
    800008a6:	b7e73703          	ld	a4,-1154(a4) # 8000a420 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	00012a97          	auipc	s5,0x12
    800008cc:	c50a8a93          	addi	s5,s5,-944 # 80012518 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	0000a497          	auipc	s1,0xa
    800008d4:	b4848493          	addi	s1,s1,-1208 # 8000a418 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	0000a997          	auipc	s3,0xa
    800008e0:	b4498993          	addi	s3,s3,-1212 # 8000a420 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	600010ef          	jal	80001efe <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
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
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	00012517          	auipc	a0,0x12
    80000950:	bcc50513          	addi	a0,a0,-1076 # 80012518 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	0000a797          	auipc	a5,0xa
    8000095c:	ab87a783          	lw	a5,-1352(a5) # 8000a410 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	0000a717          	auipc	a4,0xa
    80000966:	abe73703          	ld	a4,-1346(a4) # 8000a420 <uart_tx_w>
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	aae7b783          	ld	a5,-1362(a5) # 8000a418 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	00012997          	auipc	s3,0x12
    8000097a:	ba298993          	addi	s3,s3,-1118 # 80012518 <uart_tx_lock>
    8000097e:	0000a497          	auipc	s1,0xa
    80000982:	a9a48493          	addi	s1,s1,-1382 # 8000a418 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	0000a917          	auipc	s2,0xa
    8000098a:	a9a90913          	addi	s2,s2,-1382 # 8000a420 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	51c010ef          	jal	80001eb2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	b7048493          	addi	s1,s1,-1168 # 80012518 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	0000a797          	auipc	a5,0xa
    800009c0:	a6e7b223          	sd	a4,-1436(a5) # 8000a420 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	00012497          	auipc	s1,0x12
    80000a24:	af848493          	addi	s1,s1,-1288 # 80012518 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00029797          	auipc	a5,0x29
    80000a5a:	b4278793          	addi	a5,a5,-1214 # 80029598 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	00012917          	auipc	s2,0x12
    80000a76:	ade90913          	addi	s2,s2,-1314 # 80012550 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	00012517          	auipc	a0,0x12
    80000b04:	a5050513          	addi	a0,a0,-1456 # 80012550 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00029517          	auipc	a0,0x29
    80000b14:	a8850513          	addi	a0,a0,-1400 # 80029598 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	00012497          	auipc	s1,0x12
    80000b32:	a2248493          	addi	s1,s1,-1502 # 80012550 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012517          	auipc	a0,0x12
    80000b46:	a0e50513          	addi	a0,a0,-1522 # 80012550 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	00012517          	auipc	a0,0x12
    80000b6a:	9ea50513          	addi	a0,a0,-1558 # 80012550 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	485000ef          	jal	800018c4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ca6:	0310000f          	fence	rw,w
    80000caa:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd5a69>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00009717          	auipc	a4,0x9
    80000e72:	5ba70713          	addi	a4,a4,1466 # 8000a428 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	7f0010ef          	jal	80002688 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	68c040ef          	jal	80005528 <plicinithart>
  }

  scheduler();        
    80000ea0:	679000ef          	jal	80001d18 <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	784010ef          	jal	80002664 <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	7a4010ef          	jal	80002688 <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	626040ef          	jal	8000550e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	63c040ef          	jal	80005528 <plicinithart>
    binit();         // buffer cache
    80000ef0:	5df010ef          	jal	80002cce <binit>
    iinit();         // inode table
    80000ef4:	3d0020ef          	jal	800032c4 <iinit>
    fileinit();      // file table
    80000ef8:	17c030ef          	jal	80004074 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	71c040ef          	jal	80005618 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	44d000ef          	jal	80001b4c <userinit>
    __sync_synchronize();
    80000f04:	0330000f          	fence	rw,rw
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00009717          	auipc	a4,0x9
    80000f0e:	50f72f23          	sw	a5,1310(a4) # 8000a428 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	5127b783          	ld	a5,1298(a5) # 8000a430 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd5a5f>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	28a7b323          	sd	a0,646(a5) # 8000a430 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	00011497          	auipc	s1,0x11
    80001780:	22448493          	addi	s1,s1,548 # 800129a0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	ff4df937          	lui	s2,0xff4df
    8000178a:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b5425>
    8000178e:	0936                	slli	s2,s2,0xd
    80001790:	6f590913          	addi	s2,s2,1781
    80001794:	0936                	slli	s2,s2,0xd
    80001796:	bd390913          	addi	s2,s2,-1069
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	7a790913          	addi	s2,s2,1959
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00017a97          	auipc	s5,0x17
    800017ac:	df8a8a93          	addi	s5,s5,-520 # 800185a0 <ptable>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	8591                	srai	a1,a1,0x4
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	17048493          	addi	s1,s1,368
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800071f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9ee58593          	addi	a1,a1,-1554 # 80007200 <etext+0x200>
    8000181a:	00011517          	auipc	a0,0x11
    8000181e:	d5650513          	addi	a0,a0,-682 # 80012570 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	00011517          	auipc	a0,0x11
    80001832:	d5a50513          	addi	a0,a0,-678 # 80012588 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	00011497          	auipc	s1,0x11
    8000183e:	16648493          	addi	s1,s1,358 # 800129a0 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	ff4df937          	lui	s2,0xff4df
    80001850:	9bd90913          	addi	s2,s2,-1603 # ffffffffff4de9bd <end+0xffffffff7f4b5425>
    80001854:	0936                	slli	s2,s2,0xd
    80001856:	6f590913          	addi	s2,s2,1781
    8000185a:	0936                	slli	s2,s2,0xd
    8000185c:	bd390913          	addi	s2,s2,-1069
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	7a790913          	addi	s2,s2,1959
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00017a17          	auipc	s4,0x17
    80001872:	d32a0a13          	addi	s4,s4,-718 # 800185a0 <ptable>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	8791                	srai	a5,a5,0x4
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e4bc                	sd	a5,72(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	17048493          	addi	s1,s1,368
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	00011517          	auipc	a0,0x11
    800018d4:	cd050513          	addi	a0,a0,-816 # 800125a0 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	00011717          	auipc	a4,0x11
    800018f8:	c7c70713          	addi	a4,a4,-900 # 80012570 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first) {
    80001920:	00009797          	auipc	a5,0x9
    80001924:	a807a783          	lw	a5,-1408(a5) # 8000a3a0 <first.2>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	577000ef          	jal	800026a0 <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	121010ef          	jal	80003258 <fsinit>
    first = 0;
    8000193c:	00009797          	auipc	a5,0x9
    80001940:	a607a223          	sw	zero,-1436(a5) # 8000a3a0 <first.2>
    __sync_synchronize();
    80001944:	0330000f          	fence	rw,rw
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	00011917          	auipc	s2,0x11
    8000195a:	c1a90913          	addi	s2,s2,-998 # 80012570 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00009797          	auipc	a5,0x9
    80001968:	a4078793          	addi	a5,a5,-1472 # 8000a3a4 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
{
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ba:	4719                	li	a4,6
    800019bc:	06093683          	ld	a3,96(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
}
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    uvmfree(pagetable, 0);
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5e:	7128                	ld	a0,96(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0604b023          	sd	zero,96(s1)
  if(p->pagetable)
    80001a6a:	6ca8                	ld	a0,88(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	68ac                	ld	a1,80(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001a78:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a84:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001a88:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a8c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a94:	0004ac23          	sw	zero,24(s1)
}
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <allocproc>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aae:	00011497          	auipc	s1,0x11
    80001ab2:	ef248493          	addi	s1,s1,-270 # 800129a0 <proc>
    80001ab6:	00017917          	auipc	s2,0x17
    80001aba:	aea90913          	addi	s2,s2,-1302 # 800185a0 <ptable>
    acquire(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	934ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ac4:	4c9c                	lw	a5,24(s1)
    80001ac6:	cb91                	beqz	a5,80001ada <allocproc+0x38>
      release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	9c2ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ace:	17048493          	addi	s1,s1,368
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
  return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	a099                	j	80001b1e <allocproc+0x7c>
  p->pid = allocpid();
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae0:	4785                	li	a5,1
    80001ae2:	cc9c                	sw	a5,24(s1)
  p->is_orphan = 0; // intiallize as not orphan
    80001ae4:	0404a023          	sw	zero,64(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ae8:	83cff0ef          	jal	80000b24 <kalloc>
    80001aec:	892a                	mv	s2,a0
    80001aee:	f0a8                	sd	a0,96(s1)
    80001af0:	cd15                	beqz	a0,80001b2c <allocproc+0x8a>
  p->pagetable = proc_pagetable(p);
    80001af2:	8526                	mv	a0,s1
    80001af4:	e95ff0ef          	jal	80001988 <proc_pagetable>
    80001af8:	892a                	mv	s2,a0
    80001afa:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001afc:	c121                	beqz	a0,80001b3c <allocproc+0x9a>
  memset(&p->context, 0, sizeof(p->context));
    80001afe:	07000613          	li	a2,112
    80001b02:	4581                	li	a1,0
    80001b04:	06848513          	addi	a0,s1,104
    80001b08:	9c0ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b0c:	00000797          	auipc	a5,0x0
    80001b10:	e0478793          	addi	a5,a5,-508 # 80001910 <forkret>
    80001b14:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b16:	64bc                	ld	a5,72(s1)
    80001b18:	6705                	lui	a4,0x1
    80001b1a:	97ba                	add	a5,a5,a4
    80001b1c:	f8bc                	sd	a5,112(s1)
}
    80001b1e:	8526                	mv	a0,s1
    80001b20:	60e2                	ld	ra,24(sp)
    80001b22:	6442                	ld	s0,16(sp)
    80001b24:	64a2                	ld	s1,8(sp)
    80001b26:	6902                	ld	s2,0(sp)
    80001b28:	6105                	addi	sp,sp,32
    80001b2a:	8082                	ret
    freeproc(p);
    80001b2c:	8526                	mv	a0,s1
    80001b2e:	f25ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b32:	8526                	mv	a0,s1
    80001b34:	958ff0ef          	jal	80000c8c <release>
    return 0;
    80001b38:	84ca                	mv	s1,s2
    80001b3a:	b7d5                	j	80001b1e <allocproc+0x7c>
    freeproc(p);
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	f15ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b42:	8526                	mv	a0,s1
    80001b44:	948ff0ef          	jal	80000c8c <release>
    return 0;
    80001b48:	84ca                	mv	s1,s2
    80001b4a:	bfd1                	j	80001b1e <allocproc+0x7c>

0000000080001b4c <userinit>:
{
    80001b4c:	1101                	addi	sp,sp,-32
    80001b4e:	ec06                	sd	ra,24(sp)
    80001b50:	e822                	sd	s0,16(sp)
    80001b52:	e426                	sd	s1,8(sp)
    80001b54:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b56:	f4dff0ef          	jal	80001aa2 <allocproc>
    80001b5a:	84aa                	mv	s1,a0
  initproc = p;
    80001b5c:	00009797          	auipc	a5,0x9
    80001b60:	8ca7be23          	sd	a0,-1828(a5) # 8000a438 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b64:	03400613          	li	a2,52
    80001b68:	00009597          	auipc	a1,0x9
    80001b6c:	84858593          	addi	a1,a1,-1976 # 8000a3b0 <initcode>
    80001b70:	6d28                	ld	a0,88(a0)
    80001b72:	f2aff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b76:	6785                	lui	a5,0x1
    80001b78:	e8bc                	sd	a5,80(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b7a:	70b8                	ld	a4,96(s1)
    80001b7c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b80:	70b8                	ld	a4,96(s1)
    80001b82:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b84:	4641                	li	a2,16
    80001b86:	00005597          	auipc	a1,0x5
    80001b8a:	69a58593          	addi	a1,a1,1690 # 80007220 <etext+0x220>
    80001b8e:	16048513          	addi	a0,s1,352
    80001b92:	a74ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001b96:	00005517          	auipc	a0,0x5
    80001b9a:	69a50513          	addi	a0,a0,1690 # 80007230 <etext+0x230>
    80001b9e:	7c9010ef          	jal	80003b66 <namei>
    80001ba2:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001ba6:	478d                	li	a5,3
    80001ba8:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001baa:	8526                	mv	a0,s1
    80001bac:	8e0ff0ef          	jal	80000c8c <release>
}
    80001bb0:	60e2                	ld	ra,24(sp)
    80001bb2:	6442                	ld	s0,16(sp)
    80001bb4:	64a2                	ld	s1,8(sp)
    80001bb6:	6105                	addi	sp,sp,32
    80001bb8:	8082                	ret

0000000080001bba <growproc>:
{
    80001bba:	1101                	addi	sp,sp,-32
    80001bbc:	ec06                	sd	ra,24(sp)
    80001bbe:	e822                	sd	s0,16(sp)
    80001bc0:	e426                	sd	s1,8(sp)
    80001bc2:	e04a                	sd	s2,0(sp)
    80001bc4:	1000                	addi	s0,sp,32
    80001bc6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bc8:	d19ff0ef          	jal	800018e0 <myproc>
    80001bcc:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bce:	692c                	ld	a1,80(a0)
  if(n > 0){
    80001bd0:	01204c63          	bgtz	s2,80001be8 <growproc+0x2e>
  } else if(n < 0){
    80001bd4:	02094463          	bltz	s2,80001bfc <growproc+0x42>
  p->sz = sz;
    80001bd8:	e8ac                	sd	a1,80(s1)
  return 0;
    80001bda:	4501                	li	a0,0
}
    80001bdc:	60e2                	ld	ra,24(sp)
    80001bde:	6442                	ld	s0,16(sp)
    80001be0:	64a2                	ld	s1,8(sp)
    80001be2:	6902                	ld	s2,0(sp)
    80001be4:	6105                	addi	sp,sp,32
    80001be6:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001be8:	4691                	li	a3,4
    80001bea:	00b90633          	add	a2,s2,a1
    80001bee:	6d28                	ld	a0,88(a0)
    80001bf0:	f4eff0ef          	jal	8000133e <uvmalloc>
    80001bf4:	85aa                	mv	a1,a0
    80001bf6:	f16d                	bnez	a0,80001bd8 <growproc+0x1e>
      return -1;
    80001bf8:	557d                	li	a0,-1
    80001bfa:	b7cd                	j	80001bdc <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bfc:	00b90633          	add	a2,s2,a1
    80001c00:	6d28                	ld	a0,88(a0)
    80001c02:	ef8ff0ef          	jal	800012fa <uvmdealloc>
    80001c06:	85aa                	mv	a1,a0
    80001c08:	bfc1                	j	80001bd8 <growproc+0x1e>

0000000080001c0a <fork>:
{
    80001c0a:	7139                	addi	sp,sp,-64
    80001c0c:	fc06                	sd	ra,56(sp)
    80001c0e:	f822                	sd	s0,48(sp)
    80001c10:	f04a                	sd	s2,32(sp)
    80001c12:	e456                	sd	s5,8(sp)
    80001c14:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c16:	ccbff0ef          	jal	800018e0 <myproc>
    80001c1a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c1c:	e87ff0ef          	jal	80001aa2 <allocproc>
    80001c20:	0e050a63          	beqz	a0,80001d14 <fork+0x10a>
    80001c24:	e852                	sd	s4,16(sp)
    80001c26:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c28:	050ab603          	ld	a2,80(s5)
    80001c2c:	6d2c                	ld	a1,88(a0)
    80001c2e:	058ab503          	ld	a0,88(s5)
    80001c32:	845ff0ef          	jal	80001476 <uvmcopy>
    80001c36:	04054a63          	bltz	a0,80001c8a <fork+0x80>
    80001c3a:	f426                	sd	s1,40(sp)
    80001c3c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c3e:	050ab783          	ld	a5,80(s5)
    80001c42:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c46:	060ab683          	ld	a3,96(s5)
    80001c4a:	87b6                	mv	a5,a3
    80001c4c:	060a3703          	ld	a4,96(s4)
    80001c50:	12068693          	addi	a3,a3,288
    80001c54:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c58:	6788                	ld	a0,8(a5)
    80001c5a:	6b8c                	ld	a1,16(a5)
    80001c5c:	6f90                	ld	a2,24(a5)
    80001c5e:	01073023          	sd	a6,0(a4)
    80001c62:	e708                	sd	a0,8(a4)
    80001c64:	eb0c                	sd	a1,16(a4)
    80001c66:	ef10                	sd	a2,24(a4)
    80001c68:	02078793          	addi	a5,a5,32
    80001c6c:	02070713          	addi	a4,a4,32
    80001c70:	fed792e3          	bne	a5,a3,80001c54 <fork+0x4a>
  np->trapframe->a0 = 0;
    80001c74:	060a3783          	ld	a5,96(s4)
    80001c78:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001c7c:	0d8a8493          	addi	s1,s5,216
    80001c80:	0d8a0913          	addi	s2,s4,216
    80001c84:	158a8993          	addi	s3,s5,344
    80001c88:	a831                	j	80001ca4 <fork+0x9a>
    freeproc(np);
    80001c8a:	8552                	mv	a0,s4
    80001c8c:	dc7ff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001c90:	8552                	mv	a0,s4
    80001c92:	ffbfe0ef          	jal	80000c8c <release>
    return -1;
    80001c96:	597d                	li	s2,-1
    80001c98:	6a42                	ld	s4,16(sp)
    80001c9a:	a0b5                	j	80001d06 <fork+0xfc>
  for(i = 0; i < NOFILE; i++)
    80001c9c:	04a1                	addi	s1,s1,8
    80001c9e:	0921                	addi	s2,s2,8
    80001ca0:	01348963          	beq	s1,s3,80001cb2 <fork+0xa8>
    if(p->ofile[i])
    80001ca4:	6088                	ld	a0,0(s1)
    80001ca6:	d97d                	beqz	a0,80001c9c <fork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ca8:	44e020ef          	jal	800040f6 <filedup>
    80001cac:	00a93023          	sd	a0,0(s2)
    80001cb0:	b7f5                	j	80001c9c <fork+0x92>
  np->cwd = idup(p->cwd);
    80001cb2:	158ab503          	ld	a0,344(s5)
    80001cb6:	7a0010ef          	jal	80003456 <idup>
    80001cba:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cbe:	4641                	li	a2,16
    80001cc0:	160a8593          	addi	a1,s5,352
    80001cc4:	160a0513          	addi	a0,s4,352
    80001cc8:	93eff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001ccc:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cd0:	8552                	mv	a0,s4
    80001cd2:	fbbfe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cd6:	00011497          	auipc	s1,0x11
    80001cda:	8b248493          	addi	s1,s1,-1870 # 80012588 <wait_lock>
    80001cde:	8526                	mv	a0,s1
    80001ce0:	f15fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001ce4:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001ce8:	8526                	mv	a0,s1
    80001cea:	fa3fe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001cee:	8552                	mv	a0,s4
    80001cf0:	f05fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001cf4:	478d                	li	a5,3
    80001cf6:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cfa:	8552                	mv	a0,s4
    80001cfc:	f91fe0ef          	jal	80000c8c <release>
  return pid;
    80001d00:	74a2                	ld	s1,40(sp)
    80001d02:	69e2                	ld	s3,24(sp)
    80001d04:	6a42                	ld	s4,16(sp)
}
    80001d06:	854a                	mv	a0,s2
    80001d08:	70e2                	ld	ra,56(sp)
    80001d0a:	7442                	ld	s0,48(sp)
    80001d0c:	7902                	ld	s2,32(sp)
    80001d0e:	6aa2                	ld	s5,8(sp)
    80001d10:	6121                	addi	sp,sp,64
    80001d12:	8082                	ret
    return -1;
    80001d14:	597d                	li	s2,-1
    80001d16:	bfc5                	j	80001d06 <fork+0xfc>

0000000080001d18 <scheduler>:
{
    80001d18:	715d                	addi	sp,sp,-80
    80001d1a:	e486                	sd	ra,72(sp)
    80001d1c:	e0a2                	sd	s0,64(sp)
    80001d1e:	fc26                	sd	s1,56(sp)
    80001d20:	f84a                	sd	s2,48(sp)
    80001d22:	f44e                	sd	s3,40(sp)
    80001d24:	f052                	sd	s4,32(sp)
    80001d26:	ec56                	sd	s5,24(sp)
    80001d28:	e85a                	sd	s6,16(sp)
    80001d2a:	e45e                	sd	s7,8(sp)
    80001d2c:	e062                	sd	s8,0(sp)
    80001d2e:	0880                	addi	s0,sp,80
    80001d30:	8792                	mv	a5,tp
  int id = r_tp();
    80001d32:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d34:	00779b13          	slli	s6,a5,0x7
    80001d38:	00011717          	auipc	a4,0x11
    80001d3c:	83870713          	addi	a4,a4,-1992 # 80012570 <pid_lock>
    80001d40:	975a                	add	a4,a4,s6
    80001d42:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d46:	00011717          	auipc	a4,0x11
    80001d4a:	86270713          	addi	a4,a4,-1950 # 800125a8 <cpus+0x8>
    80001d4e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001d50:	4c11                	li	s8,4
        c->proc = p;
    80001d52:	079e                	slli	a5,a5,0x7
    80001d54:	00011a17          	auipc	s4,0x11
    80001d58:	81ca0a13          	addi	s4,s4,-2020 # 80012570 <pid_lock>
    80001d5c:	9a3e                	add	s4,s4,a5
        found = 1;
    80001d5e:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d60:	00017997          	auipc	s3,0x17
    80001d64:	84098993          	addi	s3,s3,-1984 # 800185a0 <ptable>
    80001d68:	a0a9                	j	80001db2 <scheduler+0x9a>
      release(&p->lock);
    80001d6a:	8526                	mv	a0,s1
    80001d6c:	f21fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d70:	17048493          	addi	s1,s1,368
    80001d74:	03348563          	beq	s1,s3,80001d9e <scheduler+0x86>
      acquire(&p->lock);
    80001d78:	8526                	mv	a0,s1
    80001d7a:	e7bfe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001d7e:	4c9c                	lw	a5,24(s1)
    80001d80:	ff2795e3          	bne	a5,s2,80001d6a <scheduler+0x52>
        p->state = RUNNING;
    80001d84:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d88:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d8c:	06848593          	addi	a1,s1,104
    80001d90:	855a                	mv	a0,s6
    80001d92:	069000ef          	jal	800025fa <swtch>
        c->proc = 0;
    80001d96:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001d9a:	8ade                	mv	s5,s7
    80001d9c:	b7f9                	j	80001d6a <scheduler+0x52>
    if(found == 0) {
    80001d9e:	000a9a63          	bnez	s5,80001db2 <scheduler+0x9a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001da2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001da6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001daa:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001dae:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001db2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001db6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dba:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001dbe:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80001dc0:	00011497          	auipc	s1,0x11
    80001dc4:	be048493          	addi	s1,s1,-1056 # 800129a0 <proc>
      if(p->state == RUNNABLE) {
    80001dc8:	490d                	li	s2,3
    80001dca:	b77d                	j	80001d78 <scheduler+0x60>

0000000080001dcc <sched>:
{
    80001dcc:	7179                	addi	sp,sp,-48
    80001dce:	f406                	sd	ra,40(sp)
    80001dd0:	f022                	sd	s0,32(sp)
    80001dd2:	ec26                	sd	s1,24(sp)
    80001dd4:	e84a                	sd	s2,16(sp)
    80001dd6:	e44e                	sd	s3,8(sp)
    80001dd8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dda:	b07ff0ef          	jal	800018e0 <myproc>
    80001dde:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001de0:	dabfe0ef          	jal	80000b8a <holding>
    80001de4:	c92d                	beqz	a0,80001e56 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001de6:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001de8:	2781                	sext.w	a5,a5
    80001dea:	079e                	slli	a5,a5,0x7
    80001dec:	00010717          	auipc	a4,0x10
    80001df0:	78470713          	addi	a4,a4,1924 # 80012570 <pid_lock>
    80001df4:	97ba                	add	a5,a5,a4
    80001df6:	0a87a703          	lw	a4,168(a5)
    80001dfa:	4785                	li	a5,1
    80001dfc:	06f71363          	bne	a4,a5,80001e62 <sched+0x96>
  if(p->state == RUNNING)
    80001e00:	4c98                	lw	a4,24(s1)
    80001e02:	4791                	li	a5,4
    80001e04:	06f70563          	beq	a4,a5,80001e6e <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e08:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e0c:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e0e:	e7b5                	bnez	a5,80001e7a <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e10:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e12:	00010917          	auipc	s2,0x10
    80001e16:	75e90913          	addi	s2,s2,1886 # 80012570 <pid_lock>
    80001e1a:	2781                	sext.w	a5,a5
    80001e1c:	079e                	slli	a5,a5,0x7
    80001e1e:	97ca                	add	a5,a5,s2
    80001e20:	0ac7a983          	lw	s3,172(a5)
    80001e24:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e26:	2781                	sext.w	a5,a5
    80001e28:	079e                	slli	a5,a5,0x7
    80001e2a:	00010597          	auipc	a1,0x10
    80001e2e:	77e58593          	addi	a1,a1,1918 # 800125a8 <cpus+0x8>
    80001e32:	95be                	add	a1,a1,a5
    80001e34:	06848513          	addi	a0,s1,104
    80001e38:	7c2000ef          	jal	800025fa <swtch>
    80001e3c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e3e:	2781                	sext.w	a5,a5
    80001e40:	079e                	slli	a5,a5,0x7
    80001e42:	993e                	add	s2,s2,a5
    80001e44:	0b392623          	sw	s3,172(s2)
}
    80001e48:	70a2                	ld	ra,40(sp)
    80001e4a:	7402                	ld	s0,32(sp)
    80001e4c:	64e2                	ld	s1,24(sp)
    80001e4e:	6942                	ld	s2,16(sp)
    80001e50:	69a2                	ld	s3,8(sp)
    80001e52:	6145                	addi	sp,sp,48
    80001e54:	8082                	ret
    panic("sched p->lock");
    80001e56:	00005517          	auipc	a0,0x5
    80001e5a:	3e250513          	addi	a0,a0,994 # 80007238 <etext+0x238>
    80001e5e:	937fe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001e62:	00005517          	auipc	a0,0x5
    80001e66:	3e650513          	addi	a0,a0,998 # 80007248 <etext+0x248>
    80001e6a:	92bfe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001e6e:	00005517          	auipc	a0,0x5
    80001e72:	3ea50513          	addi	a0,a0,1002 # 80007258 <etext+0x258>
    80001e76:	91ffe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001e7a:	00005517          	auipc	a0,0x5
    80001e7e:	3ee50513          	addi	a0,a0,1006 # 80007268 <etext+0x268>
    80001e82:	913fe0ef          	jal	80000794 <panic>

0000000080001e86 <yield>:
{
    80001e86:	1101                	addi	sp,sp,-32
    80001e88:	ec06                	sd	ra,24(sp)
    80001e8a:	e822                	sd	s0,16(sp)
    80001e8c:	e426                	sd	s1,8(sp)
    80001e8e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e90:	a51ff0ef          	jal	800018e0 <myproc>
    80001e94:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e96:	d5ffe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001e9a:	478d                	li	a5,3
    80001e9c:	cc9c                	sw	a5,24(s1)
  sched();
    80001e9e:	f2fff0ef          	jal	80001dcc <sched>
  release(&p->lock);
    80001ea2:	8526                	mv	a0,s1
    80001ea4:	de9fe0ef          	jal	80000c8c <release>
}
    80001ea8:	60e2                	ld	ra,24(sp)
    80001eaa:	6442                	ld	s0,16(sp)
    80001eac:	64a2                	ld	s1,8(sp)
    80001eae:	6105                	addi	sp,sp,32
    80001eb0:	8082                	ret

0000000080001eb2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001eb2:	7179                	addi	sp,sp,-48
    80001eb4:	f406                	sd	ra,40(sp)
    80001eb6:	f022                	sd	s0,32(sp)
    80001eb8:	ec26                	sd	s1,24(sp)
    80001eba:	e84a                	sd	s2,16(sp)
    80001ebc:	e44e                	sd	s3,8(sp)
    80001ebe:	1800                	addi	s0,sp,48
    80001ec0:	89aa                	mv	s3,a0
    80001ec2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001ec4:	a1dff0ef          	jal	800018e0 <myproc>
    80001ec8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001eca:	d2bfe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001ece:	854a                	mv	a0,s2
    80001ed0:	dbdfe0ef          	jal	80000c8c <release>
  // Go to sleep.
  p->chan = chan;
    80001ed4:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001ed8:	4789                	li	a5,2
    80001eda:	cc9c                	sw	a5,24(s1)

  sched();
    80001edc:	ef1ff0ef          	jal	80001dcc <sched>

  // Tidy up.
  p->chan = 0;
    80001ee0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	da7fe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001eea:	854a                	mv	a0,s2
    80001eec:	d09fe0ef          	jal	80000bf4 <acquire>
}
    80001ef0:	70a2                	ld	ra,40(sp)
    80001ef2:	7402                	ld	s0,32(sp)
    80001ef4:	64e2                	ld	s1,24(sp)
    80001ef6:	6942                	ld	s2,16(sp)
    80001ef8:	69a2                	ld	s3,8(sp)
    80001efa:	6145                	addi	sp,sp,48
    80001efc:	8082                	ret

0000000080001efe <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001efe:	7139                	addi	sp,sp,-64
    80001f00:	fc06                	sd	ra,56(sp)
    80001f02:	f822                	sd	s0,48(sp)
    80001f04:	f426                	sd	s1,40(sp)
    80001f06:	f04a                	sd	s2,32(sp)
    80001f08:	ec4e                	sd	s3,24(sp)
    80001f0a:	e852                	sd	s4,16(sp)
    80001f0c:	e456                	sd	s5,8(sp)
    80001f0e:	0080                	addi	s0,sp,64
    80001f10:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f12:	00011497          	auipc	s1,0x11
    80001f16:	a8e48493          	addi	s1,s1,-1394 # 800129a0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f1a:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f1c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f1e:	00016917          	auipc	s2,0x16
    80001f22:	68290913          	addi	s2,s2,1666 # 800185a0 <ptable>
    80001f26:	a801                	j	80001f36 <wakeup+0x38>
      }
      release(&p->lock);
    80001f28:	8526                	mv	a0,s1
    80001f2a:	d63fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f2e:	17048493          	addi	s1,s1,368
    80001f32:	03248263          	beq	s1,s2,80001f56 <wakeup+0x58>
    if(p != myproc()){
    80001f36:	9abff0ef          	jal	800018e0 <myproc>
    80001f3a:	fea48ae3          	beq	s1,a0,80001f2e <wakeup+0x30>
      acquire(&p->lock);
    80001f3e:	8526                	mv	a0,s1
    80001f40:	cb5fe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001f44:	4c9c                	lw	a5,24(s1)
    80001f46:	ff3791e3          	bne	a5,s3,80001f28 <wakeup+0x2a>
    80001f4a:	709c                	ld	a5,32(s1)
    80001f4c:	fd479ee3          	bne	a5,s4,80001f28 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f50:	0154ac23          	sw	s5,24(s1)
    80001f54:	bfd1                	j	80001f28 <wakeup+0x2a>
    }
  }
}
    80001f56:	70e2                	ld	ra,56(sp)
    80001f58:	7442                	ld	s0,48(sp)
    80001f5a:	74a2                	ld	s1,40(sp)
    80001f5c:	7902                	ld	s2,32(sp)
    80001f5e:	69e2                	ld	s3,24(sp)
    80001f60:	6a42                	ld	s4,16(sp)
    80001f62:	6aa2                	ld	s5,8(sp)
    80001f64:	6121                	addi	sp,sp,64
    80001f66:	8082                	ret

0000000080001f68 <reparent>:
void reparent(struct proc *p) {
    80001f68:	7139                	addi	sp,sp,-64
    80001f6a:	fc06                	sd	ra,56(sp)
    80001f6c:	f822                	sd	s0,48(sp)
    80001f6e:	f426                	sd	s1,40(sp)
    80001f70:	f04a                	sd	s2,32(sp)
    80001f72:	ec4e                	sd	s3,24(sp)
    80001f74:	e852                	sd	s4,16(sp)
    80001f76:	e456                	sd	s5,8(sp)
    80001f78:	0080                	addi	s0,sp,64
    80001f7a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++) {
    80001f7c:	00011497          	auipc	s1,0x11
    80001f80:	a2448493          	addi	s1,s1,-1500 # 800129a0 <proc>
      pp->parent = initproc;
    80001f84:	00008a17          	auipc	s4,0x8
    80001f88:	4b4a0a13          	addi	s4,s4,1204 # 8000a438 <initproc>
        pp->is_orphan = 1;  // Mark as orphan
    80001f8c:	4a85                	li	s5,1
  for(pp = proc; pp < &proc[NPROC]; pp++) {
    80001f8e:	00016997          	auipc	s3,0x16
    80001f92:	61298993          	addi	s3,s3,1554 # 800185a0 <ptable>
    80001f96:	a029                	j	80001fa0 <reparent+0x38>
    80001f98:	17048493          	addi	s1,s1,368
    80001f9c:	03348563          	beq	s1,s3,80001fc6 <reparent+0x5e>
    if(pp->parent == p) {
    80001fa0:	7c9c                	ld	a5,56(s1)
    80001fa2:	ff279be3          	bne	a5,s2,80001f98 <reparent+0x30>
      acquire(&pp->lock);
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	c4dfe0ef          	jal	80000bf4 <acquire>
      pp->parent = initproc;
    80001fac:	000a3783          	ld	a5,0(s4)
    80001fb0:	fc9c                	sd	a5,56(s1)
        pp->is_orphan = 1;  // Mark as orphan
    80001fb2:	0554a023          	sw	s5,64(s1)
        release(&pp->lock);
    80001fb6:	8526                	mv	a0,s1
    80001fb8:	cd5fe0ef          	jal	80000c8c <release>
      wakeup(initproc);
    80001fbc:	000a3503          	ld	a0,0(s4)
    80001fc0:	f3fff0ef          	jal	80001efe <wakeup>
    80001fc4:	bfd1                	j	80001f98 <reparent+0x30>
}
    80001fc6:	70e2                	ld	ra,56(sp)
    80001fc8:	7442                	ld	s0,48(sp)
    80001fca:	74a2                	ld	s1,40(sp)
    80001fcc:	7902                	ld	s2,32(sp)
    80001fce:	69e2                	ld	s3,24(sp)
    80001fd0:	6a42                	ld	s4,16(sp)
    80001fd2:	6aa2                	ld	s5,8(sp)
    80001fd4:	6121                	addi	sp,sp,64
    80001fd6:	8082                	ret

0000000080001fd8 <exit>:
{
    80001fd8:	7139                	addi	sp,sp,-64
    80001fda:	fc06                	sd	ra,56(sp)
    80001fdc:	f822                	sd	s0,48(sp)
    80001fde:	f426                	sd	s1,40(sp)
    80001fe0:	f04a                	sd	s2,32(sp)
    80001fe2:	ec4e                	sd	s3,24(sp)
    80001fe4:	e852                	sd	s4,16(sp)
    80001fe6:	e456                	sd	s5,8(sp)
    80001fe8:	e05a                	sd	s6,0(sp)
    80001fea:	0080                	addi	s0,sp,64
    80001fec:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001fee:	8f3ff0ef          	jal	800018e0 <myproc>
    80001ff2:	892a                	mv	s2,a0
  if(p == initproc)
    80001ff4:	00008797          	auipc	a5,0x8
    80001ff8:	4447b783          	ld	a5,1092(a5) # 8000a438 <initproc>
    80001ffc:	0d850493          	addi	s1,a0,216
    80002000:	15850a13          	addi	s4,a0,344
    if(p->parent != initproc) 
    80002004:	00008997          	auipc	s3,0x8
    80002008:	43498993          	addi	s3,s3,1076 # 8000a438 <initproc>
      p->is_orphan = 1;
    8000200c:	4a85                	li	s5,1
  if(p == initproc)
    8000200e:	02a79963          	bne	a5,a0,80002040 <exit+0x68>
    panic("init exiting");
    80002012:	00005517          	auipc	a0,0x5
    80002016:	26e50513          	addi	a0,a0,622 # 80007280 <etext+0x280>
    8000201a:	f7afe0ef          	jal	80000794 <panic>
     acquire(&p->lock);
    8000201e:	854a                	mv	a0,s2
    80002020:	bd5fe0ef          	jal	80000bf4 <acquire>
    if(p->parent != initproc) 
    80002024:	03893703          	ld	a4,56(s2)
    80002028:	0009b783          	ld	a5,0(s3)
    8000202c:	00f70463          	beq	a4,a5,80002034 <exit+0x5c>
      p->is_orphan = 1;
    80002030:	05592023          	sw	s5,64(s2)
    release(&p->lock);
    80002034:	854a                	mv	a0,s2
    80002036:	c57fe0ef          	jal	80000c8c <release>
  for(int fd = 0; fd < NOFILE; fd++){
    8000203a:	04a1                	addi	s1,s1,8
    8000203c:	01448963          	beq	s1,s4,8000204e <exit+0x76>
    if(p->ofile[fd]){
    80002040:	6088                	ld	a0,0(s1)
    80002042:	dd71                	beqz	a0,8000201e <exit+0x46>
      fileclose(f);
    80002044:	0f8020ef          	jal	8000413c <fileclose>
      p->ofile[fd] = 0;
    80002048:	0004b023          	sd	zero,0(s1)
    8000204c:	bfc9                	j	8000201e <exit+0x46>
  begin_op();
    8000204e:	4d5010ef          	jal	80003d22 <begin_op>
  iput(p->cwd);
    80002052:	15893503          	ld	a0,344(s2)
    80002056:	5b8010ef          	jal	8000360e <iput>
  end_op();
    8000205a:	533010ef          	jal	80003d8c <end_op>
  p->cwd = 0;
    8000205e:	14093c23          	sd	zero,344(s2)
  acquire(&wait_lock);
    80002062:	00010497          	auipc	s1,0x10
    80002066:	52648493          	addi	s1,s1,1318 # 80012588 <wait_lock>
    8000206a:	8526                	mv	a0,s1
    8000206c:	b89fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    80002070:	854a                	mv	a0,s2
    80002072:	ef7ff0ef          	jal	80001f68 <reparent>
  wakeup(p->parent);
    80002076:	03893503          	ld	a0,56(s2)
    8000207a:	e85ff0ef          	jal	80001efe <wakeup>
  acquire(&p->lock);
    8000207e:	854a                	mv	a0,s2
    80002080:	b75fe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    80002084:	03692623          	sw	s6,44(s2)
  p->state = ZOMBIE;
    80002088:	4795                	li	a5,5
    8000208a:	00f92c23          	sw	a5,24(s2)
  release(&wait_lock);
    8000208e:	8526                	mv	a0,s1
    80002090:	bfdfe0ef          	jal	80000c8c <release>
  sched();
    80002094:	d39ff0ef          	jal	80001dcc <sched>
  panic("zombie exit");
    80002098:	00005517          	auipc	a0,0x5
    8000209c:	1f850513          	addi	a0,a0,504 # 80007290 <etext+0x290>
    800020a0:	ef4fe0ef          	jal	80000794 <panic>

00000000800020a4 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800020a4:	7179                	addi	sp,sp,-48
    800020a6:	f406                	sd	ra,40(sp)
    800020a8:	f022                	sd	s0,32(sp)
    800020aa:	ec26                	sd	s1,24(sp)
    800020ac:	e84a                	sd	s2,16(sp)
    800020ae:	e44e                	sd	s3,8(sp)
    800020b0:	1800                	addi	s0,sp,48
    800020b2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020b4:	00011497          	auipc	s1,0x11
    800020b8:	8ec48493          	addi	s1,s1,-1812 # 800129a0 <proc>
    800020bc:	00016997          	auipc	s3,0x16
    800020c0:	4e498993          	addi	s3,s3,1252 # 800185a0 <ptable>
    acquire(&p->lock);
    800020c4:	8526                	mv	a0,s1
    800020c6:	b2ffe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    800020ca:	589c                	lw	a5,48(s1)
    800020cc:	01278b63          	beq	a5,s2,800020e2 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020d0:	8526                	mv	a0,s1
    800020d2:	bbbfe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800020d6:	17048493          	addi	s1,s1,368
    800020da:	ff3495e3          	bne	s1,s3,800020c4 <kill+0x20>
  }
  return -1;
    800020de:	557d                	li	a0,-1
    800020e0:	a819                	j	800020f6 <kill+0x52>
      p->killed = 1;
    800020e2:	4785                	li	a5,1
    800020e4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800020e6:	4c98                	lw	a4,24(s1)
    800020e8:	4789                	li	a5,2
    800020ea:	00f70d63          	beq	a4,a5,80002104 <kill+0x60>
      release(&p->lock);
    800020ee:	8526                	mv	a0,s1
    800020f0:	b9dfe0ef          	jal	80000c8c <release>
      return 0;
    800020f4:	4501                	li	a0,0
}
    800020f6:	70a2                	ld	ra,40(sp)
    800020f8:	7402                	ld	s0,32(sp)
    800020fa:	64e2                	ld	s1,24(sp)
    800020fc:	6942                	ld	s2,16(sp)
    800020fe:	69a2                	ld	s3,8(sp)
    80002100:	6145                	addi	sp,sp,48
    80002102:	8082                	ret
        p->state = RUNNABLE;
    80002104:	478d                	li	a5,3
    80002106:	cc9c                	sw	a5,24(s1)
    80002108:	b7dd                	j	800020ee <kill+0x4a>

000000008000210a <setkilled>:

void
setkilled(struct proc *p)
{
    8000210a:	1101                	addi	sp,sp,-32
    8000210c:	ec06                	sd	ra,24(sp)
    8000210e:	e822                	sd	s0,16(sp)
    80002110:	e426                	sd	s1,8(sp)
    80002112:	1000                	addi	s0,sp,32
    80002114:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002116:	adffe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    8000211a:	4785                	li	a5,1
    8000211c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000211e:	8526                	mv	a0,s1
    80002120:	b6dfe0ef          	jal	80000c8c <release>
}
    80002124:	60e2                	ld	ra,24(sp)
    80002126:	6442                	ld	s0,16(sp)
    80002128:	64a2                	ld	s1,8(sp)
    8000212a:	6105                	addi	sp,sp,32
    8000212c:	8082                	ret

000000008000212e <killed>:

int
killed(struct proc *p)
{
    8000212e:	1101                	addi	sp,sp,-32
    80002130:	ec06                	sd	ra,24(sp)
    80002132:	e822                	sd	s0,16(sp)
    80002134:	e426                	sd	s1,8(sp)
    80002136:	e04a                	sd	s2,0(sp)
    80002138:	1000                	addi	s0,sp,32
    8000213a:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000213c:	ab9fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002140:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002144:	8526                	mv	a0,s1
    80002146:	b47fe0ef          	jal	80000c8c <release>
  return k;
}
    8000214a:	854a                	mv	a0,s2
    8000214c:	60e2                	ld	ra,24(sp)
    8000214e:	6442                	ld	s0,16(sp)
    80002150:	64a2                	ld	s1,8(sp)
    80002152:	6902                	ld	s2,0(sp)
    80002154:	6105                	addi	sp,sp,32
    80002156:	8082                	ret

0000000080002158 <wait>:
{
    80002158:	715d                	addi	sp,sp,-80
    8000215a:	e486                	sd	ra,72(sp)
    8000215c:	e0a2                	sd	s0,64(sp)
    8000215e:	fc26                	sd	s1,56(sp)
    80002160:	f84a                	sd	s2,48(sp)
    80002162:	f44e                	sd	s3,40(sp)
    80002164:	f052                	sd	s4,32(sp)
    80002166:	ec56                	sd	s5,24(sp)
    80002168:	e85a                	sd	s6,16(sp)
    8000216a:	e45e                	sd	s7,8(sp)
    8000216c:	e062                	sd	s8,0(sp)
    8000216e:	0880                	addi	s0,sp,80
    80002170:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002172:	f6eff0ef          	jal	800018e0 <myproc>
    80002176:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002178:	00010517          	auipc	a0,0x10
    8000217c:	41050513          	addi	a0,a0,1040 # 80012588 <wait_lock>
    80002180:	a75fe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    80002184:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80002186:	4a15                	li	s4,5
        havekids = 1;
    80002188:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000218a:	00016997          	auipc	s3,0x16
    8000218e:	41698993          	addi	s3,s3,1046 # 800185a0 <ptable>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002192:	00010c17          	auipc	s8,0x10
    80002196:	3f6c0c13          	addi	s8,s8,1014 # 80012588 <wait_lock>
    8000219a:	a871                	j	80002236 <wait+0xde>
          pid = pp->pid;
    8000219c:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021a0:	000b0c63          	beqz	s6,800021b8 <wait+0x60>
    800021a4:	4691                	li	a3,4
    800021a6:	02c48613          	addi	a2,s1,44
    800021aa:	85da                	mv	a1,s6
    800021ac:	05893503          	ld	a0,88(s2)
    800021b0:	ba2ff0ef          	jal	80001552 <copyout>
    800021b4:	02054b63          	bltz	a0,800021ea <wait+0x92>
          freeproc(pp);
    800021b8:	8526                	mv	a0,s1
    800021ba:	899ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    800021be:	8526                	mv	a0,s1
    800021c0:	acdfe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    800021c4:	00010517          	auipc	a0,0x10
    800021c8:	3c450513          	addi	a0,a0,964 # 80012588 <wait_lock>
    800021cc:	ac1fe0ef          	jal	80000c8c <release>
}
    800021d0:	854e                	mv	a0,s3
    800021d2:	60a6                	ld	ra,72(sp)
    800021d4:	6406                	ld	s0,64(sp)
    800021d6:	74e2                	ld	s1,56(sp)
    800021d8:	7942                	ld	s2,48(sp)
    800021da:	79a2                	ld	s3,40(sp)
    800021dc:	7a02                	ld	s4,32(sp)
    800021de:	6ae2                	ld	s5,24(sp)
    800021e0:	6b42                	ld	s6,16(sp)
    800021e2:	6ba2                	ld	s7,8(sp)
    800021e4:	6c02                	ld	s8,0(sp)
    800021e6:	6161                	addi	sp,sp,80
    800021e8:	8082                	ret
            release(&pp->lock);
    800021ea:	8526                	mv	a0,s1
    800021ec:	aa1fe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    800021f0:	00010517          	auipc	a0,0x10
    800021f4:	39850513          	addi	a0,a0,920 # 80012588 <wait_lock>
    800021f8:	a95fe0ef          	jal	80000c8c <release>
            return -1;
    800021fc:	59fd                	li	s3,-1
    800021fe:	bfc9                	j	800021d0 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002200:	17048493          	addi	s1,s1,368
    80002204:	03348063          	beq	s1,s3,80002224 <wait+0xcc>
      if(pp->parent == p){
    80002208:	7c9c                	ld	a5,56(s1)
    8000220a:	ff279be3          	bne	a5,s2,80002200 <wait+0xa8>
        acquire(&pp->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	9e5fe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    80002214:	4c9c                	lw	a5,24(s1)
    80002216:	f94783e3          	beq	a5,s4,8000219c <wait+0x44>
        release(&pp->lock);
    8000221a:	8526                	mv	a0,s1
    8000221c:	a71fe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002220:	8756                	mv	a4,s5
    80002222:	bff9                	j	80002200 <wait+0xa8>
    if(!havekids || killed(p)){
    80002224:	cf19                	beqz	a4,80002242 <wait+0xea>
    80002226:	854a                	mv	a0,s2
    80002228:	f07ff0ef          	jal	8000212e <killed>
    8000222c:	e919                	bnez	a0,80002242 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000222e:	85e2                	mv	a1,s8
    80002230:	854a                	mv	a0,s2
    80002232:	c81ff0ef          	jal	80001eb2 <sleep>
    havekids = 0;
    80002236:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002238:	00010497          	auipc	s1,0x10
    8000223c:	76848493          	addi	s1,s1,1896 # 800129a0 <proc>
    80002240:	b7e1                	j	80002208 <wait+0xb0>
      release(&wait_lock);
    80002242:	00010517          	auipc	a0,0x10
    80002246:	34650513          	addi	a0,a0,838 # 80012588 <wait_lock>
    8000224a:	a43fe0ef          	jal	80000c8c <release>
      return -1;
    8000224e:	59fd                	li	s3,-1
    80002250:	b741                	j	800021d0 <wait+0x78>

0000000080002252 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002252:	7179                	addi	sp,sp,-48
    80002254:	f406                	sd	ra,40(sp)
    80002256:	f022                	sd	s0,32(sp)
    80002258:	ec26                	sd	s1,24(sp)
    8000225a:	e84a                	sd	s2,16(sp)
    8000225c:	e44e                	sd	s3,8(sp)
    8000225e:	e052                	sd	s4,0(sp)
    80002260:	1800                	addi	s0,sp,48
    80002262:	84aa                	mv	s1,a0
    80002264:	892e                	mv	s2,a1
    80002266:	89b2                	mv	s3,a2
    80002268:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000226a:	e76ff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    8000226e:	cc99                	beqz	s1,8000228c <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002270:	86d2                	mv	a3,s4
    80002272:	864e                	mv	a2,s3
    80002274:	85ca                	mv	a1,s2
    80002276:	6d28                	ld	a0,88(a0)
    80002278:	adaff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000227c:	70a2                	ld	ra,40(sp)
    8000227e:	7402                	ld	s0,32(sp)
    80002280:	64e2                	ld	s1,24(sp)
    80002282:	6942                	ld	s2,16(sp)
    80002284:	69a2                	ld	s3,8(sp)
    80002286:	6a02                	ld	s4,0(sp)
    80002288:	6145                	addi	sp,sp,48
    8000228a:	8082                	ret
    memmove((char *)dst, src, len);
    8000228c:	000a061b          	sext.w	a2,s4
    80002290:	85ce                	mv	a1,s3
    80002292:	854a                	mv	a0,s2
    80002294:	a91fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002298:	8526                	mv	a0,s1
    8000229a:	b7cd                	j	8000227c <either_copyout+0x2a>

000000008000229c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000229c:	7179                	addi	sp,sp,-48
    8000229e:	f406                	sd	ra,40(sp)
    800022a0:	f022                	sd	s0,32(sp)
    800022a2:	ec26                	sd	s1,24(sp)
    800022a4:	e84a                	sd	s2,16(sp)
    800022a6:	e44e                	sd	s3,8(sp)
    800022a8:	e052                	sd	s4,0(sp)
    800022aa:	1800                	addi	s0,sp,48
    800022ac:	892a                	mv	s2,a0
    800022ae:	84ae                	mv	s1,a1
    800022b0:	89b2                	mv	s3,a2
    800022b2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022b4:	e2cff0ef          	jal	800018e0 <myproc>
  if(user_src){
    800022b8:	cc99                	beqz	s1,800022d6 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022ba:	86d2                	mv	a3,s4
    800022bc:	864e                	mv	a2,s3
    800022be:	85ca                	mv	a1,s2
    800022c0:	6d28                	ld	a0,88(a0)
    800022c2:	b66ff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022c6:	70a2                	ld	ra,40(sp)
    800022c8:	7402                	ld	s0,32(sp)
    800022ca:	64e2                	ld	s1,24(sp)
    800022cc:	6942                	ld	s2,16(sp)
    800022ce:	69a2                	ld	s3,8(sp)
    800022d0:	6a02                	ld	s4,0(sp)
    800022d2:	6145                	addi	sp,sp,48
    800022d4:	8082                	ret
    memmove(dst, (char*)src, len);
    800022d6:	000a061b          	sext.w	a2,s4
    800022da:	85ce                	mv	a1,s3
    800022dc:	854a                	mv	a0,s2
    800022de:	a47fe0ef          	jal	80000d24 <memmove>
    return 0;
    800022e2:	8526                	mv	a0,s1
    800022e4:	b7cd                	j	800022c6 <either_copyin+0x2a>

00000000800022e6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022e6:	715d                	addi	sp,sp,-80
    800022e8:	e486                	sd	ra,72(sp)
    800022ea:	e0a2                	sd	s0,64(sp)
    800022ec:	fc26                	sd	s1,56(sp)
    800022ee:	f84a                	sd	s2,48(sp)
    800022f0:	f44e                	sd	s3,40(sp)
    800022f2:	f052                	sd	s4,32(sp)
    800022f4:	ec56                	sd	s5,24(sp)
    800022f6:	e85a                	sd	s6,16(sp)
    800022f8:	e45e                	sd	s7,8(sp)
    800022fa:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800022fc:	00005517          	auipc	a0,0x5
    80002300:	d7c50513          	addi	a0,a0,-644 # 80007078 <etext+0x78>
    80002304:	9befe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002308:	00010497          	auipc	s1,0x10
    8000230c:	7f848493          	addi	s1,s1,2040 # 80012b00 <proc+0x160>
    80002310:	00016917          	auipc	s2,0x16
    80002314:	3f090913          	addi	s2,s2,1008 # 80018700 <ptable+0x160>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002318:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000231a:	00005997          	auipc	s3,0x5
    8000231e:	f8698993          	addi	s3,s3,-122 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002322:	00005a97          	auipc	s5,0x5
    80002326:	f86a8a93          	addi	s5,s5,-122 # 800072a8 <etext+0x2a8>
    printf("\n");
    8000232a:	00005a17          	auipc	s4,0x5
    8000232e:	d4ea0a13          	addi	s4,s4,-690 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002332:	00005b97          	auipc	s7,0x5
    80002336:	55eb8b93          	addi	s7,s7,1374 # 80007890 <states.1>
    8000233a:	a829                	j	80002354 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000233c:	ed06a583          	lw	a1,-304(a3)
    80002340:	8556                	mv	a0,s5
    80002342:	980fe0ef          	jal	800004c2 <printf>
    printf("\n");
    80002346:	8552                	mv	a0,s4
    80002348:	97afe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234c:	17048493          	addi	s1,s1,368
    80002350:	03248263          	beq	s1,s2,80002374 <procdump+0x8e>
    if(p->state == UNUSED)
    80002354:	86a6                	mv	a3,s1
    80002356:	eb84a783          	lw	a5,-328(s1)
    8000235a:	dbed                	beqz	a5,8000234c <procdump+0x66>
      state = "???";
    8000235c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000235e:	fcfb6fe3          	bltu	s6,a5,8000233c <procdump+0x56>
    80002362:	02079713          	slli	a4,a5,0x20
    80002366:	01d75793          	srli	a5,a4,0x1d
    8000236a:	97de                	add	a5,a5,s7
    8000236c:	6390                	ld	a2,0(a5)
    8000236e:	f679                	bnez	a2,8000233c <procdump+0x56>
      state = "???";
    80002370:	864e                	mv	a2,s3
    80002372:	b7e9                	j	8000233c <procdump+0x56>
  }
}
    80002374:	60a6                	ld	ra,72(sp)
    80002376:	6406                	ld	s0,64(sp)
    80002378:	74e2                	ld	s1,56(sp)
    8000237a:	7942                	ld	s2,48(sp)
    8000237c:	79a2                	ld	s3,40(sp)
    8000237e:	7a02                	ld	s4,32(sp)
    80002380:	6ae2                	ld	s5,24(sp)
    80002382:	6b42                	ld	s6,16(sp)
    80002384:	6ba2                	ld	s7,8(sp)
    80002386:	6161                	addi	sp,sp,80
    80002388:	8082                	ret

000000008000238a <get_state_color>:
const char* get_state_color(enum procstate state) {
    8000238a:	1141                	addi	sp,sp,-16
    8000238c:	e422                	sd	s0,8(sp)
    8000238e:	0800                	addi	s0,sp,16
    switch (state) {
    80002390:	4795                	li	a5,5
    80002392:	04a7e663          	bltu	a5,a0,800023de <get_state_color+0x54>
    80002396:	050a                	slli	a0,a0,0x2
    80002398:	00005717          	auipc	a4,0x5
    8000239c:	4e070713          	addi	a4,a4,1248 # 80007878 <digits+0x18>
    800023a0:	953a                	add	a0,a0,a4
    800023a2:	411c                	lw	a5,0(a0)
    800023a4:	97ba                	add	a5,a5,a4
    800023a6:	8782                	jr	a5
        case UNUSED:   return COLOR_UNUSED;
    800023a8:	00005517          	auipc	a0,0x5
    800023ac:	f1050513          	addi	a0,a0,-240 # 800072b8 <etext+0x2b8>
        case RUNNABLE: return COLOR_RUNNABLE;
        case RUNNING:  return COLOR_RUNNING;
        case ZOMBIE:   return COLOR_ZOMBIE;
        default:       return COLOR_RESET;
    }
}
    800023b0:	6422                	ld	s0,8(sp)
    800023b2:	0141                	addi	sp,sp,16
    800023b4:	8082                	ret
        case SLEEPING: return COLOR_SLEEPING;
    800023b6:	00005517          	auipc	a0,0x5
    800023ba:	f1250513          	addi	a0,a0,-238 # 800072c8 <etext+0x2c8>
    800023be:	bfcd                	j	800023b0 <get_state_color+0x26>
        case RUNNABLE: return COLOR_RUNNABLE;
    800023c0:	00005517          	auipc	a0,0x5
    800023c4:	f1050513          	addi	a0,a0,-240 # 800072d0 <etext+0x2d0>
    800023c8:	b7e5                	j	800023b0 <get_state_color+0x26>
        case RUNNING:  return COLOR_RUNNING;
    800023ca:	00005517          	auipc	a0,0x5
    800023ce:	f0e50513          	addi	a0,a0,-242 # 800072d8 <etext+0x2d8>
    800023d2:	bff9                	j	800023b0 <get_state_color+0x26>
        case ZOMBIE:   return COLOR_ZOMBIE;
    800023d4:	00005517          	auipc	a0,0x5
    800023d8:	f0c50513          	addi	a0,a0,-244 # 800072e0 <etext+0x2e0>
    800023dc:	bfd1                	j	800023b0 <get_state_color+0x26>
        default:       return COLOR_RESET;
    800023de:	00005517          	auipc	a0,0x5
    800023e2:	f0a50513          	addi	a0,a0,-246 # 800072e8 <etext+0x2e8>
    800023e6:	b7e9                	j	800023b0 <get_state_color+0x26>
    switch (state) {
    800023e8:	00005517          	auipc	a0,0x5
    800023ec:	ed850513          	addi	a0,a0,-296 # 800072c0 <etext+0x2c0>
    800023f0:	b7c1                	j	800023b0 <get_state_color+0x26>

00000000800023f2 <print_tree_ascii>:
  release(&ptable.lock);
  return 0;
}


void print_tree_ascii(struct proc *p, int depth, int is_last) {
    800023f2:	7139                	addi	sp,sp,-64
    800023f4:	fc06                	sd	ra,56(sp)
    800023f6:	f822                	sd	s0,48(sp)
    800023f8:	0080                	addi	s0,sp,64
        [SLEEPING]  "sleep",
        [RUNNABLE]  "runble",
        [RUNNING]   "run",
        [ZOMBIE]    "ZOMBIE" 
    };
    if(depth > 64) {
    800023fa:	04000793          	li	a5,64
    800023fe:	0cb7c863          	blt	a5,a1,800024ce <print_tree_ascii+0xdc>
    80002402:	f04a                	sd	s2,32(sp)
    80002404:	ec4e                	sd	s3,24(sp)
    80002406:	e05a                	sd	s6,0(sp)
    80002408:	892a                	mv	s2,a0
    8000240a:	89ae                	mv	s3,a1
    8000240c:	8b32                	mv	s6,a2
        printf("Max depth exceeded\n");
        return;
    }
    if(p < proc || p >= &proc[NPROC]) {
    8000240e:	00010797          	auipc	a5,0x10
    80002412:	59278793          	addi	a5,a5,1426 # 800129a0 <proc>
    80002416:	0cf56363          	bltu	a0,a5,800024dc <print_tree_ascii+0xea>
    8000241a:	00016797          	auipc	a5,0x16
    8000241e:	18678793          	addi	a5,a5,390 # 800185a0 <ptable>
    80002422:	0af57d63          	bgeu	a0,a5,800024dc <print_tree_ascii+0xea>
    80002426:	f426                	sd	s1,40(sp)
    80002428:	e852                	sd	s4,16(sp)
    8000242a:	e456                	sd	s5,8(sp)
        printf("Invalid process pointer\n");
        return;
    }
    for (int i = 0; i < depth - 1; i++)
    8000242c:	4785                	li	a5,1
    8000242e:	fff58a9b          	addiw	s5,a1,-1
    80002432:	4481                	li	s1,0
        printf("│   ");
    80002434:	00005a17          	auipc	s4,0x5
    80002438:	f14a0a13          	addi	s4,s4,-236 # 80007348 <etext+0x348>
    for (int i = 0; i < depth - 1; i++)
    8000243c:	0ab7da63          	bge	a5,a1,800024f0 <print_tree_ascii+0xfe>
        printf("│   ");
    80002440:	8552                	mv	a0,s4
    80002442:	880fe0ef          	jal	800004c2 <printf>
    for (int i = 0; i < depth - 1; i++)
    80002446:	2485                	addiw	s1,s1,1
    80002448:	ff549ce3          	bne	s1,s5,80002440 <print_tree_ascii+0x4e>
    if (depth > 0)
        printf(is_last ? "└── " : "├── ");
    8000244c:	00005517          	auipc	a0,0x5
    80002450:	eb450513          	addi	a0,a0,-332 # 80007300 <etext+0x300>
    80002454:	000b0663          	beqz	s6,80002460 <print_tree_ascii+0x6e>
    80002458:	00005517          	auipc	a0,0x5
    8000245c:	e9850513          	addi	a0,a0,-360 # 800072f0 <etext+0x2f0>
    80002460:	862fe0ef          	jal	800004c2 <printf>

    char *state = (p->state >= 0 && p->state < NELEM(states)) ? states[p->state] : "???";
    80002464:	01892503          	lw	a0,24(s2)
    80002468:	4795                	li	a5,5
    8000246a:	00005497          	auipc	s1,0x5
    8000246e:	e3648493          	addi	s1,s1,-458 # 800072a0 <etext+0x2a0>
    80002472:	00a7ec63          	bltu	a5,a0,8000248a <print_tree_ascii+0x98>
    80002476:	02051793          	slli	a5,a0,0x20
    8000247a:	01d7d713          	srli	a4,a5,0x1d
    8000247e:	00005797          	auipc	a5,0x5
    80002482:	41278793          	addi	a5,a5,1042 # 80007890 <states.1>
    80002486:	97ba                	add	a5,a5,a4
    80002488:	7b84                	ld	s1,48(a5)
    const char *color = get_state_color(p->state);
    8000248a:	f01ff0ef          	jal	8000238a <get_state_color>
    8000248e:	86aa                	mv	a3,a0
    printf("%d %s [%s%s%s]", p->pid, p->name, color, state, COLOR_RESET);
    80002490:	00005797          	auipc	a5,0x5
    80002494:	e5878793          	addi	a5,a5,-424 # 800072e8 <etext+0x2e8>
    80002498:	8726                	mv	a4,s1
    8000249a:	16090613          	addi	a2,s2,352
    8000249e:	03092583          	lw	a1,48(s2)
    800024a2:	00005517          	auipc	a0,0x5
    800024a6:	eae50513          	addi	a0,a0,-338 # 80007350 <etext+0x350>
    800024aa:	818fe0ef          	jal	800004c2 <printf>
    printf("\n");
    800024ae:	00005517          	auipc	a0,0x5
    800024b2:	bca50513          	addi	a0,a0,-1078 # 80007078 <etext+0x78>
    800024b6:	80cfe0ef          	jal	800004c2 <printf>



    int children = 0;
    for (struct proc *c = proc; c < &proc[NPROC]; c++)
    800024ba:	00010797          	auipc	a5,0x10
    800024be:	4e678793          	addi	a5,a5,1254 # 800129a0 <proc>
    int children = 0;
    800024c2:	4a01                	li	s4,0
    for (struct proc *c = proc; c < &proc[NPROC]; c++)
    800024c4:	00016697          	auipc	a3,0x16
    800024c8:	0dc68693          	addi	a3,a3,220 # 800185a0 <ptable>
    800024cc:	a80d                	j	800024fe <print_tree_ascii+0x10c>
        printf("Max depth exceeded\n");
    800024ce:	00005517          	auipc	a0,0x5
    800024d2:	e4250513          	addi	a0,a0,-446 # 80007310 <etext+0x310>
    800024d6:	fedfd0ef          	jal	800004c2 <printf>
        return;
    800024da:	a8b5                	j	80002556 <print_tree_ascii+0x164>
        printf("Invalid process pointer\n");
    800024dc:	00005517          	auipc	a0,0x5
    800024e0:	e4c50513          	addi	a0,a0,-436 # 80007328 <etext+0x328>
    800024e4:	fdffd0ef          	jal	800004c2 <printf>
        return;
    800024e8:	7902                	ld	s2,32(sp)
    800024ea:	69e2                	ld	s3,24(sp)
    800024ec:	6b02                	ld	s6,0(sp)
    800024ee:	a0a5                	j	80002556 <print_tree_ascii+0x164>
    if (depth > 0)
    800024f0:	f6b05ae3          	blez	a1,80002464 <print_tree_ascii+0x72>
    800024f4:	bfa1                	j	8000244c <print_tree_ascii+0x5a>
    for (struct proc *c = proc; c < &proc[NPROC]; c++)
    800024f6:	17078793          	addi	a5,a5,368
    800024fa:	00d78963          	beq	a5,a3,8000250c <print_tree_ascii+0x11a>
        if (c->parent == p && c->state != UNUSED)
    800024fe:	7f98                	ld	a4,56(a5)
    80002500:	ff271be3          	bne	a4,s2,800024f6 <print_tree_ascii+0x104>
    80002504:	4f98                	lw	a4,24(a5)
    80002506:	db65                	beqz	a4,800024f6 <print_tree_ascii+0x104>
            children++;
    80002508:	2a05                	addiw	s4,s4,1
    8000250a:	b7f5                	j	800024f6 <print_tree_ascii+0x104>

    int count = 0;
    for (struct proc *c = proc; c < &proc[NPROC]; c++) {
    8000250c:	00010497          	auipc	s1,0x10
    80002510:	49448493          	addi	s1,s1,1172 # 800129a0 <proc>
    int count = 0;
    80002514:	4b01                	li	s6,0
        if (c->parent == p && c->state != UNUSED) {
            count++;
            print_tree_ascii(c, depth + 1, count == children);
    80002516:	00198a9b          	addiw	s5,s3,1
    for (struct proc *c = proc; c < &proc[NPROC]; c++) {
    8000251a:	00016997          	auipc	s3,0x16
    8000251e:	08698993          	addi	s3,s3,134 # 800185a0 <ptable>
    80002522:	a029                	j	8000252c <print_tree_ascii+0x13a>
    80002524:	17048493          	addi	s1,s1,368
    80002528:	03348163          	beq	s1,s3,8000254a <print_tree_ascii+0x158>
        if (c->parent == p && c->state != UNUSED) {
    8000252c:	7c9c                	ld	a5,56(s1)
    8000252e:	ff279be3          	bne	a5,s2,80002524 <print_tree_ascii+0x132>
    80002532:	4c9c                	lw	a5,24(s1)
    80002534:	dbe5                	beqz	a5,80002524 <print_tree_ascii+0x132>
            count++;
    80002536:	2b05                	addiw	s6,s6,1
            print_tree_ascii(c, depth + 1, count == children);
    80002538:	416a0633          	sub	a2,s4,s6
    8000253c:	00163613          	seqz	a2,a2
    80002540:	85d6                	mv	a1,s5
    80002542:	8526                	mv	a0,s1
    80002544:	eafff0ef          	jal	800023f2 <print_tree_ascii>
    80002548:	bff1                	j	80002524 <print_tree_ascii+0x132>
    8000254a:	74a2                	ld	s1,40(sp)
    8000254c:	7902                	ld	s2,32(sp)
    8000254e:	69e2                	ld	s3,24(sp)
    80002550:	6a42                	ld	s4,16(sp)
    80002552:	6aa2                	ld	s5,8(sp)
    80002554:	6b02                	ld	s6,0(sp)
        }
    }
    80002556:	70e2                	ld	ra,56(sp)
    80002558:	7442                	ld	s0,48(sp)
    8000255a:	6121                	addi	sp,sp,64
    8000255c:	8082                	ret

000000008000255e <pstree>:
int pstree(void) {
    8000255e:	1101                	addi	sp,sp,-32
    80002560:	ec06                	sd	ra,24(sp)
    80002562:	e822                	sd	s0,16(sp)
    80002564:	e426                	sd	s1,8(sp)
    80002566:	1000                	addi	s0,sp,32
  printf("Process Tree:\n");
    80002568:	00005517          	auipc	a0,0x5
    8000256c:	df850513          	addi	a0,a0,-520 # 80007360 <etext+0x360>
    80002570:	f53fd0ef          	jal	800004c2 <printf>
  acquire(&wait_lock); // process lock
    80002574:	00010517          	auipc	a0,0x10
    80002578:	01450513          	addi	a0,a0,20 # 80012588 <wait_lock>
    8000257c:	e78fe0ef          	jal	80000bf4 <acquire>
  acquire(&ptable.lock); // ptable lock
    80002580:	00016517          	auipc	a0,0x16
    80002584:	02050513          	addi	a0,a0,32 # 800185a0 <ptable>
    80002588:	e6cfe0ef          	jal	80000bf4 <acquire>
  for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    8000258c:	00010497          	auipc	s1,0x10
    80002590:	41448493          	addi	s1,s1,1044 # 800129a0 <proc>
    if (p->pid == 1 && p->state != UNUSED) { 
    80002594:	4705                	li	a4,1
  for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    80002596:	00016697          	auipc	a3,0x16
    8000259a:	00a68693          	addi	a3,a3,10 # 800185a0 <ptable>
    8000259e:	a839                	j	800025bc <pstree+0x5e>
        printf("  (Zombie detected: %d %s)\n", p->pid, p->name);
    800025a0:	16048613          	addi	a2,s1,352
    800025a4:	4585                	li	a1,1
    800025a6:	00005517          	auipc	a0,0x5
    800025aa:	dca50513          	addi	a0,a0,-566 # 80007370 <etext+0x370>
    800025ae:	f15fd0ef          	jal	800004c2 <printf>
    800025b2:	a829                	j	800025cc <pstree+0x6e>
  for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    800025b4:	17048493          	addi	s1,s1,368
    800025b8:	00d48f63          	beq	s1,a3,800025d6 <pstree+0x78>
    if (p->pid == 1 && p->state != UNUSED) { 
    800025bc:	589c                	lw	a5,48(s1)
    800025be:	fee79be3          	bne	a5,a4,800025b4 <pstree+0x56>
    800025c2:	4c9c                	lw	a5,24(s1)
    800025c4:	dbe5                	beqz	a5,800025b4 <pstree+0x56>
      if (p->state == ZOMBIE)
    800025c6:	4715                	li	a4,5
    800025c8:	fce78ce3          	beq	a5,a4,800025a0 <pstree+0x42>
      print_tree_ascii(p, 0, 1);
    800025cc:	4605                	li	a2,1
    800025ce:	4581                	li	a1,0
    800025d0:	8526                	mv	a0,s1
    800025d2:	e21ff0ef          	jal	800023f2 <print_tree_ascii>
  release(&wait_lock);
    800025d6:	00010517          	auipc	a0,0x10
    800025da:	fb250513          	addi	a0,a0,-78 # 80012588 <wait_lock>
    800025de:	eaefe0ef          	jal	80000c8c <release>
  release(&ptable.lock);
    800025e2:	00016517          	auipc	a0,0x16
    800025e6:	fbe50513          	addi	a0,a0,-66 # 800185a0 <ptable>
    800025ea:	ea2fe0ef          	jal	80000c8c <release>
}
    800025ee:	4501                	li	a0,0
    800025f0:	60e2                	ld	ra,24(sp)
    800025f2:	6442                	ld	s0,16(sp)
    800025f4:	64a2                	ld	s1,8(sp)
    800025f6:	6105                	addi	sp,sp,32
    800025f8:	8082                	ret

00000000800025fa <swtch>:
    800025fa:	00153023          	sd	ra,0(a0)
    800025fe:	00253423          	sd	sp,8(a0)
    80002602:	e900                	sd	s0,16(a0)
    80002604:	ed04                	sd	s1,24(a0)
    80002606:	03253023          	sd	s2,32(a0)
    8000260a:	03353423          	sd	s3,40(a0)
    8000260e:	03453823          	sd	s4,48(a0)
    80002612:	03553c23          	sd	s5,56(a0)
    80002616:	05653023          	sd	s6,64(a0)
    8000261a:	05753423          	sd	s7,72(a0)
    8000261e:	05853823          	sd	s8,80(a0)
    80002622:	05953c23          	sd	s9,88(a0)
    80002626:	07a53023          	sd	s10,96(a0)
    8000262a:	07b53423          	sd	s11,104(a0)
    8000262e:	0005b083          	ld	ra,0(a1)
    80002632:	0085b103          	ld	sp,8(a1)
    80002636:	6980                	ld	s0,16(a1)
    80002638:	6d84                	ld	s1,24(a1)
    8000263a:	0205b903          	ld	s2,32(a1)
    8000263e:	0285b983          	ld	s3,40(a1)
    80002642:	0305ba03          	ld	s4,48(a1)
    80002646:	0385ba83          	ld	s5,56(a1)
    8000264a:	0405bb03          	ld	s6,64(a1)
    8000264e:	0485bb83          	ld	s7,72(a1)
    80002652:	0505bc03          	ld	s8,80(a1)
    80002656:	0585bc83          	ld	s9,88(a1)
    8000265a:	0605bd03          	ld	s10,96(a1)
    8000265e:	0685bd83          	ld	s11,104(a1)
    80002662:	8082                	ret

0000000080002664 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002664:	1141                	addi	sp,sp,-16
    80002666:	e406                	sd	ra,8(sp)
    80002668:	e022                	sd	s0,0(sp)
    8000266a:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000266c:	00005597          	auipc	a1,0x5
    80002670:	d6c58593          	addi	a1,a1,-660 # 800073d8 <etext+0x3d8>
    80002674:	0001c517          	auipc	a0,0x1c
    80002678:	b4450513          	addi	a0,a0,-1212 # 8001e1b8 <tickslock>
    8000267c:	cf8fe0ef          	jal	80000b74 <initlock>
}
    80002680:	60a2                	ld	ra,8(sp)
    80002682:	6402                	ld	s0,0(sp)
    80002684:	0141                	addi	sp,sp,16
    80002686:	8082                	ret

0000000080002688 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002688:	1141                	addi	sp,sp,-16
    8000268a:	e422                	sd	s0,8(sp)
    8000268c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000268e:	00003797          	auipc	a5,0x3
    80002692:	e2278793          	addi	a5,a5,-478 # 800054b0 <kernelvec>
    80002696:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000269a:	6422                	ld	s0,8(sp)
    8000269c:	0141                	addi	sp,sp,16
    8000269e:	8082                	ret

00000000800026a0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026a0:	1141                	addi	sp,sp,-16
    800026a2:	e406                	sd	ra,8(sp)
    800026a4:	e022                	sd	s0,0(sp)
    800026a6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026a8:	a38ff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ac:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800026b0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026b2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800026b6:	00004697          	auipc	a3,0x4
    800026ba:	94a68693          	addi	a3,a3,-1718 # 80006000 <_trampoline>
    800026be:	00004717          	auipc	a4,0x4
    800026c2:	94270713          	addi	a4,a4,-1726 # 80006000 <_trampoline>
    800026c6:	8f15                	sub	a4,a4,a3
    800026c8:	040007b7          	lui	a5,0x4000
    800026cc:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800026ce:	07b2                	slli	a5,a5,0xc
    800026d0:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026d2:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026d6:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026d8:	18002673          	csrr	a2,satp
    800026dc:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026de:	7130                	ld	a2,96(a0)
    800026e0:	6538                	ld	a4,72(a0)
    800026e2:	6585                	lui	a1,0x1
    800026e4:	972e                	add	a4,a4,a1
    800026e6:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026e8:	7138                	ld	a4,96(a0)
    800026ea:	00000617          	auipc	a2,0x0
    800026ee:	11060613          	addi	a2,a2,272 # 800027fa <usertrap>
    800026f2:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026f4:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026f6:	8612                	mv	a2,tp
    800026f8:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026fa:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026fe:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002702:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002706:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000270a:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000270c:	6f18                	ld	a4,24(a4)
    8000270e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002712:	6d28                	ld	a0,88(a0)
    80002714:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002716:	00004717          	auipc	a4,0x4
    8000271a:	98670713          	addi	a4,a4,-1658 # 8000609c <userret>
    8000271e:	8f15                	sub	a4,a4,a3
    80002720:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002722:	577d                	li	a4,-1
    80002724:	177e                	slli	a4,a4,0x3f
    80002726:	8d59                	or	a0,a0,a4
    80002728:	9782                	jalr	a5
}
    8000272a:	60a2                	ld	ra,8(sp)
    8000272c:	6402                	ld	s0,0(sp)
    8000272e:	0141                	addi	sp,sp,16
    80002730:	8082                	ret

0000000080002732 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002732:	1101                	addi	sp,sp,-32
    80002734:	ec06                	sd	ra,24(sp)
    80002736:	e822                	sd	s0,16(sp)
    80002738:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000273a:	97aff0ef          	jal	800018b4 <cpuid>
    8000273e:	cd11                	beqz	a0,8000275a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002740:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002744:	000f4737          	lui	a4,0xf4
    80002748:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000274c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000274e:	14d79073          	csrw	stimecmp,a5
}
    80002752:	60e2                	ld	ra,24(sp)
    80002754:	6442                	ld	s0,16(sp)
    80002756:	6105                	addi	sp,sp,32
    80002758:	8082                	ret
    8000275a:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    8000275c:	0001c497          	auipc	s1,0x1c
    80002760:	a5c48493          	addi	s1,s1,-1444 # 8001e1b8 <tickslock>
    80002764:	8526                	mv	a0,s1
    80002766:	c8efe0ef          	jal	80000bf4 <acquire>
    ticks++;
    8000276a:	00008517          	auipc	a0,0x8
    8000276e:	cd650513          	addi	a0,a0,-810 # 8000a440 <ticks>
    80002772:	411c                	lw	a5,0(a0)
    80002774:	2785                	addiw	a5,a5,1
    80002776:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002778:	f86ff0ef          	jal	80001efe <wakeup>
    release(&tickslock);
    8000277c:	8526                	mv	a0,s1
    8000277e:	d0efe0ef          	jal	80000c8c <release>
    80002782:	64a2                	ld	s1,8(sp)
    80002784:	bf75                	j	80002740 <clockintr+0xe>

0000000080002786 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002786:	1101                	addi	sp,sp,-32
    80002788:	ec06                	sd	ra,24(sp)
    8000278a:	e822                	sd	s0,16(sp)
    8000278c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000278e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002792:	57fd                	li	a5,-1
    80002794:	17fe                	slli	a5,a5,0x3f
    80002796:	07a5                	addi	a5,a5,9
    80002798:	00f70c63          	beq	a4,a5,800027b0 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000279c:	57fd                	li	a5,-1
    8000279e:	17fe                	slli	a5,a5,0x3f
    800027a0:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800027a2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800027a4:	04f70763          	beq	a4,a5,800027f2 <devintr+0x6c>
  }
}
    800027a8:	60e2                	ld	ra,24(sp)
    800027aa:	6442                	ld	s0,16(sp)
    800027ac:	6105                	addi	sp,sp,32
    800027ae:	8082                	ret
    800027b0:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800027b2:	5ab020ef          	jal	8000555c <plic_claim>
    800027b6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800027b8:	47a9                	li	a5,10
    800027ba:	00f50963          	beq	a0,a5,800027cc <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    800027be:	4785                	li	a5,1
    800027c0:	00f50963          	beq	a0,a5,800027d2 <devintr+0x4c>
    return 1;
    800027c4:	4505                	li	a0,1
    } else if(irq){
    800027c6:	e889                	bnez	s1,800027d8 <devintr+0x52>
    800027c8:	64a2                	ld	s1,8(sp)
    800027ca:	bff9                	j	800027a8 <devintr+0x22>
      uartintr();
    800027cc:	a3afe0ef          	jal	80000a06 <uartintr>
    if(irq)
    800027d0:	a819                	j	800027e6 <devintr+0x60>
      virtio_disk_intr();
    800027d2:	250030ef          	jal	80005a22 <virtio_disk_intr>
    if(irq)
    800027d6:	a801                	j	800027e6 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    800027d8:	85a6                	mv	a1,s1
    800027da:	00005517          	auipc	a0,0x5
    800027de:	c0650513          	addi	a0,a0,-1018 # 800073e0 <etext+0x3e0>
    800027e2:	ce1fd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800027e6:	8526                	mv	a0,s1
    800027e8:	595020ef          	jal	8000557c <plic_complete>
    return 1;
    800027ec:	4505                	li	a0,1
    800027ee:	64a2                	ld	s1,8(sp)
    800027f0:	bf65                	j	800027a8 <devintr+0x22>
    clockintr();
    800027f2:	f41ff0ef          	jal	80002732 <clockintr>
    return 2;
    800027f6:	4509                	li	a0,2
    800027f8:	bf45                	j	800027a8 <devintr+0x22>

00000000800027fa <usertrap>:
{
    800027fa:	1101                	addi	sp,sp,-32
    800027fc:	ec06                	sd	ra,24(sp)
    800027fe:	e822                	sd	s0,16(sp)
    80002800:	e426                	sd	s1,8(sp)
    80002802:	e04a                	sd	s2,0(sp)
    80002804:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002806:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000280a:	1007f793          	andi	a5,a5,256
    8000280e:	ef85                	bnez	a5,80002846 <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002810:	00003797          	auipc	a5,0x3
    80002814:	ca078793          	addi	a5,a5,-864 # 800054b0 <kernelvec>
    80002818:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000281c:	8c4ff0ef          	jal	800018e0 <myproc>
    80002820:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002822:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002824:	14102773          	csrr	a4,sepc
    80002828:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000282a:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000282e:	47a1                	li	a5,8
    80002830:	02f70163          	beq	a4,a5,80002852 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    80002834:	f53ff0ef          	jal	80002786 <devintr>
    80002838:	892a                	mv	s2,a0
    8000283a:	c135                	beqz	a0,8000289e <usertrap+0xa4>
  if(killed(p))
    8000283c:	8526                	mv	a0,s1
    8000283e:	8f1ff0ef          	jal	8000212e <killed>
    80002842:	cd1d                	beqz	a0,80002880 <usertrap+0x86>
    80002844:	a81d                	j	8000287a <usertrap+0x80>
    panic("usertrap: not from user mode");
    80002846:	00005517          	auipc	a0,0x5
    8000284a:	bba50513          	addi	a0,a0,-1094 # 80007400 <etext+0x400>
    8000284e:	f47fd0ef          	jal	80000794 <panic>
    if(killed(p))
    80002852:	8ddff0ef          	jal	8000212e <killed>
    80002856:	e121                	bnez	a0,80002896 <usertrap+0x9c>
    p->trapframe->epc += 4;
    80002858:	70b8                	ld	a4,96(s1)
    8000285a:	6f1c                	ld	a5,24(a4)
    8000285c:	0791                	addi	a5,a5,4
    8000285e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002860:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002864:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002868:	10079073          	csrw	sstatus,a5
    syscall();
    8000286c:	248000ef          	jal	80002ab4 <syscall>
  if(killed(p))
    80002870:	8526                	mv	a0,s1
    80002872:	8bdff0ef          	jal	8000212e <killed>
    80002876:	c901                	beqz	a0,80002886 <usertrap+0x8c>
    80002878:	4901                	li	s2,0
    exit(-1);
    8000287a:	557d                	li	a0,-1
    8000287c:	f5cff0ef          	jal	80001fd8 <exit>
  if(which_dev == 2)
    80002880:	4789                	li	a5,2
    80002882:	04f90563          	beq	s2,a5,800028cc <usertrap+0xd2>
  usertrapret();
    80002886:	e1bff0ef          	jal	800026a0 <usertrapret>
}
    8000288a:	60e2                	ld	ra,24(sp)
    8000288c:	6442                	ld	s0,16(sp)
    8000288e:	64a2                	ld	s1,8(sp)
    80002890:	6902                	ld	s2,0(sp)
    80002892:	6105                	addi	sp,sp,32
    80002894:	8082                	ret
      exit(-1);
    80002896:	557d                	li	a0,-1
    80002898:	f40ff0ef          	jal	80001fd8 <exit>
    8000289c:	bf75                	j	80002858 <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000289e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800028a2:	5890                	lw	a2,48(s1)
    800028a4:	00005517          	auipc	a0,0x5
    800028a8:	b7c50513          	addi	a0,a0,-1156 # 80007420 <etext+0x420>
    800028ac:	c17fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028b0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028b4:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800028b8:	00005517          	auipc	a0,0x5
    800028bc:	b9850513          	addi	a0,a0,-1128 # 80007450 <etext+0x450>
    800028c0:	c03fd0ef          	jal	800004c2 <printf>
    setkilled(p);
    800028c4:	8526                	mv	a0,s1
    800028c6:	845ff0ef          	jal	8000210a <setkilled>
    800028ca:	b75d                	j	80002870 <usertrap+0x76>
    yield();
    800028cc:	dbaff0ef          	jal	80001e86 <yield>
    800028d0:	bf5d                	j	80002886 <usertrap+0x8c>

00000000800028d2 <kerneltrap>:
{
    800028d2:	7179                	addi	sp,sp,-48
    800028d4:	f406                	sd	ra,40(sp)
    800028d6:	f022                	sd	s0,32(sp)
    800028d8:	ec26                	sd	s1,24(sp)
    800028da:	e84a                	sd	s2,16(sp)
    800028dc:	e44e                	sd	s3,8(sp)
    800028de:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028e0:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028e4:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028e8:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800028ec:	1004f793          	andi	a5,s1,256
    800028f0:	c795                	beqz	a5,8000291c <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028f2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028f6:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028f8:	eb85                	bnez	a5,80002928 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800028fa:	e8dff0ef          	jal	80002786 <devintr>
    800028fe:	c91d                	beqz	a0,80002934 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002900:	4789                	li	a5,2
    80002902:	04f50a63          	beq	a0,a5,80002956 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002906:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000290a:	10049073          	csrw	sstatus,s1
}
    8000290e:	70a2                	ld	ra,40(sp)
    80002910:	7402                	ld	s0,32(sp)
    80002912:	64e2                	ld	s1,24(sp)
    80002914:	6942                	ld	s2,16(sp)
    80002916:	69a2                	ld	s3,8(sp)
    80002918:	6145                	addi	sp,sp,48
    8000291a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000291c:	00005517          	auipc	a0,0x5
    80002920:	b5c50513          	addi	a0,a0,-1188 # 80007478 <etext+0x478>
    80002924:	e71fd0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    80002928:	00005517          	auipc	a0,0x5
    8000292c:	b7850513          	addi	a0,a0,-1160 # 800074a0 <etext+0x4a0>
    80002930:	e65fd0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002934:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002938:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000293c:	85ce                	mv	a1,s3
    8000293e:	00005517          	auipc	a0,0x5
    80002942:	b8250513          	addi	a0,a0,-1150 # 800074c0 <etext+0x4c0>
    80002946:	b7dfd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    8000294a:	00005517          	auipc	a0,0x5
    8000294e:	b9e50513          	addi	a0,a0,-1122 # 800074e8 <etext+0x4e8>
    80002952:	e43fd0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002956:	f8bfe0ef          	jal	800018e0 <myproc>
    8000295a:	d555                	beqz	a0,80002906 <kerneltrap+0x34>
    yield();
    8000295c:	d2aff0ef          	jal	80001e86 <yield>
    80002960:	b75d                	j	80002906 <kerneltrap+0x34>

0000000080002962 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002962:	1101                	addi	sp,sp,-32
    80002964:	ec06                	sd	ra,24(sp)
    80002966:	e822                	sd	s0,16(sp)
    80002968:	e426                	sd	s1,8(sp)
    8000296a:	1000                	addi	s0,sp,32
    8000296c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000296e:	f73fe0ef          	jal	800018e0 <myproc>
  switch (n) {
    80002972:	4795                	li	a5,5
    80002974:	0497e163          	bltu	a5,s1,800029b6 <argraw+0x54>
    80002978:	048a                	slli	s1,s1,0x2
    8000297a:	00005717          	auipc	a4,0x5
    8000297e:	f7670713          	addi	a4,a4,-138 # 800078f0 <states.0+0x30>
    80002982:	94ba                	add	s1,s1,a4
    80002984:	409c                	lw	a5,0(s1)
    80002986:	97ba                	add	a5,a5,a4
    80002988:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000298a:	713c                	ld	a5,96(a0)
    8000298c:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000298e:	60e2                	ld	ra,24(sp)
    80002990:	6442                	ld	s0,16(sp)
    80002992:	64a2                	ld	s1,8(sp)
    80002994:	6105                	addi	sp,sp,32
    80002996:	8082                	ret
    return p->trapframe->a1;
    80002998:	713c                	ld	a5,96(a0)
    8000299a:	7fa8                	ld	a0,120(a5)
    8000299c:	bfcd                	j	8000298e <argraw+0x2c>
    return p->trapframe->a2;
    8000299e:	713c                	ld	a5,96(a0)
    800029a0:	63c8                	ld	a0,128(a5)
    800029a2:	b7f5                	j	8000298e <argraw+0x2c>
    return p->trapframe->a3;
    800029a4:	713c                	ld	a5,96(a0)
    800029a6:	67c8                	ld	a0,136(a5)
    800029a8:	b7dd                	j	8000298e <argraw+0x2c>
    return p->trapframe->a4;
    800029aa:	713c                	ld	a5,96(a0)
    800029ac:	6bc8                	ld	a0,144(a5)
    800029ae:	b7c5                	j	8000298e <argraw+0x2c>
    return p->trapframe->a5;
    800029b0:	713c                	ld	a5,96(a0)
    800029b2:	6fc8                	ld	a0,152(a5)
    800029b4:	bfe9                	j	8000298e <argraw+0x2c>
  panic("argraw");
    800029b6:	00005517          	auipc	a0,0x5
    800029ba:	b4250513          	addi	a0,a0,-1214 # 800074f8 <etext+0x4f8>
    800029be:	dd7fd0ef          	jal	80000794 <panic>

00000000800029c2 <fetchaddr>:
{
    800029c2:	1101                	addi	sp,sp,-32
    800029c4:	ec06                	sd	ra,24(sp)
    800029c6:	e822                	sd	s0,16(sp)
    800029c8:	e426                	sd	s1,8(sp)
    800029ca:	e04a                	sd	s2,0(sp)
    800029cc:	1000                	addi	s0,sp,32
    800029ce:	84aa                	mv	s1,a0
    800029d0:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029d2:	f0ffe0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029d6:	693c                	ld	a5,80(a0)
    800029d8:	02f4f663          	bgeu	s1,a5,80002a04 <fetchaddr+0x42>
    800029dc:	00848713          	addi	a4,s1,8
    800029e0:	02e7e463          	bltu	a5,a4,80002a08 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029e4:	46a1                	li	a3,8
    800029e6:	8626                	mv	a2,s1
    800029e8:	85ca                	mv	a1,s2
    800029ea:	6d28                	ld	a0,88(a0)
    800029ec:	c3dfe0ef          	jal	80001628 <copyin>
    800029f0:	00a03533          	snez	a0,a0
    800029f4:	40a00533          	neg	a0,a0
}
    800029f8:	60e2                	ld	ra,24(sp)
    800029fa:	6442                	ld	s0,16(sp)
    800029fc:	64a2                	ld	s1,8(sp)
    800029fe:	6902                	ld	s2,0(sp)
    80002a00:	6105                	addi	sp,sp,32
    80002a02:	8082                	ret
    return -1;
    80002a04:	557d                	li	a0,-1
    80002a06:	bfcd                	j	800029f8 <fetchaddr+0x36>
    80002a08:	557d                	li	a0,-1
    80002a0a:	b7fd                	j	800029f8 <fetchaddr+0x36>

0000000080002a0c <fetchstr>:
{
    80002a0c:	7179                	addi	sp,sp,-48
    80002a0e:	f406                	sd	ra,40(sp)
    80002a10:	f022                	sd	s0,32(sp)
    80002a12:	ec26                	sd	s1,24(sp)
    80002a14:	e84a                	sd	s2,16(sp)
    80002a16:	e44e                	sd	s3,8(sp)
    80002a18:	1800                	addi	s0,sp,48
    80002a1a:	892a                	mv	s2,a0
    80002a1c:	84ae                	mv	s1,a1
    80002a1e:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a20:	ec1fe0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a24:	86ce                	mv	a3,s3
    80002a26:	864a                	mv	a2,s2
    80002a28:	85a6                	mv	a1,s1
    80002a2a:	6d28                	ld	a0,88(a0)
    80002a2c:	c83fe0ef          	jal	800016ae <copyinstr>
    80002a30:	00054c63          	bltz	a0,80002a48 <fetchstr+0x3c>
  return strlen(buf);
    80002a34:	8526                	mv	a0,s1
    80002a36:	c02fe0ef          	jal	80000e38 <strlen>
}
    80002a3a:	70a2                	ld	ra,40(sp)
    80002a3c:	7402                	ld	s0,32(sp)
    80002a3e:	64e2                	ld	s1,24(sp)
    80002a40:	6942                	ld	s2,16(sp)
    80002a42:	69a2                	ld	s3,8(sp)
    80002a44:	6145                	addi	sp,sp,48
    80002a46:	8082                	ret
    return -1;
    80002a48:	557d                	li	a0,-1
    80002a4a:	bfc5                	j	80002a3a <fetchstr+0x2e>

0000000080002a4c <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a4c:	1101                	addi	sp,sp,-32
    80002a4e:	ec06                	sd	ra,24(sp)
    80002a50:	e822                	sd	s0,16(sp)
    80002a52:	e426                	sd	s1,8(sp)
    80002a54:	1000                	addi	s0,sp,32
    80002a56:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a58:	f0bff0ef          	jal	80002962 <argraw>
    80002a5c:	c088                	sw	a0,0(s1)
}
    80002a5e:	60e2                	ld	ra,24(sp)
    80002a60:	6442                	ld	s0,16(sp)
    80002a62:	64a2                	ld	s1,8(sp)
    80002a64:	6105                	addi	sp,sp,32
    80002a66:	8082                	ret

0000000080002a68 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a68:	1101                	addi	sp,sp,-32
    80002a6a:	ec06                	sd	ra,24(sp)
    80002a6c:	e822                	sd	s0,16(sp)
    80002a6e:	e426                	sd	s1,8(sp)
    80002a70:	1000                	addi	s0,sp,32
    80002a72:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a74:	eefff0ef          	jal	80002962 <argraw>
    80002a78:	e088                	sd	a0,0(s1)
}
    80002a7a:	60e2                	ld	ra,24(sp)
    80002a7c:	6442                	ld	s0,16(sp)
    80002a7e:	64a2                	ld	s1,8(sp)
    80002a80:	6105                	addi	sp,sp,32
    80002a82:	8082                	ret

0000000080002a84 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a84:	7179                	addi	sp,sp,-48
    80002a86:	f406                	sd	ra,40(sp)
    80002a88:	f022                	sd	s0,32(sp)
    80002a8a:	ec26                	sd	s1,24(sp)
    80002a8c:	e84a                	sd	s2,16(sp)
    80002a8e:	1800                	addi	s0,sp,48
    80002a90:	84ae                	mv	s1,a1
    80002a92:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002a94:	fd840593          	addi	a1,s0,-40
    80002a98:	fd1ff0ef          	jal	80002a68 <argaddr>
  return fetchstr(addr, buf, max);
    80002a9c:	864a                	mv	a2,s2
    80002a9e:	85a6                	mv	a1,s1
    80002aa0:	fd843503          	ld	a0,-40(s0)
    80002aa4:	f69ff0ef          	jal	80002a0c <fetchstr>
}
    80002aa8:	70a2                	ld	ra,40(sp)
    80002aaa:	7402                	ld	s0,32(sp)
    80002aac:	64e2                	ld	s1,24(sp)
    80002aae:	6942                	ld	s2,16(sp)
    80002ab0:	6145                	addi	sp,sp,48
    80002ab2:	8082                	ret

0000000080002ab4 <syscall>:

};

void
syscall(void)
{
    80002ab4:	1101                	addi	sp,sp,-32
    80002ab6:	ec06                	sd	ra,24(sp)
    80002ab8:	e822                	sd	s0,16(sp)
    80002aba:	e426                	sd	s1,8(sp)
    80002abc:	e04a                	sd	s2,0(sp)
    80002abe:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ac0:	e21fe0ef          	jal	800018e0 <myproc>
    80002ac4:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ac6:	06053903          	ld	s2,96(a0)
    80002aca:	0a893783          	ld	a5,168(s2)
    80002ace:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ad2:	37fd                	addiw	a5,a5,-1
    80002ad4:	4755                	li	a4,21
    80002ad6:	00f76f63          	bltu	a4,a5,80002af4 <syscall+0x40>
    80002ada:	00369713          	slli	a4,a3,0x3
    80002ade:	00005797          	auipc	a5,0x5
    80002ae2:	e2a78793          	addi	a5,a5,-470 # 80007908 <syscalls>
    80002ae6:	97ba                	add	a5,a5,a4
    80002ae8:	639c                	ld	a5,0(a5)
    80002aea:	c789                	beqz	a5,80002af4 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002aec:	9782                	jalr	a5
    80002aee:	06a93823          	sd	a0,112(s2)
    80002af2:	a829                	j	80002b0c <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002af4:	16048613          	addi	a2,s1,352
    80002af8:	588c                	lw	a1,48(s1)
    80002afa:	00005517          	auipc	a0,0x5
    80002afe:	a0650513          	addi	a0,a0,-1530 # 80007500 <etext+0x500>
    80002b02:	9c1fd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b06:	70bc                	ld	a5,96(s1)
    80002b08:	577d                	li	a4,-1
    80002b0a:	fbb8                	sd	a4,112(a5)
  }
}
    80002b0c:	60e2                	ld	ra,24(sp)
    80002b0e:	6442                	ld	s0,16(sp)
    80002b10:	64a2                	ld	s1,8(sp)
    80002b12:	6902                	ld	s2,0(sp)
    80002b14:	6105                	addi	sp,sp,32
    80002b16:	8082                	ret

0000000080002b18 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002b18:	1101                	addi	sp,sp,-32
    80002b1a:	ec06                	sd	ra,24(sp)
    80002b1c:	e822                	sd	s0,16(sp)
    80002b1e:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b20:	fec40593          	addi	a1,s0,-20
    80002b24:	4501                	li	a0,0
    80002b26:	f27ff0ef          	jal	80002a4c <argint>
  exit(n);
    80002b2a:	fec42503          	lw	a0,-20(s0)
    80002b2e:	caaff0ef          	jal	80001fd8 <exit>
  return 0;  // not reached
}
    80002b32:	4501                	li	a0,0
    80002b34:	60e2                	ld	ra,24(sp)
    80002b36:	6442                	ld	s0,16(sp)
    80002b38:	6105                	addi	sp,sp,32
    80002b3a:	8082                	ret

0000000080002b3c <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b3c:	1141                	addi	sp,sp,-16
    80002b3e:	e406                	sd	ra,8(sp)
    80002b40:	e022                	sd	s0,0(sp)
    80002b42:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b44:	d9dfe0ef          	jal	800018e0 <myproc>
}
    80002b48:	5908                	lw	a0,48(a0)
    80002b4a:	60a2                	ld	ra,8(sp)
    80002b4c:	6402                	ld	s0,0(sp)
    80002b4e:	0141                	addi	sp,sp,16
    80002b50:	8082                	ret

0000000080002b52 <sys_fork>:

uint64
sys_fork(void)
{
    80002b52:	1141                	addi	sp,sp,-16
    80002b54:	e406                	sd	ra,8(sp)
    80002b56:	e022                	sd	s0,0(sp)
    80002b58:	0800                	addi	s0,sp,16
  return fork();
    80002b5a:	8b0ff0ef          	jal	80001c0a <fork>
}
    80002b5e:	60a2                	ld	ra,8(sp)
    80002b60:	6402                	ld	s0,0(sp)
    80002b62:	0141                	addi	sp,sp,16
    80002b64:	8082                	ret

0000000080002b66 <sys_wait>:

uint64
sys_wait(void)
{
    80002b66:	1101                	addi	sp,sp,-32
    80002b68:	ec06                	sd	ra,24(sp)
    80002b6a:	e822                	sd	s0,16(sp)
    80002b6c:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b6e:	fe840593          	addi	a1,s0,-24
    80002b72:	4501                	li	a0,0
    80002b74:	ef5ff0ef          	jal	80002a68 <argaddr>
  return wait(p);
    80002b78:	fe843503          	ld	a0,-24(s0)
    80002b7c:	ddcff0ef          	jal	80002158 <wait>
}
    80002b80:	60e2                	ld	ra,24(sp)
    80002b82:	6442                	ld	s0,16(sp)
    80002b84:	6105                	addi	sp,sp,32
    80002b86:	8082                	ret

0000000080002b88 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b88:	7179                	addi	sp,sp,-48
    80002b8a:	f406                	sd	ra,40(sp)
    80002b8c:	f022                	sd	s0,32(sp)
    80002b8e:	ec26                	sd	s1,24(sp)
    80002b90:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002b92:	fdc40593          	addi	a1,s0,-36
    80002b96:	4501                	li	a0,0
    80002b98:	eb5ff0ef          	jal	80002a4c <argint>
  addr = myproc()->sz;
    80002b9c:	d45fe0ef          	jal	800018e0 <myproc>
    80002ba0:	6924                	ld	s1,80(a0)
  if(growproc(n) < 0)
    80002ba2:	fdc42503          	lw	a0,-36(s0)
    80002ba6:	814ff0ef          	jal	80001bba <growproc>
    80002baa:	00054863          	bltz	a0,80002bba <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002bae:	8526                	mv	a0,s1
    80002bb0:	70a2                	ld	ra,40(sp)
    80002bb2:	7402                	ld	s0,32(sp)
    80002bb4:	64e2                	ld	s1,24(sp)
    80002bb6:	6145                	addi	sp,sp,48
    80002bb8:	8082                	ret
    return -1;
    80002bba:	54fd                	li	s1,-1
    80002bbc:	bfcd                	j	80002bae <sys_sbrk+0x26>

0000000080002bbe <sys_sleep>:

uint64
sys_sleep(void)
{
    80002bbe:	7139                	addi	sp,sp,-64
    80002bc0:	fc06                	sd	ra,56(sp)
    80002bc2:	f822                	sd	s0,48(sp)
    80002bc4:	f04a                	sd	s2,32(sp)
    80002bc6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002bc8:	fcc40593          	addi	a1,s0,-52
    80002bcc:	4501                	li	a0,0
    80002bce:	e7fff0ef          	jal	80002a4c <argint>
  if(n < 0)
    80002bd2:	fcc42783          	lw	a5,-52(s0)
    80002bd6:	0607c763          	bltz	a5,80002c44 <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    80002bda:	0001b517          	auipc	a0,0x1b
    80002bde:	5de50513          	addi	a0,a0,1502 # 8001e1b8 <tickslock>
    80002be2:	812fe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    80002be6:	00008917          	auipc	s2,0x8
    80002bea:	85a92903          	lw	s2,-1958(s2) # 8000a440 <ticks>
  while(ticks - ticks0 < n){
    80002bee:	fcc42783          	lw	a5,-52(s0)
    80002bf2:	cf8d                	beqz	a5,80002c2c <sys_sleep+0x6e>
    80002bf4:	f426                	sd	s1,40(sp)
    80002bf6:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002bf8:	0001b997          	auipc	s3,0x1b
    80002bfc:	5c098993          	addi	s3,s3,1472 # 8001e1b8 <tickslock>
    80002c00:	00008497          	auipc	s1,0x8
    80002c04:	84048493          	addi	s1,s1,-1984 # 8000a440 <ticks>
    if(killed(myproc())){
    80002c08:	cd9fe0ef          	jal	800018e0 <myproc>
    80002c0c:	d22ff0ef          	jal	8000212e <killed>
    80002c10:	ed0d                	bnez	a0,80002c4a <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    80002c12:	85ce                	mv	a1,s3
    80002c14:	8526                	mv	a0,s1
    80002c16:	a9cff0ef          	jal	80001eb2 <sleep>
  while(ticks - ticks0 < n){
    80002c1a:	409c                	lw	a5,0(s1)
    80002c1c:	412787bb          	subw	a5,a5,s2
    80002c20:	fcc42703          	lw	a4,-52(s0)
    80002c24:	fee7e2e3          	bltu	a5,a4,80002c08 <sys_sleep+0x4a>
    80002c28:	74a2                	ld	s1,40(sp)
    80002c2a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c2c:	0001b517          	auipc	a0,0x1b
    80002c30:	58c50513          	addi	a0,a0,1420 # 8001e1b8 <tickslock>
    80002c34:	858fe0ef          	jal	80000c8c <release>
  return 0;
    80002c38:	4501                	li	a0,0
}
    80002c3a:	70e2                	ld	ra,56(sp)
    80002c3c:	7442                	ld	s0,48(sp)
    80002c3e:	7902                	ld	s2,32(sp)
    80002c40:	6121                	addi	sp,sp,64
    80002c42:	8082                	ret
    n = 0;
    80002c44:	fc042623          	sw	zero,-52(s0)
    80002c48:	bf49                	j	80002bda <sys_sleep+0x1c>
      release(&tickslock);
    80002c4a:	0001b517          	auipc	a0,0x1b
    80002c4e:	56e50513          	addi	a0,a0,1390 # 8001e1b8 <tickslock>
    80002c52:	83afe0ef          	jal	80000c8c <release>
      return -1;
    80002c56:	557d                	li	a0,-1
    80002c58:	74a2                	ld	s1,40(sp)
    80002c5a:	69e2                	ld	s3,24(sp)
    80002c5c:	bff9                	j	80002c3a <sys_sleep+0x7c>

0000000080002c5e <sys_kill>:

uint64
sys_kill(void)
{
    80002c5e:	1101                	addi	sp,sp,-32
    80002c60:	ec06                	sd	ra,24(sp)
    80002c62:	e822                	sd	s0,16(sp)
    80002c64:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c66:	fec40593          	addi	a1,s0,-20
    80002c6a:	4501                	li	a0,0
    80002c6c:	de1ff0ef          	jal	80002a4c <argint>
  return kill(pid);
    80002c70:	fec42503          	lw	a0,-20(s0)
    80002c74:	c30ff0ef          	jal	800020a4 <kill>
}
    80002c78:	60e2                	ld	ra,24(sp)
    80002c7a:	6442                	ld	s0,16(sp)
    80002c7c:	6105                	addi	sp,sp,32
    80002c7e:	8082                	ret

0000000080002c80 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002c80:	1101                	addi	sp,sp,-32
    80002c82:	ec06                	sd	ra,24(sp)
    80002c84:	e822                	sd	s0,16(sp)
    80002c86:	e426                	sd	s1,8(sp)
    80002c88:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002c8a:	0001b517          	auipc	a0,0x1b
    80002c8e:	52e50513          	addi	a0,a0,1326 # 8001e1b8 <tickslock>
    80002c92:	f63fd0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002c96:	00007497          	auipc	s1,0x7
    80002c9a:	7aa4a483          	lw	s1,1962(s1) # 8000a440 <ticks>
  release(&tickslock);
    80002c9e:	0001b517          	auipc	a0,0x1b
    80002ca2:	51a50513          	addi	a0,a0,1306 # 8001e1b8 <tickslock>
    80002ca6:	fe7fd0ef          	jal	80000c8c <release>
  return xticks;
}
    80002caa:	02049513          	slli	a0,s1,0x20
    80002cae:	9101                	srli	a0,a0,0x20
    80002cb0:	60e2                	ld	ra,24(sp)
    80002cb2:	6442                	ld	s0,16(sp)
    80002cb4:	64a2                	ld	s1,8(sp)
    80002cb6:	6105                	addi	sp,sp,32
    80002cb8:	8082                	ret

0000000080002cba <sys_pstree>:
uint64
sys_pstree(void)
{
    80002cba:	1141                	addi	sp,sp,-16
    80002cbc:	e406                	sd	ra,8(sp)
    80002cbe:	e022                	sd	s0,0(sp)
    80002cc0:	0800                	addi	s0,sp,16
  return pstree();
    80002cc2:	89dff0ef          	jal	8000255e <pstree>
}
    80002cc6:	60a2                	ld	ra,8(sp)
    80002cc8:	6402                	ld	s0,0(sp)
    80002cca:	0141                	addi	sp,sp,16
    80002ccc:	8082                	ret

0000000080002cce <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002cce:	7179                	addi	sp,sp,-48
    80002cd0:	f406                	sd	ra,40(sp)
    80002cd2:	f022                	sd	s0,32(sp)
    80002cd4:	ec26                	sd	s1,24(sp)
    80002cd6:	e84a                	sd	s2,16(sp)
    80002cd8:	e44e                	sd	s3,8(sp)
    80002cda:	e052                	sd	s4,0(sp)
    80002cdc:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002cde:	00005597          	auipc	a1,0x5
    80002ce2:	84258593          	addi	a1,a1,-1982 # 80007520 <etext+0x520>
    80002ce6:	0001b517          	auipc	a0,0x1b
    80002cea:	4ea50513          	addi	a0,a0,1258 # 8001e1d0 <bcache>
    80002cee:	e87fd0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002cf2:	00023797          	auipc	a5,0x23
    80002cf6:	4de78793          	addi	a5,a5,1246 # 800261d0 <bcache+0x8000>
    80002cfa:	00023717          	auipc	a4,0x23
    80002cfe:	73e70713          	addi	a4,a4,1854 # 80026438 <bcache+0x8268>
    80002d02:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002d06:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d0a:	0001b497          	auipc	s1,0x1b
    80002d0e:	4de48493          	addi	s1,s1,1246 # 8001e1e8 <bcache+0x18>
    b->next = bcache.head.next;
    80002d12:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002d14:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002d16:	00005a17          	auipc	s4,0x5
    80002d1a:	812a0a13          	addi	s4,s4,-2030 # 80007528 <etext+0x528>
    b->next = bcache.head.next;
    80002d1e:	2b893783          	ld	a5,696(s2)
    80002d22:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002d24:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002d28:	85d2                	mv	a1,s4
    80002d2a:	01048513          	addi	a0,s1,16
    80002d2e:	248010ef          	jal	80003f76 <initsleeplock>
    bcache.head.next->prev = b;
    80002d32:	2b893783          	ld	a5,696(s2)
    80002d36:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002d38:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002d3c:	45848493          	addi	s1,s1,1112
    80002d40:	fd349fe3          	bne	s1,s3,80002d1e <binit+0x50>
  }
}
    80002d44:	70a2                	ld	ra,40(sp)
    80002d46:	7402                	ld	s0,32(sp)
    80002d48:	64e2                	ld	s1,24(sp)
    80002d4a:	6942                	ld	s2,16(sp)
    80002d4c:	69a2                	ld	s3,8(sp)
    80002d4e:	6a02                	ld	s4,0(sp)
    80002d50:	6145                	addi	sp,sp,48
    80002d52:	8082                	ret

0000000080002d54 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002d54:	7179                	addi	sp,sp,-48
    80002d56:	f406                	sd	ra,40(sp)
    80002d58:	f022                	sd	s0,32(sp)
    80002d5a:	ec26                	sd	s1,24(sp)
    80002d5c:	e84a                	sd	s2,16(sp)
    80002d5e:	e44e                	sd	s3,8(sp)
    80002d60:	1800                	addi	s0,sp,48
    80002d62:	892a                	mv	s2,a0
    80002d64:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002d66:	0001b517          	auipc	a0,0x1b
    80002d6a:	46a50513          	addi	a0,a0,1130 # 8001e1d0 <bcache>
    80002d6e:	e87fd0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002d72:	00023497          	auipc	s1,0x23
    80002d76:	7164b483          	ld	s1,1814(s1) # 80026488 <bcache+0x82b8>
    80002d7a:	00023797          	auipc	a5,0x23
    80002d7e:	6be78793          	addi	a5,a5,1726 # 80026438 <bcache+0x8268>
    80002d82:	02f48b63          	beq	s1,a5,80002db8 <bread+0x64>
    80002d86:	873e                	mv	a4,a5
    80002d88:	a021                	j	80002d90 <bread+0x3c>
    80002d8a:	68a4                	ld	s1,80(s1)
    80002d8c:	02e48663          	beq	s1,a4,80002db8 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002d90:	449c                	lw	a5,8(s1)
    80002d92:	ff279ce3          	bne	a5,s2,80002d8a <bread+0x36>
    80002d96:	44dc                	lw	a5,12(s1)
    80002d98:	ff3799e3          	bne	a5,s3,80002d8a <bread+0x36>
      b->refcnt++;
    80002d9c:	40bc                	lw	a5,64(s1)
    80002d9e:	2785                	addiw	a5,a5,1
    80002da0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002da2:	0001b517          	auipc	a0,0x1b
    80002da6:	42e50513          	addi	a0,a0,1070 # 8001e1d0 <bcache>
    80002daa:	ee3fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002dae:	01048513          	addi	a0,s1,16
    80002db2:	1fa010ef          	jal	80003fac <acquiresleep>
      return b;
    80002db6:	a889                	j	80002e08 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002db8:	00023497          	auipc	s1,0x23
    80002dbc:	6c84b483          	ld	s1,1736(s1) # 80026480 <bcache+0x82b0>
    80002dc0:	00023797          	auipc	a5,0x23
    80002dc4:	67878793          	addi	a5,a5,1656 # 80026438 <bcache+0x8268>
    80002dc8:	00f48863          	beq	s1,a5,80002dd8 <bread+0x84>
    80002dcc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002dce:	40bc                	lw	a5,64(s1)
    80002dd0:	cb91                	beqz	a5,80002de4 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002dd2:	64a4                	ld	s1,72(s1)
    80002dd4:	fee49de3          	bne	s1,a4,80002dce <bread+0x7a>
  panic("bget: no buffers");
    80002dd8:	00004517          	auipc	a0,0x4
    80002ddc:	75850513          	addi	a0,a0,1880 # 80007530 <etext+0x530>
    80002de0:	9b5fd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002de4:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002de8:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002dec:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002df0:	4785                	li	a5,1
    80002df2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002df4:	0001b517          	auipc	a0,0x1b
    80002df8:	3dc50513          	addi	a0,a0,988 # 8001e1d0 <bcache>
    80002dfc:	e91fd0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002e00:	01048513          	addi	a0,s1,16
    80002e04:	1a8010ef          	jal	80003fac <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002e08:	409c                	lw	a5,0(s1)
    80002e0a:	cb89                	beqz	a5,80002e1c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002e0c:	8526                	mv	a0,s1
    80002e0e:	70a2                	ld	ra,40(sp)
    80002e10:	7402                	ld	s0,32(sp)
    80002e12:	64e2                	ld	s1,24(sp)
    80002e14:	6942                	ld	s2,16(sp)
    80002e16:	69a2                	ld	s3,8(sp)
    80002e18:	6145                	addi	sp,sp,48
    80002e1a:	8082                	ret
    virtio_disk_rw(b, 0);
    80002e1c:	4581                	li	a1,0
    80002e1e:	8526                	mv	a0,s1
    80002e20:	1f1020ef          	jal	80005810 <virtio_disk_rw>
    b->valid = 1;
    80002e24:	4785                	li	a5,1
    80002e26:	c09c                	sw	a5,0(s1)
  return b;
    80002e28:	b7d5                	j	80002e0c <bread+0xb8>

0000000080002e2a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002e2a:	1101                	addi	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	e426                	sd	s1,8(sp)
    80002e32:	1000                	addi	s0,sp,32
    80002e34:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e36:	0541                	addi	a0,a0,16
    80002e38:	1f2010ef          	jal	8000402a <holdingsleep>
    80002e3c:	c911                	beqz	a0,80002e50 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002e3e:	4585                	li	a1,1
    80002e40:	8526                	mv	a0,s1
    80002e42:	1cf020ef          	jal	80005810 <virtio_disk_rw>
}
    80002e46:	60e2                	ld	ra,24(sp)
    80002e48:	6442                	ld	s0,16(sp)
    80002e4a:	64a2                	ld	s1,8(sp)
    80002e4c:	6105                	addi	sp,sp,32
    80002e4e:	8082                	ret
    panic("bwrite");
    80002e50:	00004517          	auipc	a0,0x4
    80002e54:	6f850513          	addi	a0,a0,1784 # 80007548 <etext+0x548>
    80002e58:	93dfd0ef          	jal	80000794 <panic>

0000000080002e5c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002e5c:	1101                	addi	sp,sp,-32
    80002e5e:	ec06                	sd	ra,24(sp)
    80002e60:	e822                	sd	s0,16(sp)
    80002e62:	e426                	sd	s1,8(sp)
    80002e64:	e04a                	sd	s2,0(sp)
    80002e66:	1000                	addi	s0,sp,32
    80002e68:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e6a:	01050913          	addi	s2,a0,16
    80002e6e:	854a                	mv	a0,s2
    80002e70:	1ba010ef          	jal	8000402a <holdingsleep>
    80002e74:	c135                	beqz	a0,80002ed8 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002e76:	854a                	mv	a0,s2
    80002e78:	17a010ef          	jal	80003ff2 <releasesleep>

  acquire(&bcache.lock);
    80002e7c:	0001b517          	auipc	a0,0x1b
    80002e80:	35450513          	addi	a0,a0,852 # 8001e1d0 <bcache>
    80002e84:	d71fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002e88:	40bc                	lw	a5,64(s1)
    80002e8a:	37fd                	addiw	a5,a5,-1
    80002e8c:	0007871b          	sext.w	a4,a5
    80002e90:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002e92:	e71d                	bnez	a4,80002ec0 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002e94:	68b8                	ld	a4,80(s1)
    80002e96:	64bc                	ld	a5,72(s1)
    80002e98:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002e9a:	68b8                	ld	a4,80(s1)
    80002e9c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002e9e:	00023797          	auipc	a5,0x23
    80002ea2:	33278793          	addi	a5,a5,818 # 800261d0 <bcache+0x8000>
    80002ea6:	2b87b703          	ld	a4,696(a5)
    80002eaa:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002eac:	00023717          	auipc	a4,0x23
    80002eb0:	58c70713          	addi	a4,a4,1420 # 80026438 <bcache+0x8268>
    80002eb4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002eb6:	2b87b703          	ld	a4,696(a5)
    80002eba:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002ebc:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002ec0:	0001b517          	auipc	a0,0x1b
    80002ec4:	31050513          	addi	a0,a0,784 # 8001e1d0 <bcache>
    80002ec8:	dc5fd0ef          	jal	80000c8c <release>
}
    80002ecc:	60e2                	ld	ra,24(sp)
    80002ece:	6442                	ld	s0,16(sp)
    80002ed0:	64a2                	ld	s1,8(sp)
    80002ed2:	6902                	ld	s2,0(sp)
    80002ed4:	6105                	addi	sp,sp,32
    80002ed6:	8082                	ret
    panic("brelse");
    80002ed8:	00004517          	auipc	a0,0x4
    80002edc:	67850513          	addi	a0,a0,1656 # 80007550 <etext+0x550>
    80002ee0:	8b5fd0ef          	jal	80000794 <panic>

0000000080002ee4 <bpin>:

void
bpin(struct buf *b) {
    80002ee4:	1101                	addi	sp,sp,-32
    80002ee6:	ec06                	sd	ra,24(sp)
    80002ee8:	e822                	sd	s0,16(sp)
    80002eea:	e426                	sd	s1,8(sp)
    80002eec:	1000                	addi	s0,sp,32
    80002eee:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ef0:	0001b517          	auipc	a0,0x1b
    80002ef4:	2e050513          	addi	a0,a0,736 # 8001e1d0 <bcache>
    80002ef8:	cfdfd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002efc:	40bc                	lw	a5,64(s1)
    80002efe:	2785                	addiw	a5,a5,1
    80002f00:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f02:	0001b517          	auipc	a0,0x1b
    80002f06:	2ce50513          	addi	a0,a0,718 # 8001e1d0 <bcache>
    80002f0a:	d83fd0ef          	jal	80000c8c <release>
}
    80002f0e:	60e2                	ld	ra,24(sp)
    80002f10:	6442                	ld	s0,16(sp)
    80002f12:	64a2                	ld	s1,8(sp)
    80002f14:	6105                	addi	sp,sp,32
    80002f16:	8082                	ret

0000000080002f18 <bunpin>:

void
bunpin(struct buf *b) {
    80002f18:	1101                	addi	sp,sp,-32
    80002f1a:	ec06                	sd	ra,24(sp)
    80002f1c:	e822                	sd	s0,16(sp)
    80002f1e:	e426                	sd	s1,8(sp)
    80002f20:	1000                	addi	s0,sp,32
    80002f22:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002f24:	0001b517          	auipc	a0,0x1b
    80002f28:	2ac50513          	addi	a0,a0,684 # 8001e1d0 <bcache>
    80002f2c:	cc9fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002f30:	40bc                	lw	a5,64(s1)
    80002f32:	37fd                	addiw	a5,a5,-1
    80002f34:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002f36:	0001b517          	auipc	a0,0x1b
    80002f3a:	29a50513          	addi	a0,a0,666 # 8001e1d0 <bcache>
    80002f3e:	d4ffd0ef          	jal	80000c8c <release>
}
    80002f42:	60e2                	ld	ra,24(sp)
    80002f44:	6442                	ld	s0,16(sp)
    80002f46:	64a2                	ld	s1,8(sp)
    80002f48:	6105                	addi	sp,sp,32
    80002f4a:	8082                	ret

0000000080002f4c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002f4c:	1101                	addi	sp,sp,-32
    80002f4e:	ec06                	sd	ra,24(sp)
    80002f50:	e822                	sd	s0,16(sp)
    80002f52:	e426                	sd	s1,8(sp)
    80002f54:	e04a                	sd	s2,0(sp)
    80002f56:	1000                	addi	s0,sp,32
    80002f58:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002f5a:	00d5d59b          	srliw	a1,a1,0xd
    80002f5e:	00024797          	auipc	a5,0x24
    80002f62:	94e7a783          	lw	a5,-1714(a5) # 800268ac <sb+0x1c>
    80002f66:	9dbd                	addw	a1,a1,a5
    80002f68:	dedff0ef          	jal	80002d54 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002f6c:	0074f713          	andi	a4,s1,7
    80002f70:	4785                	li	a5,1
    80002f72:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002f76:	14ce                	slli	s1,s1,0x33
    80002f78:	90d9                	srli	s1,s1,0x36
    80002f7a:	00950733          	add	a4,a0,s1
    80002f7e:	05874703          	lbu	a4,88(a4)
    80002f82:	00e7f6b3          	and	a3,a5,a4
    80002f86:	c29d                	beqz	a3,80002fac <bfree+0x60>
    80002f88:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002f8a:	94aa                	add	s1,s1,a0
    80002f8c:	fff7c793          	not	a5,a5
    80002f90:	8f7d                	and	a4,a4,a5
    80002f92:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002f96:	711000ef          	jal	80003ea6 <log_write>
  brelse(bp);
    80002f9a:	854a                	mv	a0,s2
    80002f9c:	ec1ff0ef          	jal	80002e5c <brelse>
}
    80002fa0:	60e2                	ld	ra,24(sp)
    80002fa2:	6442                	ld	s0,16(sp)
    80002fa4:	64a2                	ld	s1,8(sp)
    80002fa6:	6902                	ld	s2,0(sp)
    80002fa8:	6105                	addi	sp,sp,32
    80002faa:	8082                	ret
    panic("freeing free block");
    80002fac:	00004517          	auipc	a0,0x4
    80002fb0:	5ac50513          	addi	a0,a0,1452 # 80007558 <etext+0x558>
    80002fb4:	fe0fd0ef          	jal	80000794 <panic>

0000000080002fb8 <balloc>:
{
    80002fb8:	711d                	addi	sp,sp,-96
    80002fba:	ec86                	sd	ra,88(sp)
    80002fbc:	e8a2                	sd	s0,80(sp)
    80002fbe:	e4a6                	sd	s1,72(sp)
    80002fc0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002fc2:	00024797          	auipc	a5,0x24
    80002fc6:	8d27a783          	lw	a5,-1838(a5) # 80026894 <sb+0x4>
    80002fca:	0e078f63          	beqz	a5,800030c8 <balloc+0x110>
    80002fce:	e0ca                	sd	s2,64(sp)
    80002fd0:	fc4e                	sd	s3,56(sp)
    80002fd2:	f852                	sd	s4,48(sp)
    80002fd4:	f456                	sd	s5,40(sp)
    80002fd6:	f05a                	sd	s6,32(sp)
    80002fd8:	ec5e                	sd	s7,24(sp)
    80002fda:	e862                	sd	s8,16(sp)
    80002fdc:	e466                	sd	s9,8(sp)
    80002fde:	8baa                	mv	s7,a0
    80002fe0:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002fe2:	00024b17          	auipc	s6,0x24
    80002fe6:	8aeb0b13          	addi	s6,s6,-1874 # 80026890 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fea:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002fec:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002fee:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002ff0:	6c89                	lui	s9,0x2
    80002ff2:	a0b5                	j	8000305e <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002ff4:	97ca                	add	a5,a5,s2
    80002ff6:	8e55                	or	a2,a2,a3
    80002ff8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002ffc:	854a                	mv	a0,s2
    80002ffe:	6a9000ef          	jal	80003ea6 <log_write>
        brelse(bp);
    80003002:	854a                	mv	a0,s2
    80003004:	e59ff0ef          	jal	80002e5c <brelse>
  bp = bread(dev, bno);
    80003008:	85a6                	mv	a1,s1
    8000300a:	855e                	mv	a0,s7
    8000300c:	d49ff0ef          	jal	80002d54 <bread>
    80003010:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003012:	40000613          	li	a2,1024
    80003016:	4581                	li	a1,0
    80003018:	05850513          	addi	a0,a0,88
    8000301c:	cadfd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80003020:	854a                	mv	a0,s2
    80003022:	685000ef          	jal	80003ea6 <log_write>
  brelse(bp);
    80003026:	854a                	mv	a0,s2
    80003028:	e35ff0ef          	jal	80002e5c <brelse>
}
    8000302c:	6906                	ld	s2,64(sp)
    8000302e:	79e2                	ld	s3,56(sp)
    80003030:	7a42                	ld	s4,48(sp)
    80003032:	7aa2                	ld	s5,40(sp)
    80003034:	7b02                	ld	s6,32(sp)
    80003036:	6be2                	ld	s7,24(sp)
    80003038:	6c42                	ld	s8,16(sp)
    8000303a:	6ca2                	ld	s9,8(sp)
}
    8000303c:	8526                	mv	a0,s1
    8000303e:	60e6                	ld	ra,88(sp)
    80003040:	6446                	ld	s0,80(sp)
    80003042:	64a6                	ld	s1,72(sp)
    80003044:	6125                	addi	sp,sp,96
    80003046:	8082                	ret
    brelse(bp);
    80003048:	854a                	mv	a0,s2
    8000304a:	e13ff0ef          	jal	80002e5c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000304e:	015c87bb          	addw	a5,s9,s5
    80003052:	00078a9b          	sext.w	s5,a5
    80003056:	004b2703          	lw	a4,4(s6)
    8000305a:	04eaff63          	bgeu	s5,a4,800030b8 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    8000305e:	41fad79b          	sraiw	a5,s5,0x1f
    80003062:	0137d79b          	srliw	a5,a5,0x13
    80003066:	015787bb          	addw	a5,a5,s5
    8000306a:	40d7d79b          	sraiw	a5,a5,0xd
    8000306e:	01cb2583          	lw	a1,28(s6)
    80003072:	9dbd                	addw	a1,a1,a5
    80003074:	855e                	mv	a0,s7
    80003076:	cdfff0ef          	jal	80002d54 <bread>
    8000307a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000307c:	004b2503          	lw	a0,4(s6)
    80003080:	000a849b          	sext.w	s1,s5
    80003084:	8762                	mv	a4,s8
    80003086:	fca4f1e3          	bgeu	s1,a0,80003048 <balloc+0x90>
      m = 1 << (bi % 8);
    8000308a:	00777693          	andi	a3,a4,7
    8000308e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003092:	41f7579b          	sraiw	a5,a4,0x1f
    80003096:	01d7d79b          	srliw	a5,a5,0x1d
    8000309a:	9fb9                	addw	a5,a5,a4
    8000309c:	4037d79b          	sraiw	a5,a5,0x3
    800030a0:	00f90633          	add	a2,s2,a5
    800030a4:	05864603          	lbu	a2,88(a2)
    800030a8:	00c6f5b3          	and	a1,a3,a2
    800030ac:	d5a1                	beqz	a1,80002ff4 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030ae:	2705                	addiw	a4,a4,1
    800030b0:	2485                	addiw	s1,s1,1
    800030b2:	fd471ae3          	bne	a4,s4,80003086 <balloc+0xce>
    800030b6:	bf49                	j	80003048 <balloc+0x90>
    800030b8:	6906                	ld	s2,64(sp)
    800030ba:	79e2                	ld	s3,56(sp)
    800030bc:	7a42                	ld	s4,48(sp)
    800030be:	7aa2                	ld	s5,40(sp)
    800030c0:	7b02                	ld	s6,32(sp)
    800030c2:	6be2                	ld	s7,24(sp)
    800030c4:	6c42                	ld	s8,16(sp)
    800030c6:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800030c8:	00004517          	auipc	a0,0x4
    800030cc:	4a850513          	addi	a0,a0,1192 # 80007570 <etext+0x570>
    800030d0:	bf2fd0ef          	jal	800004c2 <printf>
  return 0;
    800030d4:	4481                	li	s1,0
    800030d6:	b79d                	j	8000303c <balloc+0x84>

00000000800030d8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800030d8:	7179                	addi	sp,sp,-48
    800030da:	f406                	sd	ra,40(sp)
    800030dc:	f022                	sd	s0,32(sp)
    800030de:	ec26                	sd	s1,24(sp)
    800030e0:	e84a                	sd	s2,16(sp)
    800030e2:	e44e                	sd	s3,8(sp)
    800030e4:	1800                	addi	s0,sp,48
    800030e6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800030e8:	47ad                	li	a5,11
    800030ea:	02b7e663          	bltu	a5,a1,80003116 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800030ee:	02059793          	slli	a5,a1,0x20
    800030f2:	01e7d593          	srli	a1,a5,0x1e
    800030f6:	00b504b3          	add	s1,a0,a1
    800030fa:	0504a903          	lw	s2,80(s1)
    800030fe:	06091a63          	bnez	s2,80003172 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003102:	4108                	lw	a0,0(a0)
    80003104:	eb5ff0ef          	jal	80002fb8 <balloc>
    80003108:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000310c:	06090363          	beqz	s2,80003172 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003110:	0524a823          	sw	s2,80(s1)
    80003114:	a8b9                	j	80003172 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003116:	ff45849b          	addiw	s1,a1,-12
    8000311a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000311e:	0ff00793          	li	a5,255
    80003122:	06e7ee63          	bltu	a5,a4,8000319e <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003126:	08052903          	lw	s2,128(a0)
    8000312a:	00091d63          	bnez	s2,80003144 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000312e:	4108                	lw	a0,0(a0)
    80003130:	e89ff0ef          	jal	80002fb8 <balloc>
    80003134:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003138:	02090d63          	beqz	s2,80003172 <bmap+0x9a>
    8000313c:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000313e:	0929a023          	sw	s2,128(s3)
    80003142:	a011                	j	80003146 <bmap+0x6e>
    80003144:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003146:	85ca                	mv	a1,s2
    80003148:	0009a503          	lw	a0,0(s3)
    8000314c:	c09ff0ef          	jal	80002d54 <bread>
    80003150:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003152:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003156:	02049713          	slli	a4,s1,0x20
    8000315a:	01e75593          	srli	a1,a4,0x1e
    8000315e:	00b784b3          	add	s1,a5,a1
    80003162:	0004a903          	lw	s2,0(s1)
    80003166:	00090e63          	beqz	s2,80003182 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000316a:	8552                	mv	a0,s4
    8000316c:	cf1ff0ef          	jal	80002e5c <brelse>
    return addr;
    80003170:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003172:	854a                	mv	a0,s2
    80003174:	70a2                	ld	ra,40(sp)
    80003176:	7402                	ld	s0,32(sp)
    80003178:	64e2                	ld	s1,24(sp)
    8000317a:	6942                	ld	s2,16(sp)
    8000317c:	69a2                	ld	s3,8(sp)
    8000317e:	6145                	addi	sp,sp,48
    80003180:	8082                	ret
      addr = balloc(ip->dev);
    80003182:	0009a503          	lw	a0,0(s3)
    80003186:	e33ff0ef          	jal	80002fb8 <balloc>
    8000318a:	0005091b          	sext.w	s2,a0
      if(addr){
    8000318e:	fc090ee3          	beqz	s2,8000316a <bmap+0x92>
        a[bn] = addr;
    80003192:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003196:	8552                	mv	a0,s4
    80003198:	50f000ef          	jal	80003ea6 <log_write>
    8000319c:	b7f9                	j	8000316a <bmap+0x92>
    8000319e:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800031a0:	00004517          	auipc	a0,0x4
    800031a4:	3e850513          	addi	a0,a0,1000 # 80007588 <etext+0x588>
    800031a8:	decfd0ef          	jal	80000794 <panic>

00000000800031ac <iget>:
{
    800031ac:	7179                	addi	sp,sp,-48
    800031ae:	f406                	sd	ra,40(sp)
    800031b0:	f022                	sd	s0,32(sp)
    800031b2:	ec26                	sd	s1,24(sp)
    800031b4:	e84a                	sd	s2,16(sp)
    800031b6:	e44e                	sd	s3,8(sp)
    800031b8:	e052                	sd	s4,0(sp)
    800031ba:	1800                	addi	s0,sp,48
    800031bc:	89aa                	mv	s3,a0
    800031be:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800031c0:	00023517          	auipc	a0,0x23
    800031c4:	6f050513          	addi	a0,a0,1776 # 800268b0 <itable>
    800031c8:	a2dfd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    800031cc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031ce:	00023497          	auipc	s1,0x23
    800031d2:	6fa48493          	addi	s1,s1,1786 # 800268c8 <itable+0x18>
    800031d6:	00025697          	auipc	a3,0x25
    800031da:	18268693          	addi	a3,a3,386 # 80028358 <log>
    800031de:	a039                	j	800031ec <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800031e0:	02090963          	beqz	s2,80003212 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800031e4:	08848493          	addi	s1,s1,136
    800031e8:	02d48863          	beq	s1,a3,80003218 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800031ec:	449c                	lw	a5,8(s1)
    800031ee:	fef059e3          	blez	a5,800031e0 <iget+0x34>
    800031f2:	4098                	lw	a4,0(s1)
    800031f4:	ff3716e3          	bne	a4,s3,800031e0 <iget+0x34>
    800031f8:	40d8                	lw	a4,4(s1)
    800031fa:	ff4713e3          	bne	a4,s4,800031e0 <iget+0x34>
      ip->ref++;
    800031fe:	2785                	addiw	a5,a5,1
    80003200:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003202:	00023517          	auipc	a0,0x23
    80003206:	6ae50513          	addi	a0,a0,1710 # 800268b0 <itable>
    8000320a:	a83fd0ef          	jal	80000c8c <release>
      return ip;
    8000320e:	8926                	mv	s2,s1
    80003210:	a02d                	j	8000323a <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003212:	fbe9                	bnez	a5,800031e4 <iget+0x38>
      empty = ip;
    80003214:	8926                	mv	s2,s1
    80003216:	b7f9                	j	800031e4 <iget+0x38>
  if(empty == 0)
    80003218:	02090a63          	beqz	s2,8000324c <iget+0xa0>
  ip->dev = dev;
    8000321c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003220:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003224:	4785                	li	a5,1
    80003226:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000322a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000322e:	00023517          	auipc	a0,0x23
    80003232:	68250513          	addi	a0,a0,1666 # 800268b0 <itable>
    80003236:	a57fd0ef          	jal	80000c8c <release>
}
    8000323a:	854a                	mv	a0,s2
    8000323c:	70a2                	ld	ra,40(sp)
    8000323e:	7402                	ld	s0,32(sp)
    80003240:	64e2                	ld	s1,24(sp)
    80003242:	6942                	ld	s2,16(sp)
    80003244:	69a2                	ld	s3,8(sp)
    80003246:	6a02                	ld	s4,0(sp)
    80003248:	6145                	addi	sp,sp,48
    8000324a:	8082                	ret
    panic("iget: no inodes");
    8000324c:	00004517          	auipc	a0,0x4
    80003250:	35450513          	addi	a0,a0,852 # 800075a0 <etext+0x5a0>
    80003254:	d40fd0ef          	jal	80000794 <panic>

0000000080003258 <fsinit>:
fsinit(int dev) {
    80003258:	7179                	addi	sp,sp,-48
    8000325a:	f406                	sd	ra,40(sp)
    8000325c:	f022                	sd	s0,32(sp)
    8000325e:	ec26                	sd	s1,24(sp)
    80003260:	e84a                	sd	s2,16(sp)
    80003262:	e44e                	sd	s3,8(sp)
    80003264:	1800                	addi	s0,sp,48
    80003266:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003268:	4585                	li	a1,1
    8000326a:	aebff0ef          	jal	80002d54 <bread>
    8000326e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003270:	00023997          	auipc	s3,0x23
    80003274:	62098993          	addi	s3,s3,1568 # 80026890 <sb>
    80003278:	02000613          	li	a2,32
    8000327c:	05850593          	addi	a1,a0,88
    80003280:	854e                	mv	a0,s3
    80003282:	aa3fd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    80003286:	8526                	mv	a0,s1
    80003288:	bd5ff0ef          	jal	80002e5c <brelse>
  if(sb.magic != FSMAGIC)
    8000328c:	0009a703          	lw	a4,0(s3)
    80003290:	102037b7          	lui	a5,0x10203
    80003294:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003298:	02f71063          	bne	a4,a5,800032b8 <fsinit+0x60>
  initlog(dev, &sb);
    8000329c:	00023597          	auipc	a1,0x23
    800032a0:	5f458593          	addi	a1,a1,1524 # 80026890 <sb>
    800032a4:	854a                	mv	a0,s2
    800032a6:	1f9000ef          	jal	80003c9e <initlog>
}
    800032aa:	70a2                	ld	ra,40(sp)
    800032ac:	7402                	ld	s0,32(sp)
    800032ae:	64e2                	ld	s1,24(sp)
    800032b0:	6942                	ld	s2,16(sp)
    800032b2:	69a2                	ld	s3,8(sp)
    800032b4:	6145                	addi	sp,sp,48
    800032b6:	8082                	ret
    panic("invalid file system");
    800032b8:	00004517          	auipc	a0,0x4
    800032bc:	2f850513          	addi	a0,a0,760 # 800075b0 <etext+0x5b0>
    800032c0:	cd4fd0ef          	jal	80000794 <panic>

00000000800032c4 <iinit>:
{
    800032c4:	7179                	addi	sp,sp,-48
    800032c6:	f406                	sd	ra,40(sp)
    800032c8:	f022                	sd	s0,32(sp)
    800032ca:	ec26                	sd	s1,24(sp)
    800032cc:	e84a                	sd	s2,16(sp)
    800032ce:	e44e                	sd	s3,8(sp)
    800032d0:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800032d2:	00004597          	auipc	a1,0x4
    800032d6:	2f658593          	addi	a1,a1,758 # 800075c8 <etext+0x5c8>
    800032da:	00023517          	auipc	a0,0x23
    800032de:	5d650513          	addi	a0,a0,1494 # 800268b0 <itable>
    800032e2:	893fd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    800032e6:	00023497          	auipc	s1,0x23
    800032ea:	5f248493          	addi	s1,s1,1522 # 800268d8 <itable+0x28>
    800032ee:	00025997          	auipc	s3,0x25
    800032f2:	07a98993          	addi	s3,s3,122 # 80028368 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800032f6:	00004917          	auipc	s2,0x4
    800032fa:	2da90913          	addi	s2,s2,730 # 800075d0 <etext+0x5d0>
    800032fe:	85ca                	mv	a1,s2
    80003300:	8526                	mv	a0,s1
    80003302:	475000ef          	jal	80003f76 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003306:	08848493          	addi	s1,s1,136
    8000330a:	ff349ae3          	bne	s1,s3,800032fe <iinit+0x3a>
}
    8000330e:	70a2                	ld	ra,40(sp)
    80003310:	7402                	ld	s0,32(sp)
    80003312:	64e2                	ld	s1,24(sp)
    80003314:	6942                	ld	s2,16(sp)
    80003316:	69a2                	ld	s3,8(sp)
    80003318:	6145                	addi	sp,sp,48
    8000331a:	8082                	ret

000000008000331c <ialloc>:
{
    8000331c:	7139                	addi	sp,sp,-64
    8000331e:	fc06                	sd	ra,56(sp)
    80003320:	f822                	sd	s0,48(sp)
    80003322:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003324:	00023717          	auipc	a4,0x23
    80003328:	57872703          	lw	a4,1400(a4) # 8002689c <sb+0xc>
    8000332c:	4785                	li	a5,1
    8000332e:	06e7f063          	bgeu	a5,a4,8000338e <ialloc+0x72>
    80003332:	f426                	sd	s1,40(sp)
    80003334:	f04a                	sd	s2,32(sp)
    80003336:	ec4e                	sd	s3,24(sp)
    80003338:	e852                	sd	s4,16(sp)
    8000333a:	e456                	sd	s5,8(sp)
    8000333c:	e05a                	sd	s6,0(sp)
    8000333e:	8aaa                	mv	s5,a0
    80003340:	8b2e                	mv	s6,a1
    80003342:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003344:	00023a17          	auipc	s4,0x23
    80003348:	54ca0a13          	addi	s4,s4,1356 # 80026890 <sb>
    8000334c:	00495593          	srli	a1,s2,0x4
    80003350:	018a2783          	lw	a5,24(s4)
    80003354:	9dbd                	addw	a1,a1,a5
    80003356:	8556                	mv	a0,s5
    80003358:	9fdff0ef          	jal	80002d54 <bread>
    8000335c:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    8000335e:	05850993          	addi	s3,a0,88
    80003362:	00f97793          	andi	a5,s2,15
    80003366:	079a                	slli	a5,a5,0x6
    80003368:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000336a:	00099783          	lh	a5,0(s3)
    8000336e:	cb9d                	beqz	a5,800033a4 <ialloc+0x88>
    brelse(bp);
    80003370:	aedff0ef          	jal	80002e5c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003374:	0905                	addi	s2,s2,1
    80003376:	00ca2703          	lw	a4,12(s4)
    8000337a:	0009079b          	sext.w	a5,s2
    8000337e:	fce7e7e3          	bltu	a5,a4,8000334c <ialloc+0x30>
    80003382:	74a2                	ld	s1,40(sp)
    80003384:	7902                	ld	s2,32(sp)
    80003386:	69e2                	ld	s3,24(sp)
    80003388:	6a42                	ld	s4,16(sp)
    8000338a:	6aa2                	ld	s5,8(sp)
    8000338c:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000338e:	00004517          	auipc	a0,0x4
    80003392:	24a50513          	addi	a0,a0,586 # 800075d8 <etext+0x5d8>
    80003396:	92cfd0ef          	jal	800004c2 <printf>
  return 0;
    8000339a:	4501                	li	a0,0
}
    8000339c:	70e2                	ld	ra,56(sp)
    8000339e:	7442                	ld	s0,48(sp)
    800033a0:	6121                	addi	sp,sp,64
    800033a2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800033a4:	04000613          	li	a2,64
    800033a8:	4581                	li	a1,0
    800033aa:	854e                	mv	a0,s3
    800033ac:	91dfd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800033b0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800033b4:	8526                	mv	a0,s1
    800033b6:	2f1000ef          	jal	80003ea6 <log_write>
      brelse(bp);
    800033ba:	8526                	mv	a0,s1
    800033bc:	aa1ff0ef          	jal	80002e5c <brelse>
      return iget(dev, inum);
    800033c0:	0009059b          	sext.w	a1,s2
    800033c4:	8556                	mv	a0,s5
    800033c6:	de7ff0ef          	jal	800031ac <iget>
    800033ca:	74a2                	ld	s1,40(sp)
    800033cc:	7902                	ld	s2,32(sp)
    800033ce:	69e2                	ld	s3,24(sp)
    800033d0:	6a42                	ld	s4,16(sp)
    800033d2:	6aa2                	ld	s5,8(sp)
    800033d4:	6b02                	ld	s6,0(sp)
    800033d6:	b7d9                	j	8000339c <ialloc+0x80>

00000000800033d8 <iupdate>:
{
    800033d8:	1101                	addi	sp,sp,-32
    800033da:	ec06                	sd	ra,24(sp)
    800033dc:	e822                	sd	s0,16(sp)
    800033de:	e426                	sd	s1,8(sp)
    800033e0:	e04a                	sd	s2,0(sp)
    800033e2:	1000                	addi	s0,sp,32
    800033e4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800033e6:	415c                	lw	a5,4(a0)
    800033e8:	0047d79b          	srliw	a5,a5,0x4
    800033ec:	00023597          	auipc	a1,0x23
    800033f0:	4bc5a583          	lw	a1,1212(a1) # 800268a8 <sb+0x18>
    800033f4:	9dbd                	addw	a1,a1,a5
    800033f6:	4108                	lw	a0,0(a0)
    800033f8:	95dff0ef          	jal	80002d54 <bread>
    800033fc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800033fe:	05850793          	addi	a5,a0,88
    80003402:	40d8                	lw	a4,4(s1)
    80003404:	8b3d                	andi	a4,a4,15
    80003406:	071a                	slli	a4,a4,0x6
    80003408:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000340a:	04449703          	lh	a4,68(s1)
    8000340e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003412:	04649703          	lh	a4,70(s1)
    80003416:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000341a:	04849703          	lh	a4,72(s1)
    8000341e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003422:	04a49703          	lh	a4,74(s1)
    80003426:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000342a:	44f8                	lw	a4,76(s1)
    8000342c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000342e:	03400613          	li	a2,52
    80003432:	05048593          	addi	a1,s1,80
    80003436:	00c78513          	addi	a0,a5,12
    8000343a:	8ebfd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    8000343e:	854a                	mv	a0,s2
    80003440:	267000ef          	jal	80003ea6 <log_write>
  brelse(bp);
    80003444:	854a                	mv	a0,s2
    80003446:	a17ff0ef          	jal	80002e5c <brelse>
}
    8000344a:	60e2                	ld	ra,24(sp)
    8000344c:	6442                	ld	s0,16(sp)
    8000344e:	64a2                	ld	s1,8(sp)
    80003450:	6902                	ld	s2,0(sp)
    80003452:	6105                	addi	sp,sp,32
    80003454:	8082                	ret

0000000080003456 <idup>:
{
    80003456:	1101                	addi	sp,sp,-32
    80003458:	ec06                	sd	ra,24(sp)
    8000345a:	e822                	sd	s0,16(sp)
    8000345c:	e426                	sd	s1,8(sp)
    8000345e:	1000                	addi	s0,sp,32
    80003460:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003462:	00023517          	auipc	a0,0x23
    80003466:	44e50513          	addi	a0,a0,1102 # 800268b0 <itable>
    8000346a:	f8afd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    8000346e:	449c                	lw	a5,8(s1)
    80003470:	2785                	addiw	a5,a5,1
    80003472:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003474:	00023517          	auipc	a0,0x23
    80003478:	43c50513          	addi	a0,a0,1084 # 800268b0 <itable>
    8000347c:	811fd0ef          	jal	80000c8c <release>
}
    80003480:	8526                	mv	a0,s1
    80003482:	60e2                	ld	ra,24(sp)
    80003484:	6442                	ld	s0,16(sp)
    80003486:	64a2                	ld	s1,8(sp)
    80003488:	6105                	addi	sp,sp,32
    8000348a:	8082                	ret

000000008000348c <ilock>:
{
    8000348c:	1101                	addi	sp,sp,-32
    8000348e:	ec06                	sd	ra,24(sp)
    80003490:	e822                	sd	s0,16(sp)
    80003492:	e426                	sd	s1,8(sp)
    80003494:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003496:	cd19                	beqz	a0,800034b4 <ilock+0x28>
    80003498:	84aa                	mv	s1,a0
    8000349a:	451c                	lw	a5,8(a0)
    8000349c:	00f05c63          	blez	a5,800034b4 <ilock+0x28>
  acquiresleep(&ip->lock);
    800034a0:	0541                	addi	a0,a0,16
    800034a2:	30b000ef          	jal	80003fac <acquiresleep>
  if(ip->valid == 0){
    800034a6:	40bc                	lw	a5,64(s1)
    800034a8:	cf89                	beqz	a5,800034c2 <ilock+0x36>
}
    800034aa:	60e2                	ld	ra,24(sp)
    800034ac:	6442                	ld	s0,16(sp)
    800034ae:	64a2                	ld	s1,8(sp)
    800034b0:	6105                	addi	sp,sp,32
    800034b2:	8082                	ret
    800034b4:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800034b6:	00004517          	auipc	a0,0x4
    800034ba:	13a50513          	addi	a0,a0,314 # 800075f0 <etext+0x5f0>
    800034be:	ad6fd0ef          	jal	80000794 <panic>
    800034c2:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800034c4:	40dc                	lw	a5,4(s1)
    800034c6:	0047d79b          	srliw	a5,a5,0x4
    800034ca:	00023597          	auipc	a1,0x23
    800034ce:	3de5a583          	lw	a1,990(a1) # 800268a8 <sb+0x18>
    800034d2:	9dbd                	addw	a1,a1,a5
    800034d4:	4088                	lw	a0,0(s1)
    800034d6:	87fff0ef          	jal	80002d54 <bread>
    800034da:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800034dc:	05850593          	addi	a1,a0,88
    800034e0:	40dc                	lw	a5,4(s1)
    800034e2:	8bbd                	andi	a5,a5,15
    800034e4:	079a                	slli	a5,a5,0x6
    800034e6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800034e8:	00059783          	lh	a5,0(a1)
    800034ec:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800034f0:	00259783          	lh	a5,2(a1)
    800034f4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800034f8:	00459783          	lh	a5,4(a1)
    800034fc:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003500:	00659783          	lh	a5,6(a1)
    80003504:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003508:	459c                	lw	a5,8(a1)
    8000350a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000350c:	03400613          	li	a2,52
    80003510:	05b1                	addi	a1,a1,12
    80003512:	05048513          	addi	a0,s1,80
    80003516:	80ffd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    8000351a:	854a                	mv	a0,s2
    8000351c:	941ff0ef          	jal	80002e5c <brelse>
    ip->valid = 1;
    80003520:	4785                	li	a5,1
    80003522:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003524:	04449783          	lh	a5,68(s1)
    80003528:	c399                	beqz	a5,8000352e <ilock+0xa2>
    8000352a:	6902                	ld	s2,0(sp)
    8000352c:	bfbd                	j	800034aa <ilock+0x1e>
      panic("ilock: no type");
    8000352e:	00004517          	auipc	a0,0x4
    80003532:	0ca50513          	addi	a0,a0,202 # 800075f8 <etext+0x5f8>
    80003536:	a5efd0ef          	jal	80000794 <panic>

000000008000353a <iunlock>:
{
    8000353a:	1101                	addi	sp,sp,-32
    8000353c:	ec06                	sd	ra,24(sp)
    8000353e:	e822                	sd	s0,16(sp)
    80003540:	e426                	sd	s1,8(sp)
    80003542:	e04a                	sd	s2,0(sp)
    80003544:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003546:	c505                	beqz	a0,8000356e <iunlock+0x34>
    80003548:	84aa                	mv	s1,a0
    8000354a:	01050913          	addi	s2,a0,16
    8000354e:	854a                	mv	a0,s2
    80003550:	2db000ef          	jal	8000402a <holdingsleep>
    80003554:	cd09                	beqz	a0,8000356e <iunlock+0x34>
    80003556:	449c                	lw	a5,8(s1)
    80003558:	00f05b63          	blez	a5,8000356e <iunlock+0x34>
  releasesleep(&ip->lock);
    8000355c:	854a                	mv	a0,s2
    8000355e:	295000ef          	jal	80003ff2 <releasesleep>
}
    80003562:	60e2                	ld	ra,24(sp)
    80003564:	6442                	ld	s0,16(sp)
    80003566:	64a2                	ld	s1,8(sp)
    80003568:	6902                	ld	s2,0(sp)
    8000356a:	6105                	addi	sp,sp,32
    8000356c:	8082                	ret
    panic("iunlock");
    8000356e:	00004517          	auipc	a0,0x4
    80003572:	09a50513          	addi	a0,a0,154 # 80007608 <etext+0x608>
    80003576:	a1efd0ef          	jal	80000794 <panic>

000000008000357a <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000357a:	7179                	addi	sp,sp,-48
    8000357c:	f406                	sd	ra,40(sp)
    8000357e:	f022                	sd	s0,32(sp)
    80003580:	ec26                	sd	s1,24(sp)
    80003582:	e84a                	sd	s2,16(sp)
    80003584:	e44e                	sd	s3,8(sp)
    80003586:	1800                	addi	s0,sp,48
    80003588:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000358a:	05050493          	addi	s1,a0,80
    8000358e:	08050913          	addi	s2,a0,128
    80003592:	a021                	j	8000359a <itrunc+0x20>
    80003594:	0491                	addi	s1,s1,4
    80003596:	01248b63          	beq	s1,s2,800035ac <itrunc+0x32>
    if(ip->addrs[i]){
    8000359a:	408c                	lw	a1,0(s1)
    8000359c:	dde5                	beqz	a1,80003594 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000359e:	0009a503          	lw	a0,0(s3)
    800035a2:	9abff0ef          	jal	80002f4c <bfree>
      ip->addrs[i] = 0;
    800035a6:	0004a023          	sw	zero,0(s1)
    800035aa:	b7ed                	j	80003594 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800035ac:	0809a583          	lw	a1,128(s3)
    800035b0:	ed89                	bnez	a1,800035ca <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800035b2:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800035b6:	854e                	mv	a0,s3
    800035b8:	e21ff0ef          	jal	800033d8 <iupdate>
}
    800035bc:	70a2                	ld	ra,40(sp)
    800035be:	7402                	ld	s0,32(sp)
    800035c0:	64e2                	ld	s1,24(sp)
    800035c2:	6942                	ld	s2,16(sp)
    800035c4:	69a2                	ld	s3,8(sp)
    800035c6:	6145                	addi	sp,sp,48
    800035c8:	8082                	ret
    800035ca:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800035cc:	0009a503          	lw	a0,0(s3)
    800035d0:	f84ff0ef          	jal	80002d54 <bread>
    800035d4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800035d6:	05850493          	addi	s1,a0,88
    800035da:	45850913          	addi	s2,a0,1112
    800035de:	a021                	j	800035e6 <itrunc+0x6c>
    800035e0:	0491                	addi	s1,s1,4
    800035e2:	01248963          	beq	s1,s2,800035f4 <itrunc+0x7a>
      if(a[j])
    800035e6:	408c                	lw	a1,0(s1)
    800035e8:	dde5                	beqz	a1,800035e0 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800035ea:	0009a503          	lw	a0,0(s3)
    800035ee:	95fff0ef          	jal	80002f4c <bfree>
    800035f2:	b7fd                	j	800035e0 <itrunc+0x66>
    brelse(bp);
    800035f4:	8552                	mv	a0,s4
    800035f6:	867ff0ef          	jal	80002e5c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800035fa:	0809a583          	lw	a1,128(s3)
    800035fe:	0009a503          	lw	a0,0(s3)
    80003602:	94bff0ef          	jal	80002f4c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003606:	0809a023          	sw	zero,128(s3)
    8000360a:	6a02                	ld	s4,0(sp)
    8000360c:	b75d                	j	800035b2 <itrunc+0x38>

000000008000360e <iput>:
{
    8000360e:	1101                	addi	sp,sp,-32
    80003610:	ec06                	sd	ra,24(sp)
    80003612:	e822                	sd	s0,16(sp)
    80003614:	e426                	sd	s1,8(sp)
    80003616:	1000                	addi	s0,sp,32
    80003618:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000361a:	00023517          	auipc	a0,0x23
    8000361e:	29650513          	addi	a0,a0,662 # 800268b0 <itable>
    80003622:	dd2fd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003626:	4498                	lw	a4,8(s1)
    80003628:	4785                	li	a5,1
    8000362a:	02f70063          	beq	a4,a5,8000364a <iput+0x3c>
  ip->ref--;
    8000362e:	449c                	lw	a5,8(s1)
    80003630:	37fd                	addiw	a5,a5,-1
    80003632:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003634:	00023517          	auipc	a0,0x23
    80003638:	27c50513          	addi	a0,a0,636 # 800268b0 <itable>
    8000363c:	e50fd0ef          	jal	80000c8c <release>
}
    80003640:	60e2                	ld	ra,24(sp)
    80003642:	6442                	ld	s0,16(sp)
    80003644:	64a2                	ld	s1,8(sp)
    80003646:	6105                	addi	sp,sp,32
    80003648:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000364a:	40bc                	lw	a5,64(s1)
    8000364c:	d3ed                	beqz	a5,8000362e <iput+0x20>
    8000364e:	04a49783          	lh	a5,74(s1)
    80003652:	fff1                	bnez	a5,8000362e <iput+0x20>
    80003654:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003656:	01048913          	addi	s2,s1,16
    8000365a:	854a                	mv	a0,s2
    8000365c:	151000ef          	jal	80003fac <acquiresleep>
    release(&itable.lock);
    80003660:	00023517          	auipc	a0,0x23
    80003664:	25050513          	addi	a0,a0,592 # 800268b0 <itable>
    80003668:	e24fd0ef          	jal	80000c8c <release>
    itrunc(ip);
    8000366c:	8526                	mv	a0,s1
    8000366e:	f0dff0ef          	jal	8000357a <itrunc>
    ip->type = 0;
    80003672:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003676:	8526                	mv	a0,s1
    80003678:	d61ff0ef          	jal	800033d8 <iupdate>
    ip->valid = 0;
    8000367c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003680:	854a                	mv	a0,s2
    80003682:	171000ef          	jal	80003ff2 <releasesleep>
    acquire(&itable.lock);
    80003686:	00023517          	auipc	a0,0x23
    8000368a:	22a50513          	addi	a0,a0,554 # 800268b0 <itable>
    8000368e:	d66fd0ef          	jal	80000bf4 <acquire>
    80003692:	6902                	ld	s2,0(sp)
    80003694:	bf69                	j	8000362e <iput+0x20>

0000000080003696 <iunlockput>:
{
    80003696:	1101                	addi	sp,sp,-32
    80003698:	ec06                	sd	ra,24(sp)
    8000369a:	e822                	sd	s0,16(sp)
    8000369c:	e426                	sd	s1,8(sp)
    8000369e:	1000                	addi	s0,sp,32
    800036a0:	84aa                	mv	s1,a0
  iunlock(ip);
    800036a2:	e99ff0ef          	jal	8000353a <iunlock>
  iput(ip);
    800036a6:	8526                	mv	a0,s1
    800036a8:	f67ff0ef          	jal	8000360e <iput>
}
    800036ac:	60e2                	ld	ra,24(sp)
    800036ae:	6442                	ld	s0,16(sp)
    800036b0:	64a2                	ld	s1,8(sp)
    800036b2:	6105                	addi	sp,sp,32
    800036b4:	8082                	ret

00000000800036b6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800036b6:	1141                	addi	sp,sp,-16
    800036b8:	e422                	sd	s0,8(sp)
    800036ba:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800036bc:	411c                	lw	a5,0(a0)
    800036be:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800036c0:	415c                	lw	a5,4(a0)
    800036c2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800036c4:	04451783          	lh	a5,68(a0)
    800036c8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800036cc:	04a51783          	lh	a5,74(a0)
    800036d0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800036d4:	04c56783          	lwu	a5,76(a0)
    800036d8:	e99c                	sd	a5,16(a1)
}
    800036da:	6422                	ld	s0,8(sp)
    800036dc:	0141                	addi	sp,sp,16
    800036de:	8082                	ret

00000000800036e0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800036e0:	457c                	lw	a5,76(a0)
    800036e2:	0ed7eb63          	bltu	a5,a3,800037d8 <readi+0xf8>
{
    800036e6:	7159                	addi	sp,sp,-112
    800036e8:	f486                	sd	ra,104(sp)
    800036ea:	f0a2                	sd	s0,96(sp)
    800036ec:	eca6                	sd	s1,88(sp)
    800036ee:	e0d2                	sd	s4,64(sp)
    800036f0:	fc56                	sd	s5,56(sp)
    800036f2:	f85a                	sd	s6,48(sp)
    800036f4:	f45e                	sd	s7,40(sp)
    800036f6:	1880                	addi	s0,sp,112
    800036f8:	8b2a                	mv	s6,a0
    800036fa:	8bae                	mv	s7,a1
    800036fc:	8a32                	mv	s4,a2
    800036fe:	84b6                	mv	s1,a3
    80003700:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003702:	9f35                	addw	a4,a4,a3
    return 0;
    80003704:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003706:	0cd76063          	bltu	a4,a3,800037c6 <readi+0xe6>
    8000370a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000370c:	00e7f463          	bgeu	a5,a4,80003714 <readi+0x34>
    n = ip->size - off;
    80003710:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003714:	080a8f63          	beqz	s5,800037b2 <readi+0xd2>
    80003718:	e8ca                	sd	s2,80(sp)
    8000371a:	f062                	sd	s8,32(sp)
    8000371c:	ec66                	sd	s9,24(sp)
    8000371e:	e86a                	sd	s10,16(sp)
    80003720:	e46e                	sd	s11,8(sp)
    80003722:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003724:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003728:	5c7d                	li	s8,-1
    8000372a:	a80d                	j	8000375c <readi+0x7c>
    8000372c:	020d1d93          	slli	s11,s10,0x20
    80003730:	020ddd93          	srli	s11,s11,0x20
    80003734:	05890613          	addi	a2,s2,88
    80003738:	86ee                	mv	a3,s11
    8000373a:	963a                	add	a2,a2,a4
    8000373c:	85d2                	mv	a1,s4
    8000373e:	855e                	mv	a0,s7
    80003740:	b13fe0ef          	jal	80002252 <either_copyout>
    80003744:	05850763          	beq	a0,s8,80003792 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003748:	854a                	mv	a0,s2
    8000374a:	f12ff0ef          	jal	80002e5c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000374e:	013d09bb          	addw	s3,s10,s3
    80003752:	009d04bb          	addw	s1,s10,s1
    80003756:	9a6e                	add	s4,s4,s11
    80003758:	0559f763          	bgeu	s3,s5,800037a6 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    8000375c:	00a4d59b          	srliw	a1,s1,0xa
    80003760:	855a                	mv	a0,s6
    80003762:	977ff0ef          	jal	800030d8 <bmap>
    80003766:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000376a:	c5b1                	beqz	a1,800037b6 <readi+0xd6>
    bp = bread(ip->dev, addr);
    8000376c:	000b2503          	lw	a0,0(s6)
    80003770:	de4ff0ef          	jal	80002d54 <bread>
    80003774:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003776:	3ff4f713          	andi	a4,s1,1023
    8000377a:	40ec87bb          	subw	a5,s9,a4
    8000377e:	413a86bb          	subw	a3,s5,s3
    80003782:	8d3e                	mv	s10,a5
    80003784:	2781                	sext.w	a5,a5
    80003786:	0006861b          	sext.w	a2,a3
    8000378a:	faf671e3          	bgeu	a2,a5,8000372c <readi+0x4c>
    8000378e:	8d36                	mv	s10,a3
    80003790:	bf71                	j	8000372c <readi+0x4c>
      brelse(bp);
    80003792:	854a                	mv	a0,s2
    80003794:	ec8ff0ef          	jal	80002e5c <brelse>
      tot = -1;
    80003798:	59fd                	li	s3,-1
      break;
    8000379a:	6946                	ld	s2,80(sp)
    8000379c:	7c02                	ld	s8,32(sp)
    8000379e:	6ce2                	ld	s9,24(sp)
    800037a0:	6d42                	ld	s10,16(sp)
    800037a2:	6da2                	ld	s11,8(sp)
    800037a4:	a831                	j	800037c0 <readi+0xe0>
    800037a6:	6946                	ld	s2,80(sp)
    800037a8:	7c02                	ld	s8,32(sp)
    800037aa:	6ce2                	ld	s9,24(sp)
    800037ac:	6d42                	ld	s10,16(sp)
    800037ae:	6da2                	ld	s11,8(sp)
    800037b0:	a801                	j	800037c0 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800037b2:	89d6                	mv	s3,s5
    800037b4:	a031                	j	800037c0 <readi+0xe0>
    800037b6:	6946                	ld	s2,80(sp)
    800037b8:	7c02                	ld	s8,32(sp)
    800037ba:	6ce2                	ld	s9,24(sp)
    800037bc:	6d42                	ld	s10,16(sp)
    800037be:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800037c0:	0009851b          	sext.w	a0,s3
    800037c4:	69a6                	ld	s3,72(sp)
}
    800037c6:	70a6                	ld	ra,104(sp)
    800037c8:	7406                	ld	s0,96(sp)
    800037ca:	64e6                	ld	s1,88(sp)
    800037cc:	6a06                	ld	s4,64(sp)
    800037ce:	7ae2                	ld	s5,56(sp)
    800037d0:	7b42                	ld	s6,48(sp)
    800037d2:	7ba2                	ld	s7,40(sp)
    800037d4:	6165                	addi	sp,sp,112
    800037d6:	8082                	ret
    return 0;
    800037d8:	4501                	li	a0,0
}
    800037da:	8082                	ret

00000000800037dc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800037dc:	457c                	lw	a5,76(a0)
    800037de:	10d7e063          	bltu	a5,a3,800038de <writei+0x102>
{
    800037e2:	7159                	addi	sp,sp,-112
    800037e4:	f486                	sd	ra,104(sp)
    800037e6:	f0a2                	sd	s0,96(sp)
    800037e8:	e8ca                	sd	s2,80(sp)
    800037ea:	e0d2                	sd	s4,64(sp)
    800037ec:	fc56                	sd	s5,56(sp)
    800037ee:	f85a                	sd	s6,48(sp)
    800037f0:	f45e                	sd	s7,40(sp)
    800037f2:	1880                	addi	s0,sp,112
    800037f4:	8aaa                	mv	s5,a0
    800037f6:	8bae                	mv	s7,a1
    800037f8:	8a32                	mv	s4,a2
    800037fa:	8936                	mv	s2,a3
    800037fc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800037fe:	00e687bb          	addw	a5,a3,a4
    80003802:	0ed7e063          	bltu	a5,a3,800038e2 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003806:	00043737          	lui	a4,0x43
    8000380a:	0cf76e63          	bltu	a4,a5,800038e6 <writei+0x10a>
    8000380e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003810:	0a0b0f63          	beqz	s6,800038ce <writei+0xf2>
    80003814:	eca6                	sd	s1,88(sp)
    80003816:	f062                	sd	s8,32(sp)
    80003818:	ec66                	sd	s9,24(sp)
    8000381a:	e86a                	sd	s10,16(sp)
    8000381c:	e46e                	sd	s11,8(sp)
    8000381e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003820:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003824:	5c7d                	li	s8,-1
    80003826:	a825                	j	8000385e <writei+0x82>
    80003828:	020d1d93          	slli	s11,s10,0x20
    8000382c:	020ddd93          	srli	s11,s11,0x20
    80003830:	05848513          	addi	a0,s1,88
    80003834:	86ee                	mv	a3,s11
    80003836:	8652                	mv	a2,s4
    80003838:	85de                	mv	a1,s7
    8000383a:	953a                	add	a0,a0,a4
    8000383c:	a61fe0ef          	jal	8000229c <either_copyin>
    80003840:	05850a63          	beq	a0,s8,80003894 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003844:	8526                	mv	a0,s1
    80003846:	660000ef          	jal	80003ea6 <log_write>
    brelse(bp);
    8000384a:	8526                	mv	a0,s1
    8000384c:	e10ff0ef          	jal	80002e5c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003850:	013d09bb          	addw	s3,s10,s3
    80003854:	012d093b          	addw	s2,s10,s2
    80003858:	9a6e                	add	s4,s4,s11
    8000385a:	0569f063          	bgeu	s3,s6,8000389a <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000385e:	00a9559b          	srliw	a1,s2,0xa
    80003862:	8556                	mv	a0,s5
    80003864:	875ff0ef          	jal	800030d8 <bmap>
    80003868:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000386c:	c59d                	beqz	a1,8000389a <writei+0xbe>
    bp = bread(ip->dev, addr);
    8000386e:	000aa503          	lw	a0,0(s5)
    80003872:	ce2ff0ef          	jal	80002d54 <bread>
    80003876:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003878:	3ff97713          	andi	a4,s2,1023
    8000387c:	40ec87bb          	subw	a5,s9,a4
    80003880:	413b06bb          	subw	a3,s6,s3
    80003884:	8d3e                	mv	s10,a5
    80003886:	2781                	sext.w	a5,a5
    80003888:	0006861b          	sext.w	a2,a3
    8000388c:	f8f67ee3          	bgeu	a2,a5,80003828 <writei+0x4c>
    80003890:	8d36                	mv	s10,a3
    80003892:	bf59                	j	80003828 <writei+0x4c>
      brelse(bp);
    80003894:	8526                	mv	a0,s1
    80003896:	dc6ff0ef          	jal	80002e5c <brelse>
  }

  if(off > ip->size)
    8000389a:	04caa783          	lw	a5,76(s5)
    8000389e:	0327fa63          	bgeu	a5,s2,800038d2 <writei+0xf6>
    ip->size = off;
    800038a2:	052aa623          	sw	s2,76(s5)
    800038a6:	64e6                	ld	s1,88(sp)
    800038a8:	7c02                	ld	s8,32(sp)
    800038aa:	6ce2                	ld	s9,24(sp)
    800038ac:	6d42                	ld	s10,16(sp)
    800038ae:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800038b0:	8556                	mv	a0,s5
    800038b2:	b27ff0ef          	jal	800033d8 <iupdate>

  return tot;
    800038b6:	0009851b          	sext.w	a0,s3
    800038ba:	69a6                	ld	s3,72(sp)
}
    800038bc:	70a6                	ld	ra,104(sp)
    800038be:	7406                	ld	s0,96(sp)
    800038c0:	6946                	ld	s2,80(sp)
    800038c2:	6a06                	ld	s4,64(sp)
    800038c4:	7ae2                	ld	s5,56(sp)
    800038c6:	7b42                	ld	s6,48(sp)
    800038c8:	7ba2                	ld	s7,40(sp)
    800038ca:	6165                	addi	sp,sp,112
    800038cc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800038ce:	89da                	mv	s3,s6
    800038d0:	b7c5                	j	800038b0 <writei+0xd4>
    800038d2:	64e6                	ld	s1,88(sp)
    800038d4:	7c02                	ld	s8,32(sp)
    800038d6:	6ce2                	ld	s9,24(sp)
    800038d8:	6d42                	ld	s10,16(sp)
    800038da:	6da2                	ld	s11,8(sp)
    800038dc:	bfd1                	j	800038b0 <writei+0xd4>
    return -1;
    800038de:	557d                	li	a0,-1
}
    800038e0:	8082                	ret
    return -1;
    800038e2:	557d                	li	a0,-1
    800038e4:	bfe1                	j	800038bc <writei+0xe0>
    return -1;
    800038e6:	557d                	li	a0,-1
    800038e8:	bfd1                	j	800038bc <writei+0xe0>

00000000800038ea <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800038ea:	1141                	addi	sp,sp,-16
    800038ec:	e406                	sd	ra,8(sp)
    800038ee:	e022                	sd	s0,0(sp)
    800038f0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800038f2:	4639                	li	a2,14
    800038f4:	ca0fd0ef          	jal	80000d94 <strncmp>
}
    800038f8:	60a2                	ld	ra,8(sp)
    800038fa:	6402                	ld	s0,0(sp)
    800038fc:	0141                	addi	sp,sp,16
    800038fe:	8082                	ret

0000000080003900 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003900:	7139                	addi	sp,sp,-64
    80003902:	fc06                	sd	ra,56(sp)
    80003904:	f822                	sd	s0,48(sp)
    80003906:	f426                	sd	s1,40(sp)
    80003908:	f04a                	sd	s2,32(sp)
    8000390a:	ec4e                	sd	s3,24(sp)
    8000390c:	e852                	sd	s4,16(sp)
    8000390e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003910:	04451703          	lh	a4,68(a0)
    80003914:	4785                	li	a5,1
    80003916:	00f71a63          	bne	a4,a5,8000392a <dirlookup+0x2a>
    8000391a:	892a                	mv	s2,a0
    8000391c:	89ae                	mv	s3,a1
    8000391e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003920:	457c                	lw	a5,76(a0)
    80003922:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003924:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003926:	e39d                	bnez	a5,8000394c <dirlookup+0x4c>
    80003928:	a095                	j	8000398c <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000392a:	00004517          	auipc	a0,0x4
    8000392e:	ce650513          	addi	a0,a0,-794 # 80007610 <etext+0x610>
    80003932:	e63fc0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    80003936:	00004517          	auipc	a0,0x4
    8000393a:	cf250513          	addi	a0,a0,-782 # 80007628 <etext+0x628>
    8000393e:	e57fc0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003942:	24c1                	addiw	s1,s1,16
    80003944:	04c92783          	lw	a5,76(s2)
    80003948:	04f4f163          	bgeu	s1,a5,8000398a <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000394c:	4741                	li	a4,16
    8000394e:	86a6                	mv	a3,s1
    80003950:	fc040613          	addi	a2,s0,-64
    80003954:	4581                	li	a1,0
    80003956:	854a                	mv	a0,s2
    80003958:	d89ff0ef          	jal	800036e0 <readi>
    8000395c:	47c1                	li	a5,16
    8000395e:	fcf51ce3          	bne	a0,a5,80003936 <dirlookup+0x36>
    if(de.inum == 0)
    80003962:	fc045783          	lhu	a5,-64(s0)
    80003966:	dff1                	beqz	a5,80003942 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003968:	fc240593          	addi	a1,s0,-62
    8000396c:	854e                	mv	a0,s3
    8000396e:	f7dff0ef          	jal	800038ea <namecmp>
    80003972:	f961                	bnez	a0,80003942 <dirlookup+0x42>
      if(poff)
    80003974:	000a0463          	beqz	s4,8000397c <dirlookup+0x7c>
        *poff = off;
    80003978:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000397c:	fc045583          	lhu	a1,-64(s0)
    80003980:	00092503          	lw	a0,0(s2)
    80003984:	829ff0ef          	jal	800031ac <iget>
    80003988:	a011                	j	8000398c <dirlookup+0x8c>
  return 0;
    8000398a:	4501                	li	a0,0
}
    8000398c:	70e2                	ld	ra,56(sp)
    8000398e:	7442                	ld	s0,48(sp)
    80003990:	74a2                	ld	s1,40(sp)
    80003992:	7902                	ld	s2,32(sp)
    80003994:	69e2                	ld	s3,24(sp)
    80003996:	6a42                	ld	s4,16(sp)
    80003998:	6121                	addi	sp,sp,64
    8000399a:	8082                	ret

000000008000399c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000399c:	711d                	addi	sp,sp,-96
    8000399e:	ec86                	sd	ra,88(sp)
    800039a0:	e8a2                	sd	s0,80(sp)
    800039a2:	e4a6                	sd	s1,72(sp)
    800039a4:	e0ca                	sd	s2,64(sp)
    800039a6:	fc4e                	sd	s3,56(sp)
    800039a8:	f852                	sd	s4,48(sp)
    800039aa:	f456                	sd	s5,40(sp)
    800039ac:	f05a                	sd	s6,32(sp)
    800039ae:	ec5e                	sd	s7,24(sp)
    800039b0:	e862                	sd	s8,16(sp)
    800039b2:	e466                	sd	s9,8(sp)
    800039b4:	1080                	addi	s0,sp,96
    800039b6:	84aa                	mv	s1,a0
    800039b8:	8b2e                	mv	s6,a1
    800039ba:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800039bc:	00054703          	lbu	a4,0(a0)
    800039c0:	02f00793          	li	a5,47
    800039c4:	00f70e63          	beq	a4,a5,800039e0 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800039c8:	f19fd0ef          	jal	800018e0 <myproc>
    800039cc:	15853503          	ld	a0,344(a0)
    800039d0:	a87ff0ef          	jal	80003456 <idup>
    800039d4:	8a2a                	mv	s4,a0
  while(*path == '/')
    800039d6:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800039da:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800039dc:	4b85                	li	s7,1
    800039de:	a871                	j	80003a7a <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800039e0:	4585                	li	a1,1
    800039e2:	4505                	li	a0,1
    800039e4:	fc8ff0ef          	jal	800031ac <iget>
    800039e8:	8a2a                	mv	s4,a0
    800039ea:	b7f5                	j	800039d6 <namex+0x3a>
      iunlockput(ip);
    800039ec:	8552                	mv	a0,s4
    800039ee:	ca9ff0ef          	jal	80003696 <iunlockput>
      return 0;
    800039f2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800039f4:	8552                	mv	a0,s4
    800039f6:	60e6                	ld	ra,88(sp)
    800039f8:	6446                	ld	s0,80(sp)
    800039fa:	64a6                	ld	s1,72(sp)
    800039fc:	6906                	ld	s2,64(sp)
    800039fe:	79e2                	ld	s3,56(sp)
    80003a00:	7a42                	ld	s4,48(sp)
    80003a02:	7aa2                	ld	s5,40(sp)
    80003a04:	7b02                	ld	s6,32(sp)
    80003a06:	6be2                	ld	s7,24(sp)
    80003a08:	6c42                	ld	s8,16(sp)
    80003a0a:	6ca2                	ld	s9,8(sp)
    80003a0c:	6125                	addi	sp,sp,96
    80003a0e:	8082                	ret
      iunlock(ip);
    80003a10:	8552                	mv	a0,s4
    80003a12:	b29ff0ef          	jal	8000353a <iunlock>
      return ip;
    80003a16:	bff9                	j	800039f4 <namex+0x58>
      iunlockput(ip);
    80003a18:	8552                	mv	a0,s4
    80003a1a:	c7dff0ef          	jal	80003696 <iunlockput>
      return 0;
    80003a1e:	8a4e                	mv	s4,s3
    80003a20:	bfd1                	j	800039f4 <namex+0x58>
  len = path - s;
    80003a22:	40998633          	sub	a2,s3,s1
    80003a26:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003a2a:	099c5063          	bge	s8,s9,80003aaa <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003a2e:	4639                	li	a2,14
    80003a30:	85a6                	mv	a1,s1
    80003a32:	8556                	mv	a0,s5
    80003a34:	af0fd0ef          	jal	80000d24 <memmove>
    80003a38:	84ce                	mv	s1,s3
  while(*path == '/')
    80003a3a:	0004c783          	lbu	a5,0(s1)
    80003a3e:	01279763          	bne	a5,s2,80003a4c <namex+0xb0>
    path++;
    80003a42:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a44:	0004c783          	lbu	a5,0(s1)
    80003a48:	ff278de3          	beq	a5,s2,80003a42 <namex+0xa6>
    ilock(ip);
    80003a4c:	8552                	mv	a0,s4
    80003a4e:	a3fff0ef          	jal	8000348c <ilock>
    if(ip->type != T_DIR){
    80003a52:	044a1783          	lh	a5,68(s4)
    80003a56:	f9779be3          	bne	a5,s7,800039ec <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003a5a:	000b0563          	beqz	s6,80003a64 <namex+0xc8>
    80003a5e:	0004c783          	lbu	a5,0(s1)
    80003a62:	d7dd                	beqz	a5,80003a10 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003a64:	4601                	li	a2,0
    80003a66:	85d6                	mv	a1,s5
    80003a68:	8552                	mv	a0,s4
    80003a6a:	e97ff0ef          	jal	80003900 <dirlookup>
    80003a6e:	89aa                	mv	s3,a0
    80003a70:	d545                	beqz	a0,80003a18 <namex+0x7c>
    iunlockput(ip);
    80003a72:	8552                	mv	a0,s4
    80003a74:	c23ff0ef          	jal	80003696 <iunlockput>
    ip = next;
    80003a78:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003a7a:	0004c783          	lbu	a5,0(s1)
    80003a7e:	01279763          	bne	a5,s2,80003a8c <namex+0xf0>
    path++;
    80003a82:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003a84:	0004c783          	lbu	a5,0(s1)
    80003a88:	ff278de3          	beq	a5,s2,80003a82 <namex+0xe6>
  if(*path == 0)
    80003a8c:	cb8d                	beqz	a5,80003abe <namex+0x122>
  while(*path != '/' && *path != 0)
    80003a8e:	0004c783          	lbu	a5,0(s1)
    80003a92:	89a6                	mv	s3,s1
  len = path - s;
    80003a94:	4c81                	li	s9,0
    80003a96:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003a98:	01278963          	beq	a5,s2,80003aaa <namex+0x10e>
    80003a9c:	d3d9                	beqz	a5,80003a22 <namex+0x86>
    path++;
    80003a9e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003aa0:	0009c783          	lbu	a5,0(s3)
    80003aa4:	ff279ce3          	bne	a5,s2,80003a9c <namex+0x100>
    80003aa8:	bfad                	j	80003a22 <namex+0x86>
    memmove(name, s, len);
    80003aaa:	2601                	sext.w	a2,a2
    80003aac:	85a6                	mv	a1,s1
    80003aae:	8556                	mv	a0,s5
    80003ab0:	a74fd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    80003ab4:	9cd6                	add	s9,s9,s5
    80003ab6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003aba:	84ce                	mv	s1,s3
    80003abc:	bfbd                	j	80003a3a <namex+0x9e>
  if(nameiparent){
    80003abe:	f20b0be3          	beqz	s6,800039f4 <namex+0x58>
    iput(ip);
    80003ac2:	8552                	mv	a0,s4
    80003ac4:	b4bff0ef          	jal	8000360e <iput>
    return 0;
    80003ac8:	4a01                	li	s4,0
    80003aca:	b72d                	j	800039f4 <namex+0x58>

0000000080003acc <dirlink>:
{
    80003acc:	7139                	addi	sp,sp,-64
    80003ace:	fc06                	sd	ra,56(sp)
    80003ad0:	f822                	sd	s0,48(sp)
    80003ad2:	f04a                	sd	s2,32(sp)
    80003ad4:	ec4e                	sd	s3,24(sp)
    80003ad6:	e852                	sd	s4,16(sp)
    80003ad8:	0080                	addi	s0,sp,64
    80003ada:	892a                	mv	s2,a0
    80003adc:	8a2e                	mv	s4,a1
    80003ade:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ae0:	4601                	li	a2,0
    80003ae2:	e1fff0ef          	jal	80003900 <dirlookup>
    80003ae6:	e535                	bnez	a0,80003b52 <dirlink+0x86>
    80003ae8:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aea:	04c92483          	lw	s1,76(s2)
    80003aee:	c48d                	beqz	s1,80003b18 <dirlink+0x4c>
    80003af0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003af2:	4741                	li	a4,16
    80003af4:	86a6                	mv	a3,s1
    80003af6:	fc040613          	addi	a2,s0,-64
    80003afa:	4581                	li	a1,0
    80003afc:	854a                	mv	a0,s2
    80003afe:	be3ff0ef          	jal	800036e0 <readi>
    80003b02:	47c1                	li	a5,16
    80003b04:	04f51b63          	bne	a0,a5,80003b5a <dirlink+0x8e>
    if(de.inum == 0)
    80003b08:	fc045783          	lhu	a5,-64(s0)
    80003b0c:	c791                	beqz	a5,80003b18 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b0e:	24c1                	addiw	s1,s1,16
    80003b10:	04c92783          	lw	a5,76(s2)
    80003b14:	fcf4efe3          	bltu	s1,a5,80003af2 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003b18:	4639                	li	a2,14
    80003b1a:	85d2                	mv	a1,s4
    80003b1c:	fc240513          	addi	a0,s0,-62
    80003b20:	aaafd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    80003b24:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b28:	4741                	li	a4,16
    80003b2a:	86a6                	mv	a3,s1
    80003b2c:	fc040613          	addi	a2,s0,-64
    80003b30:	4581                	li	a1,0
    80003b32:	854a                	mv	a0,s2
    80003b34:	ca9ff0ef          	jal	800037dc <writei>
    80003b38:	1541                	addi	a0,a0,-16
    80003b3a:	00a03533          	snez	a0,a0
    80003b3e:	40a00533          	neg	a0,a0
    80003b42:	74a2                	ld	s1,40(sp)
}
    80003b44:	70e2                	ld	ra,56(sp)
    80003b46:	7442                	ld	s0,48(sp)
    80003b48:	7902                	ld	s2,32(sp)
    80003b4a:	69e2                	ld	s3,24(sp)
    80003b4c:	6a42                	ld	s4,16(sp)
    80003b4e:	6121                	addi	sp,sp,64
    80003b50:	8082                	ret
    iput(ip);
    80003b52:	abdff0ef          	jal	8000360e <iput>
    return -1;
    80003b56:	557d                	li	a0,-1
    80003b58:	b7f5                	j	80003b44 <dirlink+0x78>
      panic("dirlink read");
    80003b5a:	00004517          	auipc	a0,0x4
    80003b5e:	ade50513          	addi	a0,a0,-1314 # 80007638 <etext+0x638>
    80003b62:	c33fc0ef          	jal	80000794 <panic>

0000000080003b66 <namei>:

struct inode*
namei(char *path)
{
    80003b66:	1101                	addi	sp,sp,-32
    80003b68:	ec06                	sd	ra,24(sp)
    80003b6a:	e822                	sd	s0,16(sp)
    80003b6c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003b6e:	fe040613          	addi	a2,s0,-32
    80003b72:	4581                	li	a1,0
    80003b74:	e29ff0ef          	jal	8000399c <namex>
}
    80003b78:	60e2                	ld	ra,24(sp)
    80003b7a:	6442                	ld	s0,16(sp)
    80003b7c:	6105                	addi	sp,sp,32
    80003b7e:	8082                	ret

0000000080003b80 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003b80:	1141                	addi	sp,sp,-16
    80003b82:	e406                	sd	ra,8(sp)
    80003b84:	e022                	sd	s0,0(sp)
    80003b86:	0800                	addi	s0,sp,16
    80003b88:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003b8a:	4585                	li	a1,1
    80003b8c:	e11ff0ef          	jal	8000399c <namex>
}
    80003b90:	60a2                	ld	ra,8(sp)
    80003b92:	6402                	ld	s0,0(sp)
    80003b94:	0141                	addi	sp,sp,16
    80003b96:	8082                	ret

0000000080003b98 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003b98:	1101                	addi	sp,sp,-32
    80003b9a:	ec06                	sd	ra,24(sp)
    80003b9c:	e822                	sd	s0,16(sp)
    80003b9e:	e426                	sd	s1,8(sp)
    80003ba0:	e04a                	sd	s2,0(sp)
    80003ba2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ba4:	00024917          	auipc	s2,0x24
    80003ba8:	7b490913          	addi	s2,s2,1972 # 80028358 <log>
    80003bac:	01892583          	lw	a1,24(s2)
    80003bb0:	02892503          	lw	a0,40(s2)
    80003bb4:	9a0ff0ef          	jal	80002d54 <bread>
    80003bb8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003bba:	02c92603          	lw	a2,44(s2)
    80003bbe:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003bc0:	00c05f63          	blez	a2,80003bde <write_head+0x46>
    80003bc4:	00024717          	auipc	a4,0x24
    80003bc8:	7c470713          	addi	a4,a4,1988 # 80028388 <log+0x30>
    80003bcc:	87aa                	mv	a5,a0
    80003bce:	060a                	slli	a2,a2,0x2
    80003bd0:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003bd2:	4314                	lw	a3,0(a4)
    80003bd4:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003bd6:	0711                	addi	a4,a4,4
    80003bd8:	0791                	addi	a5,a5,4
    80003bda:	fec79ce3          	bne	a5,a2,80003bd2 <write_head+0x3a>
  }
  bwrite(buf);
    80003bde:	8526                	mv	a0,s1
    80003be0:	a4aff0ef          	jal	80002e2a <bwrite>
  brelse(buf);
    80003be4:	8526                	mv	a0,s1
    80003be6:	a76ff0ef          	jal	80002e5c <brelse>
}
    80003bea:	60e2                	ld	ra,24(sp)
    80003bec:	6442                	ld	s0,16(sp)
    80003bee:	64a2                	ld	s1,8(sp)
    80003bf0:	6902                	ld	s2,0(sp)
    80003bf2:	6105                	addi	sp,sp,32
    80003bf4:	8082                	ret

0000000080003bf6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bf6:	00024797          	auipc	a5,0x24
    80003bfa:	78e7a783          	lw	a5,1934(a5) # 80028384 <log+0x2c>
    80003bfe:	08f05f63          	blez	a5,80003c9c <install_trans+0xa6>
{
    80003c02:	7139                	addi	sp,sp,-64
    80003c04:	fc06                	sd	ra,56(sp)
    80003c06:	f822                	sd	s0,48(sp)
    80003c08:	f426                	sd	s1,40(sp)
    80003c0a:	f04a                	sd	s2,32(sp)
    80003c0c:	ec4e                	sd	s3,24(sp)
    80003c0e:	e852                	sd	s4,16(sp)
    80003c10:	e456                	sd	s5,8(sp)
    80003c12:	e05a                	sd	s6,0(sp)
    80003c14:	0080                	addi	s0,sp,64
    80003c16:	8b2a                	mv	s6,a0
    80003c18:	00024a97          	auipc	s5,0x24
    80003c1c:	770a8a93          	addi	s5,s5,1904 # 80028388 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c20:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c22:	00024997          	auipc	s3,0x24
    80003c26:	73698993          	addi	s3,s3,1846 # 80028358 <log>
    80003c2a:	a829                	j	80003c44 <install_trans+0x4e>
    brelse(lbuf);
    80003c2c:	854a                	mv	a0,s2
    80003c2e:	a2eff0ef          	jal	80002e5c <brelse>
    brelse(dbuf);
    80003c32:	8526                	mv	a0,s1
    80003c34:	a28ff0ef          	jal	80002e5c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c38:	2a05                	addiw	s4,s4,1
    80003c3a:	0a91                	addi	s5,s5,4
    80003c3c:	02c9a783          	lw	a5,44(s3)
    80003c40:	04fa5463          	bge	s4,a5,80003c88 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003c44:	0189a583          	lw	a1,24(s3)
    80003c48:	014585bb          	addw	a1,a1,s4
    80003c4c:	2585                	addiw	a1,a1,1
    80003c4e:	0289a503          	lw	a0,40(s3)
    80003c52:	902ff0ef          	jal	80002d54 <bread>
    80003c56:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003c58:	000aa583          	lw	a1,0(s5)
    80003c5c:	0289a503          	lw	a0,40(s3)
    80003c60:	8f4ff0ef          	jal	80002d54 <bread>
    80003c64:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003c66:	40000613          	li	a2,1024
    80003c6a:	05890593          	addi	a1,s2,88
    80003c6e:	05850513          	addi	a0,a0,88
    80003c72:	8b2fd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003c76:	8526                	mv	a0,s1
    80003c78:	9b2ff0ef          	jal	80002e2a <bwrite>
    if(recovering == 0)
    80003c7c:	fa0b18e3          	bnez	s6,80003c2c <install_trans+0x36>
      bunpin(dbuf);
    80003c80:	8526                	mv	a0,s1
    80003c82:	a96ff0ef          	jal	80002f18 <bunpin>
    80003c86:	b75d                	j	80003c2c <install_trans+0x36>
}
    80003c88:	70e2                	ld	ra,56(sp)
    80003c8a:	7442                	ld	s0,48(sp)
    80003c8c:	74a2                	ld	s1,40(sp)
    80003c8e:	7902                	ld	s2,32(sp)
    80003c90:	69e2                	ld	s3,24(sp)
    80003c92:	6a42                	ld	s4,16(sp)
    80003c94:	6aa2                	ld	s5,8(sp)
    80003c96:	6b02                	ld	s6,0(sp)
    80003c98:	6121                	addi	sp,sp,64
    80003c9a:	8082                	ret
    80003c9c:	8082                	ret

0000000080003c9e <initlog>:
{
    80003c9e:	7179                	addi	sp,sp,-48
    80003ca0:	f406                	sd	ra,40(sp)
    80003ca2:	f022                	sd	s0,32(sp)
    80003ca4:	ec26                	sd	s1,24(sp)
    80003ca6:	e84a                	sd	s2,16(sp)
    80003ca8:	e44e                	sd	s3,8(sp)
    80003caa:	1800                	addi	s0,sp,48
    80003cac:	892a                	mv	s2,a0
    80003cae:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003cb0:	00024497          	auipc	s1,0x24
    80003cb4:	6a848493          	addi	s1,s1,1704 # 80028358 <log>
    80003cb8:	00004597          	auipc	a1,0x4
    80003cbc:	99058593          	addi	a1,a1,-1648 # 80007648 <etext+0x648>
    80003cc0:	8526                	mv	a0,s1
    80003cc2:	eb3fc0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003cc6:	0149a583          	lw	a1,20(s3)
    80003cca:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003ccc:	0109a783          	lw	a5,16(s3)
    80003cd0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003cd2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003cd6:	854a                	mv	a0,s2
    80003cd8:	87cff0ef          	jal	80002d54 <bread>
  log.lh.n = lh->n;
    80003cdc:	4d30                	lw	a2,88(a0)
    80003cde:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003ce0:	00c05f63          	blez	a2,80003cfe <initlog+0x60>
    80003ce4:	87aa                	mv	a5,a0
    80003ce6:	00024717          	auipc	a4,0x24
    80003cea:	6a270713          	addi	a4,a4,1698 # 80028388 <log+0x30>
    80003cee:	060a                	slli	a2,a2,0x2
    80003cf0:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003cf2:	4ff4                	lw	a3,92(a5)
    80003cf4:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003cf6:	0791                	addi	a5,a5,4
    80003cf8:	0711                	addi	a4,a4,4
    80003cfa:	fec79ce3          	bne	a5,a2,80003cf2 <initlog+0x54>
  brelse(buf);
    80003cfe:	95eff0ef          	jal	80002e5c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003d02:	4505                	li	a0,1
    80003d04:	ef3ff0ef          	jal	80003bf6 <install_trans>
  log.lh.n = 0;
    80003d08:	00024797          	auipc	a5,0x24
    80003d0c:	6607ae23          	sw	zero,1660(a5) # 80028384 <log+0x2c>
  write_head(); // clear the log
    80003d10:	e89ff0ef          	jal	80003b98 <write_head>
}
    80003d14:	70a2                	ld	ra,40(sp)
    80003d16:	7402                	ld	s0,32(sp)
    80003d18:	64e2                	ld	s1,24(sp)
    80003d1a:	6942                	ld	s2,16(sp)
    80003d1c:	69a2                	ld	s3,8(sp)
    80003d1e:	6145                	addi	sp,sp,48
    80003d20:	8082                	ret

0000000080003d22 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003d22:	1101                	addi	sp,sp,-32
    80003d24:	ec06                	sd	ra,24(sp)
    80003d26:	e822                	sd	s0,16(sp)
    80003d28:	e426                	sd	s1,8(sp)
    80003d2a:	e04a                	sd	s2,0(sp)
    80003d2c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003d2e:	00024517          	auipc	a0,0x24
    80003d32:	62a50513          	addi	a0,a0,1578 # 80028358 <log>
    80003d36:	ebffc0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003d3a:	00024497          	auipc	s1,0x24
    80003d3e:	61e48493          	addi	s1,s1,1566 # 80028358 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003d42:	4979                	li	s2,30
    80003d44:	a029                	j	80003d4e <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003d46:	85a6                	mv	a1,s1
    80003d48:	8526                	mv	a0,s1
    80003d4a:	968fe0ef          	jal	80001eb2 <sleep>
    if(log.committing){
    80003d4e:	50dc                	lw	a5,36(s1)
    80003d50:	fbfd                	bnez	a5,80003d46 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003d52:	5098                	lw	a4,32(s1)
    80003d54:	2705                	addiw	a4,a4,1
    80003d56:	0027179b          	slliw	a5,a4,0x2
    80003d5a:	9fb9                	addw	a5,a5,a4
    80003d5c:	0017979b          	slliw	a5,a5,0x1
    80003d60:	54d4                	lw	a3,44(s1)
    80003d62:	9fb5                	addw	a5,a5,a3
    80003d64:	00f95763          	bge	s2,a5,80003d72 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003d68:	85a6                	mv	a1,s1
    80003d6a:	8526                	mv	a0,s1
    80003d6c:	946fe0ef          	jal	80001eb2 <sleep>
    80003d70:	bff9                	j	80003d4e <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003d72:	00024517          	auipc	a0,0x24
    80003d76:	5e650513          	addi	a0,a0,1510 # 80028358 <log>
    80003d7a:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003d7c:	f11fc0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003d80:	60e2                	ld	ra,24(sp)
    80003d82:	6442                	ld	s0,16(sp)
    80003d84:	64a2                	ld	s1,8(sp)
    80003d86:	6902                	ld	s2,0(sp)
    80003d88:	6105                	addi	sp,sp,32
    80003d8a:	8082                	ret

0000000080003d8c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d8c:	7139                	addi	sp,sp,-64
    80003d8e:	fc06                	sd	ra,56(sp)
    80003d90:	f822                	sd	s0,48(sp)
    80003d92:	f426                	sd	s1,40(sp)
    80003d94:	f04a                	sd	s2,32(sp)
    80003d96:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d98:	00024497          	auipc	s1,0x24
    80003d9c:	5c048493          	addi	s1,s1,1472 # 80028358 <log>
    80003da0:	8526                	mv	a0,s1
    80003da2:	e53fc0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003da6:	509c                	lw	a5,32(s1)
    80003da8:	37fd                	addiw	a5,a5,-1
    80003daa:	0007891b          	sext.w	s2,a5
    80003dae:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003db0:	50dc                	lw	a5,36(s1)
    80003db2:	ef9d                	bnez	a5,80003df0 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003db4:	04091763          	bnez	s2,80003e02 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003db8:	00024497          	auipc	s1,0x24
    80003dbc:	5a048493          	addi	s1,s1,1440 # 80028358 <log>
    80003dc0:	4785                	li	a5,1
    80003dc2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003dc4:	8526                	mv	a0,s1
    80003dc6:	ec7fc0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003dca:	54dc                	lw	a5,44(s1)
    80003dcc:	04f04b63          	bgtz	a5,80003e22 <end_op+0x96>
    acquire(&log.lock);
    80003dd0:	00024497          	auipc	s1,0x24
    80003dd4:	58848493          	addi	s1,s1,1416 # 80028358 <log>
    80003dd8:	8526                	mv	a0,s1
    80003dda:	e1bfc0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003dde:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003de2:	8526                	mv	a0,s1
    80003de4:	91afe0ef          	jal	80001efe <wakeup>
    release(&log.lock);
    80003de8:	8526                	mv	a0,s1
    80003dea:	ea3fc0ef          	jal	80000c8c <release>
}
    80003dee:	a025                	j	80003e16 <end_op+0x8a>
    80003df0:	ec4e                	sd	s3,24(sp)
    80003df2:	e852                	sd	s4,16(sp)
    80003df4:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003df6:	00004517          	auipc	a0,0x4
    80003dfa:	85a50513          	addi	a0,a0,-1958 # 80007650 <etext+0x650>
    80003dfe:	997fc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003e02:	00024497          	auipc	s1,0x24
    80003e06:	55648493          	addi	s1,s1,1366 # 80028358 <log>
    80003e0a:	8526                	mv	a0,s1
    80003e0c:	8f2fe0ef          	jal	80001efe <wakeup>
  release(&log.lock);
    80003e10:	8526                	mv	a0,s1
    80003e12:	e7bfc0ef          	jal	80000c8c <release>
}
    80003e16:	70e2                	ld	ra,56(sp)
    80003e18:	7442                	ld	s0,48(sp)
    80003e1a:	74a2                	ld	s1,40(sp)
    80003e1c:	7902                	ld	s2,32(sp)
    80003e1e:	6121                	addi	sp,sp,64
    80003e20:	8082                	ret
    80003e22:	ec4e                	sd	s3,24(sp)
    80003e24:	e852                	sd	s4,16(sp)
    80003e26:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e28:	00024a97          	auipc	s5,0x24
    80003e2c:	560a8a93          	addi	s5,s5,1376 # 80028388 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003e30:	00024a17          	auipc	s4,0x24
    80003e34:	528a0a13          	addi	s4,s4,1320 # 80028358 <log>
    80003e38:	018a2583          	lw	a1,24(s4)
    80003e3c:	012585bb          	addw	a1,a1,s2
    80003e40:	2585                	addiw	a1,a1,1
    80003e42:	028a2503          	lw	a0,40(s4)
    80003e46:	f0ffe0ef          	jal	80002d54 <bread>
    80003e4a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003e4c:	000aa583          	lw	a1,0(s5)
    80003e50:	028a2503          	lw	a0,40(s4)
    80003e54:	f01fe0ef          	jal	80002d54 <bread>
    80003e58:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003e5a:	40000613          	li	a2,1024
    80003e5e:	05850593          	addi	a1,a0,88
    80003e62:	05848513          	addi	a0,s1,88
    80003e66:	ebffc0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003e6a:	8526                	mv	a0,s1
    80003e6c:	fbffe0ef          	jal	80002e2a <bwrite>
    brelse(from);
    80003e70:	854e                	mv	a0,s3
    80003e72:	febfe0ef          	jal	80002e5c <brelse>
    brelse(to);
    80003e76:	8526                	mv	a0,s1
    80003e78:	fe5fe0ef          	jal	80002e5c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e7c:	2905                	addiw	s2,s2,1
    80003e7e:	0a91                	addi	s5,s5,4
    80003e80:	02ca2783          	lw	a5,44(s4)
    80003e84:	faf94ae3          	blt	s2,a5,80003e38 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e88:	d11ff0ef          	jal	80003b98 <write_head>
    install_trans(0); // Now install writes to home locations
    80003e8c:	4501                	li	a0,0
    80003e8e:	d69ff0ef          	jal	80003bf6 <install_trans>
    log.lh.n = 0;
    80003e92:	00024797          	auipc	a5,0x24
    80003e96:	4e07a923          	sw	zero,1266(a5) # 80028384 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003e9a:	cffff0ef          	jal	80003b98 <write_head>
    80003e9e:	69e2                	ld	s3,24(sp)
    80003ea0:	6a42                	ld	s4,16(sp)
    80003ea2:	6aa2                	ld	s5,8(sp)
    80003ea4:	b735                	j	80003dd0 <end_op+0x44>

0000000080003ea6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003ea6:	1101                	addi	sp,sp,-32
    80003ea8:	ec06                	sd	ra,24(sp)
    80003eaa:	e822                	sd	s0,16(sp)
    80003eac:	e426                	sd	s1,8(sp)
    80003eae:	e04a                	sd	s2,0(sp)
    80003eb0:	1000                	addi	s0,sp,32
    80003eb2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003eb4:	00024917          	auipc	s2,0x24
    80003eb8:	4a490913          	addi	s2,s2,1188 # 80028358 <log>
    80003ebc:	854a                	mv	a0,s2
    80003ebe:	d37fc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003ec2:	02c92603          	lw	a2,44(s2)
    80003ec6:	47f5                	li	a5,29
    80003ec8:	06c7c363          	blt	a5,a2,80003f2e <log_write+0x88>
    80003ecc:	00024797          	auipc	a5,0x24
    80003ed0:	4a87a783          	lw	a5,1192(a5) # 80028374 <log+0x1c>
    80003ed4:	37fd                	addiw	a5,a5,-1
    80003ed6:	04f65c63          	bge	a2,a5,80003f2e <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003eda:	00024797          	auipc	a5,0x24
    80003ede:	49e7a783          	lw	a5,1182(a5) # 80028378 <log+0x20>
    80003ee2:	04f05c63          	blez	a5,80003f3a <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003ee6:	4781                	li	a5,0
    80003ee8:	04c05f63          	blez	a2,80003f46 <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003eec:	44cc                	lw	a1,12(s1)
    80003eee:	00024717          	auipc	a4,0x24
    80003ef2:	49a70713          	addi	a4,a4,1178 # 80028388 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003ef6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003ef8:	4314                	lw	a3,0(a4)
    80003efa:	04b68663          	beq	a3,a1,80003f46 <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003efe:	2785                	addiw	a5,a5,1
    80003f00:	0711                	addi	a4,a4,4
    80003f02:	fef61be3          	bne	a2,a5,80003ef8 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003f06:	0621                	addi	a2,a2,8
    80003f08:	060a                	slli	a2,a2,0x2
    80003f0a:	00024797          	auipc	a5,0x24
    80003f0e:	44e78793          	addi	a5,a5,1102 # 80028358 <log>
    80003f12:	97b2                	add	a5,a5,a2
    80003f14:	44d8                	lw	a4,12(s1)
    80003f16:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003f18:	8526                	mv	a0,s1
    80003f1a:	fcbfe0ef          	jal	80002ee4 <bpin>
    log.lh.n++;
    80003f1e:	00024717          	auipc	a4,0x24
    80003f22:	43a70713          	addi	a4,a4,1082 # 80028358 <log>
    80003f26:	575c                	lw	a5,44(a4)
    80003f28:	2785                	addiw	a5,a5,1
    80003f2a:	d75c                	sw	a5,44(a4)
    80003f2c:	a80d                	j	80003f5e <log_write+0xb8>
    panic("too big a transaction");
    80003f2e:	00003517          	auipc	a0,0x3
    80003f32:	73250513          	addi	a0,a0,1842 # 80007660 <etext+0x660>
    80003f36:	85ffc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003f3a:	00003517          	auipc	a0,0x3
    80003f3e:	73e50513          	addi	a0,a0,1854 # 80007678 <etext+0x678>
    80003f42:	853fc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003f46:	00878693          	addi	a3,a5,8
    80003f4a:	068a                	slli	a3,a3,0x2
    80003f4c:	00024717          	auipc	a4,0x24
    80003f50:	40c70713          	addi	a4,a4,1036 # 80028358 <log>
    80003f54:	9736                	add	a4,a4,a3
    80003f56:	44d4                	lw	a3,12(s1)
    80003f58:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003f5a:	faf60fe3          	beq	a2,a5,80003f18 <log_write+0x72>
  }
  release(&log.lock);
    80003f5e:	00024517          	auipc	a0,0x24
    80003f62:	3fa50513          	addi	a0,a0,1018 # 80028358 <log>
    80003f66:	d27fc0ef          	jal	80000c8c <release>
}
    80003f6a:	60e2                	ld	ra,24(sp)
    80003f6c:	6442                	ld	s0,16(sp)
    80003f6e:	64a2                	ld	s1,8(sp)
    80003f70:	6902                	ld	s2,0(sp)
    80003f72:	6105                	addi	sp,sp,32
    80003f74:	8082                	ret

0000000080003f76 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f76:	1101                	addi	sp,sp,-32
    80003f78:	ec06                	sd	ra,24(sp)
    80003f7a:	e822                	sd	s0,16(sp)
    80003f7c:	e426                	sd	s1,8(sp)
    80003f7e:	e04a                	sd	s2,0(sp)
    80003f80:	1000                	addi	s0,sp,32
    80003f82:	84aa                	mv	s1,a0
    80003f84:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f86:	00003597          	auipc	a1,0x3
    80003f8a:	71258593          	addi	a1,a1,1810 # 80007698 <etext+0x698>
    80003f8e:	0521                	addi	a0,a0,8
    80003f90:	be5fc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003f94:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f98:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f9c:	0204a423          	sw	zero,40(s1)
}
    80003fa0:	60e2                	ld	ra,24(sp)
    80003fa2:	6442                	ld	s0,16(sp)
    80003fa4:	64a2                	ld	s1,8(sp)
    80003fa6:	6902                	ld	s2,0(sp)
    80003fa8:	6105                	addi	sp,sp,32
    80003faa:	8082                	ret

0000000080003fac <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003fac:	1101                	addi	sp,sp,-32
    80003fae:	ec06                	sd	ra,24(sp)
    80003fb0:	e822                	sd	s0,16(sp)
    80003fb2:	e426                	sd	s1,8(sp)
    80003fb4:	e04a                	sd	s2,0(sp)
    80003fb6:	1000                	addi	s0,sp,32
    80003fb8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fba:	00850913          	addi	s2,a0,8
    80003fbe:	854a                	mv	a0,s2
    80003fc0:	c35fc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003fc4:	409c                	lw	a5,0(s1)
    80003fc6:	c799                	beqz	a5,80003fd4 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003fc8:	85ca                	mv	a1,s2
    80003fca:	8526                	mv	a0,s1
    80003fcc:	ee7fd0ef          	jal	80001eb2 <sleep>
  while (lk->locked) {
    80003fd0:	409c                	lw	a5,0(s1)
    80003fd2:	fbfd                	bnez	a5,80003fc8 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003fd4:	4785                	li	a5,1
    80003fd6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003fd8:	909fd0ef          	jal	800018e0 <myproc>
    80003fdc:	591c                	lw	a5,48(a0)
    80003fde:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003fe0:	854a                	mv	a0,s2
    80003fe2:	cabfc0ef          	jal	80000c8c <release>
}
    80003fe6:	60e2                	ld	ra,24(sp)
    80003fe8:	6442                	ld	s0,16(sp)
    80003fea:	64a2                	ld	s1,8(sp)
    80003fec:	6902                	ld	s2,0(sp)
    80003fee:	6105                	addi	sp,sp,32
    80003ff0:	8082                	ret

0000000080003ff2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003ff2:	1101                	addi	sp,sp,-32
    80003ff4:	ec06                	sd	ra,24(sp)
    80003ff6:	e822                	sd	s0,16(sp)
    80003ff8:	e426                	sd	s1,8(sp)
    80003ffa:	e04a                	sd	s2,0(sp)
    80003ffc:	1000                	addi	s0,sp,32
    80003ffe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004000:	00850913          	addi	s2,a0,8
    80004004:	854a                	mv	a0,s2
    80004006:	beffc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    8000400a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000400e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004012:	8526                	mv	a0,s1
    80004014:	eebfd0ef          	jal	80001efe <wakeup>
  release(&lk->lk);
    80004018:	854a                	mv	a0,s2
    8000401a:	c73fc0ef          	jal	80000c8c <release>
}
    8000401e:	60e2                	ld	ra,24(sp)
    80004020:	6442                	ld	s0,16(sp)
    80004022:	64a2                	ld	s1,8(sp)
    80004024:	6902                	ld	s2,0(sp)
    80004026:	6105                	addi	sp,sp,32
    80004028:	8082                	ret

000000008000402a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000402a:	7179                	addi	sp,sp,-48
    8000402c:	f406                	sd	ra,40(sp)
    8000402e:	f022                	sd	s0,32(sp)
    80004030:	ec26                	sd	s1,24(sp)
    80004032:	e84a                	sd	s2,16(sp)
    80004034:	1800                	addi	s0,sp,48
    80004036:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004038:	00850913          	addi	s2,a0,8
    8000403c:	854a                	mv	a0,s2
    8000403e:	bb7fc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004042:	409c                	lw	a5,0(s1)
    80004044:	ef81                	bnez	a5,8000405c <holdingsleep+0x32>
    80004046:	4481                	li	s1,0
  release(&lk->lk);
    80004048:	854a                	mv	a0,s2
    8000404a:	c43fc0ef          	jal	80000c8c <release>
  return r;
}
    8000404e:	8526                	mv	a0,s1
    80004050:	70a2                	ld	ra,40(sp)
    80004052:	7402                	ld	s0,32(sp)
    80004054:	64e2                	ld	s1,24(sp)
    80004056:	6942                	ld	s2,16(sp)
    80004058:	6145                	addi	sp,sp,48
    8000405a:	8082                	ret
    8000405c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000405e:	0284a983          	lw	s3,40(s1)
    80004062:	87ffd0ef          	jal	800018e0 <myproc>
    80004066:	5904                	lw	s1,48(a0)
    80004068:	413484b3          	sub	s1,s1,s3
    8000406c:	0014b493          	seqz	s1,s1
    80004070:	69a2                	ld	s3,8(sp)
    80004072:	bfd9                	j	80004048 <holdingsleep+0x1e>

0000000080004074 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004074:	1141                	addi	sp,sp,-16
    80004076:	e406                	sd	ra,8(sp)
    80004078:	e022                	sd	s0,0(sp)
    8000407a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000407c:	00003597          	auipc	a1,0x3
    80004080:	62c58593          	addi	a1,a1,1580 # 800076a8 <etext+0x6a8>
    80004084:	00024517          	auipc	a0,0x24
    80004088:	41c50513          	addi	a0,a0,1052 # 800284a0 <ftable>
    8000408c:	ae9fc0ef          	jal	80000b74 <initlock>
}
    80004090:	60a2                	ld	ra,8(sp)
    80004092:	6402                	ld	s0,0(sp)
    80004094:	0141                	addi	sp,sp,16
    80004096:	8082                	ret

0000000080004098 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004098:	1101                	addi	sp,sp,-32
    8000409a:	ec06                	sd	ra,24(sp)
    8000409c:	e822                	sd	s0,16(sp)
    8000409e:	e426                	sd	s1,8(sp)
    800040a0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800040a2:	00024517          	auipc	a0,0x24
    800040a6:	3fe50513          	addi	a0,a0,1022 # 800284a0 <ftable>
    800040aa:	b4bfc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040ae:	00024497          	auipc	s1,0x24
    800040b2:	40a48493          	addi	s1,s1,1034 # 800284b8 <ftable+0x18>
    800040b6:	00025717          	auipc	a4,0x25
    800040ba:	3a270713          	addi	a4,a4,930 # 80029458 <disk>
    if(f->ref == 0){
    800040be:	40dc                	lw	a5,4(s1)
    800040c0:	cf89                	beqz	a5,800040da <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800040c2:	02848493          	addi	s1,s1,40
    800040c6:	fee49ce3          	bne	s1,a4,800040be <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800040ca:	00024517          	auipc	a0,0x24
    800040ce:	3d650513          	addi	a0,a0,982 # 800284a0 <ftable>
    800040d2:	bbbfc0ef          	jal	80000c8c <release>
  return 0;
    800040d6:	4481                	li	s1,0
    800040d8:	a809                	j	800040ea <filealloc+0x52>
      f->ref = 1;
    800040da:	4785                	li	a5,1
    800040dc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800040de:	00024517          	auipc	a0,0x24
    800040e2:	3c250513          	addi	a0,a0,962 # 800284a0 <ftable>
    800040e6:	ba7fc0ef          	jal	80000c8c <release>
}
    800040ea:	8526                	mv	a0,s1
    800040ec:	60e2                	ld	ra,24(sp)
    800040ee:	6442                	ld	s0,16(sp)
    800040f0:	64a2                	ld	s1,8(sp)
    800040f2:	6105                	addi	sp,sp,32
    800040f4:	8082                	ret

00000000800040f6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800040f6:	1101                	addi	sp,sp,-32
    800040f8:	ec06                	sd	ra,24(sp)
    800040fa:	e822                	sd	s0,16(sp)
    800040fc:	e426                	sd	s1,8(sp)
    800040fe:	1000                	addi	s0,sp,32
    80004100:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004102:	00024517          	auipc	a0,0x24
    80004106:	39e50513          	addi	a0,a0,926 # 800284a0 <ftable>
    8000410a:	aebfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    8000410e:	40dc                	lw	a5,4(s1)
    80004110:	02f05063          	blez	a5,80004130 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004114:	2785                	addiw	a5,a5,1
    80004116:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004118:	00024517          	auipc	a0,0x24
    8000411c:	38850513          	addi	a0,a0,904 # 800284a0 <ftable>
    80004120:	b6dfc0ef          	jal	80000c8c <release>
  return f;
}
    80004124:	8526                	mv	a0,s1
    80004126:	60e2                	ld	ra,24(sp)
    80004128:	6442                	ld	s0,16(sp)
    8000412a:	64a2                	ld	s1,8(sp)
    8000412c:	6105                	addi	sp,sp,32
    8000412e:	8082                	ret
    panic("filedup");
    80004130:	00003517          	auipc	a0,0x3
    80004134:	58050513          	addi	a0,a0,1408 # 800076b0 <etext+0x6b0>
    80004138:	e5cfc0ef          	jal	80000794 <panic>

000000008000413c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000413c:	7139                	addi	sp,sp,-64
    8000413e:	fc06                	sd	ra,56(sp)
    80004140:	f822                	sd	s0,48(sp)
    80004142:	f426                	sd	s1,40(sp)
    80004144:	0080                	addi	s0,sp,64
    80004146:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004148:	00024517          	auipc	a0,0x24
    8000414c:	35850513          	addi	a0,a0,856 # 800284a0 <ftable>
    80004150:	aa5fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80004154:	40dc                	lw	a5,4(s1)
    80004156:	04f05a63          	blez	a5,800041aa <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000415a:	37fd                	addiw	a5,a5,-1
    8000415c:	0007871b          	sext.w	a4,a5
    80004160:	c0dc                	sw	a5,4(s1)
    80004162:	04e04e63          	bgtz	a4,800041be <fileclose+0x82>
    80004166:	f04a                	sd	s2,32(sp)
    80004168:	ec4e                	sd	s3,24(sp)
    8000416a:	e852                	sd	s4,16(sp)
    8000416c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000416e:	0004a903          	lw	s2,0(s1)
    80004172:	0094ca83          	lbu	s5,9(s1)
    80004176:	0104ba03          	ld	s4,16(s1)
    8000417a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000417e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004182:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004186:	00024517          	auipc	a0,0x24
    8000418a:	31a50513          	addi	a0,a0,794 # 800284a0 <ftable>
    8000418e:	afffc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80004192:	4785                	li	a5,1
    80004194:	04f90063          	beq	s2,a5,800041d4 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004198:	3979                	addiw	s2,s2,-2
    8000419a:	4785                	li	a5,1
    8000419c:	0527f563          	bgeu	a5,s2,800041e6 <fileclose+0xaa>
    800041a0:	7902                	ld	s2,32(sp)
    800041a2:	69e2                	ld	s3,24(sp)
    800041a4:	6a42                	ld	s4,16(sp)
    800041a6:	6aa2                	ld	s5,8(sp)
    800041a8:	a00d                	j	800041ca <fileclose+0x8e>
    800041aa:	f04a                	sd	s2,32(sp)
    800041ac:	ec4e                	sd	s3,24(sp)
    800041ae:	e852                	sd	s4,16(sp)
    800041b0:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800041b2:	00003517          	auipc	a0,0x3
    800041b6:	50650513          	addi	a0,a0,1286 # 800076b8 <etext+0x6b8>
    800041ba:	ddafc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    800041be:	00024517          	auipc	a0,0x24
    800041c2:	2e250513          	addi	a0,a0,738 # 800284a0 <ftable>
    800041c6:	ac7fc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800041ca:	70e2                	ld	ra,56(sp)
    800041cc:	7442                	ld	s0,48(sp)
    800041ce:	74a2                	ld	s1,40(sp)
    800041d0:	6121                	addi	sp,sp,64
    800041d2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800041d4:	85d6                	mv	a1,s5
    800041d6:	8552                	mv	a0,s4
    800041d8:	336000ef          	jal	8000450e <pipeclose>
    800041dc:	7902                	ld	s2,32(sp)
    800041de:	69e2                	ld	s3,24(sp)
    800041e0:	6a42                	ld	s4,16(sp)
    800041e2:	6aa2                	ld	s5,8(sp)
    800041e4:	b7dd                	j	800041ca <fileclose+0x8e>
    begin_op();
    800041e6:	b3dff0ef          	jal	80003d22 <begin_op>
    iput(ff.ip);
    800041ea:	854e                	mv	a0,s3
    800041ec:	c22ff0ef          	jal	8000360e <iput>
    end_op();
    800041f0:	b9dff0ef          	jal	80003d8c <end_op>
    800041f4:	7902                	ld	s2,32(sp)
    800041f6:	69e2                	ld	s3,24(sp)
    800041f8:	6a42                	ld	s4,16(sp)
    800041fa:	6aa2                	ld	s5,8(sp)
    800041fc:	b7f9                	j	800041ca <fileclose+0x8e>

00000000800041fe <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800041fe:	715d                	addi	sp,sp,-80
    80004200:	e486                	sd	ra,72(sp)
    80004202:	e0a2                	sd	s0,64(sp)
    80004204:	fc26                	sd	s1,56(sp)
    80004206:	f44e                	sd	s3,40(sp)
    80004208:	0880                	addi	s0,sp,80
    8000420a:	84aa                	mv	s1,a0
    8000420c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000420e:	ed2fd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004212:	409c                	lw	a5,0(s1)
    80004214:	37f9                	addiw	a5,a5,-2
    80004216:	4705                	li	a4,1
    80004218:	04f76063          	bltu	a4,a5,80004258 <filestat+0x5a>
    8000421c:	f84a                	sd	s2,48(sp)
    8000421e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004220:	6c88                	ld	a0,24(s1)
    80004222:	a6aff0ef          	jal	8000348c <ilock>
    stati(f->ip, &st);
    80004226:	fb840593          	addi	a1,s0,-72
    8000422a:	6c88                	ld	a0,24(s1)
    8000422c:	c8aff0ef          	jal	800036b6 <stati>
    iunlock(f->ip);
    80004230:	6c88                	ld	a0,24(s1)
    80004232:	b08ff0ef          	jal	8000353a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004236:	46e1                	li	a3,24
    80004238:	fb840613          	addi	a2,s0,-72
    8000423c:	85ce                	mv	a1,s3
    8000423e:	05893503          	ld	a0,88(s2)
    80004242:	b10fd0ef          	jal	80001552 <copyout>
    80004246:	41f5551b          	sraiw	a0,a0,0x1f
    8000424a:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000424c:	60a6                	ld	ra,72(sp)
    8000424e:	6406                	ld	s0,64(sp)
    80004250:	74e2                	ld	s1,56(sp)
    80004252:	79a2                	ld	s3,40(sp)
    80004254:	6161                	addi	sp,sp,80
    80004256:	8082                	ret
  return -1;
    80004258:	557d                	li	a0,-1
    8000425a:	bfcd                	j	8000424c <filestat+0x4e>

000000008000425c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000425c:	7179                	addi	sp,sp,-48
    8000425e:	f406                	sd	ra,40(sp)
    80004260:	f022                	sd	s0,32(sp)
    80004262:	e84a                	sd	s2,16(sp)
    80004264:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004266:	00854783          	lbu	a5,8(a0)
    8000426a:	cfd1                	beqz	a5,80004306 <fileread+0xaa>
    8000426c:	ec26                	sd	s1,24(sp)
    8000426e:	e44e                	sd	s3,8(sp)
    80004270:	84aa                	mv	s1,a0
    80004272:	89ae                	mv	s3,a1
    80004274:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004276:	411c                	lw	a5,0(a0)
    80004278:	4705                	li	a4,1
    8000427a:	04e78363          	beq	a5,a4,800042c0 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000427e:	470d                	li	a4,3
    80004280:	04e78763          	beq	a5,a4,800042ce <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004284:	4709                	li	a4,2
    80004286:	06e79a63          	bne	a5,a4,800042fa <fileread+0x9e>
    ilock(f->ip);
    8000428a:	6d08                	ld	a0,24(a0)
    8000428c:	a00ff0ef          	jal	8000348c <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004290:	874a                	mv	a4,s2
    80004292:	5094                	lw	a3,32(s1)
    80004294:	864e                	mv	a2,s3
    80004296:	4585                	li	a1,1
    80004298:	6c88                	ld	a0,24(s1)
    8000429a:	c46ff0ef          	jal	800036e0 <readi>
    8000429e:	892a                	mv	s2,a0
    800042a0:	00a05563          	blez	a0,800042aa <fileread+0x4e>
      f->off += r;
    800042a4:	509c                	lw	a5,32(s1)
    800042a6:	9fa9                	addw	a5,a5,a0
    800042a8:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800042aa:	6c88                	ld	a0,24(s1)
    800042ac:	a8eff0ef          	jal	8000353a <iunlock>
    800042b0:	64e2                	ld	s1,24(sp)
    800042b2:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800042b4:	854a                	mv	a0,s2
    800042b6:	70a2                	ld	ra,40(sp)
    800042b8:	7402                	ld	s0,32(sp)
    800042ba:	6942                	ld	s2,16(sp)
    800042bc:	6145                	addi	sp,sp,48
    800042be:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800042c0:	6908                	ld	a0,16(a0)
    800042c2:	388000ef          	jal	8000464a <piperead>
    800042c6:	892a                	mv	s2,a0
    800042c8:	64e2                	ld	s1,24(sp)
    800042ca:	69a2                	ld	s3,8(sp)
    800042cc:	b7e5                	j	800042b4 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800042ce:	02451783          	lh	a5,36(a0)
    800042d2:	03079693          	slli	a3,a5,0x30
    800042d6:	92c1                	srli	a3,a3,0x30
    800042d8:	4725                	li	a4,9
    800042da:	02d76863          	bltu	a4,a3,8000430a <fileread+0xae>
    800042de:	0792                	slli	a5,a5,0x4
    800042e0:	00024717          	auipc	a4,0x24
    800042e4:	12070713          	addi	a4,a4,288 # 80028400 <devsw>
    800042e8:	97ba                	add	a5,a5,a4
    800042ea:	639c                	ld	a5,0(a5)
    800042ec:	c39d                	beqz	a5,80004312 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800042ee:	4505                	li	a0,1
    800042f0:	9782                	jalr	a5
    800042f2:	892a                	mv	s2,a0
    800042f4:	64e2                	ld	s1,24(sp)
    800042f6:	69a2                	ld	s3,8(sp)
    800042f8:	bf75                	j	800042b4 <fileread+0x58>
    panic("fileread");
    800042fa:	00003517          	auipc	a0,0x3
    800042fe:	3ce50513          	addi	a0,a0,974 # 800076c8 <etext+0x6c8>
    80004302:	c92fc0ef          	jal	80000794 <panic>
    return -1;
    80004306:	597d                	li	s2,-1
    80004308:	b775                	j	800042b4 <fileread+0x58>
      return -1;
    8000430a:	597d                	li	s2,-1
    8000430c:	64e2                	ld	s1,24(sp)
    8000430e:	69a2                	ld	s3,8(sp)
    80004310:	b755                	j	800042b4 <fileread+0x58>
    80004312:	597d                	li	s2,-1
    80004314:	64e2                	ld	s1,24(sp)
    80004316:	69a2                	ld	s3,8(sp)
    80004318:	bf71                	j	800042b4 <fileread+0x58>

000000008000431a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000431a:	00954783          	lbu	a5,9(a0)
    8000431e:	10078b63          	beqz	a5,80004434 <filewrite+0x11a>
{
    80004322:	715d                	addi	sp,sp,-80
    80004324:	e486                	sd	ra,72(sp)
    80004326:	e0a2                	sd	s0,64(sp)
    80004328:	f84a                	sd	s2,48(sp)
    8000432a:	f052                	sd	s4,32(sp)
    8000432c:	e85a                	sd	s6,16(sp)
    8000432e:	0880                	addi	s0,sp,80
    80004330:	892a                	mv	s2,a0
    80004332:	8b2e                	mv	s6,a1
    80004334:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004336:	411c                	lw	a5,0(a0)
    80004338:	4705                	li	a4,1
    8000433a:	02e78763          	beq	a5,a4,80004368 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000433e:	470d                	li	a4,3
    80004340:	02e78863          	beq	a5,a4,80004370 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004344:	4709                	li	a4,2
    80004346:	0ce79c63          	bne	a5,a4,8000441e <filewrite+0x104>
    8000434a:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000434c:	0ac05863          	blez	a2,800043fc <filewrite+0xe2>
    80004350:	fc26                	sd	s1,56(sp)
    80004352:	ec56                	sd	s5,24(sp)
    80004354:	e45e                	sd	s7,8(sp)
    80004356:	e062                	sd	s8,0(sp)
    int i = 0;
    80004358:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000435a:	6b85                	lui	s7,0x1
    8000435c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004360:	6c05                	lui	s8,0x1
    80004362:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004366:	a8b5                	j	800043e2 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004368:	6908                	ld	a0,16(a0)
    8000436a:	1fc000ef          	jal	80004566 <pipewrite>
    8000436e:	a04d                	j	80004410 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004370:	02451783          	lh	a5,36(a0)
    80004374:	03079693          	slli	a3,a5,0x30
    80004378:	92c1                	srli	a3,a3,0x30
    8000437a:	4725                	li	a4,9
    8000437c:	0ad76e63          	bltu	a4,a3,80004438 <filewrite+0x11e>
    80004380:	0792                	slli	a5,a5,0x4
    80004382:	00024717          	auipc	a4,0x24
    80004386:	07e70713          	addi	a4,a4,126 # 80028400 <devsw>
    8000438a:	97ba                	add	a5,a5,a4
    8000438c:	679c                	ld	a5,8(a5)
    8000438e:	c7dd                	beqz	a5,8000443c <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004390:	4505                	li	a0,1
    80004392:	9782                	jalr	a5
    80004394:	a8b5                	j	80004410 <filewrite+0xf6>
      if(n1 > max)
    80004396:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000439a:	989ff0ef          	jal	80003d22 <begin_op>
      ilock(f->ip);
    8000439e:	01893503          	ld	a0,24(s2)
    800043a2:	8eaff0ef          	jal	8000348c <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800043a6:	8756                	mv	a4,s5
    800043a8:	02092683          	lw	a3,32(s2)
    800043ac:	01698633          	add	a2,s3,s6
    800043b0:	4585                	li	a1,1
    800043b2:	01893503          	ld	a0,24(s2)
    800043b6:	c26ff0ef          	jal	800037dc <writei>
    800043ba:	84aa                	mv	s1,a0
    800043bc:	00a05763          	blez	a0,800043ca <filewrite+0xb0>
        f->off += r;
    800043c0:	02092783          	lw	a5,32(s2)
    800043c4:	9fa9                	addw	a5,a5,a0
    800043c6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800043ca:	01893503          	ld	a0,24(s2)
    800043ce:	96cff0ef          	jal	8000353a <iunlock>
      end_op();
    800043d2:	9bbff0ef          	jal	80003d8c <end_op>

      if(r != n1){
    800043d6:	029a9563          	bne	s5,s1,80004400 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800043da:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800043de:	0149da63          	bge	s3,s4,800043f2 <filewrite+0xd8>
      int n1 = n - i;
    800043e2:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800043e6:	0004879b          	sext.w	a5,s1
    800043ea:	fafbd6e3          	bge	s7,a5,80004396 <filewrite+0x7c>
    800043ee:	84e2                	mv	s1,s8
    800043f0:	b75d                	j	80004396 <filewrite+0x7c>
    800043f2:	74e2                	ld	s1,56(sp)
    800043f4:	6ae2                	ld	s5,24(sp)
    800043f6:	6ba2                	ld	s7,8(sp)
    800043f8:	6c02                	ld	s8,0(sp)
    800043fa:	a039                	j	80004408 <filewrite+0xee>
    int i = 0;
    800043fc:	4981                	li	s3,0
    800043fe:	a029                	j	80004408 <filewrite+0xee>
    80004400:	74e2                	ld	s1,56(sp)
    80004402:	6ae2                	ld	s5,24(sp)
    80004404:	6ba2                	ld	s7,8(sp)
    80004406:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004408:	033a1c63          	bne	s4,s3,80004440 <filewrite+0x126>
    8000440c:	8552                	mv	a0,s4
    8000440e:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004410:	60a6                	ld	ra,72(sp)
    80004412:	6406                	ld	s0,64(sp)
    80004414:	7942                	ld	s2,48(sp)
    80004416:	7a02                	ld	s4,32(sp)
    80004418:	6b42                	ld	s6,16(sp)
    8000441a:	6161                	addi	sp,sp,80
    8000441c:	8082                	ret
    8000441e:	fc26                	sd	s1,56(sp)
    80004420:	f44e                	sd	s3,40(sp)
    80004422:	ec56                	sd	s5,24(sp)
    80004424:	e45e                	sd	s7,8(sp)
    80004426:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004428:	00003517          	auipc	a0,0x3
    8000442c:	2b050513          	addi	a0,a0,688 # 800076d8 <etext+0x6d8>
    80004430:	b64fc0ef          	jal	80000794 <panic>
    return -1;
    80004434:	557d                	li	a0,-1
}
    80004436:	8082                	ret
      return -1;
    80004438:	557d                	li	a0,-1
    8000443a:	bfd9                	j	80004410 <filewrite+0xf6>
    8000443c:	557d                	li	a0,-1
    8000443e:	bfc9                	j	80004410 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004440:	557d                	li	a0,-1
    80004442:	79a2                	ld	s3,40(sp)
    80004444:	b7f1                	j	80004410 <filewrite+0xf6>

0000000080004446 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004446:	7179                	addi	sp,sp,-48
    80004448:	f406                	sd	ra,40(sp)
    8000444a:	f022                	sd	s0,32(sp)
    8000444c:	ec26                	sd	s1,24(sp)
    8000444e:	e052                	sd	s4,0(sp)
    80004450:	1800                	addi	s0,sp,48
    80004452:	84aa                	mv	s1,a0
    80004454:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004456:	0005b023          	sd	zero,0(a1)
    8000445a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000445e:	c3bff0ef          	jal	80004098 <filealloc>
    80004462:	e088                	sd	a0,0(s1)
    80004464:	c549                	beqz	a0,800044ee <pipealloc+0xa8>
    80004466:	c33ff0ef          	jal	80004098 <filealloc>
    8000446a:	00aa3023          	sd	a0,0(s4)
    8000446e:	cd25                	beqz	a0,800044e6 <pipealloc+0xa0>
    80004470:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004472:	eb2fc0ef          	jal	80000b24 <kalloc>
    80004476:	892a                	mv	s2,a0
    80004478:	c12d                	beqz	a0,800044da <pipealloc+0x94>
    8000447a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000447c:	4985                	li	s3,1
    8000447e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004482:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004486:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000448a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000448e:	00003597          	auipc	a1,0x3
    80004492:	25a58593          	addi	a1,a1,602 # 800076e8 <etext+0x6e8>
    80004496:	edefc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    8000449a:	609c                	ld	a5,0(s1)
    8000449c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800044a0:	609c                	ld	a5,0(s1)
    800044a2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800044a6:	609c                	ld	a5,0(s1)
    800044a8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800044ac:	609c                	ld	a5,0(s1)
    800044ae:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800044b2:	000a3783          	ld	a5,0(s4)
    800044b6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800044ba:	000a3783          	ld	a5,0(s4)
    800044be:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800044c2:	000a3783          	ld	a5,0(s4)
    800044c6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800044ca:	000a3783          	ld	a5,0(s4)
    800044ce:	0127b823          	sd	s2,16(a5)
  return 0;
    800044d2:	4501                	li	a0,0
    800044d4:	6942                	ld	s2,16(sp)
    800044d6:	69a2                	ld	s3,8(sp)
    800044d8:	a01d                	j	800044fe <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800044da:	6088                	ld	a0,0(s1)
    800044dc:	c119                	beqz	a0,800044e2 <pipealloc+0x9c>
    800044de:	6942                	ld	s2,16(sp)
    800044e0:	a029                	j	800044ea <pipealloc+0xa4>
    800044e2:	6942                	ld	s2,16(sp)
    800044e4:	a029                	j	800044ee <pipealloc+0xa8>
    800044e6:	6088                	ld	a0,0(s1)
    800044e8:	c10d                	beqz	a0,8000450a <pipealloc+0xc4>
    fileclose(*f0);
    800044ea:	c53ff0ef          	jal	8000413c <fileclose>
  if(*f1)
    800044ee:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800044f2:	557d                	li	a0,-1
  if(*f1)
    800044f4:	c789                	beqz	a5,800044fe <pipealloc+0xb8>
    fileclose(*f1);
    800044f6:	853e                	mv	a0,a5
    800044f8:	c45ff0ef          	jal	8000413c <fileclose>
  return -1;
    800044fc:	557d                	li	a0,-1
}
    800044fe:	70a2                	ld	ra,40(sp)
    80004500:	7402                	ld	s0,32(sp)
    80004502:	64e2                	ld	s1,24(sp)
    80004504:	6a02                	ld	s4,0(sp)
    80004506:	6145                	addi	sp,sp,48
    80004508:	8082                	ret
  return -1;
    8000450a:	557d                	li	a0,-1
    8000450c:	bfcd                	j	800044fe <pipealloc+0xb8>

000000008000450e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000450e:	1101                	addi	sp,sp,-32
    80004510:	ec06                	sd	ra,24(sp)
    80004512:	e822                	sd	s0,16(sp)
    80004514:	e426                	sd	s1,8(sp)
    80004516:	e04a                	sd	s2,0(sp)
    80004518:	1000                	addi	s0,sp,32
    8000451a:	84aa                	mv	s1,a0
    8000451c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000451e:	ed6fc0ef          	jal	80000bf4 <acquire>
  if(writable){
    80004522:	02090763          	beqz	s2,80004550 <pipeclose+0x42>
    pi->writeopen = 0;
    80004526:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000452a:	21848513          	addi	a0,s1,536
    8000452e:	9d1fd0ef          	jal	80001efe <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004532:	2204b783          	ld	a5,544(s1)
    80004536:	e785                	bnez	a5,8000455e <pipeclose+0x50>
    release(&pi->lock);
    80004538:	8526                	mv	a0,s1
    8000453a:	f52fc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    8000453e:	8526                	mv	a0,s1
    80004540:	d02fc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    80004544:	60e2                	ld	ra,24(sp)
    80004546:	6442                	ld	s0,16(sp)
    80004548:	64a2                	ld	s1,8(sp)
    8000454a:	6902                	ld	s2,0(sp)
    8000454c:	6105                	addi	sp,sp,32
    8000454e:	8082                	ret
    pi->readopen = 0;
    80004550:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004554:	21c48513          	addi	a0,s1,540
    80004558:	9a7fd0ef          	jal	80001efe <wakeup>
    8000455c:	bfd9                	j	80004532 <pipeclose+0x24>
    release(&pi->lock);
    8000455e:	8526                	mv	a0,s1
    80004560:	f2cfc0ef          	jal	80000c8c <release>
}
    80004564:	b7c5                	j	80004544 <pipeclose+0x36>

0000000080004566 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004566:	711d                	addi	sp,sp,-96
    80004568:	ec86                	sd	ra,88(sp)
    8000456a:	e8a2                	sd	s0,80(sp)
    8000456c:	e4a6                	sd	s1,72(sp)
    8000456e:	e0ca                	sd	s2,64(sp)
    80004570:	fc4e                	sd	s3,56(sp)
    80004572:	f852                	sd	s4,48(sp)
    80004574:	f456                	sd	s5,40(sp)
    80004576:	1080                	addi	s0,sp,96
    80004578:	84aa                	mv	s1,a0
    8000457a:	8aae                	mv	s5,a1
    8000457c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000457e:	b62fd0ef          	jal	800018e0 <myproc>
    80004582:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004584:	8526                	mv	a0,s1
    80004586:	e6efc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    8000458a:	0b405a63          	blez	s4,8000463e <pipewrite+0xd8>
    8000458e:	f05a                	sd	s6,32(sp)
    80004590:	ec5e                	sd	s7,24(sp)
    80004592:	e862                	sd	s8,16(sp)
  int i = 0;
    80004594:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004596:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004598:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000459c:	21c48b93          	addi	s7,s1,540
    800045a0:	a81d                	j	800045d6 <pipewrite+0x70>
      release(&pi->lock);
    800045a2:	8526                	mv	a0,s1
    800045a4:	ee8fc0ef          	jal	80000c8c <release>
      return -1;
    800045a8:	597d                	li	s2,-1
    800045aa:	7b02                	ld	s6,32(sp)
    800045ac:	6be2                	ld	s7,24(sp)
    800045ae:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800045b0:	854a                	mv	a0,s2
    800045b2:	60e6                	ld	ra,88(sp)
    800045b4:	6446                	ld	s0,80(sp)
    800045b6:	64a6                	ld	s1,72(sp)
    800045b8:	6906                	ld	s2,64(sp)
    800045ba:	79e2                	ld	s3,56(sp)
    800045bc:	7a42                	ld	s4,48(sp)
    800045be:	7aa2                	ld	s5,40(sp)
    800045c0:	6125                	addi	sp,sp,96
    800045c2:	8082                	ret
      wakeup(&pi->nread);
    800045c4:	8562                	mv	a0,s8
    800045c6:	939fd0ef          	jal	80001efe <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800045ca:	85a6                	mv	a1,s1
    800045cc:	855e                	mv	a0,s7
    800045ce:	8e5fd0ef          	jal	80001eb2 <sleep>
  while(i < n){
    800045d2:	05495b63          	bge	s2,s4,80004628 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800045d6:	2204a783          	lw	a5,544(s1)
    800045da:	d7e1                	beqz	a5,800045a2 <pipewrite+0x3c>
    800045dc:	854e                	mv	a0,s3
    800045de:	b51fd0ef          	jal	8000212e <killed>
    800045e2:	f161                	bnez	a0,800045a2 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800045e4:	2184a783          	lw	a5,536(s1)
    800045e8:	21c4a703          	lw	a4,540(s1)
    800045ec:	2007879b          	addiw	a5,a5,512
    800045f0:	fcf70ae3          	beq	a4,a5,800045c4 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800045f4:	4685                	li	a3,1
    800045f6:	01590633          	add	a2,s2,s5
    800045fa:	faf40593          	addi	a1,s0,-81
    800045fe:	0589b503          	ld	a0,88(s3)
    80004602:	826fd0ef          	jal	80001628 <copyin>
    80004606:	03650e63          	beq	a0,s6,80004642 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000460a:	21c4a783          	lw	a5,540(s1)
    8000460e:	0017871b          	addiw	a4,a5,1
    80004612:	20e4ae23          	sw	a4,540(s1)
    80004616:	1ff7f793          	andi	a5,a5,511
    8000461a:	97a6                	add	a5,a5,s1
    8000461c:	faf44703          	lbu	a4,-81(s0)
    80004620:	00e78c23          	sb	a4,24(a5)
      i++;
    80004624:	2905                	addiw	s2,s2,1
    80004626:	b775                	j	800045d2 <pipewrite+0x6c>
    80004628:	7b02                	ld	s6,32(sp)
    8000462a:	6be2                	ld	s7,24(sp)
    8000462c:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    8000462e:	21848513          	addi	a0,s1,536
    80004632:	8cdfd0ef          	jal	80001efe <wakeup>
  release(&pi->lock);
    80004636:	8526                	mv	a0,s1
    80004638:	e54fc0ef          	jal	80000c8c <release>
  return i;
    8000463c:	bf95                	j	800045b0 <pipewrite+0x4a>
  int i = 0;
    8000463e:	4901                	li	s2,0
    80004640:	b7fd                	j	8000462e <pipewrite+0xc8>
    80004642:	7b02                	ld	s6,32(sp)
    80004644:	6be2                	ld	s7,24(sp)
    80004646:	6c42                	ld	s8,16(sp)
    80004648:	b7dd                	j	8000462e <pipewrite+0xc8>

000000008000464a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000464a:	715d                	addi	sp,sp,-80
    8000464c:	e486                	sd	ra,72(sp)
    8000464e:	e0a2                	sd	s0,64(sp)
    80004650:	fc26                	sd	s1,56(sp)
    80004652:	f84a                	sd	s2,48(sp)
    80004654:	f44e                	sd	s3,40(sp)
    80004656:	f052                	sd	s4,32(sp)
    80004658:	ec56                	sd	s5,24(sp)
    8000465a:	0880                	addi	s0,sp,80
    8000465c:	84aa                	mv	s1,a0
    8000465e:	892e                	mv	s2,a1
    80004660:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004662:	a7efd0ef          	jal	800018e0 <myproc>
    80004666:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004668:	8526                	mv	a0,s1
    8000466a:	d8afc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000466e:	2184a703          	lw	a4,536(s1)
    80004672:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004676:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000467a:	02f71563          	bne	a4,a5,800046a4 <piperead+0x5a>
    8000467e:	2244a783          	lw	a5,548(s1)
    80004682:	cb85                	beqz	a5,800046b2 <piperead+0x68>
    if(killed(pr)){
    80004684:	8552                	mv	a0,s4
    80004686:	aa9fd0ef          	jal	8000212e <killed>
    8000468a:	ed19                	bnez	a0,800046a8 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000468c:	85a6                	mv	a1,s1
    8000468e:	854e                	mv	a0,s3
    80004690:	823fd0ef          	jal	80001eb2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004694:	2184a703          	lw	a4,536(s1)
    80004698:	21c4a783          	lw	a5,540(s1)
    8000469c:	fef701e3          	beq	a4,a5,8000467e <piperead+0x34>
    800046a0:	e85a                	sd	s6,16(sp)
    800046a2:	a809                	j	800046b4 <piperead+0x6a>
    800046a4:	e85a                	sd	s6,16(sp)
    800046a6:	a039                	j	800046b4 <piperead+0x6a>
      release(&pi->lock);
    800046a8:	8526                	mv	a0,s1
    800046aa:	de2fc0ef          	jal	80000c8c <release>
      return -1;
    800046ae:	59fd                	li	s3,-1
    800046b0:	a8b1                	j	8000470c <piperead+0xc2>
    800046b2:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046b4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800046b6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046b8:	05505263          	blez	s5,800046fc <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800046bc:	2184a783          	lw	a5,536(s1)
    800046c0:	21c4a703          	lw	a4,540(s1)
    800046c4:	02f70c63          	beq	a4,a5,800046fc <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800046c8:	0017871b          	addiw	a4,a5,1
    800046cc:	20e4ac23          	sw	a4,536(s1)
    800046d0:	1ff7f793          	andi	a5,a5,511
    800046d4:	97a6                	add	a5,a5,s1
    800046d6:	0187c783          	lbu	a5,24(a5)
    800046da:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800046de:	4685                	li	a3,1
    800046e0:	fbf40613          	addi	a2,s0,-65
    800046e4:	85ca                	mv	a1,s2
    800046e6:	058a3503          	ld	a0,88(s4)
    800046ea:	e69fc0ef          	jal	80001552 <copyout>
    800046ee:	01650763          	beq	a0,s6,800046fc <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046f2:	2985                	addiw	s3,s3,1
    800046f4:	0905                	addi	s2,s2,1
    800046f6:	fd3a93e3          	bne	s5,s3,800046bc <piperead+0x72>
    800046fa:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800046fc:	21c48513          	addi	a0,s1,540
    80004700:	ffefd0ef          	jal	80001efe <wakeup>
  release(&pi->lock);
    80004704:	8526                	mv	a0,s1
    80004706:	d86fc0ef          	jal	80000c8c <release>
    8000470a:	6b42                	ld	s6,16(sp)
  return i;
}
    8000470c:	854e                	mv	a0,s3
    8000470e:	60a6                	ld	ra,72(sp)
    80004710:	6406                	ld	s0,64(sp)
    80004712:	74e2                	ld	s1,56(sp)
    80004714:	7942                	ld	s2,48(sp)
    80004716:	79a2                	ld	s3,40(sp)
    80004718:	7a02                	ld	s4,32(sp)
    8000471a:	6ae2                	ld	s5,24(sp)
    8000471c:	6161                	addi	sp,sp,80
    8000471e:	8082                	ret

0000000080004720 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004720:	1141                	addi	sp,sp,-16
    80004722:	e422                	sd	s0,8(sp)
    80004724:	0800                	addi	s0,sp,16
    80004726:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004728:	8905                	andi	a0,a0,1
    8000472a:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000472c:	8b89                	andi	a5,a5,2
    8000472e:	c399                	beqz	a5,80004734 <flags2perm+0x14>
      perm |= PTE_W;
    80004730:	00456513          	ori	a0,a0,4
    return perm;
}
    80004734:	6422                	ld	s0,8(sp)
    80004736:	0141                	addi	sp,sp,16
    80004738:	8082                	ret

000000008000473a <exec>:

int
exec(char *path, char **argv)
{
    8000473a:	df010113          	addi	sp,sp,-528
    8000473e:	20113423          	sd	ra,520(sp)
    80004742:	20813023          	sd	s0,512(sp)
    80004746:	ffa6                	sd	s1,504(sp)
    80004748:	fbca                	sd	s2,496(sp)
    8000474a:	0c00                	addi	s0,sp,528
    8000474c:	892a                	mv	s2,a0
    8000474e:	dea43c23          	sd	a0,-520(s0)
    80004752:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004756:	98afd0ef          	jal	800018e0 <myproc>
    8000475a:	84aa                	mv	s1,a0

  begin_op();
    8000475c:	dc6ff0ef          	jal	80003d22 <begin_op>

  if((ip = namei(path)) == 0){
    80004760:	854a                	mv	a0,s2
    80004762:	c04ff0ef          	jal	80003b66 <namei>
    80004766:	c931                	beqz	a0,800047ba <exec+0x80>
    80004768:	f3d2                	sd	s4,480(sp)
    8000476a:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    8000476c:	d21fe0ef          	jal	8000348c <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004770:	04000713          	li	a4,64
    80004774:	4681                	li	a3,0
    80004776:	e5040613          	addi	a2,s0,-432
    8000477a:	4581                	li	a1,0
    8000477c:	8552                	mv	a0,s4
    8000477e:	f63fe0ef          	jal	800036e0 <readi>
    80004782:	04000793          	li	a5,64
    80004786:	00f51a63          	bne	a0,a5,8000479a <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000478a:	e5042703          	lw	a4,-432(s0)
    8000478e:	464c47b7          	lui	a5,0x464c4
    80004792:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004796:	02f70663          	beq	a4,a5,800047c2 <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000479a:	8552                	mv	a0,s4
    8000479c:	efbfe0ef          	jal	80003696 <iunlockput>
    end_op();
    800047a0:	decff0ef          	jal	80003d8c <end_op>
  }
  return -1;
    800047a4:	557d                	li	a0,-1
    800047a6:	7a1e                	ld	s4,480(sp)
}
    800047a8:	20813083          	ld	ra,520(sp)
    800047ac:	20013403          	ld	s0,512(sp)
    800047b0:	74fe                	ld	s1,504(sp)
    800047b2:	795e                	ld	s2,496(sp)
    800047b4:	21010113          	addi	sp,sp,528
    800047b8:	8082                	ret
    end_op();
    800047ba:	dd2ff0ef          	jal	80003d8c <end_op>
    return -1;
    800047be:	557d                	li	a0,-1
    800047c0:	b7e5                	j	800047a8 <exec+0x6e>
    800047c2:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800047c4:	8526                	mv	a0,s1
    800047c6:	9c2fd0ef          	jal	80001988 <proc_pagetable>
    800047ca:	8b2a                	mv	s6,a0
    800047cc:	2c050b63          	beqz	a0,80004aa2 <exec+0x368>
    800047d0:	f7ce                	sd	s3,488(sp)
    800047d2:	efd6                	sd	s5,472(sp)
    800047d4:	e7de                	sd	s7,456(sp)
    800047d6:	e3e2                	sd	s8,448(sp)
    800047d8:	ff66                	sd	s9,440(sp)
    800047da:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047dc:	e7042d03          	lw	s10,-400(s0)
    800047e0:	e8845783          	lhu	a5,-376(s0)
    800047e4:	12078963          	beqz	a5,80004916 <exec+0x1dc>
    800047e8:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047ea:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047ec:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800047ee:	6c85                	lui	s9,0x1
    800047f0:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800047f4:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800047f8:	6a85                	lui	s5,0x1
    800047fa:	a085                	j	8000485a <exec+0x120>
      panic("loadseg: address should exist");
    800047fc:	00003517          	auipc	a0,0x3
    80004800:	ef450513          	addi	a0,a0,-268 # 800076f0 <etext+0x6f0>
    80004804:	f91fb0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004808:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000480a:	8726                	mv	a4,s1
    8000480c:	012c06bb          	addw	a3,s8,s2
    80004810:	4581                	li	a1,0
    80004812:	8552                	mv	a0,s4
    80004814:	ecdfe0ef          	jal	800036e0 <readi>
    80004818:	2501                	sext.w	a0,a0
    8000481a:	24a49a63          	bne	s1,a0,80004a6e <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    8000481e:	012a893b          	addw	s2,s5,s2
    80004822:	03397363          	bgeu	s2,s3,80004848 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004826:	02091593          	slli	a1,s2,0x20
    8000482a:	9181                	srli	a1,a1,0x20
    8000482c:	95de                	add	a1,a1,s7
    8000482e:	855a                	mv	a0,s6
    80004830:	fa6fc0ef          	jal	80000fd6 <walkaddr>
    80004834:	862a                	mv	a2,a0
    if(pa == 0)
    80004836:	d179                	beqz	a0,800047fc <exec+0xc2>
    if(sz - i < PGSIZE)
    80004838:	412984bb          	subw	s1,s3,s2
    8000483c:	0004879b          	sext.w	a5,s1
    80004840:	fcfcf4e3          	bgeu	s9,a5,80004808 <exec+0xce>
    80004844:	84d6                	mv	s1,s5
    80004846:	b7c9                	j	80004808 <exec+0xce>
    sz = sz1;
    80004848:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000484c:	2d85                	addiw	s11,s11,1
    8000484e:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004852:	e8845783          	lhu	a5,-376(s0)
    80004856:	08fdd063          	bge	s11,a5,800048d6 <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000485a:	2d01                	sext.w	s10,s10
    8000485c:	03800713          	li	a4,56
    80004860:	86ea                	mv	a3,s10
    80004862:	e1840613          	addi	a2,s0,-488
    80004866:	4581                	li	a1,0
    80004868:	8552                	mv	a0,s4
    8000486a:	e77fe0ef          	jal	800036e0 <readi>
    8000486e:	03800793          	li	a5,56
    80004872:	1cf51663          	bne	a0,a5,80004a3e <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004876:	e1842783          	lw	a5,-488(s0)
    8000487a:	4705                	li	a4,1
    8000487c:	fce798e3          	bne	a5,a4,8000484c <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004880:	e4043483          	ld	s1,-448(s0)
    80004884:	e3843783          	ld	a5,-456(s0)
    80004888:	1af4ef63          	bltu	s1,a5,80004a46 <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000488c:	e2843783          	ld	a5,-472(s0)
    80004890:	94be                	add	s1,s1,a5
    80004892:	1af4ee63          	bltu	s1,a5,80004a4e <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004896:	df043703          	ld	a4,-528(s0)
    8000489a:	8ff9                	and	a5,a5,a4
    8000489c:	1a079d63          	bnez	a5,80004a56 <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800048a0:	e1c42503          	lw	a0,-484(s0)
    800048a4:	e7dff0ef          	jal	80004720 <flags2perm>
    800048a8:	86aa                	mv	a3,a0
    800048aa:	8626                	mv	a2,s1
    800048ac:	85ca                	mv	a1,s2
    800048ae:	855a                	mv	a0,s6
    800048b0:	a8ffc0ef          	jal	8000133e <uvmalloc>
    800048b4:	e0a43423          	sd	a0,-504(s0)
    800048b8:	1a050363          	beqz	a0,80004a5e <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800048bc:	e2843b83          	ld	s7,-472(s0)
    800048c0:	e2042c03          	lw	s8,-480(s0)
    800048c4:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800048c8:	00098463          	beqz	s3,800048d0 <exec+0x196>
    800048cc:	4901                	li	s2,0
    800048ce:	bfa1                	j	80004826 <exec+0xec>
    sz = sz1;
    800048d0:	e0843903          	ld	s2,-504(s0)
    800048d4:	bfa5                	j	8000484c <exec+0x112>
    800048d6:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800048d8:	8552                	mv	a0,s4
    800048da:	dbdfe0ef          	jal	80003696 <iunlockput>
  end_op();
    800048de:	caeff0ef          	jal	80003d8c <end_op>
  p = myproc();
    800048e2:	ffffc0ef          	jal	800018e0 <myproc>
    800048e6:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800048e8:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    800048ec:	6985                	lui	s3,0x1
    800048ee:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800048f0:	99ca                	add	s3,s3,s2
    800048f2:	77fd                	lui	a5,0xfffff
    800048f4:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048f8:	4691                	li	a3,4
    800048fa:	6609                	lui	a2,0x2
    800048fc:	964e                	add	a2,a2,s3
    800048fe:	85ce                	mv	a1,s3
    80004900:	855a                	mv	a0,s6
    80004902:	a3dfc0ef          	jal	8000133e <uvmalloc>
    80004906:	892a                	mv	s2,a0
    80004908:	e0a43423          	sd	a0,-504(s0)
    8000490c:	e519                	bnez	a0,8000491a <exec+0x1e0>
  if(pagetable)
    8000490e:	e1343423          	sd	s3,-504(s0)
    80004912:	4a01                	li	s4,0
    80004914:	aab1                	j	80004a70 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004916:	4901                	li	s2,0
    80004918:	b7c1                	j	800048d8 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    8000491a:	75f9                	lui	a1,0xffffe
    8000491c:	95aa                	add	a1,a1,a0
    8000491e:	855a                	mv	a0,s6
    80004920:	c09fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004924:	7bfd                	lui	s7,0xfffff
    80004926:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004928:	e0043783          	ld	a5,-512(s0)
    8000492c:	6388                	ld	a0,0(a5)
    8000492e:	cd39                	beqz	a0,8000498c <exec+0x252>
    80004930:	e9040993          	addi	s3,s0,-368
    80004934:	f9040c13          	addi	s8,s0,-112
    80004938:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000493a:	cfefc0ef          	jal	80000e38 <strlen>
    8000493e:	0015079b          	addiw	a5,a0,1
    80004942:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004946:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000494a:	11796e63          	bltu	s2,s7,80004a66 <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000494e:	e0043d03          	ld	s10,-512(s0)
    80004952:	000d3a03          	ld	s4,0(s10)
    80004956:	8552                	mv	a0,s4
    80004958:	ce0fc0ef          	jal	80000e38 <strlen>
    8000495c:	0015069b          	addiw	a3,a0,1
    80004960:	8652                	mv	a2,s4
    80004962:	85ca                	mv	a1,s2
    80004964:	855a                	mv	a0,s6
    80004966:	bedfc0ef          	jal	80001552 <copyout>
    8000496a:	10054063          	bltz	a0,80004a6a <exec+0x330>
    ustack[argc] = sp;
    8000496e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004972:	0485                	addi	s1,s1,1
    80004974:	008d0793          	addi	a5,s10,8
    80004978:	e0f43023          	sd	a5,-512(s0)
    8000497c:	008d3503          	ld	a0,8(s10)
    80004980:	c909                	beqz	a0,80004992 <exec+0x258>
    if(argc >= MAXARG)
    80004982:	09a1                	addi	s3,s3,8
    80004984:	fb899be3          	bne	s3,s8,8000493a <exec+0x200>
  ip = 0;
    80004988:	4a01                	li	s4,0
    8000498a:	a0dd                	j	80004a70 <exec+0x336>
  sp = sz;
    8000498c:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004990:	4481                	li	s1,0
  ustack[argc] = 0;
    80004992:	00349793          	slli	a5,s1,0x3
    80004996:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffd59f8>
    8000499a:	97a2                	add	a5,a5,s0
    8000499c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800049a0:	00148693          	addi	a3,s1,1
    800049a4:	068e                	slli	a3,a3,0x3
    800049a6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800049aa:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800049ae:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800049b2:	f5796ee3          	bltu	s2,s7,8000490e <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800049b6:	e9040613          	addi	a2,s0,-368
    800049ba:	85ca                	mv	a1,s2
    800049bc:	855a                	mv	a0,s6
    800049be:	b95fc0ef          	jal	80001552 <copyout>
    800049c2:	0e054263          	bltz	a0,80004aa6 <exec+0x36c>
  p->trapframe->a1 = sp;
    800049c6:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    800049ca:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800049ce:	df843783          	ld	a5,-520(s0)
    800049d2:	0007c703          	lbu	a4,0(a5)
    800049d6:	cf11                	beqz	a4,800049f2 <exec+0x2b8>
    800049d8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800049da:	02f00693          	li	a3,47
    800049de:	a039                	j	800049ec <exec+0x2b2>
      last = s+1;
    800049e0:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800049e4:	0785                	addi	a5,a5,1
    800049e6:	fff7c703          	lbu	a4,-1(a5)
    800049ea:	c701                	beqz	a4,800049f2 <exec+0x2b8>
    if(*s == '/')
    800049ec:	fed71ce3          	bne	a4,a3,800049e4 <exec+0x2aa>
    800049f0:	bfc5                	j	800049e0 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800049f2:	4641                	li	a2,16
    800049f4:	df843583          	ld	a1,-520(s0)
    800049f8:	160a8513          	addi	a0,s5,352
    800049fc:	c0afc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004a00:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80004a04:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    80004a08:	e0843783          	ld	a5,-504(s0)
    80004a0c:	04fab823          	sd	a5,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004a10:	060ab783          	ld	a5,96(s5)
    80004a14:	e6843703          	ld	a4,-408(s0)
    80004a18:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004a1a:	060ab783          	ld	a5,96(s5)
    80004a1e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a22:	85e6                	mv	a1,s9
    80004a24:	fe9fc0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a28:	0004851b          	sext.w	a0,s1
    80004a2c:	79be                	ld	s3,488(sp)
    80004a2e:	7a1e                	ld	s4,480(sp)
    80004a30:	6afe                	ld	s5,472(sp)
    80004a32:	6b5e                	ld	s6,464(sp)
    80004a34:	6bbe                	ld	s7,456(sp)
    80004a36:	6c1e                	ld	s8,448(sp)
    80004a38:	7cfa                	ld	s9,440(sp)
    80004a3a:	7d5a                	ld	s10,432(sp)
    80004a3c:	b3b5                	j	800047a8 <exec+0x6e>
    80004a3e:	e1243423          	sd	s2,-504(s0)
    80004a42:	7dba                	ld	s11,424(sp)
    80004a44:	a035                	j	80004a70 <exec+0x336>
    80004a46:	e1243423          	sd	s2,-504(s0)
    80004a4a:	7dba                	ld	s11,424(sp)
    80004a4c:	a015                	j	80004a70 <exec+0x336>
    80004a4e:	e1243423          	sd	s2,-504(s0)
    80004a52:	7dba                	ld	s11,424(sp)
    80004a54:	a831                	j	80004a70 <exec+0x336>
    80004a56:	e1243423          	sd	s2,-504(s0)
    80004a5a:	7dba                	ld	s11,424(sp)
    80004a5c:	a811                	j	80004a70 <exec+0x336>
    80004a5e:	e1243423          	sd	s2,-504(s0)
    80004a62:	7dba                	ld	s11,424(sp)
    80004a64:	a031                	j	80004a70 <exec+0x336>
  ip = 0;
    80004a66:	4a01                	li	s4,0
    80004a68:	a021                	j	80004a70 <exec+0x336>
    80004a6a:	4a01                	li	s4,0
  if(pagetable)
    80004a6c:	a011                	j	80004a70 <exec+0x336>
    80004a6e:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004a70:	e0843583          	ld	a1,-504(s0)
    80004a74:	855a                	mv	a0,s6
    80004a76:	f97fc0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    80004a7a:	557d                	li	a0,-1
  if(ip){
    80004a7c:	000a1b63          	bnez	s4,80004a92 <exec+0x358>
    80004a80:	79be                	ld	s3,488(sp)
    80004a82:	7a1e                	ld	s4,480(sp)
    80004a84:	6afe                	ld	s5,472(sp)
    80004a86:	6b5e                	ld	s6,464(sp)
    80004a88:	6bbe                	ld	s7,456(sp)
    80004a8a:	6c1e                	ld	s8,448(sp)
    80004a8c:	7cfa                	ld	s9,440(sp)
    80004a8e:	7d5a                	ld	s10,432(sp)
    80004a90:	bb21                	j	800047a8 <exec+0x6e>
    80004a92:	79be                	ld	s3,488(sp)
    80004a94:	6afe                	ld	s5,472(sp)
    80004a96:	6b5e                	ld	s6,464(sp)
    80004a98:	6bbe                	ld	s7,456(sp)
    80004a9a:	6c1e                	ld	s8,448(sp)
    80004a9c:	7cfa                	ld	s9,440(sp)
    80004a9e:	7d5a                	ld	s10,432(sp)
    80004aa0:	b9ed                	j	8000479a <exec+0x60>
    80004aa2:	6b5e                	ld	s6,464(sp)
    80004aa4:	b9dd                	j	8000479a <exec+0x60>
  sz = sz1;
    80004aa6:	e0843983          	ld	s3,-504(s0)
    80004aaa:	b595                	j	8000490e <exec+0x1d4>

0000000080004aac <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004aac:	7179                	addi	sp,sp,-48
    80004aae:	f406                	sd	ra,40(sp)
    80004ab0:	f022                	sd	s0,32(sp)
    80004ab2:	ec26                	sd	s1,24(sp)
    80004ab4:	e84a                	sd	s2,16(sp)
    80004ab6:	1800                	addi	s0,sp,48
    80004ab8:	892e                	mv	s2,a1
    80004aba:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004abc:	fdc40593          	addi	a1,s0,-36
    80004ac0:	f8dfd0ef          	jal	80002a4c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ac4:	fdc42703          	lw	a4,-36(s0)
    80004ac8:	47bd                	li	a5,15
    80004aca:	02e7e963          	bltu	a5,a4,80004afc <argfd+0x50>
    80004ace:	e13fc0ef          	jal	800018e0 <myproc>
    80004ad2:	fdc42703          	lw	a4,-36(s0)
    80004ad6:	01a70793          	addi	a5,a4,26
    80004ada:	078e                	slli	a5,a5,0x3
    80004adc:	953e                	add	a0,a0,a5
    80004ade:	651c                	ld	a5,8(a0)
    80004ae0:	c385                	beqz	a5,80004b00 <argfd+0x54>
    return -1;
  if(pfd)
    80004ae2:	00090463          	beqz	s2,80004aea <argfd+0x3e>
    *pfd = fd;
    80004ae6:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004aea:	4501                	li	a0,0
  if(pf)
    80004aec:	c091                	beqz	s1,80004af0 <argfd+0x44>
    *pf = f;
    80004aee:	e09c                	sd	a5,0(s1)
}
    80004af0:	70a2                	ld	ra,40(sp)
    80004af2:	7402                	ld	s0,32(sp)
    80004af4:	64e2                	ld	s1,24(sp)
    80004af6:	6942                	ld	s2,16(sp)
    80004af8:	6145                	addi	sp,sp,48
    80004afa:	8082                	ret
    return -1;
    80004afc:	557d                	li	a0,-1
    80004afe:	bfcd                	j	80004af0 <argfd+0x44>
    80004b00:	557d                	li	a0,-1
    80004b02:	b7fd                	j	80004af0 <argfd+0x44>

0000000080004b04 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b04:	1101                	addi	sp,sp,-32
    80004b06:	ec06                	sd	ra,24(sp)
    80004b08:	e822                	sd	s0,16(sp)
    80004b0a:	e426                	sd	s1,8(sp)
    80004b0c:	1000                	addi	s0,sp,32
    80004b0e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b10:	dd1fc0ef          	jal	800018e0 <myproc>
    80004b14:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004b16:	0d850793          	addi	a5,a0,216
    80004b1a:	4501                	li	a0,0
    80004b1c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004b1e:	6398                	ld	a4,0(a5)
    80004b20:	cb19                	beqz	a4,80004b36 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004b22:	2505                	addiw	a0,a0,1
    80004b24:	07a1                	addi	a5,a5,8
    80004b26:	fed51ce3          	bne	a0,a3,80004b1e <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004b2a:	557d                	li	a0,-1
}
    80004b2c:	60e2                	ld	ra,24(sp)
    80004b2e:	6442                	ld	s0,16(sp)
    80004b30:	64a2                	ld	s1,8(sp)
    80004b32:	6105                	addi	sp,sp,32
    80004b34:	8082                	ret
      p->ofile[fd] = f;
    80004b36:	01a50793          	addi	a5,a0,26
    80004b3a:	078e                	slli	a5,a5,0x3
    80004b3c:	963e                	add	a2,a2,a5
    80004b3e:	e604                	sd	s1,8(a2)
      return fd;
    80004b40:	b7f5                	j	80004b2c <fdalloc+0x28>

0000000080004b42 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004b42:	715d                	addi	sp,sp,-80
    80004b44:	e486                	sd	ra,72(sp)
    80004b46:	e0a2                	sd	s0,64(sp)
    80004b48:	fc26                	sd	s1,56(sp)
    80004b4a:	f84a                	sd	s2,48(sp)
    80004b4c:	f44e                	sd	s3,40(sp)
    80004b4e:	ec56                	sd	s5,24(sp)
    80004b50:	e85a                	sd	s6,16(sp)
    80004b52:	0880                	addi	s0,sp,80
    80004b54:	8b2e                	mv	s6,a1
    80004b56:	89b2                	mv	s3,a2
    80004b58:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b5a:	fb040593          	addi	a1,s0,-80
    80004b5e:	822ff0ef          	jal	80003b80 <nameiparent>
    80004b62:	84aa                	mv	s1,a0
    80004b64:	10050a63          	beqz	a0,80004c78 <create+0x136>
    return 0;

  ilock(dp);
    80004b68:	925fe0ef          	jal	8000348c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b6c:	4601                	li	a2,0
    80004b6e:	fb040593          	addi	a1,s0,-80
    80004b72:	8526                	mv	a0,s1
    80004b74:	d8dfe0ef          	jal	80003900 <dirlookup>
    80004b78:	8aaa                	mv	s5,a0
    80004b7a:	c129                	beqz	a0,80004bbc <create+0x7a>
    iunlockput(dp);
    80004b7c:	8526                	mv	a0,s1
    80004b7e:	b19fe0ef          	jal	80003696 <iunlockput>
    ilock(ip);
    80004b82:	8556                	mv	a0,s5
    80004b84:	909fe0ef          	jal	8000348c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b88:	4789                	li	a5,2
    80004b8a:	02fb1463          	bne	s6,a5,80004bb2 <create+0x70>
    80004b8e:	044ad783          	lhu	a5,68(s5)
    80004b92:	37f9                	addiw	a5,a5,-2
    80004b94:	17c2                	slli	a5,a5,0x30
    80004b96:	93c1                	srli	a5,a5,0x30
    80004b98:	4705                	li	a4,1
    80004b9a:	00f76c63          	bltu	a4,a5,80004bb2 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b9e:	8556                	mv	a0,s5
    80004ba0:	60a6                	ld	ra,72(sp)
    80004ba2:	6406                	ld	s0,64(sp)
    80004ba4:	74e2                	ld	s1,56(sp)
    80004ba6:	7942                	ld	s2,48(sp)
    80004ba8:	79a2                	ld	s3,40(sp)
    80004baa:	6ae2                	ld	s5,24(sp)
    80004bac:	6b42                	ld	s6,16(sp)
    80004bae:	6161                	addi	sp,sp,80
    80004bb0:	8082                	ret
    iunlockput(ip);
    80004bb2:	8556                	mv	a0,s5
    80004bb4:	ae3fe0ef          	jal	80003696 <iunlockput>
    return 0;
    80004bb8:	4a81                	li	s5,0
    80004bba:	b7d5                	j	80004b9e <create+0x5c>
    80004bbc:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80004bbe:	85da                	mv	a1,s6
    80004bc0:	4088                	lw	a0,0(s1)
    80004bc2:	f5afe0ef          	jal	8000331c <ialloc>
    80004bc6:	8a2a                	mv	s4,a0
    80004bc8:	cd15                	beqz	a0,80004c04 <create+0xc2>
  ilock(ip);
    80004bca:	8c3fe0ef          	jal	8000348c <ilock>
  ip->major = major;
    80004bce:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004bd2:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004bd6:	4905                	li	s2,1
    80004bd8:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004bdc:	8552                	mv	a0,s4
    80004bde:	ffafe0ef          	jal	800033d8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004be2:	032b0763          	beq	s6,s2,80004c10 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004be6:	004a2603          	lw	a2,4(s4)
    80004bea:	fb040593          	addi	a1,s0,-80
    80004bee:	8526                	mv	a0,s1
    80004bf0:	eddfe0ef          	jal	80003acc <dirlink>
    80004bf4:	06054563          	bltz	a0,80004c5e <create+0x11c>
  iunlockput(dp);
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	a9dfe0ef          	jal	80003696 <iunlockput>
  return ip;
    80004bfe:	8ad2                	mv	s5,s4
    80004c00:	7a02                	ld	s4,32(sp)
    80004c02:	bf71                	j	80004b9e <create+0x5c>
    iunlockput(dp);
    80004c04:	8526                	mv	a0,s1
    80004c06:	a91fe0ef          	jal	80003696 <iunlockput>
    return 0;
    80004c0a:	8ad2                	mv	s5,s4
    80004c0c:	7a02                	ld	s4,32(sp)
    80004c0e:	bf41                	j	80004b9e <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c10:	004a2603          	lw	a2,4(s4)
    80004c14:	00003597          	auipc	a1,0x3
    80004c18:	afc58593          	addi	a1,a1,-1284 # 80007710 <etext+0x710>
    80004c1c:	8552                	mv	a0,s4
    80004c1e:	eaffe0ef          	jal	80003acc <dirlink>
    80004c22:	02054e63          	bltz	a0,80004c5e <create+0x11c>
    80004c26:	40d0                	lw	a2,4(s1)
    80004c28:	00003597          	auipc	a1,0x3
    80004c2c:	af058593          	addi	a1,a1,-1296 # 80007718 <etext+0x718>
    80004c30:	8552                	mv	a0,s4
    80004c32:	e9bfe0ef          	jal	80003acc <dirlink>
    80004c36:	02054463          	bltz	a0,80004c5e <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004c3a:	004a2603          	lw	a2,4(s4)
    80004c3e:	fb040593          	addi	a1,s0,-80
    80004c42:	8526                	mv	a0,s1
    80004c44:	e89fe0ef          	jal	80003acc <dirlink>
    80004c48:	00054b63          	bltz	a0,80004c5e <create+0x11c>
    dp->nlink++;  // for ".."
    80004c4c:	04a4d783          	lhu	a5,74(s1)
    80004c50:	2785                	addiw	a5,a5,1
    80004c52:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c56:	8526                	mv	a0,s1
    80004c58:	f80fe0ef          	jal	800033d8 <iupdate>
    80004c5c:	bf71                	j	80004bf8 <create+0xb6>
  ip->nlink = 0;
    80004c5e:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004c62:	8552                	mv	a0,s4
    80004c64:	f74fe0ef          	jal	800033d8 <iupdate>
  iunlockput(ip);
    80004c68:	8552                	mv	a0,s4
    80004c6a:	a2dfe0ef          	jal	80003696 <iunlockput>
  iunlockput(dp);
    80004c6e:	8526                	mv	a0,s1
    80004c70:	a27fe0ef          	jal	80003696 <iunlockput>
  return 0;
    80004c74:	7a02                	ld	s4,32(sp)
    80004c76:	b725                	j	80004b9e <create+0x5c>
    return 0;
    80004c78:	8aaa                	mv	s5,a0
    80004c7a:	b715                	j	80004b9e <create+0x5c>

0000000080004c7c <sys_dup>:
{
    80004c7c:	7179                	addi	sp,sp,-48
    80004c7e:	f406                	sd	ra,40(sp)
    80004c80:	f022                	sd	s0,32(sp)
    80004c82:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c84:	fd840613          	addi	a2,s0,-40
    80004c88:	4581                	li	a1,0
    80004c8a:	4501                	li	a0,0
    80004c8c:	e21ff0ef          	jal	80004aac <argfd>
    return -1;
    80004c90:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c92:	02054363          	bltz	a0,80004cb8 <sys_dup+0x3c>
    80004c96:	ec26                	sd	s1,24(sp)
    80004c98:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004c9a:	fd843903          	ld	s2,-40(s0)
    80004c9e:	854a                	mv	a0,s2
    80004ca0:	e65ff0ef          	jal	80004b04 <fdalloc>
    80004ca4:	84aa                	mv	s1,a0
    return -1;
    80004ca6:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004ca8:	00054d63          	bltz	a0,80004cc2 <sys_dup+0x46>
  filedup(f);
    80004cac:	854a                	mv	a0,s2
    80004cae:	c48ff0ef          	jal	800040f6 <filedup>
  return fd;
    80004cb2:	87a6                	mv	a5,s1
    80004cb4:	64e2                	ld	s1,24(sp)
    80004cb6:	6942                	ld	s2,16(sp)
}
    80004cb8:	853e                	mv	a0,a5
    80004cba:	70a2                	ld	ra,40(sp)
    80004cbc:	7402                	ld	s0,32(sp)
    80004cbe:	6145                	addi	sp,sp,48
    80004cc0:	8082                	ret
    80004cc2:	64e2                	ld	s1,24(sp)
    80004cc4:	6942                	ld	s2,16(sp)
    80004cc6:	bfcd                	j	80004cb8 <sys_dup+0x3c>

0000000080004cc8 <sys_read>:
{
    80004cc8:	7179                	addi	sp,sp,-48
    80004cca:	f406                	sd	ra,40(sp)
    80004ccc:	f022                	sd	s0,32(sp)
    80004cce:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cd0:	fd840593          	addi	a1,s0,-40
    80004cd4:	4505                	li	a0,1
    80004cd6:	d93fd0ef          	jal	80002a68 <argaddr>
  argint(2, &n);
    80004cda:	fe440593          	addi	a1,s0,-28
    80004cde:	4509                	li	a0,2
    80004ce0:	d6dfd0ef          	jal	80002a4c <argint>
  if(argfd(0, 0, &f) < 0)
    80004ce4:	fe840613          	addi	a2,s0,-24
    80004ce8:	4581                	li	a1,0
    80004cea:	4501                	li	a0,0
    80004cec:	dc1ff0ef          	jal	80004aac <argfd>
    80004cf0:	87aa                	mv	a5,a0
    return -1;
    80004cf2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cf4:	0007ca63          	bltz	a5,80004d08 <sys_read+0x40>
  return fileread(f, p, n);
    80004cf8:	fe442603          	lw	a2,-28(s0)
    80004cfc:	fd843583          	ld	a1,-40(s0)
    80004d00:	fe843503          	ld	a0,-24(s0)
    80004d04:	d58ff0ef          	jal	8000425c <fileread>
}
    80004d08:	70a2                	ld	ra,40(sp)
    80004d0a:	7402                	ld	s0,32(sp)
    80004d0c:	6145                	addi	sp,sp,48
    80004d0e:	8082                	ret

0000000080004d10 <sys_write>:
{
    80004d10:	7179                	addi	sp,sp,-48
    80004d12:	f406                	sd	ra,40(sp)
    80004d14:	f022                	sd	s0,32(sp)
    80004d16:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d18:	fd840593          	addi	a1,s0,-40
    80004d1c:	4505                	li	a0,1
    80004d1e:	d4bfd0ef          	jal	80002a68 <argaddr>
  argint(2, &n);
    80004d22:	fe440593          	addi	a1,s0,-28
    80004d26:	4509                	li	a0,2
    80004d28:	d25fd0ef          	jal	80002a4c <argint>
  if(argfd(0, 0, &f) < 0)
    80004d2c:	fe840613          	addi	a2,s0,-24
    80004d30:	4581                	li	a1,0
    80004d32:	4501                	li	a0,0
    80004d34:	d79ff0ef          	jal	80004aac <argfd>
    80004d38:	87aa                	mv	a5,a0
    return -1;
    80004d3a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d3c:	0007ca63          	bltz	a5,80004d50 <sys_write+0x40>
  return filewrite(f, p, n);
    80004d40:	fe442603          	lw	a2,-28(s0)
    80004d44:	fd843583          	ld	a1,-40(s0)
    80004d48:	fe843503          	ld	a0,-24(s0)
    80004d4c:	dceff0ef          	jal	8000431a <filewrite>
}
    80004d50:	70a2                	ld	ra,40(sp)
    80004d52:	7402                	ld	s0,32(sp)
    80004d54:	6145                	addi	sp,sp,48
    80004d56:	8082                	ret

0000000080004d58 <sys_close>:
{
    80004d58:	1101                	addi	sp,sp,-32
    80004d5a:	ec06                	sd	ra,24(sp)
    80004d5c:	e822                	sd	s0,16(sp)
    80004d5e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d60:	fe040613          	addi	a2,s0,-32
    80004d64:	fec40593          	addi	a1,s0,-20
    80004d68:	4501                	li	a0,0
    80004d6a:	d43ff0ef          	jal	80004aac <argfd>
    return -1;
    80004d6e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d70:	02054063          	bltz	a0,80004d90 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004d74:	b6dfc0ef          	jal	800018e0 <myproc>
    80004d78:	fec42783          	lw	a5,-20(s0)
    80004d7c:	07e9                	addi	a5,a5,26
    80004d7e:	078e                	slli	a5,a5,0x3
    80004d80:	953e                	add	a0,a0,a5
    80004d82:	00053423          	sd	zero,8(a0)
  fileclose(f);
    80004d86:	fe043503          	ld	a0,-32(s0)
    80004d8a:	bb2ff0ef          	jal	8000413c <fileclose>
  return 0;
    80004d8e:	4781                	li	a5,0
}
    80004d90:	853e                	mv	a0,a5
    80004d92:	60e2                	ld	ra,24(sp)
    80004d94:	6442                	ld	s0,16(sp)
    80004d96:	6105                	addi	sp,sp,32
    80004d98:	8082                	ret

0000000080004d9a <sys_fstat>:
{
    80004d9a:	1101                	addi	sp,sp,-32
    80004d9c:	ec06                	sd	ra,24(sp)
    80004d9e:	e822                	sd	s0,16(sp)
    80004da0:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004da2:	fe040593          	addi	a1,s0,-32
    80004da6:	4505                	li	a0,1
    80004da8:	cc1fd0ef          	jal	80002a68 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004dac:	fe840613          	addi	a2,s0,-24
    80004db0:	4581                	li	a1,0
    80004db2:	4501                	li	a0,0
    80004db4:	cf9ff0ef          	jal	80004aac <argfd>
    80004db8:	87aa                	mv	a5,a0
    return -1;
    80004dba:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004dbc:	0007c863          	bltz	a5,80004dcc <sys_fstat+0x32>
  return filestat(f, st);
    80004dc0:	fe043583          	ld	a1,-32(s0)
    80004dc4:	fe843503          	ld	a0,-24(s0)
    80004dc8:	c36ff0ef          	jal	800041fe <filestat>
}
    80004dcc:	60e2                	ld	ra,24(sp)
    80004dce:	6442                	ld	s0,16(sp)
    80004dd0:	6105                	addi	sp,sp,32
    80004dd2:	8082                	ret

0000000080004dd4 <sys_link>:
{
    80004dd4:	7169                	addi	sp,sp,-304
    80004dd6:	f606                	sd	ra,296(sp)
    80004dd8:	f222                	sd	s0,288(sp)
    80004dda:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ddc:	08000613          	li	a2,128
    80004de0:	ed040593          	addi	a1,s0,-304
    80004de4:	4501                	li	a0,0
    80004de6:	c9ffd0ef          	jal	80002a84 <argstr>
    return -1;
    80004dea:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dec:	0c054e63          	bltz	a0,80004ec8 <sys_link+0xf4>
    80004df0:	08000613          	li	a2,128
    80004df4:	f5040593          	addi	a1,s0,-176
    80004df8:	4505                	li	a0,1
    80004dfa:	c8bfd0ef          	jal	80002a84 <argstr>
    return -1;
    80004dfe:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e00:	0c054463          	bltz	a0,80004ec8 <sys_link+0xf4>
    80004e04:	ee26                	sd	s1,280(sp)
  begin_op();
    80004e06:	f1dfe0ef          	jal	80003d22 <begin_op>
  if((ip = namei(old)) == 0){
    80004e0a:	ed040513          	addi	a0,s0,-304
    80004e0e:	d59fe0ef          	jal	80003b66 <namei>
    80004e12:	84aa                	mv	s1,a0
    80004e14:	c53d                	beqz	a0,80004e82 <sys_link+0xae>
  ilock(ip);
    80004e16:	e76fe0ef          	jal	8000348c <ilock>
  if(ip->type == T_DIR){
    80004e1a:	04449703          	lh	a4,68(s1)
    80004e1e:	4785                	li	a5,1
    80004e20:	06f70663          	beq	a4,a5,80004e8c <sys_link+0xb8>
    80004e24:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004e26:	04a4d783          	lhu	a5,74(s1)
    80004e2a:	2785                	addiw	a5,a5,1
    80004e2c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e30:	8526                	mv	a0,s1
    80004e32:	da6fe0ef          	jal	800033d8 <iupdate>
  iunlock(ip);
    80004e36:	8526                	mv	a0,s1
    80004e38:	f02fe0ef          	jal	8000353a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004e3c:	fd040593          	addi	a1,s0,-48
    80004e40:	f5040513          	addi	a0,s0,-176
    80004e44:	d3dfe0ef          	jal	80003b80 <nameiparent>
    80004e48:	892a                	mv	s2,a0
    80004e4a:	cd21                	beqz	a0,80004ea2 <sys_link+0xce>
  ilock(dp);
    80004e4c:	e40fe0ef          	jal	8000348c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e50:	00092703          	lw	a4,0(s2)
    80004e54:	409c                	lw	a5,0(s1)
    80004e56:	04f71363          	bne	a4,a5,80004e9c <sys_link+0xc8>
    80004e5a:	40d0                	lw	a2,4(s1)
    80004e5c:	fd040593          	addi	a1,s0,-48
    80004e60:	854a                	mv	a0,s2
    80004e62:	c6bfe0ef          	jal	80003acc <dirlink>
    80004e66:	02054b63          	bltz	a0,80004e9c <sys_link+0xc8>
  iunlockput(dp);
    80004e6a:	854a                	mv	a0,s2
    80004e6c:	82bfe0ef          	jal	80003696 <iunlockput>
  iput(ip);
    80004e70:	8526                	mv	a0,s1
    80004e72:	f9cfe0ef          	jal	8000360e <iput>
  end_op();
    80004e76:	f17fe0ef          	jal	80003d8c <end_op>
  return 0;
    80004e7a:	4781                	li	a5,0
    80004e7c:	64f2                	ld	s1,280(sp)
    80004e7e:	6952                	ld	s2,272(sp)
    80004e80:	a0a1                	j	80004ec8 <sys_link+0xf4>
    end_op();
    80004e82:	f0bfe0ef          	jal	80003d8c <end_op>
    return -1;
    80004e86:	57fd                	li	a5,-1
    80004e88:	64f2                	ld	s1,280(sp)
    80004e8a:	a83d                	j	80004ec8 <sys_link+0xf4>
    iunlockput(ip);
    80004e8c:	8526                	mv	a0,s1
    80004e8e:	809fe0ef          	jal	80003696 <iunlockput>
    end_op();
    80004e92:	efbfe0ef          	jal	80003d8c <end_op>
    return -1;
    80004e96:	57fd                	li	a5,-1
    80004e98:	64f2                	ld	s1,280(sp)
    80004e9a:	a03d                	j	80004ec8 <sys_link+0xf4>
    iunlockput(dp);
    80004e9c:	854a                	mv	a0,s2
    80004e9e:	ff8fe0ef          	jal	80003696 <iunlockput>
  ilock(ip);
    80004ea2:	8526                	mv	a0,s1
    80004ea4:	de8fe0ef          	jal	8000348c <ilock>
  ip->nlink--;
    80004ea8:	04a4d783          	lhu	a5,74(s1)
    80004eac:	37fd                	addiw	a5,a5,-1
    80004eae:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	d24fe0ef          	jal	800033d8 <iupdate>
  iunlockput(ip);
    80004eb8:	8526                	mv	a0,s1
    80004eba:	fdcfe0ef          	jal	80003696 <iunlockput>
  end_op();
    80004ebe:	ecffe0ef          	jal	80003d8c <end_op>
  return -1;
    80004ec2:	57fd                	li	a5,-1
    80004ec4:	64f2                	ld	s1,280(sp)
    80004ec6:	6952                	ld	s2,272(sp)
}
    80004ec8:	853e                	mv	a0,a5
    80004eca:	70b2                	ld	ra,296(sp)
    80004ecc:	7412                	ld	s0,288(sp)
    80004ece:	6155                	addi	sp,sp,304
    80004ed0:	8082                	ret

0000000080004ed2 <sys_unlink>:
{
    80004ed2:	7151                	addi	sp,sp,-240
    80004ed4:	f586                	sd	ra,232(sp)
    80004ed6:	f1a2                	sd	s0,224(sp)
    80004ed8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004eda:	08000613          	li	a2,128
    80004ede:	f3040593          	addi	a1,s0,-208
    80004ee2:	4501                	li	a0,0
    80004ee4:	ba1fd0ef          	jal	80002a84 <argstr>
    80004ee8:	16054063          	bltz	a0,80005048 <sys_unlink+0x176>
    80004eec:	eda6                	sd	s1,216(sp)
  begin_op();
    80004eee:	e35fe0ef          	jal	80003d22 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004ef2:	fb040593          	addi	a1,s0,-80
    80004ef6:	f3040513          	addi	a0,s0,-208
    80004efa:	c87fe0ef          	jal	80003b80 <nameiparent>
    80004efe:	84aa                	mv	s1,a0
    80004f00:	c945                	beqz	a0,80004fb0 <sys_unlink+0xde>
  ilock(dp);
    80004f02:	d8afe0ef          	jal	8000348c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f06:	00003597          	auipc	a1,0x3
    80004f0a:	80a58593          	addi	a1,a1,-2038 # 80007710 <etext+0x710>
    80004f0e:	fb040513          	addi	a0,s0,-80
    80004f12:	9d9fe0ef          	jal	800038ea <namecmp>
    80004f16:	10050e63          	beqz	a0,80005032 <sys_unlink+0x160>
    80004f1a:	00002597          	auipc	a1,0x2
    80004f1e:	7fe58593          	addi	a1,a1,2046 # 80007718 <etext+0x718>
    80004f22:	fb040513          	addi	a0,s0,-80
    80004f26:	9c5fe0ef          	jal	800038ea <namecmp>
    80004f2a:	10050463          	beqz	a0,80005032 <sys_unlink+0x160>
    80004f2e:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004f30:	f2c40613          	addi	a2,s0,-212
    80004f34:	fb040593          	addi	a1,s0,-80
    80004f38:	8526                	mv	a0,s1
    80004f3a:	9c7fe0ef          	jal	80003900 <dirlookup>
    80004f3e:	892a                	mv	s2,a0
    80004f40:	0e050863          	beqz	a0,80005030 <sys_unlink+0x15e>
  ilock(ip);
    80004f44:	d48fe0ef          	jal	8000348c <ilock>
  if(ip->nlink < 1)
    80004f48:	04a91783          	lh	a5,74(s2)
    80004f4c:	06f05763          	blez	a5,80004fba <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f50:	04491703          	lh	a4,68(s2)
    80004f54:	4785                	li	a5,1
    80004f56:	06f70963          	beq	a4,a5,80004fc8 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004f5a:	4641                	li	a2,16
    80004f5c:	4581                	li	a1,0
    80004f5e:	fc040513          	addi	a0,s0,-64
    80004f62:	d67fb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f66:	4741                	li	a4,16
    80004f68:	f2c42683          	lw	a3,-212(s0)
    80004f6c:	fc040613          	addi	a2,s0,-64
    80004f70:	4581                	li	a1,0
    80004f72:	8526                	mv	a0,s1
    80004f74:	869fe0ef          	jal	800037dc <writei>
    80004f78:	47c1                	li	a5,16
    80004f7a:	08f51b63          	bne	a0,a5,80005010 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004f7e:	04491703          	lh	a4,68(s2)
    80004f82:	4785                	li	a5,1
    80004f84:	08f70d63          	beq	a4,a5,8000501e <sys_unlink+0x14c>
  iunlockput(dp);
    80004f88:	8526                	mv	a0,s1
    80004f8a:	f0cfe0ef          	jal	80003696 <iunlockput>
  ip->nlink--;
    80004f8e:	04a95783          	lhu	a5,74(s2)
    80004f92:	37fd                	addiw	a5,a5,-1
    80004f94:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f98:	854a                	mv	a0,s2
    80004f9a:	c3efe0ef          	jal	800033d8 <iupdate>
  iunlockput(ip);
    80004f9e:	854a                	mv	a0,s2
    80004fa0:	ef6fe0ef          	jal	80003696 <iunlockput>
  end_op();
    80004fa4:	de9fe0ef          	jal	80003d8c <end_op>
  return 0;
    80004fa8:	4501                	li	a0,0
    80004faa:	64ee                	ld	s1,216(sp)
    80004fac:	694e                	ld	s2,208(sp)
    80004fae:	a849                	j	80005040 <sys_unlink+0x16e>
    end_op();
    80004fb0:	dddfe0ef          	jal	80003d8c <end_op>
    return -1;
    80004fb4:	557d                	li	a0,-1
    80004fb6:	64ee                	ld	s1,216(sp)
    80004fb8:	a061                	j	80005040 <sys_unlink+0x16e>
    80004fba:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004fbc:	00002517          	auipc	a0,0x2
    80004fc0:	76450513          	addi	a0,a0,1892 # 80007720 <etext+0x720>
    80004fc4:	fd0fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fc8:	04c92703          	lw	a4,76(s2)
    80004fcc:	02000793          	li	a5,32
    80004fd0:	f8e7f5e3          	bgeu	a5,a4,80004f5a <sys_unlink+0x88>
    80004fd4:	e5ce                	sd	s3,200(sp)
    80004fd6:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fda:	4741                	li	a4,16
    80004fdc:	86ce                	mv	a3,s3
    80004fde:	f1840613          	addi	a2,s0,-232
    80004fe2:	4581                	li	a1,0
    80004fe4:	854a                	mv	a0,s2
    80004fe6:	efafe0ef          	jal	800036e0 <readi>
    80004fea:	47c1                	li	a5,16
    80004fec:	00f51c63          	bne	a0,a5,80005004 <sys_unlink+0x132>
    if(de.inum != 0)
    80004ff0:	f1845783          	lhu	a5,-232(s0)
    80004ff4:	efa1                	bnez	a5,8000504c <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ff6:	29c1                	addiw	s3,s3,16
    80004ff8:	04c92783          	lw	a5,76(s2)
    80004ffc:	fcf9efe3          	bltu	s3,a5,80004fda <sys_unlink+0x108>
    80005000:	69ae                	ld	s3,200(sp)
    80005002:	bfa1                	j	80004f5a <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005004:	00002517          	auipc	a0,0x2
    80005008:	73450513          	addi	a0,a0,1844 # 80007738 <etext+0x738>
    8000500c:	f88fb0ef          	jal	80000794 <panic>
    80005010:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005012:	00002517          	auipc	a0,0x2
    80005016:	73e50513          	addi	a0,a0,1854 # 80007750 <etext+0x750>
    8000501a:	f7afb0ef          	jal	80000794 <panic>
    dp->nlink--;
    8000501e:	04a4d783          	lhu	a5,74(s1)
    80005022:	37fd                	addiw	a5,a5,-1
    80005024:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005028:	8526                	mv	a0,s1
    8000502a:	baefe0ef          	jal	800033d8 <iupdate>
    8000502e:	bfa9                	j	80004f88 <sys_unlink+0xb6>
    80005030:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005032:	8526                	mv	a0,s1
    80005034:	e62fe0ef          	jal	80003696 <iunlockput>
  end_op();
    80005038:	d55fe0ef          	jal	80003d8c <end_op>
  return -1;
    8000503c:	557d                	li	a0,-1
    8000503e:	64ee                	ld	s1,216(sp)
}
    80005040:	70ae                	ld	ra,232(sp)
    80005042:	740e                	ld	s0,224(sp)
    80005044:	616d                	addi	sp,sp,240
    80005046:	8082                	ret
    return -1;
    80005048:	557d                	li	a0,-1
    8000504a:	bfdd                	j	80005040 <sys_unlink+0x16e>
    iunlockput(ip);
    8000504c:	854a                	mv	a0,s2
    8000504e:	e48fe0ef          	jal	80003696 <iunlockput>
    goto bad;
    80005052:	694e                	ld	s2,208(sp)
    80005054:	69ae                	ld	s3,200(sp)
    80005056:	bff1                	j	80005032 <sys_unlink+0x160>

0000000080005058 <sys_open>:

uint64
sys_open(void)
{
    80005058:	7131                	addi	sp,sp,-192
    8000505a:	fd06                	sd	ra,184(sp)
    8000505c:	f922                	sd	s0,176(sp)
    8000505e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005060:	f4c40593          	addi	a1,s0,-180
    80005064:	4505                	li	a0,1
    80005066:	9e7fd0ef          	jal	80002a4c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000506a:	08000613          	li	a2,128
    8000506e:	f5040593          	addi	a1,s0,-176
    80005072:	4501                	li	a0,0
    80005074:	a11fd0ef          	jal	80002a84 <argstr>
    80005078:	87aa                	mv	a5,a0
    return -1;
    8000507a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000507c:	0a07c263          	bltz	a5,80005120 <sys_open+0xc8>
    80005080:	f526                	sd	s1,168(sp)

  begin_op();
    80005082:	ca1fe0ef          	jal	80003d22 <begin_op>

  if(omode & O_CREATE){
    80005086:	f4c42783          	lw	a5,-180(s0)
    8000508a:	2007f793          	andi	a5,a5,512
    8000508e:	c3d5                	beqz	a5,80005132 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005090:	4681                	li	a3,0
    80005092:	4601                	li	a2,0
    80005094:	4589                	li	a1,2
    80005096:	f5040513          	addi	a0,s0,-176
    8000509a:	aa9ff0ef          	jal	80004b42 <create>
    8000509e:	84aa                	mv	s1,a0
    if(ip == 0){
    800050a0:	c541                	beqz	a0,80005128 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800050a2:	04449703          	lh	a4,68(s1)
    800050a6:	478d                	li	a5,3
    800050a8:	00f71763          	bne	a4,a5,800050b6 <sys_open+0x5e>
    800050ac:	0464d703          	lhu	a4,70(s1)
    800050b0:	47a5                	li	a5,9
    800050b2:	0ae7ed63          	bltu	a5,a4,8000516c <sys_open+0x114>
    800050b6:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800050b8:	fe1fe0ef          	jal	80004098 <filealloc>
    800050bc:	892a                	mv	s2,a0
    800050be:	c179                	beqz	a0,80005184 <sys_open+0x12c>
    800050c0:	ed4e                	sd	s3,152(sp)
    800050c2:	a43ff0ef          	jal	80004b04 <fdalloc>
    800050c6:	89aa                	mv	s3,a0
    800050c8:	0a054a63          	bltz	a0,8000517c <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800050cc:	04449703          	lh	a4,68(s1)
    800050d0:	478d                	li	a5,3
    800050d2:	0cf70263          	beq	a4,a5,80005196 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800050d6:	4789                	li	a5,2
    800050d8:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800050dc:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800050e0:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800050e4:	f4c42783          	lw	a5,-180(s0)
    800050e8:	0017c713          	xori	a4,a5,1
    800050ec:	8b05                	andi	a4,a4,1
    800050ee:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800050f2:	0037f713          	andi	a4,a5,3
    800050f6:	00e03733          	snez	a4,a4
    800050fa:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050fe:	4007f793          	andi	a5,a5,1024
    80005102:	c791                	beqz	a5,8000510e <sys_open+0xb6>
    80005104:	04449703          	lh	a4,68(s1)
    80005108:	4789                	li	a5,2
    8000510a:	08f70d63          	beq	a4,a5,800051a4 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    8000510e:	8526                	mv	a0,s1
    80005110:	c2afe0ef          	jal	8000353a <iunlock>
  end_op();
    80005114:	c79fe0ef          	jal	80003d8c <end_op>

  return fd;
    80005118:	854e                	mv	a0,s3
    8000511a:	74aa                	ld	s1,168(sp)
    8000511c:	790a                	ld	s2,160(sp)
    8000511e:	69ea                	ld	s3,152(sp)
}
    80005120:	70ea                	ld	ra,184(sp)
    80005122:	744a                	ld	s0,176(sp)
    80005124:	6129                	addi	sp,sp,192
    80005126:	8082                	ret
      end_op();
    80005128:	c65fe0ef          	jal	80003d8c <end_op>
      return -1;
    8000512c:	557d                	li	a0,-1
    8000512e:	74aa                	ld	s1,168(sp)
    80005130:	bfc5                	j	80005120 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005132:	f5040513          	addi	a0,s0,-176
    80005136:	a31fe0ef          	jal	80003b66 <namei>
    8000513a:	84aa                	mv	s1,a0
    8000513c:	c11d                	beqz	a0,80005162 <sys_open+0x10a>
    ilock(ip);
    8000513e:	b4efe0ef          	jal	8000348c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005142:	04449703          	lh	a4,68(s1)
    80005146:	4785                	li	a5,1
    80005148:	f4f71de3          	bne	a4,a5,800050a2 <sys_open+0x4a>
    8000514c:	f4c42783          	lw	a5,-180(s0)
    80005150:	d3bd                	beqz	a5,800050b6 <sys_open+0x5e>
      iunlockput(ip);
    80005152:	8526                	mv	a0,s1
    80005154:	d42fe0ef          	jal	80003696 <iunlockput>
      end_op();
    80005158:	c35fe0ef          	jal	80003d8c <end_op>
      return -1;
    8000515c:	557d                	li	a0,-1
    8000515e:	74aa                	ld	s1,168(sp)
    80005160:	b7c1                	j	80005120 <sys_open+0xc8>
      end_op();
    80005162:	c2bfe0ef          	jal	80003d8c <end_op>
      return -1;
    80005166:	557d                	li	a0,-1
    80005168:	74aa                	ld	s1,168(sp)
    8000516a:	bf5d                	j	80005120 <sys_open+0xc8>
    iunlockput(ip);
    8000516c:	8526                	mv	a0,s1
    8000516e:	d28fe0ef          	jal	80003696 <iunlockput>
    end_op();
    80005172:	c1bfe0ef          	jal	80003d8c <end_op>
    return -1;
    80005176:	557d                	li	a0,-1
    80005178:	74aa                	ld	s1,168(sp)
    8000517a:	b75d                	j	80005120 <sys_open+0xc8>
      fileclose(f);
    8000517c:	854a                	mv	a0,s2
    8000517e:	fbffe0ef          	jal	8000413c <fileclose>
    80005182:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005184:	8526                	mv	a0,s1
    80005186:	d10fe0ef          	jal	80003696 <iunlockput>
    end_op();
    8000518a:	c03fe0ef          	jal	80003d8c <end_op>
    return -1;
    8000518e:	557d                	li	a0,-1
    80005190:	74aa                	ld	s1,168(sp)
    80005192:	790a                	ld	s2,160(sp)
    80005194:	b771                	j	80005120 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005196:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000519a:	04649783          	lh	a5,70(s1)
    8000519e:	02f91223          	sh	a5,36(s2)
    800051a2:	bf3d                	j	800050e0 <sys_open+0x88>
    itrunc(ip);
    800051a4:	8526                	mv	a0,s1
    800051a6:	bd4fe0ef          	jal	8000357a <itrunc>
    800051aa:	b795                	j	8000510e <sys_open+0xb6>

00000000800051ac <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800051ac:	7175                	addi	sp,sp,-144
    800051ae:	e506                	sd	ra,136(sp)
    800051b0:	e122                	sd	s0,128(sp)
    800051b2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800051b4:	b6ffe0ef          	jal	80003d22 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800051b8:	08000613          	li	a2,128
    800051bc:	f7040593          	addi	a1,s0,-144
    800051c0:	4501                	li	a0,0
    800051c2:	8c3fd0ef          	jal	80002a84 <argstr>
    800051c6:	02054363          	bltz	a0,800051ec <sys_mkdir+0x40>
    800051ca:	4681                	li	a3,0
    800051cc:	4601                	li	a2,0
    800051ce:	4585                	li	a1,1
    800051d0:	f7040513          	addi	a0,s0,-144
    800051d4:	96fff0ef          	jal	80004b42 <create>
    800051d8:	c911                	beqz	a0,800051ec <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051da:	cbcfe0ef          	jal	80003696 <iunlockput>
  end_op();
    800051de:	baffe0ef          	jal	80003d8c <end_op>
  return 0;
    800051e2:	4501                	li	a0,0
}
    800051e4:	60aa                	ld	ra,136(sp)
    800051e6:	640a                	ld	s0,128(sp)
    800051e8:	6149                	addi	sp,sp,144
    800051ea:	8082                	ret
    end_op();
    800051ec:	ba1fe0ef          	jal	80003d8c <end_op>
    return -1;
    800051f0:	557d                	li	a0,-1
    800051f2:	bfcd                	j	800051e4 <sys_mkdir+0x38>

00000000800051f4 <sys_mknod>:

uint64
sys_mknod(void)
{
    800051f4:	7135                	addi	sp,sp,-160
    800051f6:	ed06                	sd	ra,152(sp)
    800051f8:	e922                	sd	s0,144(sp)
    800051fa:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051fc:	b27fe0ef          	jal	80003d22 <begin_op>
  argint(1, &major);
    80005200:	f6c40593          	addi	a1,s0,-148
    80005204:	4505                	li	a0,1
    80005206:	847fd0ef          	jal	80002a4c <argint>
  argint(2, &minor);
    8000520a:	f6840593          	addi	a1,s0,-152
    8000520e:	4509                	li	a0,2
    80005210:	83dfd0ef          	jal	80002a4c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005214:	08000613          	li	a2,128
    80005218:	f7040593          	addi	a1,s0,-144
    8000521c:	4501                	li	a0,0
    8000521e:	867fd0ef          	jal	80002a84 <argstr>
    80005222:	02054563          	bltz	a0,8000524c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005226:	f6841683          	lh	a3,-152(s0)
    8000522a:	f6c41603          	lh	a2,-148(s0)
    8000522e:	458d                	li	a1,3
    80005230:	f7040513          	addi	a0,s0,-144
    80005234:	90fff0ef          	jal	80004b42 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005238:	c911                	beqz	a0,8000524c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000523a:	c5cfe0ef          	jal	80003696 <iunlockput>
  end_op();
    8000523e:	b4ffe0ef          	jal	80003d8c <end_op>
  return 0;
    80005242:	4501                	li	a0,0
}
    80005244:	60ea                	ld	ra,152(sp)
    80005246:	644a                	ld	s0,144(sp)
    80005248:	610d                	addi	sp,sp,160
    8000524a:	8082                	ret
    end_op();
    8000524c:	b41fe0ef          	jal	80003d8c <end_op>
    return -1;
    80005250:	557d                	li	a0,-1
    80005252:	bfcd                	j	80005244 <sys_mknod+0x50>

0000000080005254 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005254:	7135                	addi	sp,sp,-160
    80005256:	ed06                	sd	ra,152(sp)
    80005258:	e922                	sd	s0,144(sp)
    8000525a:	e14a                	sd	s2,128(sp)
    8000525c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000525e:	e82fc0ef          	jal	800018e0 <myproc>
    80005262:	892a                	mv	s2,a0
  
  begin_op();
    80005264:	abffe0ef          	jal	80003d22 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005268:	08000613          	li	a2,128
    8000526c:	f6040593          	addi	a1,s0,-160
    80005270:	4501                	li	a0,0
    80005272:	813fd0ef          	jal	80002a84 <argstr>
    80005276:	04054363          	bltz	a0,800052bc <sys_chdir+0x68>
    8000527a:	e526                	sd	s1,136(sp)
    8000527c:	f6040513          	addi	a0,s0,-160
    80005280:	8e7fe0ef          	jal	80003b66 <namei>
    80005284:	84aa                	mv	s1,a0
    80005286:	c915                	beqz	a0,800052ba <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005288:	a04fe0ef          	jal	8000348c <ilock>
  if(ip->type != T_DIR){
    8000528c:	04449703          	lh	a4,68(s1)
    80005290:	4785                	li	a5,1
    80005292:	02f71963          	bne	a4,a5,800052c4 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005296:	8526                	mv	a0,s1
    80005298:	aa2fe0ef          	jal	8000353a <iunlock>
  iput(p->cwd);
    8000529c:	15893503          	ld	a0,344(s2)
    800052a0:	b6efe0ef          	jal	8000360e <iput>
  end_op();
    800052a4:	ae9fe0ef          	jal	80003d8c <end_op>
  p->cwd = ip;
    800052a8:	14993c23          	sd	s1,344(s2)
  return 0;
    800052ac:	4501                	li	a0,0
    800052ae:	64aa                	ld	s1,136(sp)
}
    800052b0:	60ea                	ld	ra,152(sp)
    800052b2:	644a                	ld	s0,144(sp)
    800052b4:	690a                	ld	s2,128(sp)
    800052b6:	610d                	addi	sp,sp,160
    800052b8:	8082                	ret
    800052ba:	64aa                	ld	s1,136(sp)
    end_op();
    800052bc:	ad1fe0ef          	jal	80003d8c <end_op>
    return -1;
    800052c0:	557d                	li	a0,-1
    800052c2:	b7fd                	j	800052b0 <sys_chdir+0x5c>
    iunlockput(ip);
    800052c4:	8526                	mv	a0,s1
    800052c6:	bd0fe0ef          	jal	80003696 <iunlockput>
    end_op();
    800052ca:	ac3fe0ef          	jal	80003d8c <end_op>
    return -1;
    800052ce:	557d                	li	a0,-1
    800052d0:	64aa                	ld	s1,136(sp)
    800052d2:	bff9                	j	800052b0 <sys_chdir+0x5c>

00000000800052d4 <sys_exec>:

uint64
sys_exec(void)
{
    800052d4:	7121                	addi	sp,sp,-448
    800052d6:	ff06                	sd	ra,440(sp)
    800052d8:	fb22                	sd	s0,432(sp)
    800052da:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800052dc:	e4840593          	addi	a1,s0,-440
    800052e0:	4505                	li	a0,1
    800052e2:	f86fd0ef          	jal	80002a68 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800052e6:	08000613          	li	a2,128
    800052ea:	f5040593          	addi	a1,s0,-176
    800052ee:	4501                	li	a0,0
    800052f0:	f94fd0ef          	jal	80002a84 <argstr>
    800052f4:	87aa                	mv	a5,a0
    return -1;
    800052f6:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052f8:	0c07c463          	bltz	a5,800053c0 <sys_exec+0xec>
    800052fc:	f726                	sd	s1,424(sp)
    800052fe:	f34a                	sd	s2,416(sp)
    80005300:	ef4e                	sd	s3,408(sp)
    80005302:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005304:	10000613          	li	a2,256
    80005308:	4581                	li	a1,0
    8000530a:	e5040513          	addi	a0,s0,-432
    8000530e:	9bbfb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005312:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005316:	89a6                	mv	s3,s1
    80005318:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    8000531a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000531e:	00391513          	slli	a0,s2,0x3
    80005322:	e4040593          	addi	a1,s0,-448
    80005326:	e4843783          	ld	a5,-440(s0)
    8000532a:	953e                	add	a0,a0,a5
    8000532c:	e96fd0ef          	jal	800029c2 <fetchaddr>
    80005330:	02054663          	bltz	a0,8000535c <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005334:	e4043783          	ld	a5,-448(s0)
    80005338:	c3a9                	beqz	a5,8000537a <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    8000533a:	feafb0ef          	jal	80000b24 <kalloc>
    8000533e:	85aa                	mv	a1,a0
    80005340:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005344:	cd01                	beqz	a0,8000535c <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005346:	6605                	lui	a2,0x1
    80005348:	e4043503          	ld	a0,-448(s0)
    8000534c:	ec0fd0ef          	jal	80002a0c <fetchstr>
    80005350:	00054663          	bltz	a0,8000535c <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005354:	0905                	addi	s2,s2,1
    80005356:	09a1                	addi	s3,s3,8
    80005358:	fd4913e3          	bne	s2,s4,8000531e <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000535c:	f5040913          	addi	s2,s0,-176
    80005360:	6088                	ld	a0,0(s1)
    80005362:	c931                	beqz	a0,800053b6 <sys_exec+0xe2>
    kfree(argv[i]);
    80005364:	edefb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005368:	04a1                	addi	s1,s1,8
    8000536a:	ff249be3          	bne	s1,s2,80005360 <sys_exec+0x8c>
  return -1;
    8000536e:	557d                	li	a0,-1
    80005370:	74ba                	ld	s1,424(sp)
    80005372:	791a                	ld	s2,416(sp)
    80005374:	69fa                	ld	s3,408(sp)
    80005376:	6a5a                	ld	s4,400(sp)
    80005378:	a0a1                	j	800053c0 <sys_exec+0xec>
      argv[i] = 0;
    8000537a:	0009079b          	sext.w	a5,s2
    8000537e:	078e                	slli	a5,a5,0x3
    80005380:	fd078793          	addi	a5,a5,-48
    80005384:	97a2                	add	a5,a5,s0
    80005386:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    8000538a:	e5040593          	addi	a1,s0,-432
    8000538e:	f5040513          	addi	a0,s0,-176
    80005392:	ba8ff0ef          	jal	8000473a <exec>
    80005396:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005398:	f5040993          	addi	s3,s0,-176
    8000539c:	6088                	ld	a0,0(s1)
    8000539e:	c511                	beqz	a0,800053aa <sys_exec+0xd6>
    kfree(argv[i]);
    800053a0:	ea2fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053a4:	04a1                	addi	s1,s1,8
    800053a6:	ff349be3          	bne	s1,s3,8000539c <sys_exec+0xc8>
  return ret;
    800053aa:	854a                	mv	a0,s2
    800053ac:	74ba                	ld	s1,424(sp)
    800053ae:	791a                	ld	s2,416(sp)
    800053b0:	69fa                	ld	s3,408(sp)
    800053b2:	6a5a                	ld	s4,400(sp)
    800053b4:	a031                	j	800053c0 <sys_exec+0xec>
  return -1;
    800053b6:	557d                	li	a0,-1
    800053b8:	74ba                	ld	s1,424(sp)
    800053ba:	791a                	ld	s2,416(sp)
    800053bc:	69fa                	ld	s3,408(sp)
    800053be:	6a5a                	ld	s4,400(sp)
}
    800053c0:	70fa                	ld	ra,440(sp)
    800053c2:	745a                	ld	s0,432(sp)
    800053c4:	6139                	addi	sp,sp,448
    800053c6:	8082                	ret

00000000800053c8 <sys_pipe>:

uint64
sys_pipe(void)
{
    800053c8:	7139                	addi	sp,sp,-64
    800053ca:	fc06                	sd	ra,56(sp)
    800053cc:	f822                	sd	s0,48(sp)
    800053ce:	f426                	sd	s1,40(sp)
    800053d0:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800053d2:	d0efc0ef          	jal	800018e0 <myproc>
    800053d6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800053d8:	fd840593          	addi	a1,s0,-40
    800053dc:	4501                	li	a0,0
    800053de:	e8afd0ef          	jal	80002a68 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800053e2:	fc840593          	addi	a1,s0,-56
    800053e6:	fd040513          	addi	a0,s0,-48
    800053ea:	85cff0ef          	jal	80004446 <pipealloc>
    return -1;
    800053ee:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800053f0:	0a054463          	bltz	a0,80005498 <sys_pipe+0xd0>
  fd0 = -1;
    800053f4:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800053f8:	fd043503          	ld	a0,-48(s0)
    800053fc:	f08ff0ef          	jal	80004b04 <fdalloc>
    80005400:	fca42223          	sw	a0,-60(s0)
    80005404:	08054163          	bltz	a0,80005486 <sys_pipe+0xbe>
    80005408:	fc843503          	ld	a0,-56(s0)
    8000540c:	ef8ff0ef          	jal	80004b04 <fdalloc>
    80005410:	fca42023          	sw	a0,-64(s0)
    80005414:	06054063          	bltz	a0,80005474 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005418:	4691                	li	a3,4
    8000541a:	fc440613          	addi	a2,s0,-60
    8000541e:	fd843583          	ld	a1,-40(s0)
    80005422:	6ca8                	ld	a0,88(s1)
    80005424:	92efc0ef          	jal	80001552 <copyout>
    80005428:	00054e63          	bltz	a0,80005444 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000542c:	4691                	li	a3,4
    8000542e:	fc040613          	addi	a2,s0,-64
    80005432:	fd843583          	ld	a1,-40(s0)
    80005436:	0591                	addi	a1,a1,4
    80005438:	6ca8                	ld	a0,88(s1)
    8000543a:	918fc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000543e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005440:	04055c63          	bgez	a0,80005498 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005444:	fc442783          	lw	a5,-60(s0)
    80005448:	07e9                	addi	a5,a5,26
    8000544a:	078e                	slli	a5,a5,0x3
    8000544c:	97a6                	add	a5,a5,s1
    8000544e:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005452:	fc042783          	lw	a5,-64(s0)
    80005456:	07e9                	addi	a5,a5,26
    80005458:	078e                	slli	a5,a5,0x3
    8000545a:	94be                	add	s1,s1,a5
    8000545c:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005460:	fd043503          	ld	a0,-48(s0)
    80005464:	cd9fe0ef          	jal	8000413c <fileclose>
    fileclose(wf);
    80005468:	fc843503          	ld	a0,-56(s0)
    8000546c:	cd1fe0ef          	jal	8000413c <fileclose>
    return -1;
    80005470:	57fd                	li	a5,-1
    80005472:	a01d                	j	80005498 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005474:	fc442783          	lw	a5,-60(s0)
    80005478:	0007c763          	bltz	a5,80005486 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    8000547c:	07e9                	addi	a5,a5,26
    8000547e:	078e                	slli	a5,a5,0x3
    80005480:	97a6                	add	a5,a5,s1
    80005482:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005486:	fd043503          	ld	a0,-48(s0)
    8000548a:	cb3fe0ef          	jal	8000413c <fileclose>
    fileclose(wf);
    8000548e:	fc843503          	ld	a0,-56(s0)
    80005492:	cabfe0ef          	jal	8000413c <fileclose>
    return -1;
    80005496:	57fd                	li	a5,-1
}
    80005498:	853e                	mv	a0,a5
    8000549a:	70e2                	ld	ra,56(sp)
    8000549c:	7442                	ld	s0,48(sp)
    8000549e:	74a2                	ld	s1,40(sp)
    800054a0:	6121                	addi	sp,sp,64
    800054a2:	8082                	ret
	...

00000000800054b0 <kernelvec>:
    800054b0:	7111                	addi	sp,sp,-256
    800054b2:	e006                	sd	ra,0(sp)
    800054b4:	e40a                	sd	sp,8(sp)
    800054b6:	e80e                	sd	gp,16(sp)
    800054b8:	ec12                	sd	tp,24(sp)
    800054ba:	f016                	sd	t0,32(sp)
    800054bc:	f41a                	sd	t1,40(sp)
    800054be:	f81e                	sd	t2,48(sp)
    800054c0:	e4aa                	sd	a0,72(sp)
    800054c2:	e8ae                	sd	a1,80(sp)
    800054c4:	ecb2                	sd	a2,88(sp)
    800054c6:	f0b6                	sd	a3,96(sp)
    800054c8:	f4ba                	sd	a4,104(sp)
    800054ca:	f8be                	sd	a5,112(sp)
    800054cc:	fcc2                	sd	a6,120(sp)
    800054ce:	e146                	sd	a7,128(sp)
    800054d0:	edf2                	sd	t3,216(sp)
    800054d2:	f1f6                	sd	t4,224(sp)
    800054d4:	f5fa                	sd	t5,232(sp)
    800054d6:	f9fe                	sd	t6,240(sp)
    800054d8:	bfafd0ef          	jal	800028d2 <kerneltrap>
    800054dc:	6082                	ld	ra,0(sp)
    800054de:	6122                	ld	sp,8(sp)
    800054e0:	61c2                	ld	gp,16(sp)
    800054e2:	7282                	ld	t0,32(sp)
    800054e4:	7322                	ld	t1,40(sp)
    800054e6:	73c2                	ld	t2,48(sp)
    800054e8:	6526                	ld	a0,72(sp)
    800054ea:	65c6                	ld	a1,80(sp)
    800054ec:	6666                	ld	a2,88(sp)
    800054ee:	7686                	ld	a3,96(sp)
    800054f0:	7726                	ld	a4,104(sp)
    800054f2:	77c6                	ld	a5,112(sp)
    800054f4:	7866                	ld	a6,120(sp)
    800054f6:	688a                	ld	a7,128(sp)
    800054f8:	6e6e                	ld	t3,216(sp)
    800054fa:	7e8e                	ld	t4,224(sp)
    800054fc:	7f2e                	ld	t5,232(sp)
    800054fe:	7fce                	ld	t6,240(sp)
    80005500:	6111                	addi	sp,sp,256
    80005502:	10200073          	sret
	...

000000008000550e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000550e:	1141                	addi	sp,sp,-16
    80005510:	e422                	sd	s0,8(sp)
    80005512:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005514:	0c0007b7          	lui	a5,0xc000
    80005518:	4705                	li	a4,1
    8000551a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000551c:	0c0007b7          	lui	a5,0xc000
    80005520:	c3d8                	sw	a4,4(a5)
}
    80005522:	6422                	ld	s0,8(sp)
    80005524:	0141                	addi	sp,sp,16
    80005526:	8082                	ret

0000000080005528 <plicinithart>:

void
plicinithart(void)
{
    80005528:	1141                	addi	sp,sp,-16
    8000552a:	e406                	sd	ra,8(sp)
    8000552c:	e022                	sd	s0,0(sp)
    8000552e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005530:	b84fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005534:	0085171b          	slliw	a4,a0,0x8
    80005538:	0c0027b7          	lui	a5,0xc002
    8000553c:	97ba                	add	a5,a5,a4
    8000553e:	40200713          	li	a4,1026
    80005542:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005546:	00d5151b          	slliw	a0,a0,0xd
    8000554a:	0c2017b7          	lui	a5,0xc201
    8000554e:	97aa                	add	a5,a5,a0
    80005550:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005554:	60a2                	ld	ra,8(sp)
    80005556:	6402                	ld	s0,0(sp)
    80005558:	0141                	addi	sp,sp,16
    8000555a:	8082                	ret

000000008000555c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000555c:	1141                	addi	sp,sp,-16
    8000555e:	e406                	sd	ra,8(sp)
    80005560:	e022                	sd	s0,0(sp)
    80005562:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005564:	b50fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005568:	00d5151b          	slliw	a0,a0,0xd
    8000556c:	0c2017b7          	lui	a5,0xc201
    80005570:	97aa                	add	a5,a5,a0
  return irq;
}
    80005572:	43c8                	lw	a0,4(a5)
    80005574:	60a2                	ld	ra,8(sp)
    80005576:	6402                	ld	s0,0(sp)
    80005578:	0141                	addi	sp,sp,16
    8000557a:	8082                	ret

000000008000557c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000557c:	1101                	addi	sp,sp,-32
    8000557e:	ec06                	sd	ra,24(sp)
    80005580:	e822                	sd	s0,16(sp)
    80005582:	e426                	sd	s1,8(sp)
    80005584:	1000                	addi	s0,sp,32
    80005586:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005588:	b2cfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000558c:	00d5151b          	slliw	a0,a0,0xd
    80005590:	0c2017b7          	lui	a5,0xc201
    80005594:	97aa                	add	a5,a5,a0
    80005596:	c3c4                	sw	s1,4(a5)
}
    80005598:	60e2                	ld	ra,24(sp)
    8000559a:	6442                	ld	s0,16(sp)
    8000559c:	64a2                	ld	s1,8(sp)
    8000559e:	6105                	addi	sp,sp,32
    800055a0:	8082                	ret

00000000800055a2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800055a2:	1141                	addi	sp,sp,-16
    800055a4:	e406                	sd	ra,8(sp)
    800055a6:	e022                	sd	s0,0(sp)
    800055a8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800055aa:	479d                	li	a5,7
    800055ac:	04a7ca63          	blt	a5,a0,80005600 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800055b0:	00024797          	auipc	a5,0x24
    800055b4:	ea878793          	addi	a5,a5,-344 # 80029458 <disk>
    800055b8:	97aa                	add	a5,a5,a0
    800055ba:	0187c783          	lbu	a5,24(a5)
    800055be:	e7b9                	bnez	a5,8000560c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800055c0:	00451693          	slli	a3,a0,0x4
    800055c4:	00024797          	auipc	a5,0x24
    800055c8:	e9478793          	addi	a5,a5,-364 # 80029458 <disk>
    800055cc:	6398                	ld	a4,0(a5)
    800055ce:	9736                	add	a4,a4,a3
    800055d0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800055d4:	6398                	ld	a4,0(a5)
    800055d6:	9736                	add	a4,a4,a3
    800055d8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800055dc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800055e0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800055e4:	97aa                	add	a5,a5,a0
    800055e6:	4705                	li	a4,1
    800055e8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800055ec:	00024517          	auipc	a0,0x24
    800055f0:	e8450513          	addi	a0,a0,-380 # 80029470 <disk+0x18>
    800055f4:	90bfc0ef          	jal	80001efe <wakeup>
}
    800055f8:	60a2                	ld	ra,8(sp)
    800055fa:	6402                	ld	s0,0(sp)
    800055fc:	0141                	addi	sp,sp,16
    800055fe:	8082                	ret
    panic("free_desc 1");
    80005600:	00002517          	auipc	a0,0x2
    80005604:	16050513          	addi	a0,a0,352 # 80007760 <etext+0x760>
    80005608:	98cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000560c:	00002517          	auipc	a0,0x2
    80005610:	16450513          	addi	a0,a0,356 # 80007770 <etext+0x770>
    80005614:	980fb0ef          	jal	80000794 <panic>

0000000080005618 <virtio_disk_init>:
{
    80005618:	1101                	addi	sp,sp,-32
    8000561a:	ec06                	sd	ra,24(sp)
    8000561c:	e822                	sd	s0,16(sp)
    8000561e:	e426                	sd	s1,8(sp)
    80005620:	e04a                	sd	s2,0(sp)
    80005622:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005624:	00002597          	auipc	a1,0x2
    80005628:	15c58593          	addi	a1,a1,348 # 80007780 <etext+0x780>
    8000562c:	00024517          	auipc	a0,0x24
    80005630:	f5450513          	addi	a0,a0,-172 # 80029580 <disk+0x128>
    80005634:	d40fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005638:	100017b7          	lui	a5,0x10001
    8000563c:	4398                	lw	a4,0(a5)
    8000563e:	2701                	sext.w	a4,a4
    80005640:	747277b7          	lui	a5,0x74727
    80005644:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005648:	18f71063          	bne	a4,a5,800057c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000564c:	100017b7          	lui	a5,0x10001
    80005650:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005652:	439c                	lw	a5,0(a5)
    80005654:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005656:	4709                	li	a4,2
    80005658:	16e79863          	bne	a5,a4,800057c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000565c:	100017b7          	lui	a5,0x10001
    80005660:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005662:	439c                	lw	a5,0(a5)
    80005664:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005666:	16e79163          	bne	a5,a4,800057c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000566a:	100017b7          	lui	a5,0x10001
    8000566e:	47d8                	lw	a4,12(a5)
    80005670:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005672:	554d47b7          	lui	a5,0x554d4
    80005676:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000567a:	14f71763          	bne	a4,a5,800057c8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000567e:	100017b7          	lui	a5,0x10001
    80005682:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005686:	4705                	li	a4,1
    80005688:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000568a:	470d                	li	a4,3
    8000568c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000568e:	10001737          	lui	a4,0x10001
    80005692:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005694:	c7ffe737          	lui	a4,0xc7ffe
    80005698:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd51c7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000569c:	8ef9                	and	a3,a3,a4
    8000569e:	10001737          	lui	a4,0x10001
    800056a2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056a4:	472d                	li	a4,11
    800056a6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056a8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800056ac:	439c                	lw	a5,0(a5)
    800056ae:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800056b2:	8ba1                	andi	a5,a5,8
    800056b4:	12078063          	beqz	a5,800057d4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800056b8:	100017b7          	lui	a5,0x10001
    800056bc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800056c0:	100017b7          	lui	a5,0x10001
    800056c4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800056c8:	439c                	lw	a5,0(a5)
    800056ca:	2781                	sext.w	a5,a5
    800056cc:	10079a63          	bnez	a5,800057e0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800056d0:	100017b7          	lui	a5,0x10001
    800056d4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800056d8:	439c                	lw	a5,0(a5)
    800056da:	2781                	sext.w	a5,a5
  if(max == 0)
    800056dc:	10078863          	beqz	a5,800057ec <virtio_disk_init+0x1d4>
  if(max < NUM)
    800056e0:	471d                	li	a4,7
    800056e2:	10f77b63          	bgeu	a4,a5,800057f8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800056e6:	c3efb0ef          	jal	80000b24 <kalloc>
    800056ea:	00024497          	auipc	s1,0x24
    800056ee:	d6e48493          	addi	s1,s1,-658 # 80029458 <disk>
    800056f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800056f4:	c30fb0ef          	jal	80000b24 <kalloc>
    800056f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800056fa:	c2afb0ef          	jal	80000b24 <kalloc>
    800056fe:	87aa                	mv	a5,a0
    80005700:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005702:	6088                	ld	a0,0(s1)
    80005704:	10050063          	beqz	a0,80005804 <virtio_disk_init+0x1ec>
    80005708:	00024717          	auipc	a4,0x24
    8000570c:	d5873703          	ld	a4,-680(a4) # 80029460 <disk+0x8>
    80005710:	0e070a63          	beqz	a4,80005804 <virtio_disk_init+0x1ec>
    80005714:	0e078863          	beqz	a5,80005804 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005718:	6605                	lui	a2,0x1
    8000571a:	4581                	li	a1,0
    8000571c:	dacfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005720:	00024497          	auipc	s1,0x24
    80005724:	d3848493          	addi	s1,s1,-712 # 80029458 <disk>
    80005728:	6605                	lui	a2,0x1
    8000572a:	4581                	li	a1,0
    8000572c:	6488                	ld	a0,8(s1)
    8000572e:	d9afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005732:	6605                	lui	a2,0x1
    80005734:	4581                	li	a1,0
    80005736:	6888                	ld	a0,16(s1)
    80005738:	d90fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000573c:	100017b7          	lui	a5,0x10001
    80005740:	4721                	li	a4,8
    80005742:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005744:	4098                	lw	a4,0(s1)
    80005746:	100017b7          	lui	a5,0x10001
    8000574a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000574e:	40d8                	lw	a4,4(s1)
    80005750:	100017b7          	lui	a5,0x10001
    80005754:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005758:	649c                	ld	a5,8(s1)
    8000575a:	0007869b          	sext.w	a3,a5
    8000575e:	10001737          	lui	a4,0x10001
    80005762:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005766:	9781                	srai	a5,a5,0x20
    80005768:	10001737          	lui	a4,0x10001
    8000576c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005770:	689c                	ld	a5,16(s1)
    80005772:	0007869b          	sext.w	a3,a5
    80005776:	10001737          	lui	a4,0x10001
    8000577a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000577e:	9781                	srai	a5,a5,0x20
    80005780:	10001737          	lui	a4,0x10001
    80005784:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005788:	10001737          	lui	a4,0x10001
    8000578c:	4785                	li	a5,1
    8000578e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005790:	00f48c23          	sb	a5,24(s1)
    80005794:	00f48ca3          	sb	a5,25(s1)
    80005798:	00f48d23          	sb	a5,26(s1)
    8000579c:	00f48da3          	sb	a5,27(s1)
    800057a0:	00f48e23          	sb	a5,28(s1)
    800057a4:	00f48ea3          	sb	a5,29(s1)
    800057a8:	00f48f23          	sb	a5,30(s1)
    800057ac:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800057b0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800057b4:	100017b7          	lui	a5,0x10001
    800057b8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800057bc:	60e2                	ld	ra,24(sp)
    800057be:	6442                	ld	s0,16(sp)
    800057c0:	64a2                	ld	s1,8(sp)
    800057c2:	6902                	ld	s2,0(sp)
    800057c4:	6105                	addi	sp,sp,32
    800057c6:	8082                	ret
    panic("could not find virtio disk");
    800057c8:	00002517          	auipc	a0,0x2
    800057cc:	fc850513          	addi	a0,a0,-56 # 80007790 <etext+0x790>
    800057d0:	fc5fa0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    800057d4:	00002517          	auipc	a0,0x2
    800057d8:	fdc50513          	addi	a0,a0,-36 # 800077b0 <etext+0x7b0>
    800057dc:	fb9fa0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800057e0:	00002517          	auipc	a0,0x2
    800057e4:	ff050513          	addi	a0,a0,-16 # 800077d0 <etext+0x7d0>
    800057e8:	fadfa0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800057ec:	00002517          	auipc	a0,0x2
    800057f0:	00450513          	addi	a0,a0,4 # 800077f0 <etext+0x7f0>
    800057f4:	fa1fa0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800057f8:	00002517          	auipc	a0,0x2
    800057fc:	01850513          	addi	a0,a0,24 # 80007810 <etext+0x810>
    80005800:	f95fa0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005804:	00002517          	auipc	a0,0x2
    80005808:	02c50513          	addi	a0,a0,44 # 80007830 <etext+0x830>
    8000580c:	f89fa0ef          	jal	80000794 <panic>

0000000080005810 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005810:	7159                	addi	sp,sp,-112
    80005812:	f486                	sd	ra,104(sp)
    80005814:	f0a2                	sd	s0,96(sp)
    80005816:	eca6                	sd	s1,88(sp)
    80005818:	e8ca                	sd	s2,80(sp)
    8000581a:	e4ce                	sd	s3,72(sp)
    8000581c:	e0d2                	sd	s4,64(sp)
    8000581e:	fc56                	sd	s5,56(sp)
    80005820:	f85a                	sd	s6,48(sp)
    80005822:	f45e                	sd	s7,40(sp)
    80005824:	f062                	sd	s8,32(sp)
    80005826:	ec66                	sd	s9,24(sp)
    80005828:	1880                	addi	s0,sp,112
    8000582a:	8a2a                	mv	s4,a0
    8000582c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000582e:	00c52c83          	lw	s9,12(a0)
    80005832:	001c9c9b          	slliw	s9,s9,0x1
    80005836:	1c82                	slli	s9,s9,0x20
    80005838:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000583c:	00024517          	auipc	a0,0x24
    80005840:	d4450513          	addi	a0,a0,-700 # 80029580 <disk+0x128>
    80005844:	bb0fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005848:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000584a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000584c:	00024b17          	auipc	s6,0x24
    80005850:	c0cb0b13          	addi	s6,s6,-1012 # 80029458 <disk>
  for(int i = 0; i < 3; i++){
    80005854:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005856:	00024c17          	auipc	s8,0x24
    8000585a:	d2ac0c13          	addi	s8,s8,-726 # 80029580 <disk+0x128>
    8000585e:	a8b9                	j	800058bc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005860:	00fb0733          	add	a4,s6,a5
    80005864:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005868:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000586a:	0207c563          	bltz	a5,80005894 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000586e:	2905                	addiw	s2,s2,1
    80005870:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005872:	05590963          	beq	s2,s5,800058c4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005876:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005878:	00024717          	auipc	a4,0x24
    8000587c:	be070713          	addi	a4,a4,-1056 # 80029458 <disk>
    80005880:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005882:	01874683          	lbu	a3,24(a4)
    80005886:	fee9                	bnez	a3,80005860 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005888:	2785                	addiw	a5,a5,1
    8000588a:	0705                	addi	a4,a4,1
    8000588c:	fe979be3          	bne	a5,s1,80005882 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005890:	57fd                	li	a5,-1
    80005892:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005894:	01205d63          	blez	s2,800058ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005898:	f9042503          	lw	a0,-112(s0)
    8000589c:	d07ff0ef          	jal	800055a2 <free_desc>
      for(int j = 0; j < i; j++)
    800058a0:	4785                	li	a5,1
    800058a2:	0127d663          	bge	a5,s2,800058ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800058a6:	f9442503          	lw	a0,-108(s0)
    800058aa:	cf9ff0ef          	jal	800055a2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800058ae:	85e2                	mv	a1,s8
    800058b0:	00024517          	auipc	a0,0x24
    800058b4:	bc050513          	addi	a0,a0,-1088 # 80029470 <disk+0x18>
    800058b8:	dfafc0ef          	jal	80001eb2 <sleep>
  for(int i = 0; i < 3; i++){
    800058bc:	f9040613          	addi	a2,s0,-112
    800058c0:	894e                	mv	s2,s3
    800058c2:	bf55                	j	80005876 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800058c4:	f9042503          	lw	a0,-112(s0)
    800058c8:	00451693          	slli	a3,a0,0x4

  if(write)
    800058cc:	00024797          	auipc	a5,0x24
    800058d0:	b8c78793          	addi	a5,a5,-1140 # 80029458 <disk>
    800058d4:	00a50713          	addi	a4,a0,10
    800058d8:	0712                	slli	a4,a4,0x4
    800058da:	973e                	add	a4,a4,a5
    800058dc:	01703633          	snez	a2,s7
    800058e0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800058e2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800058e6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800058ea:	6398                	ld	a4,0(a5)
    800058ec:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800058ee:	0a868613          	addi	a2,a3,168
    800058f2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800058f4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800058f6:	6390                	ld	a2,0(a5)
    800058f8:	00d605b3          	add	a1,a2,a3
    800058fc:	4741                	li	a4,16
    800058fe:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005900:	4805                	li	a6,1
    80005902:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005906:	f9442703          	lw	a4,-108(s0)
    8000590a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000590e:	0712                	slli	a4,a4,0x4
    80005910:	963a                	add	a2,a2,a4
    80005912:	058a0593          	addi	a1,s4,88
    80005916:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005918:	0007b883          	ld	a7,0(a5)
    8000591c:	9746                	add	a4,a4,a7
    8000591e:	40000613          	li	a2,1024
    80005922:	c710                	sw	a2,8(a4)
  if(write)
    80005924:	001bb613          	seqz	a2,s7
    80005928:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000592c:	00166613          	ori	a2,a2,1
    80005930:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005934:	f9842583          	lw	a1,-104(s0)
    80005938:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000593c:	00250613          	addi	a2,a0,2
    80005940:	0612                	slli	a2,a2,0x4
    80005942:	963e                	add	a2,a2,a5
    80005944:	577d                	li	a4,-1
    80005946:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000594a:	0592                	slli	a1,a1,0x4
    8000594c:	98ae                	add	a7,a7,a1
    8000594e:	03068713          	addi	a4,a3,48
    80005952:	973e                	add	a4,a4,a5
    80005954:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005958:	6398                	ld	a4,0(a5)
    8000595a:	972e                	add	a4,a4,a1
    8000595c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005960:	4689                	li	a3,2
    80005962:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005966:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000596a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000596e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005972:	6794                	ld	a3,8(a5)
    80005974:	0026d703          	lhu	a4,2(a3)
    80005978:	8b1d                	andi	a4,a4,7
    8000597a:	0706                	slli	a4,a4,0x1
    8000597c:	96ba                	add	a3,a3,a4
    8000597e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005982:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005986:	6798                	ld	a4,8(a5)
    80005988:	00275783          	lhu	a5,2(a4)
    8000598c:	2785                	addiw	a5,a5,1
    8000598e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005992:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005996:	100017b7          	lui	a5,0x10001
    8000599a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000599e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800059a2:	00024917          	auipc	s2,0x24
    800059a6:	bde90913          	addi	s2,s2,-1058 # 80029580 <disk+0x128>
  while(b->disk == 1) {
    800059aa:	4485                	li	s1,1
    800059ac:	01079a63          	bne	a5,a6,800059c0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800059b0:	85ca                	mv	a1,s2
    800059b2:	8552                	mv	a0,s4
    800059b4:	cfefc0ef          	jal	80001eb2 <sleep>
  while(b->disk == 1) {
    800059b8:	004a2783          	lw	a5,4(s4)
    800059bc:	fe978ae3          	beq	a5,s1,800059b0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800059c0:	f9042903          	lw	s2,-112(s0)
    800059c4:	00290713          	addi	a4,s2,2
    800059c8:	0712                	slli	a4,a4,0x4
    800059ca:	00024797          	auipc	a5,0x24
    800059ce:	a8e78793          	addi	a5,a5,-1394 # 80029458 <disk>
    800059d2:	97ba                	add	a5,a5,a4
    800059d4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800059d8:	00024997          	auipc	s3,0x24
    800059dc:	a8098993          	addi	s3,s3,-1408 # 80029458 <disk>
    800059e0:	00491713          	slli	a4,s2,0x4
    800059e4:	0009b783          	ld	a5,0(s3)
    800059e8:	97ba                	add	a5,a5,a4
    800059ea:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800059ee:	854a                	mv	a0,s2
    800059f0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800059f4:	bafff0ef          	jal	800055a2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800059f8:	8885                	andi	s1,s1,1
    800059fa:	f0fd                	bnez	s1,800059e0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800059fc:	00024517          	auipc	a0,0x24
    80005a00:	b8450513          	addi	a0,a0,-1148 # 80029580 <disk+0x128>
    80005a04:	a88fb0ef          	jal	80000c8c <release>
}
    80005a08:	70a6                	ld	ra,104(sp)
    80005a0a:	7406                	ld	s0,96(sp)
    80005a0c:	64e6                	ld	s1,88(sp)
    80005a0e:	6946                	ld	s2,80(sp)
    80005a10:	69a6                	ld	s3,72(sp)
    80005a12:	6a06                	ld	s4,64(sp)
    80005a14:	7ae2                	ld	s5,56(sp)
    80005a16:	7b42                	ld	s6,48(sp)
    80005a18:	7ba2                	ld	s7,40(sp)
    80005a1a:	7c02                	ld	s8,32(sp)
    80005a1c:	6ce2                	ld	s9,24(sp)
    80005a1e:	6165                	addi	sp,sp,112
    80005a20:	8082                	ret

0000000080005a22 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005a22:	1101                	addi	sp,sp,-32
    80005a24:	ec06                	sd	ra,24(sp)
    80005a26:	e822                	sd	s0,16(sp)
    80005a28:	e426                	sd	s1,8(sp)
    80005a2a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005a2c:	00024497          	auipc	s1,0x24
    80005a30:	a2c48493          	addi	s1,s1,-1492 # 80029458 <disk>
    80005a34:	00024517          	auipc	a0,0x24
    80005a38:	b4c50513          	addi	a0,a0,-1204 # 80029580 <disk+0x128>
    80005a3c:	9b8fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005a40:	100017b7          	lui	a5,0x10001
    80005a44:	53b8                	lw	a4,96(a5)
    80005a46:	8b0d                	andi	a4,a4,3
    80005a48:	100017b7          	lui	a5,0x10001
    80005a4c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005a4e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005a52:	689c                	ld	a5,16(s1)
    80005a54:	0204d703          	lhu	a4,32(s1)
    80005a58:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005a5c:	04f70663          	beq	a4,a5,80005aa8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005a60:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005a64:	6898                	ld	a4,16(s1)
    80005a66:	0204d783          	lhu	a5,32(s1)
    80005a6a:	8b9d                	andi	a5,a5,7
    80005a6c:	078e                	slli	a5,a5,0x3
    80005a6e:	97ba                	add	a5,a5,a4
    80005a70:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a72:	00278713          	addi	a4,a5,2
    80005a76:	0712                	slli	a4,a4,0x4
    80005a78:	9726                	add	a4,a4,s1
    80005a7a:	01074703          	lbu	a4,16(a4)
    80005a7e:	e321                	bnez	a4,80005abe <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a80:	0789                	addi	a5,a5,2
    80005a82:	0792                	slli	a5,a5,0x4
    80005a84:	97a6                	add	a5,a5,s1
    80005a86:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a88:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a8c:	c72fc0ef          	jal	80001efe <wakeup>

    disk.used_idx += 1;
    80005a90:	0204d783          	lhu	a5,32(s1)
    80005a94:	2785                	addiw	a5,a5,1
    80005a96:	17c2                	slli	a5,a5,0x30
    80005a98:	93c1                	srli	a5,a5,0x30
    80005a9a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a9e:	6898                	ld	a4,16(s1)
    80005aa0:	00275703          	lhu	a4,2(a4)
    80005aa4:	faf71ee3          	bne	a4,a5,80005a60 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005aa8:	00024517          	auipc	a0,0x24
    80005aac:	ad850513          	addi	a0,a0,-1320 # 80029580 <disk+0x128>
    80005ab0:	9dcfb0ef          	jal	80000c8c <release>
}
    80005ab4:	60e2                	ld	ra,24(sp)
    80005ab6:	6442                	ld	s0,16(sp)
    80005ab8:	64a2                	ld	s1,8(sp)
    80005aba:	6105                	addi	sp,sp,32
    80005abc:	8082                	ret
      panic("virtio_disk_intr status");
    80005abe:	00002517          	auipc	a0,0x2
    80005ac2:	d8a50513          	addi	a0,a0,-630 # 80007848 <etext+0x848>
    80005ac6:	ccffa0ef          	jal	80000794 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
