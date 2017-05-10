#!/usr/bin/env perl6
use lib <lib ../lib>;

use Pythonic::Str;

say 'foobar'[3];    # b
say 'foobar'[3..*]; # bar
say 'foobar'[^3];   # foo
say 'IP y♥t hPoenr l♥ ♥6 '[^∞ .grep: * %% 2]; # I ♥ Perl 6
