
unit module Net::FTP::Buffer;

sub split (Buf $buf is rw, Buf $sep, :$empty = False) is export {
    my @lines;
    my ($l, $r, $len) = (0, 0, +$buf - +$sep);
    my $get = 0;
    
    loop (;$r <= $len;$r++) {
        for 0 .. (+$sep - 1) {
            if $buf[$r + $_] == $sep[$_] {
                $get++;
                if ($get == +$sep) || ($l == $r && $empty) {
                    @lines.push: $buf.subbuf($l, $r - $l);
                    $r += +$sep;
                    $l = $r;

                }
            } else{
                $get = 0;last;
            }
        }
    }

    if ($r - $l >= 1) {
        $buf = $buf.subbuf($l, +$buf - $l);
    } 
    
    return @lines;
}

sub merge (Buf $lb, Buf $rb) is export {
    my $ret = Buf.new($lb);

    my $len = $lb.elems;

    for 0 .. $rb.elems - 1 {
        $ret[$len + $_] = $rb[$_];
    }

    return $ret;
}

# vim: ft=perl6

