use Test;
use Pod::To::HTML;
plan 2;
my $r;

# XXX Need a module to walk HTML trees

=begin foo
=end foo

$r = node2html $=pod[0];
ok $r ~~ ms/'<section>' '<h1>' foo '</h1>' '</section>' /;

=begin foo
some text
=end foo

$r = node2html $=pod[1];
ok $r ~~ ms/'<section>' '<h1>' foo '</h1>' '<p>' some text '</p>' '</section>'/;
