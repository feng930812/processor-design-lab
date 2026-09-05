  .option norvc
  .section .text
  .globl _start

_start:
  addi x1,  x0, 5
  addi x2,  x0, 3

  add  x3, x1, x2
  addi x4, x0, 8
  bne  x3, x4, fail

  sub  x3, x1, x2
  addi x4, x0, 2
  bne  x3, x4, fail

  sll  x3, x2, x2
  addi x4, x0, 24
  bne  x3, x4, fail

  slt  x3, x2, x1
  addi x4, x0, 1
  bne  x3, x4, fail
  sltu x3, x2, x1
  bne  x3, x4, fail

  xor  x3, x1, x2
  addi x4, x0, 6
  bne  x3, x4, fail
  or   x3, x1, x2
  addi x4, x0, 7
  bne  x3, x4, fail
  and  x3, x1, x2
  addi x4, x0, 1
  bne  x3, x4, fail

  addi x4, x0, 32
  srl  x3, x4, x2
  addi x5, x0, 4
  bne  x3, x5, fail
  addi x4, x0, -32
  sra  x3, x4, x2
  addi x5, x0, -4
  bne  x3, x5, fail

  slli x3, x2, 4
  addi x4, x0, 48
  bne  x3, x4, fail
  slti x3, x2, 4
  addi x4, x0, 1
  bne  x3, x4, fail
  sltiu x3, x2, 2
  bne   x3, x0, fail
  xori x3, x2, 6
  addi x4, x0, 5
  bne  x3, x4, fail
  addi x4, x0, 32
  srli x3, x4, 3
  addi x5, x0, 4
  bne  x3, x5, fail
  addi x4, x0, -32
  srai x3, x4, 3
  addi x5, x0, -4
  bne  x3, x5, fail
  ori  x3, x2, 8
  addi x4, x0, 11
  bne  x3, x4, fail
  andi x3, x1, 3
  addi x4, x0, 1
  bne  x3, x4, fail

  lui  x3, 0x12345
  lui  x4, 0x12345
  bne  x3, x4, fail
  auipc x3, 0
  auipc x4, 0
  addi  x3, x3, 4
  bne   x3, x4, fail

  beq  x1, x1, 1f
  jal  x0, fail
1:
  bne  x1, x2, 2f
  jal  x0, fail
2:
  blt  x2, x1, 3f
  jal  x0, fail
3:
  bge  x1, x2, 4f
  jal  x0, fail
4:
  bltu x2, x1, 5f
  jal  x0, fail
5:
  bgeu x1, x2, 6f
  jal  x0, fail
6:
  beq  x1, x2, fail

  jal  x10, jal_target
  jal  x0, fail
jal_target:
  auipc x11, 0
  addi  x10, x10, 4
  bne   x10, x11, fail

  lla   x12, jalr_target
  jalr  x10, 1(x12)
  jal   x0, fail
jalr_target:

  addi x20, x0, 0x100
  addi x21, x0, -128
  sb   x21, 0(x20)
  lb   x22, 0(x20)
  bne  x21, x22, fail
  lbu  x22, 0(x20)
  addi x23, x0, 128
  bne  x22, x23, fail

  addi x21, x0, -2
  sh   x21, 4(x20)
  lh   x22, 4(x20)
  bne  x21, x22, fail
  lhu  x22, 4(x20)
  lui  x23, 0x10
  addi x23, x23, -2
  bne  x22, x23, fail

  sw   x21, 8(x20)
  lw   x22, 8(x20)
  bne  x21, x22, fail

  fence rw, rw

pass:
  addi x30, x0, 1
  sw   x30, 0(x20)
pass_loop:
  jal  x0, pass_loop

fail:
  addi x30, x0, -1
  sw   x30, 0(x20)
fail_loop:
  jal  x0, fail_loop
