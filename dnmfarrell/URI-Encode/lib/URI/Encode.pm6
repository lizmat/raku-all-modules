module URI::Encode:ver<0.04>
{
    my $RFC3986_unreserved = /<[0..9A..Za..z\-.~]>/;

    my %escapes;
    for (0..255) {
      next if chr($_) ~~ /$RFC3986_unreserved/;

      # for uri_decode
      %escapes{sprintf("%%%02X", $_)} = chr($_);
    }

    sub uri_encode (Str:D $text) is export
    {
      return $text.subst(/<[\x00..\xff]-[a..zA..Z0..9_.~\-\#\$\&\+,\/\:;\=\?@]>/, *.ord.fmt('%%%02X'), :g);
    }

    sub uri_encode_component (Str:D $text) is export
    {
      return $text.subst(/<[\x00..\xff]-[a..zA..Z0..9_.~\-]>/, *.ord.fmt('%%%02X'), :g);
    }

    sub uri_decode (Str:D $text) is export
    {
      return $text.subst(/(\%<[0..9A..Fa..f]>** 2)/, { %escapes{$0} }, :g);
    }

    sub uri_decode_component (Str:D $text) is export
    {
      return $text.subst(/(\%<[0..9A..Fa..f]>** 2)/, { %escapes{$0} }, :g);
    }
}

# vim: ft=perl6
