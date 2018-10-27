#!perl6

use v6.c;

use Test;

use URI::Template;

my $template = URI::Template.new(template => 'http://foo.com{/foo,bar}');

is $template.process(foo => 'baz', bar => 'quux'), 'http://foo.com/baz/quux', "check the synopsis code is actually correct";


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
