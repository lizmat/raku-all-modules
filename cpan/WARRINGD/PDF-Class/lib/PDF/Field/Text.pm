use v6;

use PDF::Field;

role PDF::Field::Text
    does PDF::Field {

    use PDF::COS;
    use PDF::COS::Tie;
    use PDF::COS::Stream;
    use PDF::COS::TextString;

    # [PDF 1.7 TABLE 8.78 Additional entry specific to a text field]
    my subset TextOrStream of PDF::COS where PDF::COS::Stream | PDF::COS::TextString;
    multi sub coerce(Str $s is rw, TextOrStream) {
	PDF::COS.coerce($s, PDF::COS::TextString)
    }
    has TextOrStream $.V is entry(:&coerce, :inherit, :alias<value>);
    has TextOrStream $.DV is entry(:&coerce, :inherit, :alias<default-value>);

    has UInt $.MaxLen is entry; #| (Optional; inheritable) The maximum length of the field’s text, in characters.
}
