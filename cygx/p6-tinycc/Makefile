PROVE  = prove
PERL6  = perl6
MODULE = blib/TinyCC.pm6.moarvm

export PERL6LIB = blib

all: README.md $(MODULE)

README.md: build/README.md.in build/README.md.p6 TinyCC.pm6
	$(PERL6) build/$@.p6 <build/$@.in >$@

$(MODULE): TinyCC.pm6
	$(PERL6) --target=mbc --output=$@ TinyCC.pm6

test: $(MODULE)
	$(PROVE) -e '$(PERL6)' t

t-%: t/%-*.t $(MODULE)
	$<
