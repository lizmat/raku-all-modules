use v6.c;
use Test;

use Env;

BEGIN %*ENV<USER> //= ~$*USER;      # make sure we have an ENV<USER>
my @keys = BEGIN %*ENV.keys.sort;   # must be *before* next line
use Env;                            # must be *after* previous line

plan @keys + 3;

my @vars = @keys.map: '$' ~ *;

for @keys.kv -> $i, $name {
    is ::(@vars[$i]), %*ENV{$name}, "did we find \%*ENV<$name> as @vars[$i]"; 
}

$USER = 42;
is %*ENV<USER>, 42, 'did we change inside %*ENV also';

$USER = Nil;
is $USER, Nil,          'did we actually reset $USER';
nok %*ENV<USER>:exists, 'did we actually remove it from %*ENV';

# vim: ft=perl6 expandtab sw=4
