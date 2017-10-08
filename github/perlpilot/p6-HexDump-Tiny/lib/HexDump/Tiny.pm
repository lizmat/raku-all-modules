unit module HexDump::Tiny;

sub hexdump($value, :$chunk-size = 16) is export {
    my @chars = $value.comb;
    my @chunks = @chars.rotor($chunk-size, :partial);
    gather for @chunks.kv -> $k, $v {
        my $hex = join " ", map -> $a, $b? { 
            ?$b ?? sprintf("%02x%02x", $a.ord, $b.ord) 
                !! sprintf("%02x", $a.ord) 
        }, @$v;
        take ($k*$chunk-size).fmt('%08x:  ') ~ 
            sprintf("%-*s", $chunk-size * 2 + $chunk-size div 2, $hex)  ~ "  " ~ 
            $v.list.map({ s:g/<-print>/./; $_ }).join;
    }
}
