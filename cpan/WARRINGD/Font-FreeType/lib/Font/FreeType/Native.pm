unit module Font::FreeType::Native;

=begin pod

=head1 NAME

Font::FreeType::Native - bindings to the freetype library

=head1 SYNOPSIS

    # E.g. build a map of glyphs number to Unicode
    use Font::FreeType::Face;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    sub face-unicode-map(Font::FreeType::Face $face) {
        my uint16 @to-unicode[$face.num-glyphs];
        my FT_Face $struct = $face.struct;  # get the native face object
        my FT_UInt  $glyph-idx;
        my FT_ULong $char-code = $struct.FT_Get_First_Char( $glyph-idx);
        while $glyph-idx {
            @to-unicode[ $glyph-idx ] = $char-code;
            $char-code = $struct.FT_Get_Next_Char( $char-code, $glyph-idx);
        }
    }

=head1 DESCRIPTION

This class contains the actual bindings to the FreeType library.

Other high level classes in this have a `struct()` accessor, which can be
used, if needed, to gain access to native objects from this library:

=table
  Class | struct() binding | Description
  ------+------------------+------------
  Font::FreeType | L<FT_Library|https://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_Library> | A handle to a freetype library instance
  Font::FreeType::Face | L<FT_Face|https://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_Face> | A Handle to a typographic face object
  Font::FreeType::Glyph | L<FT_GlyphSlot|https://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_GlyphSlot> | A handle to a glyph container
  Font::FreeType::GlyphImage | L<FT_Glyph|https://www.freetype.org/freetype2/docs/reference/ft2-glyph_management.html> | A specific glyph bitmap or outline object
  Font::FreeType::BitMap | L<FT_Bitmap|https://www.freetype.org/freetype2/docs/reference/ft2-bitmap_handling.html> | A rendered bitmap for a glyph
  Font::FreeType::Outline | L<FT_Outline|https://www.freetype.org/freetype2/docs/reference/ft2-outline_processing.html> | A scalable glyph outline

=end pod

#`{{

=cut
}}

use NativeCall;
use NativeCall::Types;
use LibraryMake;
use Font::FreeType::Error;
use Font::FreeType::Native::Types;

# library bindings
our $ftlib;
BEGIN {
    if $*VM.config<dll> ~~ /dll/ {
        $ftlib = 'libfreetype';
    } else {
        $ftlib = ('freetype', v6);
    }
}

# additional C bindings
our $ft-p6-lib;
BEGIN {
    my $so = get-vars('')<SO>;
    $ft-p6-lib = ~(%?RESOURCES{"lib/libft6$so"});
}

constant FT_Byte   = uint8;
constant FT_Encoding = uint32;
constant FT_Fixed  = long;
constant FT_Long   = long;
constant FT_Short  = int16;
constant FT_String = Str;
constant FT_UShort = uint16;
constant FT_Glyph_Format = int32; # enum
constant FT_Render_Mode = int32; # enum

class FT_Face is repr('CStruct') {...}
class FT_Library is repr('CPointer') {...}

#| A rendered bit-map
class FT_Bitmap is repr('CStruct') is export {
    has uint32  $.rows;          # The number of bitmap rows.
    has uint32  $.width;         # The number of pixels in bitmap row.
    has int32   $.pitch;         # The pitch's absolute value is the number of bytes taken by one bitmap row, including padding. However, the pitch is positive when the bitmap has a ‘down’ flow, and negative when it has an ‘up’ flow. In all cases, the pitch is an offset to add to a bitmap pointer in order to go down one row.
    has Pointer[uint8] $.buffer; # bitmap buffer
    has uint16  $.num-grays;     # This field is only used with FT_PIXEL_MODE_GRAY; it gives the number of gray levels used in the bitmap.
    has uint8   $.pixel-mode;    # The pixel mode, i.e., how pixel bits are stored. See FT_Pixel_Mode for possible values.
    has uint8   $.palette-mode;  # Intended for paletted pixel modes. Not used currently.
    has Pointer $.palette;       # Intended for paletted pixel modes. Not used currently.

    #| initialize a bitmap structure.
    method FT_Bitmap_Init
        is native($ftlib) {*};

    #| make a copy of the bitmap
    method clone(FT_Library $library) {
        my FT_Bitmap $bitmap .= new;
        ft-try({ $library.FT_Bitmap_Copy(self, $bitmap); });
        $bitmap;
    }
}

#| This structure models the metrics of a bitmap strike (i.e., a set of glyphs for a given point size and resolution) in a bitmap font. It is used for the ‘available_sizes’ field of FT_Face.
class FT_Bitmap_Size is repr('CStruct') is export {
    has FT_Short  $.height;
    has FT_Short  $.width;

    has FT_Pos    $.size;

    has FT_Pos    $.x-ppem;
    has FT_Pos    $.y-ppem;
}

#| A handle to a character map (usually abbreviated to ‘charmap’). A charmap is used to translate character codes in a given encoding into glyph indexes
class FT_CharMap is export is repr('CStruct') is export {
    has FT_Face      $.face;
    has FT_Encoding  $.encoding;
    has FT_UShort    $.platform-id;
    has FT_UShort    $.encoding-id;
}

class FT_Generic is repr('CStruct') {
    has Pointer       $.data;
    has Pointer       $.finalizer;
}

#| A structure used to hold an outline's bounding box, i.e., the coordinates of its extrema in the horizontal and vertical directions.
class FT_BBox is repr('CStruct') is export {
    has FT_Pos  ($.x-min, $.y-min);
    has FT_Pos  ($.x-max, $.y-max);
    #| returns [x-min, y-min, x-max, y-max]
    method Array { [$!x-min, $!y-min, $!x-max, $!y-max] }
 }

#| A structure to model the metrics of a single glyph. The values are expressed in 26.6 fractional pixel format; if the flag FT_LOAD_NO_SCALE has been used while loading the glyph, values are expressed in font units instead.
class FT_Glyph_Metrics is repr('CStruct') {
    has FT_Pos  $.width;
    has FT_Pos  $.height;

    has FT_Pos  $.hori-bearing-x;
    has FT_Pos  $.hori-bearing-y;
    has FT_Pos  $.hori-advance;

    has FT_Pos  $.vert-bearing-x;
    has FT_Pos  $.vert-bearing-y;
    has FT_Pos  $.vert-advance;
}

#| A simple structure used to store a 2D vector; coordinates x and y are of the FT_Pos type.
class FT_Vector is repr('CStruct') is export {
    has FT_Pos  $.x;
    has FT_Pos  $.y;
 }

#| A scalable glyph outline
class FT_Outline is repr('CStruct') is export {
    has uint16       $.n-contours;       # number of contours in glyph
    has uint16       $.n-points;         # number of points in the glyph

    has Pointer[FT_Vector]  $.points;    # the outline's points
    has Pointer[uint8]      $.tags;      # the points flags
    has Pointer[uint16]     $.contours;  # the contour end points
    has int32               $.flags;     # outline masks

    method FT_Outline_Copy(FT_Outline $target)
        returns FT_Error is native($ftlib) {*};

    method FT_Outline_Get_BBox(FT_BBox $bbox)
        returns FT_Error is native($ftlib) {*};

    method FT_Outline_Embolden(FT_Pos $strength)
        returns FT_Error is native($ftlib) {*};

    method clone(FT_Library $library) {
        my FT_Outline $outline .= new;
        ft-try({ $library.FT_Outline_New( self.n-points, self.n-contours, $outline) });
        ft-try({ self.FT_Outline_Copy($outline) });
        $outline;
    }
}

class FT_SubGlyph is repr('CPointer') { }
class FT_Slot_Internal is repr('CPointer') { }
class FT_Size_Internal is repr('CPointer') { }

#| The size metrics structure gives the metrics of a size object.
class FT_Size_Metrics is repr('CStruct') {
    has FT_UShort  $.x-ppem;      # horizontal pixels per EM
    has FT_UShort  $.y-ppem;      # vertical pixels per EM

    has FT_Fixed   $.x-scale;     # scaling values used to convert font
    has FT_Fixed   $.y-scale;     # units to 26.6 fractional pixels

    has FT_Pos     $.ascender;    # ascender in 26.6 frac. pixels
    has FT_Pos     $.descender;   # descender in 26.6 frac. pixels
    has FT_Pos     $.height;      # text height in 26.6 frac. pixels
    has FT_Pos     $.max-advance; # max horizontal advance, in 26.6 pixels
  }

#| FreeType root size class structure. A size object models a face object at a given size.
class FT_Size is repr('CStruct') {
    has FT_Face           $.face;      # parent face object
    has FT_Generic        $.generic;   # generic pointer for client uses
    has FT_Size_Metrics   $.metrics;   # size metrics
    has FT_Size_Internal  $.internal;
}

#| The root glyph structure contains a given glyph image plus its advance width in 16.16 fixed-point format.
class FT_Glyph is repr('CStruct') is export {
    has FT_Library        $.library;
    has Pointer           $.class;
    has FT_Glyph_Format   $.format;
    has FT_Vector         $.advance;

    #| Return a glyph's ‘control box’. The control box encloses all the outline's points, including Bézier control points. Though it coincides with the exact bounding box for most glyphs, it can be slightly larger in some situations (like when rotating an outline that contains Bézier outside arcs).
    #|
    #| Computing the control box is very fast, while getting the bounding box can take much more time as it needs to walk over all segments and arcs in the outline.
    method FT_Glyph_Get_CBox(
        FT_UInt $bbox-mode,
        FT_BBox $bbox
        )
        is native($ftlib) {*};

    #| Destroy a given glyph.
    method FT_Done_Glyph
        returns FT_Error is native($ftlib) {*};
}

#| A handle to an object used to model a bitmap glyph image. This is a sub-class of FT_Glyph
class FT_BitmapGlyph is repr('CStruct') is FT_Glyph is export is rw {
    has FT_Int            $.left;
    has FT_Int            $.top;
    HAS FT_Bitmap         $.bitmap;
    method !bitmap-pointer
        is native($ft-p6-lib)
        is symbol('ft_glyph_bitmap')
        returns Pointer[FT_Bitmap]
    {*}
    method bitmap { self!bitmap-pointer.deref }
}

#| A structure used for bitmap glyph images. This is a sub-class of FT_Glyph
class FT_OutlineGlyph is FT_Glyph is repr('CStruct') is export {
    HAS FT_Outline        $.outline;
    method !outline-pointer
        is native($ft-p6-lib)
        is symbol('ft_glyph_outline')
        returns Pointer[FT_Outline]
    {*}
    method outline { self!outline-pointer.deref }
}

#| A handle to a given ‘glyph slot’. A slot is a container that can hold any of the glyphs contained in its parent face.
#| 
#| In other words, each time you call FT_Load_Glyph or FT_Load_Char, the slot's content is erased by the new glyph data, i.e., the glyph's metrics, its image (bitmap or outline), and other control information.
class FT_GlyphSlot is repr('CStruct') is export {
    has FT_Library        $.library;
    has FT_Face           $.face;
    has FT_GlyphSlot      $.next;
    has FT_UInt           $.reserved;       # retained for binary compatibility
    HAS FT_Generic        $.generic;

    HAS FT_Glyph_Metrics  $.metrics;
    has FT_Fixed          $.linear-hori-advance;
    has FT_Fixed          $.linear-vert-advance;
    HAS FT_Vector         $.advance;

    has FT_Glyph_Format   $.format;

    HAS FT_Bitmap         $.bitmap;
    has FT_Int            $.bitmap-left;
    has FT_Int            $.bitmap-top;

    HAS FT_Outline        $.outline;

    has FT_UInt           $.num_subglyphs;
    has FT_SubGlyph       $.subglyphs;

    has Pointer           $.control-data;
    has long              $.control-len;

    has FT_Pos            $.lsb-delta;
    has FT_Pos            $.rsb-delta;

    has Pointer           $.other;

    has FT_Slot_Internal  $.internal;

    #| Convert a given glyph image to a bitmap. It does so by inspecting the glyph image format, finding the relevant renderer, and invoking it.
    method FT_Render_Glyph(
        FT_Render_Mode $render-mode )
    returns FT_Error is native($ftlib) {*};

    #| A function used to extract a glyph image from a slot. Note that the created FT_Glyph object must be released with FT_Done_Glyph.
    method FT_Get_Glyph(
        Pointer[FT_Glyph] $glyph-p is rw )
    returns FT_Error is native($ftlib) {*};

    ## Work-around for Rakudo RT #132222 - iffy HAS accessor
    method !metrics-pointer
        is native($ft-p6-lib)
        is symbol('ft_glyphslot_metrics')
        returns Pointer[FT_Glyph_Metrics]
    {*}
    method metrics { self!metrics-pointer.deref }
}

#| The TrueType and OpenType specifications allow the inclusion of a special names table (‘name’) in font files. This table contains textual (and internationalized) information regarding the font, like family name, copyright, version, etc.
class FT_SfntName is repr('CStruct') is export {
    has FT_UShort  $.platform-id;
    has FT_UShort  $.encoding-id;
    has FT_UShort  $.language-id;
    has FT_UShort  $.name-id;

    has Pointer[FT_Byte]   $.string;      # this string is *not* null-terminated!
    has FT_UInt   $.string-len;           # in bytes
}

#| A handle to a typographic face object. A face object models a given typeface, in a given style.
#|
#| Note: A face object also owns a single FT_GlyphSlot object, as well as one or more FT_Size objects.
class FT_Face is export {
    has FT_Long           $.num-faces;
    has FT_Long           $.face-index;

    has FT_Long           $.face-flags;
    has FT_Long           $.style-flags;

    has FT_Long           $.num-glyphs;

    has FT_String         $.family-name;
    has FT_String         $.style-name;

    has FT_Int            $.num-fixed-sizes;
    has Pointer[FT_Bitmap_Size]   $.available-sizes;

    has FT_Int            $.num-charmaps;
    has Pointer[FT_CharMap]       $.charmaps;

    HAS FT_Generic        $.generic;
##
##    /*# The following member variables (down to `underline-thickness') */
##    /*# are only relevant to scalable outlines; cf. @FT_Bitmap_Size    */
##    /*# for bitmap fonts.                                              */
    HAS FT_BBox           $.bbox;

    has FT_UShort         $.units-per-EM;
    has FT_Short          $.ascender;
    has FT_Short          $.descender;
    has FT_Short          $.height;

    has FT_Short          $.max-advance-width;
    has FT_Short          $.max-advance-height;

    has FT_Short          $.underline-position;
    has FT_Short          $.underline-thickness;

    has FT_GlyphSlot      $.glyph;
    has FT_Size           $.size;
    has FT_CharMap        $.charmap;

    #| Return true if a given face provides reliable PostScript glyph names. 
    method FT_Has_PS_Glyph_Names(  )
        returns FT_Int is native($ftlib) {*};

    #| Retrieve the ASCII PostScript name of a given face, if available. This only works with PostScript, TrueType, and OpenType fonts.
    method FT_Get_Postscript_Name(  )
        returns Str is native($ftlib) {*};

    #| Retrieve the number of name strings in the SFNT ‘name’ table.
    method FT_Get_Sfnt_Name_Count(  )
        returns FT_UInt is native($ftlib) {*};

    #| Retrieve a string of the SFNT ‘name’ table for a given index.
    method FT_Get_Sfnt_Name(
        FT_UInt $index,
        FT_SfntName $sfnt)
    returns FT_Error is native($ftlib) {*};

    #| Retrieve the ASCII name of a given glyph in a face.
    method FT_Get_Glyph_Name(
        FT_UInt $glyph-index,
        buf8    $buffer,
        FT_UInt $buffer-max )
    returns FT_Error is native($ftlib) {*};

    #| Return the glyph index of a given character code. This function uses the currently selected charmap to do the mapping.
    method FT_Get_Char_Index(
        FT_ULong  $charcode )
    returns FT_UInt is native($ftlib) {*};

    #| Return the glyph index of a given glyph name.
    method FT_Get_Name_Index(
        FT_String  $glyph-name )
    returns FT_UInt is native($ftlib) {*};

    #| Load a glyph into the glyph slot of a face object.
    method FT_Load_Glyph(
        FT_UInt   $glyph-index,
        FT_Int32  $load-flags )
    returns FT_Error is native($ftlib) {*};

    #| Load a glyph into the glyph slot of a face object, accessed by its character code.
    method FT_Load_Char(
        FT_ULong  $char-code,
        FT_Int32  $load-flags )
    returns FT_Error is native($ftlib) {*};

    #| Return the first character code in the current charmap of a given face, together with its corresponding glyph index.
    method FT_Get_First_Char(
        FT_UInt  $agindex is rw )
    returns FT_UInt is native($ftlib) {*};

    #| Return the next character code in the current charmap of a given face following the value ‘char_code’, as well as the corresponding glyph index.
    method FT_Get_Next_Char(
        FT_UInt  $char-code,
        FT_UInt  $agindex is rw )
    returns FT_UInt is native($ftlib) {*};

    #| Call FT_Request_Size to request the nominal size (in points).
    method FT_Set_Char_Size(
        FT_F26Dot6  $char-width,
        FT_F26Dot6  $char-height,
        FT_UInt     $horz-resolution,
        FT_UInt     $vert-resolution )
    returns FT_Error is native($ftlib) {*};

    #| Call FT_Request_Size to request the nominal size (in pixels).
    method FT_Set_Pixel_Sizes(
        FT_UInt  $char-width,
        FT_UInt  $char-height )
    returns FT_Error is native($ftlib) {*};

    #| Return the kerning vector between two glyphs of the same face.
    method FT_Get_Kerning(
        FT_UInt     $left-glyph,
        FT_UInt     $right-glyph,
        FT_UInt     $kern-mode,
        FT_Vector   $kerning)
    returns FT_Error is native($ftlib) {*};

    #| Return a string describing the format of a given face. Possible values are ‘TrueType’, ‘Type 1’, ‘BDF’, ‘PCF’, ‘Type 42’, ‘CID Type 1’, ‘CFF’, ‘PFR’, and ‘Windows FNT’.
    method FT_Get_Font_Format
        returns Str
        is export
        is symbol('FT_Get_X11_Font_Format') # for FreeType < v2.0.0 compat
        is native($ftlib) {*};

    #| A counter gets initialized to 1 at the time an FT_Face structure is created. This function increments the counter. FT_Done_Face then only destroys a face if the counter is 1, otherwise it simply decrements the counter.
    method FT_Reference_Face
        returns FT_Error
        is export
        is native($ftlib) {*};

    #| Discard a given face object, as well as all of its child slots and sizes.
    method FT_Done_Face
        returns FT_Error
        is export
        is native($ftlib) {*};
}

#| A handle to a FreeType library instance. Each ‘library’ is completely independent from the others; it is the ‘root’ of a set of objects like fonts, faces, sizes, etc.
#|
#| It also embeds a memory manager (see FT_Memory), as well as a scan-line converter object (see FT_Raster).
#|
#|In multi-threaded applications it is easiest to use one ‘FT_Library’ object per thread. In case this is too cumbersome, a single ‘FT_Library’ object across threads is possible also (since FreeType version 2.5.6), as long as a mutex lock is used around FT_New_Face and FT_Done_Face.
class FT_Library is export {

    #| Call FT_Open_Face to open a font by its pathname.
    method FT_New_Face(
        Str $file-path-name,
        FT_Long $face-index,
        Pointer[FT_Face] $aface is rw
        )
    returns FT_Error is native($ftlib) {*};

    #| Call FT_Open_Face to open a font that has been loaded into memory.
    method FT_New_Memory_Face(
        Blob[FT_Byte] $buffer,
        FT_Long $buffer-size,
        FT_Long $face-index,
        Pointer[FT_Face] $aface is rw
        )
    returns FT_Error is native($ftlib) {*};

    #| Convert a bitmap object with depth 1bpp, 2bpp, 4bpp, 8bpp or 32bpp to a bitmap object with depth 8bpp, making the number of used bytes line (a.k.a. the ‘pitch’) a multiple of ‘alignment’.
    method FT_Bitmap_Convert(
        FT_Bitmap  $source,
        FT_Bitmap  $target,
        FT_Int     $alignment
        )
    returns FT_Error is native($ftlib) {*};

    #| Copy a bitmap into another one.
    method FT_Bitmap_Copy(
        FT_Bitmap $source,
        FT_Bitmap $target,
        )
        returns FT_Error is native($ftlib) {*};

    #| Embolden a bitmap. The new bitmap will be about ‘xStrength’ pixels wider and ‘yStrength’ pixels higher. The left and bottom borders are kept unchanged.
    method FT_Bitmap_Embolden(
        FT_Bitmap $bitmap,
        FT_Pos $x-strength,
        FT_Pos $y-strength,
        )
        returns FT_Error is native($ftlib) {*};

    #| Destroy a bitmap object initialized with FT_Bitmap_Init.
    method FT_Bitmap_Done(
        FT_Bitmap  $bitmap
        )
    returns FT_Error is native($ftlib) {*};

    #| Create a new outline of a given size.
    method FT_Outline_New(
        FT_UInt    $num-points,
        FT_Int     $num-contours,
        FT_Outline $aoutline,
        )
    returns FT_Error is native($ftlib) {*};

    #| Destroy an outline created with FT_Outline_New.
    method FT_Outline_Done(
        FT_Outline  $outline
        )
    returns FT_Error is native($ftlib) {*};

    #| Return the version of the FreeType library being used.
    method FT_Library_Version(
        FT_Int $major is rw,
        FT_Int $minor is rw,
        FT_Int $patch is rw,
        )
    returns FT_Error is native($ftlib) {*};

    #| Destroy a given FreeType library object and all of its children, including resources, drivers, faces, sizes, etc.
    method FT_Done_FreeType
        returns FT_Error
        is export
        is native($ftlib) {*};
}

#| Convert a given glyph object to a bitmap glyph object.
sub FT_Glyph_To_Bitmap(
    Pointer[FT_Glyph] $the-glyph is rw,
    FT_Render_Mode $mode,
    FT_Vector $origin,
    FT_Bool $destroy,
    ) returns FT_Error
        is export
        is native($ftlib) {*};

#| Initialize a new FreeType library object.
sub FT_Init_FreeType(Pointer[FT_Library] $library is rw)
    returns FT_Error
        is export
        is native($ftlib) {*};

our sub memcpy(Pointer, Pointer, size_t) returns Pointer is native($ftlib) {*};

