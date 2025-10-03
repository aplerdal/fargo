EXES = flib.92p hexlib.92p gray4lib.92p gray7lib.92p

.SUFFIXES: .asm .o .92p

.asm.o:
	a68k $< -o$@

.o.92p:
	flinker $< -o $@

all: $(EXES)

clean:; rm -f $(EXES)
