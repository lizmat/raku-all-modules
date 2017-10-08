
use Test;

plan 5;

my grammar Pair::Grammar {
    token TOP { ^ <pair> $ }

    proto rule pair {*}

    rule pair:sym<arrow> { <key> '=>' <value> }

    rule pair:sym<colon> { ':' <key> '(' $<value> = (.+ <!before $>) ')' }

    rule pair:sym<angle> { ':' <key> '<' $<value> = (.+ <!before $>) '>' }

    rule pair:sym<true> { ':' <key> }

    rule pair:sym<false> { ':' '!' <key> }

    token value { .+ }

    token key { <[0..9A..Za..z\-_\'\"]>+ }
}

my class Pair::Actions {
    method TOP($/) { $/.make: $<pair>.made; }

    method pair:sym<arrow>($/) {
        $/.make: $<key>.made => $<value>.Str;
    }

    method pair:sym<colon>($/) {
        $/.make: $<key>.made => $<value>.Str;
    }

    method pair:sym<true>($/) {
        $/.make: $<key>.made => True;
    }

    method pair:sym<false>($/) {
        $/.make: $<key>.made => False;
    }

    method pair:sym<angle>($/) {
        $/.make: $<key>.made => $<value>.Str;
    }

    method value($/) {
        $/.make: ~$/;
    }

    method key($/) {
        $/.make: ~$/;
    }
}

my @pairs  = ['a => b', ':a', ':!a', ':a(42)', ':a<42>'];
my @result = [Pair.new("a", "b"), Pair.new("a", True), Pair.new("a", False), Pair.new("a", "42"), Pair.new("a","42")];

for ^+@pairs -> $index {
    my $r = Pair::Grammar.parse(@pairs[$index], :actions(Pair::Actions)).made;

    is $r, @result[$index];
}
