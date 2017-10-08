#!/usr/bin/env perl6

unit module Number::Bytes::Human;

constant @SUFFIXES = < B K M G T P E Z Y >;
constant %MAGNITUDES = {
    B => 2 ** 0,
    K => 2 ** 10,
    M => 2 ** 20,
    G => 2 ** 30,
    T => 2 ** 40,
    P => 2 ** 50,
    E => 2 ** 60,
    Z => 2 ** 70,
    Y => 2 ** 80,
};

sub format-bytes(Numeric $bytes, Int :$magnitude = 0 --> Str) is export(:functions) {
    if $bytes.abs < 1024 {
        return "{ sprintf '%.0f', $bytes }" ~ "{ @SUFFIXES[ $magnitude ] }";
    }

    return format-bytes $bytes / 1024, magnitude => $magnitude + 1;
}

sub parse-bytes(Str $bytes --> Numeric) is export(:functions) {
    if $bytes ~~ m:i/$<value>=(\-?\d+[\.\d+]?) \s? $<suffix>=(<[BKMGTPEZY]>)B?/ {
        my $value = $<value>.Numeric * %MAGNITUDES{ $<suffix> };
        return $value;
    }
    else {
        die "Invalid value: $bytes";
    }
}

class Number::Bytes::Human {
    method format (Numeric $bytes --> Str) {
        return format-bytes $bytes;
    }
    method parse (Str $bytes --> Numeric) {
        return parse-bytes $bytes;
    }
};
