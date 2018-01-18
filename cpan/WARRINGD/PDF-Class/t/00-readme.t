use v6;
use Test;
use PDF::Class;
# ensure consistant document ID generation
srand(123456);

my $read-me = "README.md".IO.slurp;

$read-me ~~ /^ $<waffle>=.*? +%% ["```" \n? $<code>=.*? "```" \n?] $/
    or die "README.md parse failed";

my $n = 0;

for @<code> {
    my $snippet = ~$_;
    given $snippet {
	default {
	    # assume anything else is code.
	    $snippet = $snippet.subst('DateTime.now;', 'DateTime.new( :year(2015), :month(12), :day(25) );' );
	    # disable say
	    sub say(|c) { }

            todo "Class from an eval"
                 if ++$n == 5;
            lives-ok {EVAL $snippet}, 'code sample'
		or warn "eval error: $snippet";
	}
    }
}

done-testing;
