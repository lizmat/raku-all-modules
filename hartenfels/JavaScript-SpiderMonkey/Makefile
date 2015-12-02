test-mozjs24: libp6-spidermonkey.so
	LD_LIBRARY_PATH=. PERL6LIB=lib prove -ve perl6


libp6-spidermonkey.so: p6-spidermonkey.cpp
	g++ -Wall -Wshadow -std=c++98 -pedantic -pedantic-errors $< \
		-D__STDC_LIMIT_MACROS -DP6SM_VERSION=24 -shared -o $@ -fPIC \
		-g -lmozjs-24 -lz -lpthread -ldl


clean:
	rm -rf libp6-spidermonkey.so


README.md: lib/JavaScript/SpiderMonkey.pm6
	echo '[![Build Status](https://travis-ci.org/hartenfels/Javascript-SpiderMonkey.svg)](https://travis-ci.org/hartenfels/Javascript-SpiderMonkey)' \
	                                      > $@
	echo                                 >> $@
	PERL6LIB=lib perl6 --doc=Markdown $< >> $@


.PHONY: test-mozjs24 clean realclean
