use v6;

role PDF::Content::Font {
    use PDF::COS;
    use PDF::COS::Dict;

    has $.font-obj is rw handles <encode decode filter font-name height kern stringwidth cb-finish>;

    method make-font(PDF::COS::Dict $font-dict, $font-obj) {
        $font-dict.^mixin: PDF::Content::Font
            unless $font-dict.does(PDF::Content::Font);
        $font-dict.set-font-obj($font-obj);
        $font-dict;
    }
    # needed by PDF::Class (PDF::Font::Type1)
    method set-font-obj($!font-obj) { $!font-obj }

}
