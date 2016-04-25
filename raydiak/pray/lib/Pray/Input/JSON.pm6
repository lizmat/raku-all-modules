unit module Pray::Input::JSON;
# forked from https://github.com/tadzik/JSON-Unmarshal
# will either be heavily customized for scene files, or replaced

use JSON::Tiny;

sub panic ($json, $type) {
    die "Cannot load {$json.perl} to type {$type.perl}"
}

multi _load ($json, Int) {
    if $json ~~ Int {
        return Int($json)
    }
    panic($json, Int)
}

multi _load ($json, Numeric) {
    if $json ~~ Numeric {
        return Num($json)
    }
    panic($json, Numeric)
}

multi _load ($json, Str) {
    if $json ~~ Stringy {
        return Str($json)
    }
}

multi _load ($json is copy, Any $x) {
    my $type = $x.WHAT;
    my %args;
    for $type.^attributes -> $attr {
        my $name = $attr.name.substr(2);
        next unless $json{$name} :exists;
        %args{$name} := _load($json{$name} :delete, $attr.type);
    }
    for $json.keys -> $arg {
        %args{$arg} := $json{$arg};
    }
    return $type.new(|%args)
}

multi _load ($json, @x) {
    return $json.list.map: { _load($_, @x.of) }
}

multi _load ($json, Mu) {
    return $json
}

our sub load_file ($file, $obj) {
    load_json(slurp($file), $obj)
}

our sub load_json ($json, $obj) {
    load_data(from-json($json), $obj)
}

our sub load_data ($data, $obj) {
    _load($data, $obj)
}

