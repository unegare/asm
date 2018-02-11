; the author: unegare
; https://github.com/unegare
; date: 11.02.2018

;----------------------MACRO----------------------

%macro FD_ZERO 1
	mov qword [%1], 0
	mov qword [%1 + 8], 0
	mov qword [%1 + 16], 0
	mov qword [%1 + 24], 0
	mov qword [%1 + 32], 0
%endmacro

%macro FD_SET 2
	mov rax, %2
	mov cl, al
	shr rax, 3
	and cl, 7
	mov bl, 1
	shl bl, cl
	mov dl, [%1 + rax]
	or dl, bl
	mov [%1 + rax], dl
%endmacro

%macro FD_ISSET 2
	mov rax, %2
	mov cl, al
	shr rax, 3
	and cl, 7
	mov bl, 1
	shl bl, cl
	mov dl, [%1 + rax]
	test dl, bl
%endmacro

%macro WRITE_STDOUT 2
	mov rax, 1
;	xor rdi, rdi
	mov rdi, 1
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

;-------------------------------------------------

global _start

section .bss
listenerfd resd 2
socketfd resd 2
sock_max resd 2
rfds resq fd_set_qwsize ;struct fd_set
wfds resq fd_set_qwsize ;struct fd_set
;struct timeval
tv_sec resd 1
tv_usec resq 1
;
buffrecvlen resb 1
buff resb 258
buffsize equ 256

section .data
fd_set_bitsize equ 8*8*1024
fd_set_qwsize equ 1024

sockaddr_in db 2, 0, 
	db 9, 154, ;port
	db 0, 0, 0, 0, ;addr ex: 192, 168, 1, 1; 0,0,0,0 - any addr
	db 0, 0, 0, 0, 0, 0, 0, 0
sockaddr_in_len equ $-sockaddr_in

;constants
AF_INET equ 2
SOCK_STREAM equ 1
F_SETFL equ 4
O_NONBLOCK equ 4000
__NR_socket equ 41
__NR_fcntl equ 72
__NR_bind equ 49
__NR_listen equ 50
__NR_select equ 23
__NR_accept equ 43

;strings
welmsg db "socket server has been started", 10, 0
welmsglen equ $-welmsg
okword db "OK", 10, 0
okwordlen equ $-okword
errword db "ERROR", 10, 0
errwordlen equ $-errword
crsocket db "creating socket ... ", 0
crsocketlen equ $-crsocket
bindingsocket db "binding socket ... ", 0
bindingsocketlen equ $-bindingsocket
startinglistening db "starting listening ... ", 0
startinglisteninglen equ $-startinglistening
waitingforselect db "waiting for select ... ", 0
waitingforselectlen equ $-waitingforselect
isitlistener db "is it listener ... ", 0
isitlistenerlen equ $-isitlistener
accepting db "accepting ... ", 0
acceptinglen equ $-accepting
titlerecvmsg db "received message:", 10, 0
titlerecvmsglen equ $-titlerecvmsg
lineend db 10, 0
lineendlen equ $-lineend

section .text
_start:	
	WRITE_STDOUT welmsg, welmsglen

	WRITE_STDOUT crsocket, crsocketlen	
	
	mov rax, __NR_socket
	mov rdi, AF_INET
	mov rsi, SOCK_STREAM
	xor rdx, rdx
	syscall

	cmp rax, 0
	jl errMsgPrint

	mov [listenerfd], rax

	WRITE_STDOUT okword, okwordlen
	
	mov rax, __NR_fcntl
	mov rdi, [listenerfd]
	mov rsi, F_SETFL
	mov rdx, O_NONBLOCK
	syscall

	WRITE_STDOUT bindingsocket, bindingsocketlen

	mov rax, __NR_bind
	mov rdi, [listenerfd]
	mov rsi, sockaddr_in
	mov rdx, sockaddr_in_len
	syscall
	
	cmp rax, 0
	jl errMsgPrint

	WRITE_STDOUT okword, okwordlen	

	WRITE_STDOUT startinglistening, startinglisteninglen

	mov rax, __NR_listen
	mov rdi, [listenerfd]
	mov rsi, 1
	syscall

	test rax, rax
	jnz errMsgPrint
	
	WRITE_STDOUT okword, okwordlen

	FD_ZERO rfds
	FD_ZERO wfds
	FD_SET rfds, qword [listenerfd]

	mov rax, [listenerfd]
	mov [sock_max], rax
	mov dword [tv_sec], 15
	mov qword [tv_usec], 0

	WRITE_STDOUT waitingforselect, waitingforselectlen

	mov rax, __NR_select
	mov rdi, [sock_max]
	inc rdi
	mov rsi, rfds
	mov rdx, wfds
	mov r10, 0
	mov r8, tv_sec ;timeval
	syscall

	test rax, rax
	jz errMsgPrint
	
	WRITE_STDOUT okword, okwordlen
	
	WRITE_STDOUT isitlistener, isitlistenerlen
	
	FD_ISSET rfds, [listenerfd]
	jz errMsgPrint
	
	WRITE_STDOUT okword, okwordlen
	
	WRITE_STDOUT accepting, acceptinglen
	
	mov rax, __NR_accept
	mov rdi, [listenerfd]
	xor rsi, rsi
	xor rdx, rdx
	syscall
	
	cmp rax, 0
	jl errMsgPrint
	
	mov rbx, rax
	
	WRITE_STDOUT okword, okwordlen
	
	mov byte [buff + buffsize], 0
	
	xor rax, rax
	mov rdi, rbx
	mov rsi, buffrecvlen
	mov rdx, 1
	syscall

	xor rax, rax
	mov rdi, rbx
	mov rsi, buff
	mov rdx, [buffrecvlen]
	syscall

	mov rdx, rax

	mov rax, 3
	mov rdi, rbx
	syscall

	lea rcx, [buff + rdx]
	mov byte [rcx], 10
	inc rcx
	mov byte [rcx], 0
	add rdx, 2
	mov rcx, rax

	WRITE_STDOUT lineend, lineendlen
	
	WRITE_STDOUT titlerecvmsg, titlerecvmsglen

	WRITE_STDOUT buff, rcx

	mov rax, 3
	mov rdi, [listenerfd]
	syscall
	
	mov rax, 60
	xor rdi, rdi
	syscall

;
;--------------------------------
;

errMsgPrint:
	WRITE_STDOUT errword, errwordlen

	mov rax, 3
	mov rdi, [listenerfd]
	syscall
	
	mov rax, 60
	xor rdi, rdi
	syscall

