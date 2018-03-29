use v6;
use PDF::Font;

class PDF::Font::Type0
    is PDF::Font {
	use PDF::COS::Tie;
	use PDF::COS::Name;
	use PDF::COS::Stream;
	# see [ PDF 1.7 TABLE 5.18 Entries in a Type 0 font dictionary]
	has PDF::COS::Name $.BaseFont is entry(:required); #| (Required) The PostScript name of the font. In principle, this is an arbitrary name, since there is no font program associated directly with a Type 0 font dictionary.
        use PDF::CMap;
	subset NameOrCMap of PDF::COS where PDF::COS::Name | PDF::CMap;
        has NameOrCMap $.Encoding is entry(:required);   #| (Required) The name of a predefined CMap, or a stream containing a CMap that maps character codes to font numbers and CIDs.
	has PDF::Font @.DescendantFonts is entry(:required,:len(1));    #| (Required) A one-element array specifying the CIDFont dictionary that is the descendant of this Type 0 font.
        has PDF::CMap $.ToUnicode is entry;         #| (Optional) A stream containing a CMap file that maps character codes to Unicode values
}
