use Test; # -*- mode: perl6 -*-
use Pod::To::HTML;
plan 3;

# XXX Need a module to walk HTML trees

=begin foo
=end foo

my $r = node2html $=pod[0];
ok $r ~~ ms/'<section>' '<h1>' foo '</h1>' '</section>' /;

=begin foo
some text
=end foo

$r = node2html $=pod[1];
ok $r ~~ ms/'<section>' '<h1>' foo '</h1>' '<p>' some text '</p>' '</section>'/;

=head1 Talking about Perl 6

if  $*PERL.compiler.name eq 'rakudo'
and $*PERL.compiler.version before v2018.06 {
    skip "Your rakudo is too old for this test. Need 2018.06 or newer";
}
else {
    $r = node2html $=pod[2];
    nok $r ~~ m:s/Perl 6/, "no-break space is not converted to other space";
}
