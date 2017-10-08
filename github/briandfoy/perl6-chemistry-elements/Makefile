PERL=perl
.PHONEY: test contributors

test:
	prove --exec "perl6 -Ilib" -r t

# this one should not clobber the list already there since some of
# them might not show up in the git log. Append to what is already
# there then sort and uniq.
contrib:
	@ git log | grep Author: | ${PERL} -pe "s/^Author:\s+//" >> CONTRIBUTORS
	@ cat CONTRIBUTORS | sort -f | uniq > CONTRIBUTORS~
	@ mv CONTRIBUTORS~ CONTRIBUTORS

