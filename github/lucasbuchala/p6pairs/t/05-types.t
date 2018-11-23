
use v6;
use Test;
use Duo;

my \o = Duo.new;

# ok o.key-of   =:= Any
# ok o.value-of =:= Any

is-deeply o.key-of,   Any, 'default key type';
is-deeply o.value-of, Any, 'default value type';

is-deeply o.is-symmetric, True, 'is symmetric';

done-testing;

# vim: ft=perl6
