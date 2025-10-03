all:
	make -C a68k
	make -C bin
	make -C asm

clean:
	make -C a68k clean
	make -C bin clean
	make -C asm clean
