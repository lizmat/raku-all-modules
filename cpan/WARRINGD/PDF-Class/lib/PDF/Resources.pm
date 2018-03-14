use v6;

use PDF::COS::Tie::Hash;
use PDF::Content::ResourceDict;

#| Resource Dictionary
role PDF::Resources
    does PDF::COS::Tie::Hash
    does PDF::Content::ResourceDict {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::Stream;

    # See [PDF 1.7 TABLE 3.30 Entries in a resource dictionary]

    has %.ExtGState  is entry;  #| (Optional) A dictionary that maps resource names to graphics state parameter dictionaries

    use PDF::ColorSpace;
    my subset NameOrColorSpace of PDF::COS where PDF::COS::Name | PDF::ColorSpace;
    has NameOrColorSpace %.ColorSpace is entry;  #| (Optional) A dictionary that maps each resource name to either the name of a device-dependent color space or an array describing a color space

    has %.Pattern    is entry;  #| (Optional) A dictionary that maps resource names to pattern objects

    has %.Shading    is entry;  #| (Optional; PDF 1.3) A dictionary that maps resource names to shading dictionaries

    has PDF::COS::Stream %.XObject    is entry;  #| (Optional) A dictionary that maps resource names to external objects

    has Hash %.Font       is entry;  #| (Optional) A dictionary that maps resource names to font dictionaries
    has PDF::COS::Name @.ProcSet    is entry;  #| (Optional) An array of predefined procedure set names
    has Hash %.Properties is entry;  #|  (Optional; PDF 1.2) A dictionary that maps resource names to property list dictionaries for marked content


}

