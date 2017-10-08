use v6;
=begin pod

=head1 JSON5::Tiny

C<JSON5::Tiny> is a minimalistic module that reads and writes JSON5.
It supports strings, numbers, arrays and hashes (no custom objects).

=head1 Synopsis

    use JSON5::Tiny;
    my $json = to-json([1, 2, "a third item"]);
    my $copy-of-original-data-structure = from-json($json);

=end pod

unit module JSON5::Tiny;

use JSON5::Tiny::Actions;
use JSON5::Tiny::Grammar;

proto to-json($) is export {*}

multi to-json(Real:D $d) { ~$d }
multi to-json(Bool:D $d) { $d ?? 'true' !! 'false'; }
multi to-json(Str:D  $d) {
    '"'
    ~ $d.trans(['"',  '\\',   "\b", "\f", "\n", "\r", "\t"]
            => ['\"', '\\\\', '\b', '\f', '\n', '\r', '\t'])\
            .subst(/<-[\c32..\c126]>/, { ord(~$_).fmt('\u%04x') }, :g)
    ~ '"'
}
multi to-json(Positional:D $d) {
    return  '[ '
            ~ $d.map(&to-json).join(', ')
            ~ ' ]';
}
multi to-json(Associative:D  $d) {
    return '{ '
            ~ $d.map({ to-json(.key) ~ ' : ' ~ to-json(.value) }).join(', ')
            ~ ' }';
}

multi to-json(Mu:U $) { 'null' }
multi to-json(Mu:D $s) {
    die "Can't serialize an object of type " ~ $s.WHAT.perl
}

sub from-json($text) is export {
    my $a = JSON5::Tiny::Actions.new();
    my $o = JSON5::Tiny::Grammar.parse($text, :actions($a));
    return $o.ast;
}
# vim: ft=perl6
