#!perl6

use v6;

use Test;
use Template::Anti;

my $at = Template::Anti.load("t/void-tags.html".IO);
my $output = $at.render.subst(/\>\s+\</, "><", :g);

is "$output\n", "t/void-tags.out".IO.slurp, 'output is as expected';

done-testing;
