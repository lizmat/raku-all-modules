PREFIX   = install
DESTDIR  = $(PREFIX)/lib/Native
PERL6    = perl6
PROVE    = prove
CC       = gcc
CFLAGS   = -Wall -Wextra
DLLFLAGS = -fPIC -shared
DLLEXT   = so
DLL      = p6-native-libc.$(DLLEXT)
OUT      = -o
RM       = rm -f
MV       = mv
MKDIR    = mkdir -p
INSTALL  = cp -t
GEN      = blib/Native/LibC.pm6.moarvm blib/Native/Array.pm6.moarvm $(DLL)
GARBAGE  =

all: $(GEN) README.md

dll: $(DLL)

install: $(GEN) __PHONY__
	$(MKDIR) $(DESTDIR)
	$(INSTALL) $(DESTDIR) $(GEN)

clean:
	$(RM) $(GEN) $(GARBAGE)

test: $(GEN)
	$(PROVE) -e "$(PERL6) -Iblib" t

__PHONY__:

blib/Native/LibC.pm6.moarvm: lib/Native/LibC.pm6 $(DLL)
	$(PERL6) --target=mbc --output=$@ lib/Native/LibC.pm6

blib/Native/Array.pm6.moarvm: lib/Native/Array.pm6 blib/Native/LibC.pm6.moarvm
	$(PERL6) -Iblib --target=mbc --output=$@ lib/Native/Array.pm6

$(DLL): build/p6-native-libc.c
	$(CC) build/p6-native-libc.c $(CFLAGS) $(DLLFLAGS) $(OUT)$@

README.md: build/README.md.in build/README.md.p6 lib/Native/LibC.pm6
	$(PERL6) build/$@.p6 <build/$@.in >$@.tmp
	$(MV) $@.tmp $@
