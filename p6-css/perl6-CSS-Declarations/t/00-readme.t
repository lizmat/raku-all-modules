use Test;
plan 11;

my $read-me = "README.md".IO.slurp;

$read-me ~~ /^ $<waffle>=.*? +%% ["```" \n? $<code>=.*? "```" \n?] $/
    or die "README.md parse failed";

for @<code> {
    my $snippet = ~$_;
    # unless this looks like css
    unless $snippet ~~ /^ ['@font-face' | 'margin-top:'] / {
        # disable say
        sub say(|c) { }
        quietly {
            lives-ok {EVAL $snippet}, 'code sample'
                or die "eval error: $snippet";
        }
    }
}

done-testing;
