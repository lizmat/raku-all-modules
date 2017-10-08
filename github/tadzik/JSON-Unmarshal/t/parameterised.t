#!perl6

use Test;
use JSON::Unmarshal;

class C {
	has Str %.bla{subset :: of Str where any("ble", "blob")}
}; 

my $res;

lives-ok { 
    $res = unmarshal( ｢{"bla": {"ble": "bli"}}｣, C);
}, "unmarshal class with hash with subset constrained values";

is $res.bla<ble> , 'bli', "and the result is what is expected";

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
