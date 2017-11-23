unit module Font::FreeType::Native::Types;

=begin pod

=head1 NAME

Font::FreeType::Native - type and enumeration declarations

=head1 SYNOPSIS

    # E.g. build a map of glyphs number to unicode
    use Font::FreeType::Native::Types;
    my FT_ULong $char-code;
    my FT_UInt $render-mode = FT_RENDER_MODE_LCD;

=head1 DESCRIPTION

This class contains datatye and enumerations for the FreeType library.

=end pod

#`{{

=cut
}}


use NativeCall;
use NativeCall::Types;

constant FT_Bool   is export = uint8;
constant FT_Error  is export = uint32;
constant FT_Int    is export = int32;
constant FT_Int32  is export = int32;
constant FT_Pos    is export = long;
constant FT_UInt   is export = uint32;
constant FT_ULong  is export = ulong;
constant FT_F26Dot6 is export = long;

sub ft-code(Str $s) {
    my uint32 $enc = 0;
    for $s.ords {
        $enc *= 256;
        $enc += $_;
    }
    $enc;
}

# FT_ENCODING - An enumeration to specify character sets supported by charmaps.
enum FT_ENCODING is export «
    :FT_ENCODING_NONE(0)
    :FT_ENCODING_SYMBOL(ft-code("symb"))
    :FT_ENCODING_UNICODE(ft-code("unic"))
    :FT_ENCODING_SJIS(ft-code("sjis"))
    :FT_ENCODING_PRC(ft-code("gb  "))
    :FT_ENCODING_BIG5(ft-code("big5"))
    :FT_ENCODING_WANGSUNG(ft-code("wang"))
    :FT_ENCODING_JOHAB(ft-code("joha"))
    :FT_ENCODING_ADOBE_STANDARD(ft-code("ADOB"))
    :FT_ENCODING_ADOBE_EXPERT(ft-code("ADBE"))
    :FT_ENCODING_ADOBE_CUSTOM(ft-code("ADBC"))
    :FT_ENCODING_ADOBE_LATIN_1(ft-code("lat1"))
    :FT_ENCODING_OLD_LATIN_2(ft-code("lat2"))
    :FT_ENCODING_APPLE_ROMAN(ft-code("armn"))
    »;

# FT_FACE - A list of bit flags used in the ‘face-flags’ field of the FT_FaceRec structure. They inform client applications of properties of the corresponding face.
enum FT_FACE_FLAG is export «
    :FT_FACE_FLAG_SCALABLE(1 +<  0)
    :FT_FACE_FLAG_FIXED_SIZES(1 +<  1)
    :FT_FACE_FLAG_FIXED_WIDTH(1 +<  2)
    :FT_FACE_FLAG_SFNT(1 +<  3)
    :FT_FACE_FLAG_HORIZONTAL(1 +<  4)
    :FT_FACE_FLAG_VERTICAL(1 +<  5)
    :FT_FACE_FLAG_KERNING(1 +<  6)
    :FT_FACE_FLAG_FAST_GLYPHS(1 +<  7)
    :FT_FACE_FLAG_MULTIPLE_MASTERS(1 +<  8)
    :FT_FACE_FLAG_GLYPH_NAMES(1 +<  9)
    :FT_FACE_FLAG_EXTERNAL_STREAM(1 +< 10)
    :FT_FACE_FLAG_HINTER(1 +< 11)
    :FT_FACE_FLAG_CID_KEYED(1 +< 12)
    :FT_FACE_FLAG_TRICKY(1 +< 13)
    :FT_FACE_FLAG_COLOR(1 +< 14)
    »;

# FT_KERNING - An enumeration to specify the format of kerning values returned by FT_Get_Kerning.
enum FT_KERNING is export «
    :FT_KERNING_DEFAULT(0x0)
    :FT_KERNING_UNFITTED(0x1)
    :FT_KERNING_UNSCALED(0x2)
    »;

# FT_GLYPH_FORMAT - An enumeration type used to describe the format of a given glyph image. 
enum FT_GLYPH_FORMAT is export «
    :FT_GLYPH_FORMAT_NONE(0)
    :FT_GLYPH_FORMAT_COMPOSITE(ft-code('comp'))
    :FT_GLYPH_FORMAT_BITMAP(ft-code('bits'))
    :FT_GLYPH_FORMAT_OUTLINE(ft-code('outl'))
    :FT_GLYPH_FORMAT_PLOT(ft-code('plot'))
    »;

# FT_LOAD - A list of bit field constants for FT_Load_Glyph to indicate what kind of operations to perform during glyph loading.
enum FT_LOAD is export «
    :FT_LOAD_DEFAULT(0x0)
    :FT_LOAD_NO_SCALE(1 +< 0)
    :FT_LOAD_NO_HINTING(1 +< 1)
    :FT_LOAD_RENDER(1 +< 2)
    :FT_LOAD_NO_BITMAP(1 +< 3)
    :FT_LOAD_VERTICAL_LAYOUT(1 +< 4)
    :FT_LOAD_FORCE_AUTOHINT(1 +< 5)
    :FT_LOAD_CROP_BITMAP(1 +< 6)
    :FT_LOAD_PEDANTIC(1 +< 7)
    :FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH(1 +< 9)
    :FT_LOAD_NO_RECURSE(1 +< 10)
    :FT_LOAD_IGNORE_TRANSFORM(1 +< 11)
    :FT_LOAD_MONOCHROME(1 +< 12)
    :FT_LOAD_LINEAR_DESIGN(1 +< 13)
    :FT_LOAD_NO_AUTOHINT(1 +< 15)
  # Bits 16-19 are used by `FT_LOAD_TARGET_'
    :FT_LOAD_COLOR(1 +< 20)
    :FT_LOAD_COMPUTE_METRICS(1 +< 21)
    :FT_LOAD_BITMAP_METRICS_ONLY(1 +< 22)
    »;

# FT_GLYPH_BBOX_MODE - The mode how the values of FT_Glyph_Get_CBox are returned.
enum FT_GLYPH_BBOX_MODE is export «
    :FT_GLYPH_BBOX_UNSCALED(0)
    :FT_GLYPH_BBOX_SUBPIXELS(0)
    :FT_GLYPH_BBOX_GRIDFIT(1)
    :FT_GLYPH_BBOX_TRUNCATE(2)
    :FT_GLYPH_BBOX_PIXELS(3)
    »;

# FT_PIXEL_MODE - An enumeration type used to describe the format of pixels in a given bitmap. Note that additional formats may be added in the future.
enum FT_PIXEL_MODE is export «
    :FT_PIXEL_MODE_NONE(0)
    :FT_PIXEL_MODE_MONO(1)
    :FT_PIXEL_MODE_GRAY(2)
    :FT_PIXEL_MODE_GRAY2(3)
    :FT_PIXEL_MODE_GRAY4(4)
    :FT_PIXEL_MODE_LCD(5)
    :FT_PIXEL_MODE_LCD_V(6)
    :FT_PIXEL_MODE_BGRA(7)
    »;

# FT_RENDER_MODE - Render modes supported by FreeType 2. Each mode corresponds to a specific type of scanline conversion performed on the outline.
enum FT_RENDER_MODE is export «
    :FT_RENDER_MODE_NORMAL(0)
    :FT_RENDER_MODE_LIGHT(1)
    :FT_RENDER_MODE_MONO(2)
    :FT_RENDER_MODE_LCD(3)
    :FT_RENDER_MODE_LCD_V(4)
    :FT_RENDER_MODE_MAX(5)
    »;

# FT_STYLE_FLAG - A list of bit flags to indicate the style of a given face. These are used in the ‘style_flags’ field of FT_FaceRec.
enum FT_STYLE_FLAG is export «
    :FT_STYLE_FLAG_ITALIC(1 +< 0)
    :FT_STYLE_FLAG_BOLD(1 +< 1)
    »;
