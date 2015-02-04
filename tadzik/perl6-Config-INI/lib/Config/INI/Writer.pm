use v6;

module Config::INI::Writer;

our sub dump (%what) {
    my $ret;
    # toplevel
    for %what.kv -> $key, $value {
        next if $value ~~ Hash;
        $ret ~= "$key=$value\n";
    }
    # sections
    for %what.kv -> $key, $value {
        next unless $value ~~ Hash;
        $ret ~= "\n[$key]\n";
        for $value.kv -> $key, $value {
            $ret ~= "$key=$value\n";
        }
    }
    return $ret;
}

our sub dumpfile (%what, $where) {
    my $fh = open($where, :w);
    $fh.print(dump(%what));
    $fh.close;
}

# vim: ft=perl6
