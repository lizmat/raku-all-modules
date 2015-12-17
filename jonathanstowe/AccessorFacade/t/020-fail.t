#!perl6

use v6;
use Test;

use lib 'lib';
use AccessorFacade;

my $test_class;

$test_class = 'class Bar { method boom() is rw is accessor-facade {}; }';
throws-like { EVAL $test_class }, X::AccessorFacade::Usage, "accessor-facade - no args",  message => q[trait 'accessor-facade' requires &getter and &setter arguments];
 
$test_class = 'class Bar { method boom() is rw is accessor-facade("foo", "bar") {}; }';
throws-like { EVAL $test_class }, X::AccessorFacade::Usage, "accessor-facade - non-code args",  message => q[trait 'accessor-facade' only takes Callable arguments];
 

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
