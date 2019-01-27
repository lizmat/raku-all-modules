VERSION=$(shell perl6 -Ilib -MAlgorithm::Heap::Binary -e 'say Algorithm::Heap::Binary.^ver.Str')

doc: lib/Algorithm/Heap/Binary.pm6
	echo "[![Build Status](https://travis-ci.org/cono/p6-algorithm-heap-binary.svg?branch=master)](https://travis-ci.org/cono/p6-algorithm-heap-binary)" > README.md
	echo "" >> README.md
	perl6 -Ilib --doc=Markdown lib/Algorithm/Heap/Binary.pm6 >> README.md

test:
	prove --exec 'perl6 -Ilib' -r t

archive:
	mkdir -p cpan
	tar -czf "cpan/Algorithm-Heap-Binary-${VERSION}.tar.gz" --transform s/^\./Algorithm-Heap-Binary-${VERSION}/ --exclude-vcs --exclude=.[^/]* --exclude Makefile --exclude cpan .
