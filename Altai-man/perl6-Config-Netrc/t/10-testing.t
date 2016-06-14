use v6;

use Test;
use lib 'lib';

use Config::Netrc;

my Str $text = q:to/EOI/;
                   # this is my netrc with default
                   machine m
                   login l # this is my username
                   password p

                   default
                   login default_login # this is my default username
                   password default_password
                   EOI
ok parse($text); # TODO more tests to add;

done-testing;
