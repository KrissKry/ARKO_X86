CC = gcc
CFLAGS = -m64

all: main.o add_sub_matrices.o mul_matrices.o det_matrix.o
	$(CC) $(CFLAGS) -g -o program -fPIC main.o add_sub_matrices.o mul_matrices.o det_matrix.o

add_sub_matrices.o: add_sub_matrices.s
	nasm -f elf64 -o add_sub_matrices.o add_sub_matrices.s

mul_matrices.o: mul_matrices.s
	nasm -f elf64 -o mul_matrices.o mul_matrices.s

det_matrix.o: det_matrix.s
	nasm -f elf64 -o det_matrix.o det_matrix.s

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

clean:
	rm -f *.o