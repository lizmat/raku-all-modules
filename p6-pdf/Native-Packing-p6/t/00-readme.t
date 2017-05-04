use Test;
plan 2;

my $read-me = "README.md".IO.slurp;

$read-me ~~ /^ $<waffle>=.*? +%% ["```" \n? $<code>=.*? "```" \n?] $/
    or die "README.md parse failed";

for @<code> {
    my $snippet = ~$_;
    # disable say
    sub say(|c) { }
    quietly {
        lives-ok {EVAL $snippet}, 'code sample'
            or die "eval error: $snippet";
    }
}

done-testing;
