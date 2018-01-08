use v6;
use PDF::Font::Type1;

#| TrueType fonts - /Type /Font /Subtype TrueType
#| see [PDF 1.7 Section 5.5.2 TrueType Fonts]
# "A TrueType font dictionary can contain the same entries as a Type 1 font dictionary"
class PDF::Font::TrueType
    is PDF::Font::Type1 {
}
