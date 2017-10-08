use v6;
use Test;
plan 2;

# Load the module
use Masquerade;

# At this point this is pretty simple:  just take a json object and turn it
# into a corresponding perl6 object.
ok (('{"a":"foo"}' but AsIf::Perl)<a> eq 'foo'), "can access object elements";
ok (('["a","b","c"]' but AsIf::Perl)[0] eq 'a'), "can access array elements"; 

