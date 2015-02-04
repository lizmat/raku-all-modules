use v6;

module Acme::DSON;

use Acme::DSON::Actions;
use Acme::DSON::Grammar;

proto to-dson($) is export {*}

multi to-dson(Real:D $d is copy) {
    return $d.base(8).subst(/\.$/, "");
}
multi to-dson(Bool:D $d) {
    return $d ?? 'yes' !! 'no';
}
multi to-dson(Str:D $d) {
    '"'
    ~ $d.trans(['"', '\\', "\b", "\f", "\n", "\r", "\t"]
            => ['\"', '\\\\', '\b', '\f', '\n', '\r', '\t'])\
            .subst(/<-[\c32..\c126]>/, { ord(~$_).fmt('\u%06o') }, :g)
    ~ '"'
}
multi to-dson(Positional:D $d) {
    return 'so '
            ~ $d.map(&to-dson).join(' also ')
            ~ ' many';
}
multi to-dson(Associative:D $d) {
    return 'such '
            ~ $d.map({ to-dson(.key) ~ ' is ' ~ to-dson(.value) }).join(', ')
            ~ ' wow';
}
multi to-dson(Mu:U $) { 'empty' }
multi to-dson(Mu:D $s) {
    die "Can't serialize an object of type " ~ $s.WHAT.perl
}

sub from-dson($text) is export {
    my $a = Acme::DSON::Actions.new();
    my $o = Acme::DSON::Grammar.parse($text, :actions($a));
    return $o.ast;
}
