use PDF::COS::Stream;
class PDF::FontFile
    is PDF::COS::Stream {
    use PDF::COS::Name;
    use PDF::COS::Tie;
    my subset Subtype of PDF::COS::Name where 'Type1C'|'CIDFontType0C'|'OpenType';
    has Subtype $.Subtype is entry(:required);
}
