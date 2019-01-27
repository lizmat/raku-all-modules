#| replacement Catalog class - built from scratch
use PDF::COS::Dict;

class TestDoc::Catalog
    is PDF::COS::Dict {

    use PDF::COS::Tie;
    # see [PDF 1.7 TABLE 3.25 Entries in the catalog dictionary]
    use PDF::COS::Name;
    has PDF::COS::Name $.Type is entry(:required);
    has PDF::COS::Name $.Version is entry;        #| (Optional; PDF 1.4) The version of the PDF specification to which the document conforms (for example, /1.4) 
    has Hash $.Pages is entry(:required, :indirect); #| (Required; must be an indirect reference) The page tree node
    has Hash $.Resources is entry;
    use TestDoc::ViewerPreferences;
    has TestDoc::ViewerPreferences $.ViewerPreferences is entry;
}
