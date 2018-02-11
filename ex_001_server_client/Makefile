all: server client

server: server.asm
	nasm -f elf64 ./server.asm
	ld -m elf_x86_64 ./server.o -o ./server

client: client.cpp
	g++ ./client.cpp -o ./client

clean:
	rm ./server ./server.o ./client
