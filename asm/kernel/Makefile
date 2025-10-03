OBJS = kernel.o tios.o 0_1_x.o 0_2_0.o

.SUFFIXES: .asm .92p

.asm.o:
	a68k $< -o$@

.o.92p:
	flinker $< -o $@

all: $(OBJS)

clean:; rm -f $(OBJS)