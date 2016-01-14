use v6;
use Test;
use Pod::EOD;

plan *;

sub load-pod($code) {
    my $full-code = "$code\n\$=pod";
    EVAL $full-code;
}

my $pod = load-pod(q:to/END_PERL6/);
#| Example sub!
sub example { }

=begin head1
NAME
Example
=end head1

END_PERL6

move-declarations-to-end($pod);

isa-ok $pod[0], Pod::Heading;
isa-ok $pod[1], Pod::Block::Declarator;

done-testing;
