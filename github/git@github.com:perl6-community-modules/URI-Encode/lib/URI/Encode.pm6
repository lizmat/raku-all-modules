module URI::Encode:ver<0.05>
{
    my $RFC3986_unreserved = rx/<[0..9A..Za..z\-.~_]>/;
    my $RFC3986_reserved = rx/<[:/?#\[\]@!$&'()*+,;=]>/;

    my %escapes;
    for (0..255) {
      next if chr($_) ~~ /$RFC3986_unreserved/;

      # for uri_decode
      %escapes{sprintf("%%%02X", $_)} = chr($_);
    }

    my &enc = sub (Str:D $m) {
        $m.encode.list.map(*.fmt('%%%02X')).join
    }

    sub uri_encode (Str:D $text) is export
    {
      return $text.comb.map({ if $RFC3986_unreserved or $RFC3986_reserved { $_ } else { &enc($_) }}).join;
    }

    sub uri_encode_component (Str:D $text) is export
    {
      return $text.comb.map({ if $RFC3986_unreserved { $_ } else { &enc($_) }}).join;
    }

    my &dec = sub ($m) {
        Buf.new($m<bit>.list.map({:16($_.Str)})).decode;
    }

    sub uri_decode (Str:D $text) is export
    {
      return $text.subst(/[\%$<bit>=[<[0..9A..Fa..f]>** 2]]+/, &dec, :g);
    }

    sub uri_decode_component (Str:D $text) is export
    {
      return $text.subst(/[\%$<bit>=[<[0..9A..Fa..f]>** 2]]+/, &dec, :g);
    }
}

# vim: ft=perl6
