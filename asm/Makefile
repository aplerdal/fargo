all:
	make -C kernel
	make -C prgm
	make -C lib
	make -C oldfargo

clean:
	make -C kernel clean
	make -C prgm clean
	make -C lib clean
	make -C oldfargo clean

backups: a.92b b.92b c.92b

a.92b: kernel/kernel.o kernel/tios.o
	cp /wd/e/ti/92/92b-ver/1--3.92b a.92b
	flinker -vb a.92b kernel/kernel.o kernel/tios.o

b.92b: kernel/kernel.o kernel/pre-021.o kernel/tios.o
	cp /wd/e/ti/92/92b-ver/1--3.92b b.92b
	flinker -vb b.92b kernel/kernel.o kernel/pre-021.o kernel/tios.o

c.92b: kernel/kernel.o kernel/pre-021.o kernel/pre-020.o kernel/tios.o
	cp /wd/e/ti/92/92b-ver/1--3.92b c.92b
	flinker -vb c.92b kernel/kernel.o kernel/pre-021.o kernel/pre-020.o kernel/tios.o
