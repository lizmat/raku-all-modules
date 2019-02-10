PERL6     := perl6
LIBPATH   := ./lib

TESTS := t/*.t

.PHONY: test

default: test

# the original test suite (i.e., 'make test')
test:
	for f in $(TESTS) ; do \
	    PERL6LIB=$(LIBPATH) prove -v --exec=$(PERL6) $$f ; \
	done
