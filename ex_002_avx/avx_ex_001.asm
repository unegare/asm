global _start

section .data
data1 dq 0x1,0x2,0x3,0x4
data2 dq 0x2,0x3,0x4,0x5
data3 dq 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0

fp1 dq 1.0, 1.0, 1.0, 1.0
fp2 dq 2.0, 2.0, 2.0, 2.0

msg db '1234567890123456789012345678901234567890', 10
msglen equ $-msg

newline db 10

msg_yes db 'yes', 10
msg_yes_len equ $-msg_yes

msg_no db 'no', 10
msg_no_len equ $-msg_no

section .text
_start:
  mov rax, 1
  mov rdi, 1
  mov rsi, msg
  mov rdx, msglen
  syscall
  
;  vmovdqu ymm0, [msg]
;  vmovups [data3], ymm0

  mov r9, msg
  vmovdqu ymm6, [msg]
  vinserti128 ymm0, ymm6, [r9+16], 0x1
  vmovdqu [data3], ymm0

  mov rax, 1
  mov rdi, 1
  mov rsi, data3
  mov rdx, 32
  syscall

  mov rax, 1
  mov rdi, 1
  mov rsi, newline
  mov rdx, 1
  syscall

;-----------------------

  vmovdqu ymm0, [fp1]
  vmovdqu ymm1, [fp2]

  vaddpd ymm0, ymm0

  vpcmpeqq ymm0, ymm0, ymm1
  vmovdqu [data3], ymm0

  mov r9, [data3]
  mov r10, [data3 + 8]
  mov r11, [data3 + 16]
  mov r12, [data3 + 24]
  and r9, r10
  and r11, r12
  and r9, r11

  jz neq_branch
  
  mov rax, 1
  mov rdi, 1
  mov rsi, msg_yes
  mov rdx, msg_yes_len
  syscall
  jmp after_condition

neq_branch:
  mov rax, 1
  mov rdi, 1
  mov rsi, msg_no
  mov rdx, msg_no_len
  syscall
after_condition:

;-----------------------
  
  mov rax, 60
  xor rdi, rdi
  syscall
