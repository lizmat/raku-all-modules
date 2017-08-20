use v6;

role PDF::Content::Font {

    has $.font-obj is rw handles <encode decode filter height kern stringwidth>;
    method set-font-obj($!font-obj) { $!font-obj }
}
