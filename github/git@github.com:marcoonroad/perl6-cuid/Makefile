all: test

install:
	zef --force install .

test:
	PERL6LIB=lib/ prove -v -r --exec=perl6 t/
