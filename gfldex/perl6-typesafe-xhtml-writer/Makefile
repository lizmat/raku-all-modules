lib/Typesafe/XHTML/Writer.pm6: bin/generate-function-definition.p6 Build.pm
	perl6 -I . -M Build -e 'Build.new.build(".")'

bin/benchmark.p6: bin/generate-benchmark.p6
	perl6 -I ./lib $< > $@

TESTS=t/basic.t t/skeleton.t

$(TESTS): lib/Typesafe/XHTML/Writer.pm6

benchmark: bin/benchmark.p6
	perl6 -I ./lib $< > /dev/null

test: t/basic.t
	prove --exec "perl6 -I ./lib" -r ./t/

lib: lib/Typesafe/XHTML/Writer.pm6


all: lib test benchmark
