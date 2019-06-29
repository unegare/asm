.PHONY: all
all:	avx_ex_001

avx_ex_001:	avx_ex_001.o
	ld avx_ex_001.o -o avx_ex_001

avx_ex_001.o:	avx_ex_001.asm
	nasm -f elf64 avx_ex_001.asm

.PHONY: clean
clean:
	rm -rf ./avx_ex_001.o ./avx_ex_001
