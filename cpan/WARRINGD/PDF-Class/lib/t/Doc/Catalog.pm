#| replacement Catalog class - built from scratch
use PDF::DAO::Dict;

class t::Doc::Catalog
    is PDF::DAO::Dict {

    use PDF::DAO::Tie;
    # see [PDF 1.7 TABLE 3.25 Entries in the catalog dictionary]
    use PDF::DAO::Name;
    has PDF::DAO::Name $.Type is entry(:required);
    has PDF::DAO::Name $.Version is entry;        #| (Optional; PDF 1.4) The version of the PDF specification to which the document conforms (for example, /1.4) 
    has Hash $.Pages is entry(:required, :indirect); #| (Required; must be an indirect reference) The page tree node
    has Hash $.Resources is entry;
    use t::Doc::ViewerPreferences;
    has t::Doc::ViewerPreferences $.ViewerPreferences is entry; 
}
