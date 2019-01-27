use v6;

use PDF::Field;

role PDF::Field::Text
    does PDF::Field {

    use PDF::COS;
    use PDF::COS::Tie;
    use PDF::COS::Stream;
    use PDF::COS::TextString;

    # See [PDF 32000 TABLE 229 - Additional entry specific to a text field]
    ## use ISO_32000::Text_field_additional;
    ## also does ISO_32000::Text_field_additional;
    my subset TextOrStream of PDF::COS where PDF::COS::Stream | PDF::COS::TextString;
    multi sub coerce(Str $_ is rw, TextOrStream) {
	PDF::COS.coerce($_, PDF::COS::TextString)
    }
    multi sub coerce($_, TextOrStream) is default {
	fail "unable to coerce {.perl} to Text or a Stream";
    }
    has TextOrStream $.V is entry(:&coerce, :inherit, :alias<value>);
    has TextOrStream $.DV is entry(:&coerce, :inherit, :alias<default-value>);

    has UInt $.MaxLen is entry; # (Optional; inheritable) The maximum length of the field’s text, in characters.
}
