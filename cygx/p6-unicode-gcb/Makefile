PROVE = prove
PERL6 = perl6

export PERL6LIB = lib

test:
	$(PROVE) -e '$(PERL6)' t

t-%: t/%-*.t
	$(PERL6) $<
