use Test;
plan 4;

# ensure consistant document ID generation
srand(123456);

my $read-me = "README.md".IO.slurp;

$read-me ~~ /^ $<waffle>=.*? +%% ["```" \n? $<code>=.*? "```" \n?] $/
    or die "README.md parse failed";

for @<code> {
    my $snippet = ~$_;
    given $snippet {
	default {
	    # disable say
	    sub say(|c) { }

	    lives-ok {EVAL $snippet}, 'code sample'
		or die "eval error: $snippet";
	}
    }
}

done-testing;
