module URI::Encode
{
    # build two arrays of reserved encoded chars
    # use arrays because straight-up hash transliteration only
    # replaces 1 char on either side. E.g. " " becomes % not %
    my $RFC3986_unreserved = /<[0..9A..Za..z\-.~]>/;

    my (%escapes, @escape_chars, @escape_encoding);
    for (0..255) {
        next if chr($_) ~~ /$RFC3986_unreserved/;

        @escape_chars.push(chr($_));
        @escape_encoding.push(sprintf("%%%02X", $_));

        # used for uri_decode
        %escapes{sprintf("%%%02X", $_)} = chr($_);
    }

    sub uri_encode (Str $text!) is export
    {
        return $text.trans(@escape_chars => @escape_encoding);
    }

    sub uri_decode (Str $text!) is export
    {
        return $text.subst(/(\%<[0..9A..Fa..f]>** 2)/, { %escapes{$0} }, :g);
    }
}
