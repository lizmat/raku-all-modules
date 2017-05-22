use Test;
plan 3;

my $read-me = "README.md".IO.slurp;

$read-me ~~ /^ $<waffle>=.*? +%% ["```" \n? $<code>=.*? "```" \n?] $/
    or die "README.md parse failed";

sub do-stuff(|c) { }

for @<code> {
    my $snippet = ~$_;
    # work around "Merging Global symbols failed" error
    $snippet ~~ s/'unit module OpenSSL::Digest;'//;
    # avoid premature end of testing
    $snippet ~~ s/'done-testing;'//;
    unless $snippet ~~ / extern | '#define' / { # not C
        # disable say
        sub say(|c) { }
        quietly {
            lives-ok {EVAL $snippet}, 'code sample'
                or die "eval error: $snippet";
        }
    }
}

done-testing;
