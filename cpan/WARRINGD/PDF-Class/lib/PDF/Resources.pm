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

    # See [PDF 32000 Table 33 - Entries in a resource dictionary]
    ## use ISO_32000::Resource;
    ## also does ISO_32000::Resource;

    has Hash %.ExtGState  is entry;  # (Optional) A dictionary that maps resource names to graphics state parameter dictionaries

    my subset NameOrColorSpace of PDF::COS where PDF::COS::Name | List; # autoloaded PDF::ColorSpace
    has NameOrColorSpace %.ColorSpace is entry;  # (Optional) A dictionary that maps each resource name to either the name of a device-dependent color space or an array describing a color space

    my subset Pattern of Hash where .<PatternType> ~~ UInt; # autoloaded PDF::Pattern
    has Pattern %.Pattern is entry;  # (Optional) A dictionary that maps resource names to pattern objects

    my subset Shading of Hash where .<ShadingType> ~~ UInt; # autoloaded PDF::Shading
    has Shading %.Shading is entry;  # (Optional; PDF 1.3) A dictionary that maps resource names to shading dictionaries

    my subset XObject of PDF::COS::Stream where .<Subtype> ~~ 'Image'|'Form'|'PS'; # autoloaded PDF::XObject
    has XObject %.XObject is entry;  # (Optional) A dictionary that maps resource names to external objects

    my subset Font of Hash where .<Type> ~~ 'Font'; # autoloaded PDF::Font
    has Font %.Font is entry;        # (Optional) A dictionary that maps resource names to font dictionaries

    has PDF::COS::Name @.ProcSet    is entry;  # (Optional) An array of predefined procedure set names
    has Hash %.Properties is entry;  # (Optional; PDF 1.2) A dictionary that maps resource names to property list dictionaries for marked content


}

