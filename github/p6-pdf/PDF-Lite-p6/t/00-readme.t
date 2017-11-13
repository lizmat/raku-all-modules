use Test;
plan 11;

my $read-me = "README.md".IO.slurp;

$read-me ~~ /^ $<waffle>=.*? +%% ["```" \n? $<code>=.*? "```" \n?] $/
    or die "README.md parse failed";

my $n;

for @<code> {
    my $snippet = ~$_;
    given $snippet {
	default {
            # ensure consistant document ID generation
            srand(123456);

	    # assume anything else is code.
	    $snippet = $snippet.subst('DateTime.now;', 'DateTime.new( :year(2015), :month(12), :day(25) );' );
	    # disable say
	    sub say(|c) { }

            todo 'code sample not working from EVAL' if ++$n == 6;
	    lives-ok {EVAL $snippet}, 'code sample'
		or warn "eval error: $snippet";
	}
    }
}

done-testing;
