EXES = flib.92p graylib.92p graylib7.92p shell.92p

.SUFFIXES: .asm .92p

.asm.o:
	a68k $< -o$@

.o.92p:
	flinker -foldfargo $< --old92p=$@

all: $(EXES)

clean:; rm -f $(EXES)
