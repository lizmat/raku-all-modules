PERL6     := perl6
LIBPATH   := lib

# set below to 1 for no effect, 1 for debugging messages
DEBUG := TEXT_MORE_DEBUG=0

# set below to 0 for no effect, 1 to die on first failure
EARLYFAIL := PERL6_TEST_DIE_ON_FAIL=0

# set below for 0 for no effect and 1 to run Test::META
TA := TEST_AUTHOR=1

.PHONY: test bad good

default: test

TESTS     := t/*.t
BADTESTS  := bad-tests/*.t
GOODTESTS := good-tests/*.t

# the original test suite (i.e., 'make test')
test:
	for f in $(TESTS) ; do \
	    $(DEBUG) $(TA) $(EARLYFAIL) PERL6LIB=$(LIBPATH) prove -v --exec=$(PERL6) $$f ; \
	done

bad:
	for f in $(BADTESTS) ; do \
	    $(DEBUG) $(TA) $(EARLYFAIL) PERL6LIB=$(LIBPATH) prove -v --exec=$(PERL6) $$f ; \
	done

good:
	for f in $(GOODTESTS) ; do \
	    $(DEBUG) $(TA) $(EARLYFAIL) PERL6LIB=$(LIBPATH) prove -v --exec=$(PERL6) $$f ; \
	done
