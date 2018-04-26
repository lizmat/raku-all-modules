#!perl6

use v6;

use Test;
use HTTP::Headers;

my $h = HTTP::Headers.new;

# Test the Hash-accessors
is($h{HTTP::Header::Content-Type}.name, HTTP::Header::Content-Type);
is($h<Content-Type>.name, HTTP::Header::Content-Type);

$h<Zoo> = 'bar';
is($h<Zoo>.name, 'Zoo');
is($h<Zoo>.value, 'bar');

is($h<Zoo> :exists, True);
ok($h<Zoo> :delete);
is($h<Zoo> :exists, False);

done-testing;
