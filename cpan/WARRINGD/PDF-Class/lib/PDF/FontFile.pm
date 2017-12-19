use PDF::DAO::Stream;
class PDF::FontFile
    is PDF::DAO::Stream {
    use PDF::DAO::Name;
    use PDF::DAO::Tie;
    my subset Subtype of PDF::DAO::Name where 'Type1C'|'CIDFontType0C'|'OpenType';
    has Subtype $.Subtype is entry(:required);
}
