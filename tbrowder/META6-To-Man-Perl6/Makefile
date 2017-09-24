PERL6     := perl6
# note LIBPATH uses normal PERL6LIB Perl 6 separators (',')
LIBPATH   := lib

# set below to 1 for no effect, 1 for debugging messages
DEBUG := MODULE_DEBUG=0

# set below to 0 for no effect, 1 to die on first failure
EARLYFAIL := PERL6_TEST_DIE_ON_FAIL=0

# set below for 0 for no effect and 1 to run Test::META
TA := TEST_AUTHOR=1

.PHONY: test bad good doc

default: test readme

TESTS     := t/*.t
BADTESTS  := bad-tests/*.t
GOODTESTS := good-tests/*.t

# the original test suite (i.e., 'make test')
test:
	for f in $(TESTS) ; do \
            #echo "=== running $$f..." ; \
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



readme: README.md

# build the readme file and a sample
README.md: ./bin/meta6-to-man ./dev/README.md.begin ./dev/README.md.end
	@echo "Building a new README.md file..."
	@perl6 -Ilib ./bin/meta6-to-man > dev/README.md.middle
	if [ !-d "./doc" ] ; then \
           mkdir "./doc" ; \
        fi
	@perl6 -Ilib ./bin/meta6-to-man --meta6=./META6.json --install-to=./doc
	@cat dev/README.md.begin  > ./README.md
	@cat dev/README.md.middle >> ./README.md
	@cat dev/README.md.end    >> ./README.md
