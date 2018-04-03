.PHONY: all bin test

all: bin

bin:
	perl6 -Ilib bin/palindrome

test:
	PERL6LIB=lib TEST_META=1 prove -v -r --exec=perl6 t/
