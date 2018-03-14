use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

#| /Type /FontDescriptor - the FontDescriptor dictionary

class PDF::FontDescriptor
    is PDF::COS::Dict
    does PDF::Class::Type {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::Stream;

    # see [PDF 1.7 TABLE 5.19 Entries common to all font descriptors]
    my subset Name-FontDescriptor of PDF::COS::Name where 'FontDescriptor';
    has Name-FontDescriptor $.Type is entry(:required);
    has PDF::COS::Name $.FontName is entry(:required); #| (Required) The PostScript name of the font.
    has Str $.FontFamily is entry;                     #| (Optional; PDF 1.5; strongly recommended for Type 3 fonts in Tagged PDF documents) A byte string specifying the preferred font family name
    subset FontStretchName of PDF::COS::Name where 'ExtraCondensed'|'Condensed'|'SemiCondensed'|'Normal'|'SemiExpanded'|'Expanded'|'ExtraExpanded'|'UltraExpanded';
    has FontStretchName $.FontStretch is entry;        #| (Optional; PDF 1.5; strongly recommended for Type 3 fonts in Tagged PDF documents) The font stretch value
    subset FontWeightValue of Int where 100|200|300|400|500|600|700|800|900;
    has FontWeightValue $.FontWeight is entry;         #| Optional; PDF 1.5; strongly recommended for Type 3 fonts in Tagged PDF documents) The weight (thickness) component of the fully-qualified font name or font specifier.
    subset FontFlags of Int where 0 ..^ (2 +< 18);
	#| See [PDF 1.7 TABLE 5.20 Font flags]
	#|     BIT POSITION: NAME - MEANING
	#|     1: FixedPitch - All glyphs have the same width (as opposed to proportional or variable-pitch fonts, which have different widths).
	#|     2: Serif - Glyphs have serifs, which are short strokes drawn at an angle on the top and bottom of glyph stems. (Sans serif fonts do not have serifs.)
	#|     3: Symbolic - Font contains glyphs outside the Adobe standard Latin character set. This flag and the Nonsymbolic flag cannot both be set or both be clear (see below).
	#|     4: Script - Glyphs resemble cursive handwriting.
	#|     6: Nonsymbolic - Font uses the Adobe standard Latin character set or a subset of it (see below).
	#|     7: Italic - Glyphs have dominant vertical strokes that are slanted.
	#|     17: AllCap - Font contains no lowercase letters; typically used for display purposes, such as for titles or headlines.
	#|     18: SmallCap - Font contains both uppercase and lowercase letters. The uppercase letters are similar to those in the regular version of the same typeface family. The glyphs for the lowercase letters have the same shapes as the corresponding uppercase letters, but they are sized and their proportions adjusted so that they have the same size and stroke weight as lowercase glyphs in the same typeface family.
	#|     19: ForceBold - See [PDF 1.7 Section 5.7.1 Font Descriptor Flags]
    has FontFlags $.Flags is entry;                    #| (Required) A collection of flags defining various characteristics of the font
    has Numeric @.FontBBox is entry(:len(4));          #| (Required, except for Type 3 fonts) A rectangle, expressed in the glyph coordinate system, specifying the font bounding box.
    has Numeric $.ItalicAngle is entry;                #| (Required) The angle, expressed in degrees counterclockwise from the vertical, of the dominant vertical strokes of the font. (
    has Numeric $.Ascent is entry;                     #| (Required, except for Type 3 fonts) The maximum height above the baseline reached by glyphs in this font, excluding the height of glyphs for accented characters.
    has Numeric $.Descent is entry;                    #| (Required, except for Type 3 fonts) The maximum depth below the baseline reached by glyphs in this font. The value is a negative number.
    has Numeric $.Leading is entry;                    #| (Optional) The spacing between baselines of consecutive lines of text
    has Numeric $.CapHeight is entry;                  #| (Required for fonts that have Latin characters, except for Type 3 fonts) The vertical coordinate of the top of flat capital letters, measured from the baseline
    has Numeric $.XHeight is entry;                    #| (Optional) The font’s x height: the vertical coordinate of the top of flat nonascending lowercase letters (like the letter x), measured from the baseline, in fonts that have Latin characters
    has Numeric $.StemV is entry;                      #| (Required, except for Type 3 fonts) The thickness, measured horizontally, of the dominant vertical stems of glyphs in the font.
    has Numeric $.StemH is entry;                      #| (Optional) The thickness, measured vertically, of the dominant horizontal stems of glyphs in the font
    has Numeric $.AvgWidth is entry;                   #| (Optional) The average width of glyphs in the font
    has Numeric $.MaxWidth is entry;                   #| (Optional) The maximum width of glyphs in the font
    has Numeric $.MissingWidth is entry;               #| (Optional) The width to use for character codes whose widths are not specified in a font dictionary’s Widths array.
    has PDF::COS::Stream $.FontFile is entry;          #| (Optional) A stream containing a Type 1 font program
    has PDF::COS::Stream $.FontFile2 is entry;         #| (Optional; PDF 1.1) A stream containing a TrueType font program
    use PDF::FontFile;
    has PDF::FontFile $.FontFile3 is entry;           #| (Optional; PDF 1.2) A stream containing a font program whose format is specified by the Subtype entry in the stream dictionary. type1C for Type 1 compact fonts, CIDFontType0C for Type 0 compact CIDFonts, or OpenType for OpenType fonts.
    has Str $.CharSet is entry;                        #| Optional; meaningful only in Type 1 fonts; PDF 1.1) A string listing the character names defined in a font subset


}
