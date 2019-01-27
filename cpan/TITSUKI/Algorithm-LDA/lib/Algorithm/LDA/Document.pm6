use v6.c;
use NativeCall;
unit class Algorithm::LDA::Document:ver<0.0.9>:auth<cpan:TITSUKI> is repr('CPointer');

my constant $library = %?RESOURCES<libraries/lda>.Str;

my sub lda_create_document(int32, CArray[int32] --> Algorithm::LDA::Document) is native($library) { * }

method new(Int :$length, Int :@words) {
    lda_create_document($length, CArray[int32].new(@words));
}
