.PHONY: test doc md s13 mgft
LIB=./lib/
test: t/basic.t
	perl6 t/basic.t
	perl6 xt/basic.t

doc: lib/MinG.pm6 lib/MinG/S13.pm6 lib/MinG/From/Text.pm6
	perl6 --doc=HTML lib/MinG.pm6 > doc/MinG.html
	PERL6LIB=$(LIB) perl6 --doc=HTML lib/MinG/S13.pm6 > doc/S13.html
	PERL6LIB=$(LIB) perl6 --doc=HTML lib/MinG/S13/Logic.pm6 > doc/S13::Logic.html
	PERL6LIB=$(LIB) perl6 --doc=HTML lib/MinG/From/Text.pm6 > doc/MinG::From::Text.html
	PERL6LIB=$(LIB) perl6 --doc=HTML lib/MinG/EDMG.pm6 > doc/MinG::EDMG.html

md: lib/MinG.pm6
	perl6 --doc=Markdown doc/to-readme.pod6 > README.md

s13: lib/MinG.pm6 lib/MinG/S13.pm6
	PERL6LIB=$(LIB) perl6 lib/MinG/S13.pm6

mgft: lib/MinG.pm6 lib/MinG/From/Text.pm6
	PERL6LIB=$(LIB) perl6 lib/MinG/From/Text.pm6
