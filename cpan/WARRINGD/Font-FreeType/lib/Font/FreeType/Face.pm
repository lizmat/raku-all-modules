class Font::FreeType::Face {

    constant Px = 64.0;

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    use Font::FreeType::BitMap;
    use Font::FreeType::Glyph;
    use Font::FreeType::NamedInfo;
    use Font::FreeType::CharMap;

    has FT_Face $.struct handles <num-faces face-index face-flags style-flags
        num-glyphs family-name style-name num-fixed-sizes num-charmaps generic
        height max-advance-width max-advance-height size>;
    has UInt $.load-flags = FT_LOAD_DEFAULT;

    submethod TWEAK( :$!struct! ) {
        $!struct.FT_Reference_Face;
    }

    method units-per-EM { self.is-scalable ?? $!struct.units-per-EM !! Mu }
    method underline-position { self.is-scalable ?? $!struct.underline-position !! Mu }
    method underline-thickness { self.is-scalable ?? $!struct.underline-thickness !! Mu }
    method bounding-box { self.is-scalable ?? $!struct.bbox !! Mu }

    method ascender { self.is-scalable ?? $!struct.ascender !! Mu }
    method descender { self.is-scalable ?? $!struct.descender !! Mu }

    subset FontFormat of Str where 'TrueType'|'Type 1'|'BDF'|'PCF'|'Type 42'|'CID Type 1'|'CFF'|'PFR'|'Windows FNT';
    method font-format returns FontFormat {
        $!struct.FT_Get_Font_Format;
    }

    method fixed-sizes {
        my int $n-sizes = self.num-fixed-sizes;
        my $ptr = $!struct.available-sizes;
        my Font::FreeType::BitMap::Size @fixed-sizes;
        (0 ..^ $n-sizes).map: {
            my $struct = $ptr[$_];
            @fixed-sizes.push: Font::FreeType::BitMap::Size.new: :$struct;
        }
        @fixed-sizes;
    }

    method charmap {
        Font::FreeType::CharMap.new: :struct($!struct.charmap);
    }

    method charmaps {
        my int $n-sizes = self.num-charmaps;
        my $ptr = $!struct.charmaps;
        my Font::FreeType::CharMap @charmaps;
        (0 ..^ $n-sizes).map: {
            @charmaps.push: Font::FreeType::CharMap.new: :struct($ptr[$_]);
        }
        @charmaps;
    }

    my class Vector {
        has FT_Vector $.struct;
        method x { $!struct.x / Px }
        method y { $!struct.y / Px }
    }

    method named-infos {
        return Mu unless self.is-scalable;
        my int $n-sizes = $!struct.FT_Get_Sfnt_Name_Count;
        my buf8 $buf .= allocate(256);

        (0 ..^ $n-sizes).map: -> $i {
            my FT_SfntName $sfnt .= new;
            ft-try({ $!struct.FT_Get_Sfnt_Name($i, $sfnt); });
            Font::FreeType::NamedInfo.new: :struct($sfnt);
        }
    }

    method postscript-name { $!struct.FT_Get_Postscript_Name }

    method !flag-set(FT_FACE_FLAG $f) { ?($!struct.face-flags +& $f) }
    method is-scalable { self!flag-set: FT_FACE_FLAG_SCALABLE }
    method has-fixed-sizes { self!flag-set: FT_FACE_FLAG_FIXED_SIZES }
    method is-fixed-width { self!flag-set: FT_FACE_FLAG_FIXED_WIDTH }
    method is-sfnt { self!flag-set: FT_FACE_FLAG_SFNT }
    method has-horizontal-metrics { self!flag-set: FT_FACE_FLAG_HORIZONTAL }
    method has-vertical-metrics { self!flag-set: FT_FACE_FLAG_VERTICAL }
    method has-kerning { self!flag-set: FT_FACE_FLAG_KERNING }
    method has-glyph-names { self!flag-set: FT_FACE_FLAG_GLYPH_NAMES }
    method has-reliable-glyph-names { self.has-glyph-names && ? $!struct.FT_Has_PS_Glyph_Names }
    method is-bold { ?($!struct.style-flags +& FT_STYLE_FLAG_BOLD) }
    method is-italic { ?($!struct.style-flags +& FT_STYLE_FLAG_ITALIC) }

    method !get-glyph-name(UInt $ord) {
        my buf8 $buf .= allocate(256);
        my FT_UInt $index = $!struct.FT_Get_Char_Index( $ord );
        ft-try({ $!struct.FT_Get_Glyph_Name($index, $buf, $buf.bytes); });
        nativecast(Str, $buf);
    }

    multi method glyph-name(Str $char) {
        $.glyph-name($char.ord);
    }
    multi method glyph-name(Int $char-code) {
        self.has-glyph-names
            ?? self!get-glyph-name($char-code)
            !! Mu;
    }

    method forall-chars(&code, Int :$flags = $!load-flags) {
        my FT_UInt  $glyph-idx;
        my $struct = $!struct.glyph;
        my $glyph = Font::FreeType::Glyph.new: :face(self), :$struct;
        $glyph.char-code = $!struct.FT_Get_First_Char( $glyph-idx);

        while $glyph-idx {
            $!struct.FT_Load_Glyph( $glyph-idx, $flags );
            &code($glyph);
            $glyph.char-code = $!struct.FT_Get_Next_Char( $glyph.char-code, $glyph-idx);
        }
    }

    method for-glyphs(Str $text, &code, Int :$flags = $!load-flags) {
        my $struct = $!struct.glyph;
        my $glyph = Font::FreeType::Glyph.new: :face(self), :$struct;
        for $text.ords -> $char-code {
            ft-try({ $!struct.FT_Load_Char( $char-code, $flags ); });
            $glyph.char-code = $char-code;
            &code($glyph);
        }
    }

    method glyph-images(Str $text, Int :$flags = $!load-flags) {
        my Font::FreeType::GlyphImage @glyphs-images;
        self.for-glyphs($text, {
            @glyphs-images.push: .glyph-image;
        }, :$flags);
        @glyphs-images;
    }

    method set-char-size(Numeric $width, Numeric $height, UInt $horiz-res, UInt $vert-res) {
        my FT_F26Dot6 $w = ($width * Px + 0.5).Int;
        my FT_F26Dot6 $h = ($height * Px + 0.5).Int;
        ft-try({ $!struct.FT_Set_Char_Size($w, $h, $horiz-res, $vert-res) });
    }

    method set-pixel-sizes(UInt $width, UInt $height) {
        ft-try({ $!struct.FT_Set_Pixel_Sizes($width, $height) });
    }

    method kerning(Str $left, Str $right, UInt :$mode = FT_KERNING_UNFITTED) {
        my FT_UInt $left-idx = $!struct.FT_Get_Char_Index( $left.ord );
        my FT_UInt $right-idx = $!struct.FT_Get_Char_Index( $right.ord );
        my $vec = FT_Vector.new;
        ft-try({ $!struct.FT_Get_Kerning($left-idx, $right-idx, $mode, $vec); });
        Vector.new: :struct($vec);
    }

    submethod DESTROY {
        ft-try({ $!struct.FT_Done_Face;});
        $!struct = Nil;
    }
}

=begin pod

=head1 NAME

Font::FreeType::Face - font typefaces loaded from Font::FreeType

=head1 SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');

=head1 DESCRIPTION

This class represents a font face (or typeface) loaded from a font file.
Usually a face represents all the information in the font file (such as
a TTF file), although it is possible to have multiple faces in a single
file.

Never 'use' this module directly; the class is loaded automatically from Font::FreeType.  Use the `Font::FreeType.face()`
method to create a new Font::FreeType::Face object from a filename and then use the `forall-chars()` or `for-glyphs()` methods to iterate through the glyphs.

=head1 METHODS

Unless otherwise stated, all methods will die if there is an error.

=head3 ascender()

The height above the baseline of the 'top' of the font's glyphs, scaled to
the current size of the face.

=head3 attach-file(_filename_)   *** NYI ***

Informs FreeType of an ancillary file needed for reading the font.
Hasn't been tested yet.

=head3 font-format()

Return a string describing the format of a given face. Possible values are
‘TrueType’, ‘Type 1’, ‘BDF’, ‘PCF’, ‘Type 42’, ‘CID Type 1’, ‘CFF’, ‘PFR’,
and ‘Windows FNT’.

=head3 face-index()

The index number of the current font face.  Usually this will be
zero, which is the default.  See `Font::FreeType.face()` for how
to load other faces from the same file.

=head3 descender()

The depth below the baseline of the 'bottom' of the font's glyphs, scaled to
the current size of the face.  Actually represents the distance moving up
from the baseline, so usually negative.

=head3 family-name()

A string containing the name of the family this font claims to be from.

=head3 fixed-sizes()

Returns an array of Font::FreeType::BitMap::Size objects which
detail sizes.  Each object has the following available methods:

    =begin item
    I<size>

    Size of the glyphs in points.  Only available with Freetype 2.1.5 or newer.
    =end item

    =begin item
    I<height>

    Height of the bitmaps in pixels.
    =end item

    =begin item
    I<width>

    Width of the bitmaps in pixels.
    =end item

    =begin item
    I<x-res(:dpi)>, I<y-res(:dpi)>

    Resolution the bitmaps were designed for, in dots per inch.
    Only available with Freetype 2.1.5 or newer.
    =end item

    =begin item
    I<x-res(:ppem)>, I<y-res(:ppem)>

    Resolution the bitmaps were designed for, in pixels per em.
    Only available with Freetype 2.1.5 or newer.
    =end item

=head3 glyph-images(str)

Returns an array of [glyphs-images](GlyphImage.md) for the Unicode string.

=head3 forall-chars(_code-ref_)

Iterates through all the characters in the font, and calls _code-ref_
for each of them in turn.  Glyphs which don't correspond to Unicode
characters are ignored.  There is currently no facility for iterating
over all glyphs.

Each time your callback code is called, a [Font::FreeType::Glyph](Glyph.md) object is
passed for the current glyph. For an example see the program _list-characters.pl_ provided in the distribution.

=head3 for-glyphs(str, _code-ref_)

Execute a callback for each glyph in a string.

=head3 has-glyph-names()

True if individual glyphs have names.  If so, the names can be
retrieved with the `name()` method on
[Font::FreeType::Glyph](Glyph.md) objects.

See also `has-reliable-glyph-names()` below.

=head3 has-horizontal-metrics()
=head3 has-vertical-metrics()

These return true if the font contains metrics for the corresponding
directional layout.  Most fonts will contain horizontal metrics, describing
(for example) how the characters should be spaced out across a page when
being written horizontally like English.  Some fonts, such as Chinese ones,
may contain vertical metrics as well, allowing typesetting down the page.

=head3 has-kerning()

True if the font provides kerning information.  See the `kerning()`
method below.

=head3 has-reliable-glyph-names()

True if the font contains reliable PostScript glyph names.  Some
Some fonts contain bad glyph names.

See also `has-glyph-names()` above.

=head3 height()

The line height of the text, i.e. distance between baselines of two
lines of text.

=head3 is-bold()

True if the font claims to be in a bold style.

=head3 is-fixed-width()

True if all the characters in the font are the same width.
Will be true for mono-spaced fonts like Courier.

=head3 is-italic()

Returns true if the font claims to be in an italic style.

=head3 is-scalable()

True if the font has a scalable outline, meaning it can be rendered
nicely at virtually any size.  Returns false for bitmap fonts.

=head3 is-sfnt()

True if the font file is in the 'sfnt' format, meaning it is
either TrueType or OpenType.  This isn't much use yet, but future versions
of this library might provide access to extra information about sfnt fonts.

=head3 kerning(_left-char_, _right-char_, :mode)

Returns a vector for the the suggested kerning adjustment between two glyphs.

For example:

    my $kern = $face.kerning('A', 'V');
    my $kern-distance = $kern.x;

The `mode` option controls how the kerning is calculated, with
the following options available:

=begin item
I<FT_KERNING_DEFAULT>

Grid-fitting (hinting) and scaling are done.  Use this
when rendering glyphs to bitmaps to make the kerning take the resolution
of the output in to account.
=end item

=begin item
I<FT_KERNING_UNFITTED>

Scaling is done, but not hinting.  Use this when extracting
the outlines of glyphs.  If you used the `FT_LOAD_NO_HINTING` option
when creating the face then use this when calculating the kerning.
=end item

=begin item
I<FT_KERNING_UNSCALED>

Leave the measurements in font units, without scaling, and without hinting.
=end item

=head3 number-of-faces()

The number of faces contained in the file from which this one
was created.  Usually there is only one.  See `Font::FreeType.face()`
for how to load the others if there are more.

=head3 number-of-glyphs()

The number of glyphs in the font face.

=head3 postscript-name()

A string containing the PostScript name of the font, or _undef_
if it doesn't have one.

=head3 set-char-size(_width_, _height_, _x-res_, _y-res_)

Set the size at which glyphs should be rendered.  Metrics are also
scaled to match.  The width and height will usually be the same, and
are in points.  The resolution is in dots-per-inch.

When generating PostScript outlines a resolution of 72 will scale
to PostScript points.

=head3 set-pixel-size(_width_, _height_)

Set the size at which bit-mapped fonts will be loaded.  Bitmap fonts are
automatically set to the first available standard size, so this usually
isn't needed.

=head3 style-name()

A string describing the style of the font, such as 'Roman' or
'Demi Bold'.  Most TrueType fonts are just 'Regular'.

=head3 underline-position()
=head3 underline-thickness()

The suggested position and thickness of underlining for the font,
or _undef_ if the information isn't provided.  Currently in font units,
but this is likely to be changed in a future version.

=head3 units-per-EM()

The size of the em square used by the font designer.  This can
be used to scale font-specific measurements to the right size, although
that's usually done for you by FreeType.  Usually this is 2048 for
TrueType fonts.

=head3 charmap()

The current active [charmap](CharMap.md) for this face.

=head3 charmaps()

An array of the [charmaps](CharMap.md) of the face.

=head3 bounding-box()

The outline's bounding box for this face.

=head1 SEE ALSO

[Font::FreeType](../../../README.md),
[Font::FreeType::Glyph](Glyph.md)
[Font::FreeType::GlyphImage](GlyphImage.md)

=head1 AUTHOR

Geoff Richards <qef@laxan.com>

Ivan Baidakou <dmol@cpan.org>

David Warring <david.warring@gmail.com> (Perl 6 Port)

=head1 COPYRIGHT

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring Copyright 2017.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=end pod
