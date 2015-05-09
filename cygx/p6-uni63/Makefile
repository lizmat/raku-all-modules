PROVE = prove
PERL6 = perl6

export PERL6LIB = .

test:
	$(PROVE) -e '$(PERL6)' t

t-%: t/%-*.t
	$<
