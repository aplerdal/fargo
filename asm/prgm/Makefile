EXES = shell.92p romdump1.92p romdump2.92p hexdump.92p fterm.92p
EXES += langston.92p sierpin.92p sprite.92p testfunc.92p

.SUFFIXES: .asm .92p

.asm.o:
	a68k $< -o$@

.o.92p:
	flinker $< -o $@

all: $(EXES)

clean:; rm -f $(EXES)
