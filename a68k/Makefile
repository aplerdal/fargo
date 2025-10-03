GCC	= gcc

CFLAGS = -D__NOPROTO -O3 -s -std=c90

SRC := A68kmain.c Opcodes.c Operands.c Adirect.c A68kmisc.c Symtab.c Codegen.c
SRC := $(SRC) wb_parse.c

OBJ	= $(SRC:%.c=%.o)

EXE	= A68k

all: $(EXE)

.c.o:
	$(GCC) $(CFLAGS) -c $< -o $@

$(EXE):\
	$(OBJ) 
	$(GCC) -s -o $@ $(OBJ)

$(OBJ): A68kdef.h A68kglb.h protos.h

clean:; rm -f $(OBJ) $(EXE) core
