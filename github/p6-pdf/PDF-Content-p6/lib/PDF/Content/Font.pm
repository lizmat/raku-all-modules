use v6;

role PDF::Content::Font {
    use PDF::DAO;
    use PDF::DAO::Dict;

    has $.font-obj is rw handles <encode decode filter font-name height kern stringwidth cb-finish>;

    method make-font(PDF::DAO::Dict $dict, $font-obj) {
        my $font-dict = PDF::DAO.coerce(
            $dict,
            PDF::Content::Font
            );
        $font-dict.set-font-obj($font-obj);
        $font-dict;
    }
    # needed by PDF::Zen (PDF::Font::Type1)
    method set-font-obj($!font-obj) { $!font-obj }

}
