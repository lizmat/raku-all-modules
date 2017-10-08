#!perl6

use v6;
use lib 'lib';

use Test;
use Haikunator;

use-ok('Haikunator', 'Can load "Haikunator" ok');

like haikunate(), /([<[a..z]><[a..z]>+])('-')([<[a..z]><[a..z]>+])('-')(\d** 4 )\n?$/, 'haikunate should return 4 digits';
like haikunate(:tokenHex(True)), /([<[a..z]><[a..z]>+])('-')([<[a..z]><[a..z]>+])('-')(\N** 4 )\n?$/, 'haikunate should return 4 digits as hex';
like haikunate(:tokenLength(9)), /([<[a..z]><[a..z]>+])('-')([<[a..z]><[a..z]>+])('-')(\d** 9 )\n?$/, 'haikunate should return 9 digits';
like haikunate(:tokenLength(9), :tokenHex(True)), /([<[a..z]><[a..z]>+])('-')([<[a..z]><[a..z]>+])('-')(\N** 9 )\n?$/, 'haikunate should return 9 digits as hex';
like haikunate(:tokenLength(0)), /([<[a..z]><[a..z]>+])('-')([<[a..z]><[a..z]>+])\n?$/, 'haikunate drops the token if token range is 0';
like haikunate(:delimiter(".")), /([<[a..z]><[a..z]>+])(\.)([<[a..z]><[a..z]>+])(\.)(\d+)\n?$/, 'haikunate permits optional configuration of the delimiter';
like haikunate(:tokenLength(0), :delimiter(" ")), /([<[a..z]><[a..z]>+])(' ')([<[a..z]><[a..z]>+])\n?$/, 'haikunate drops the token if token range is 0 and delimiter is an empty space';
like haikunate(:tokenLength(0), :delimiter("")), /([<[a..z]><[a..z]>+])\n?$/, 'haikunate returns one single word if token and delimiter are dropped';
like haikunate(:tokenChars("A")), /([<[a..z]><[a..z]>+])('-')([<[a..z]><[a..z]>+])('-')(AAAA)\n?$/, 'haikunate permits custom token chars';

isnt haikunate(), haikunate(), 'haikunate wont return the same name for subsequent calls';

done-testing;
