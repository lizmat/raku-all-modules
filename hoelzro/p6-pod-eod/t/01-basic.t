use v6;
use Test;
use Pod::EOD;

plan *;

sub load-pod($code) {
    my $full-code = "$code\n\$=pod";
    EVAL $full-code;
}

my @features = (
    'sub example {}',
    'module My::Module {}',
);

for @features -> $feature {
    my $pod = load-pod(qq:to/END_PERL6/);
    #| Example Feature!
    $feature

    =begin head1
    NAME
    Example
    =end head1

    END_PERL6

    move-declarations-to-end($pod);

    isa-ok $pod[0], Pod::Heading, "rearrangement should be successful for feature '$feature'";
    isa-ok $pod[1], Pod::Block::Declarator, "rearrangement should be successful for feature '$feature'";
}

done-testing;
