module JSON::Unmarshal;
use JSON::Tiny;

sub panic($json, $type) {
    die "Cannot unmarshal {$json.perl} to type {$type.perl}"
}

multi _unmarshal($json, Int) {
    if $json ~~ Int {
        return Int($json)
    }
    panic($json, Int)
}

multi _unmarshal($json, Numeric) {
    if $json ~~ Numeric {
        return Num($json)
    }
    panic($json, Numeric)
}

multi _unmarshal($json, Str) {
    if $json ~~ Stringy {
        return Str($json)
    }
}

multi _unmarshal($json, Any $x) {
    my %args;
    for $x.^attributes -> $attr {
        my $name = $attr.name.substr(2);
        %args{$name} = _unmarshal($json{$name}, $attr.type);
    }
    return $x.new(|%args)
}

multi _unmarshal($json, @x) {
    return $json.list.map: { _unmarshal($_, @x.of) }
}

multi _unmarshal($json, Mu) {
    return $json
}

sub unmarshal($json, $obj) is export {
    _unmarshal(from-json($json), $obj)
}
