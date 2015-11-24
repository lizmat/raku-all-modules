PROVE = prove
PERL6 = perl6

BC = blib/TinyCC.pm6.moarvm \
     blib/TinyCC/CCall.pm6.moarvm \
     blib/TinyCC/CFunc.pm6.moarvm \
     blib/TinyCC/Eval.pm6.moarvm \
     blib/TinyCC/Invoke.pm6.moarvm \
     blib/TinyCC/Types.pm6.moarvm \
     blib/TinyCC/NC.pm6.moarvm

export PERL6LIB = blib

all: $(BC)

clean:
	rm -f $(BC)

$(BC): blib/%.pm6.moarvm: lib/%.pm6
	$(PERL6) --target=mbc --output=$@ $<

blib/TinyCC.pm6.moarvm: blib/TinyCC/Types.pm6.moarvm
blib/TinyCC/CCall.pm6.moarvm: blib/TinyCC.pm6.moarvm
blib/TinyCC/CFunc.pm6.moarvm: blib/TinyCC/Invoke.pm6.moarvm
blib/TinyCC/Eval.pm6.moarvm: blib/TinyCC.pm6.moarvm
blib/TinyCC/Invoke.pm6.moarvm: blib/TinyCC.pm6.moarvm
blib/TinyCC/Types.pm6.moarvm: blib/TinyCC/NC.pm6.moarvm

test: $(BC)
	$(PROVE) -e '$(PERL6)' t

t-%: t/%-*.t $(BC)
	$<
