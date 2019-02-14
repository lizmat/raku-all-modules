PERL6     := perl6
LIBPATH   := ./lib

TESTS  := t/*.t
GTESTS := good/*.t
BTESTS := bad/*.t
EG     := examples/*.p6

.PHONY: test good bad eg all

default: test

# the original test suite (i.e., 'make test')
test:
	for f in $(TESTS) ; do \
	    PERL6LIB=$(LIBPATH) prove -v --exec=$(PERL6) $$f ; \
	done

good:
	for f in $(GTESTS) ; do \
	    PERL6LIB=$(LIBPATH) prove -v --exec=$(PERL6) $$f ; \
	done

bad:
	for f in $(BTESTS) ; do \
	    PERL6LIB=$(LIBPATH) prove -v --exec=$(PERL6) $$f ; \
	done

eg:
	for f in $(EG) ; do \
	    PERL6LIB=$(LIBPATH) $$f ; \
	done

all: test eg
