use v6;

use PDF::Field;

role PDF::Field::Text
    does PDF::Field {

    use PDF::DAO;
    use PDF::DAO::Tie;
    use PDF::DAO::Stream;
    use PDF::DAO::TextString;

    # [PDF 1.7 TABLE 8.78 Additional entry specific to a text field]
    my subset TextOrStream of PDF::DAO where PDF::DAO::Stream | PDF::DAO::TextString;
    multi sub coerce(Str $s is rw, TextOrStream) {
	PDF::DAO.coerce($s, PDF::DAO::TextString)
    }
    has TextOrStream $.V is entry(:&coerce, :inherit);
    has TextOrStream $.DV is entry(:&coerce, :inherit);

    has UInt $.MaxLen is entry; #| (Optional; inheritable) The maximum length of the field’s text, in characters.
}
