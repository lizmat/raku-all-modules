use v6.c;
use NativeCall;
unit class Algorithm::HierarchicalPAM::Document:ver<0.0.1>:auth<cpan:TITSUKI> is repr('CPointer');

my constant $library = %?RESOURCES<libraries/hpam>.Str;

my sub hpam_create_document(int32, CArray[int32] --> Algorithm::HierarchicalPAM::Document) is native($library) { * }

method new(Int :$length, Int :@words) {
    hpam_create_document($length, CArray[int32].new(@words));
}
