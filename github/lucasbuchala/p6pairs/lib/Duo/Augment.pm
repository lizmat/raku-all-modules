
use v6;
use MONKEY-TYPING;

use Duo;

augment class Pair {
    multi method Duo(|) {*}
    multi method Duo(Pair:U:) { Duo }
    multi method Duo(Pair:D:) { Duo.new($!key, $!value) }
}

# vim: ft=perl6
