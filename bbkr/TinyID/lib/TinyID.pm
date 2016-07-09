unit class TinyID;

has $!length;
has %!chars_to_positions;
has @!positions_to_chars;

submethod BUILD ( Str:D :$key where { .chars >= 2 and not /(.).*$0/ } ){
    $!length = $key.chars;
    @!positions_to_chars = $key.comb;
    %!chars_to_positions = @!positions_to_chars.kv.reverse;
}

method encode ( Int:D $in where $in >= 0 ) returns Str:D {
    my $tmp = $in;
    my Str:D $out = '';
    
    repeat {
        $out ~= @!positions_to_chars[ $tmp % $!length ];
        $tmp /= $!length;
    } while $tmp .= Int;
    
    return $out.flip;
}

method decode ( Str:D $in where $in.comb (<=) @!positions_to_chars ) returns Int:D {
    my Int:D $out = 0;

    for $in.comb.reverse.kv -> $pos, $tmp {
        $out += %!chars_to_positions{ $tmp } * $!length ** $pos;
    }
    
    return $out;
}
