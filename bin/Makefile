GCC	= g++

CFLAGS = -O0 -g -s -std=c++98

DOCC = module: module.o;\
	$(GCC) $(CFLAGS) -o module module.o

all: romconv sum92 flinker autofarg afcompat pfcompat

.SUFFIXES: .obj

.c.o:;  $(GCC) $(CFLAGS) -c $< -o $@
.cc.o:; $(GCC) $(CFLAGS) -c $< -o $@

$(subst module,romconv,$(DOCC))

$(subst module,sum92,$(DOCC))

FLINKER_OBJ = flinker.o flinkerObj.o flinkerA68k.o flinker92p.o flinker92b.o flinker9xz.o flinkerOld92p.o gnu/getopt.o gnu/getopt1.o

flinker: $(FLINKER_OBJ)
	$(GCC) $(CFLAGS) -o $@ $(FLINKER_OBJ)

autofarg:; ln -fs autofargo $@
afcompat:; ln -fs autofargo-compat $@
pfcompat:; ln -fs putfargo-compat $@

sum92.o: endian.h

flinker.o: flinker.h endian.h lists.h hash.h
flinkerObj.o: flinker.h endian.h lists.h hash.h
flinkerA68k.o: flinker.h endian.h lists.h hash.h
flinker92p.o: flinker.h endian.h lists.h hash.h
flinker9xz.o: flinker.h endian.h lists.h hash.h
flinkerOld92p.o: flinker.h endian.h lists.h hash.h
flinker92b.o: flinker.h endian.h lists.h hash.h romtab.h

clean:; rm -f romconv.o romconv sum92.o sum92 \
	      $(FLINKER_OBJ) flinker core
