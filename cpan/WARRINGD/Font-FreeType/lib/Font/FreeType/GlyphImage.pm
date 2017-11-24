class Font::FreeType::GlyphImage {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    use Font::FreeType::BitMap;
    use Font::FreeType::Outline;

    has FT_Glyph $.struct handles <top left>;
    has FT_Library $!library;
    has FT_ULong     $.char-code;

    method format { FT_GLYPH_FORMAT($!struct.format) }

    submethod TWEAK(FT_GlyphSlot :$glyph!, :$top, :$left,) {
        my $glyph-p = Pointer[FT_Glyph].new;
        ft-try({ $glyph.FT_Get_Glyph($glyph-p) });
        my FT_Glyph $glyph-image = $glyph-p.deref;

        given $glyph-image {
            when .format == FT_GLYPH_FORMAT_OUTLINE {
                $_ = nativecast(FT_OutlineGlyph, $_);
            }
            when .format == FT_GLYPH_FORMAT_BITMAP {
                $_ = nativecast(FT_BitmapGlyph, $_);
                .top = $top;
                .left = $left;
            }
            default {
                die "unknown glyph image format: {.format}";
            }
        }

        $!library = $glyph.library;
        $!struct := $glyph-image;
    }
    method is-outline {
        .format == FT_GLYPH_FORMAT_OUTLINE with $!struct;
    }
    method outline {
        die "not an outline glyph"
            unless self.is-outline;
        my FT_Outline:D $outline = $!struct.outline;
        my FT_Outline $struct = $outline.clone($!library);
        Font::FreeType::Outline.new: :$!library, :$struct;
    }
    method bold(Int $strength) {
        if self.is-outline {
            my FT_Outline:D $outline = $!struct.outline;
            ft-try({ $outline.FT_Outline_Embolden($strength); });
        }
        elsif self.is-bitmap {
            my FT_Bitmap:D $bitmap = $!struct.bitmap;
            ft-try({ $!library.FT_Bitmap_Embolden($bitmap, $strength, $strength); });
        }
    }

    method is-bitmap {
        .format == FT_GLYPH_FORMAT_BITMAP with $!struct;
    }
    method to-bitmap(
        :$render-mode = FT_RENDER_MODE_NORMAL,
        :$origin = FT_Vector.new,
        Bool :$destroy = True,
        )  {
        my FT_BBox $bbox .= new;
        $!struct.FT_Glyph_Get_CBox(FT_GLYPH_BBOX_PIXELS, $bbox);
        my $struct-p = nativecast(Pointer[FT_Glyph], $!struct);
        ft-try({ FT_Glyph_To_Bitmap($struct-p, +$render-mode, $origin, $destroy); });
        $!struct = nativecast(FT_BitmapGlyph, $struct-p.deref);
        $.left = $bbox.x-min;
        $.top  = $bbox.y-max;
    }
    method bitmap(UInt :$render-mode = FT_RENDER_MODE_NORMAL) {
        self.to-bitmap(:$render-mode)
            unless self.is-bitmap;
        my FT_Bitmap:D $bitmap = $!struct.bitmap;
        my FT_Bitmap $struct = $bitmap.clone($!library);
        my $top = $.top;
        Font::FreeType::BitMap.new: :$!library, :$struct, :$.left, :$top, :$!char-code;
    }

    method DESTROY {
        $!struct.FT_Done_Glyph;
    }
}

=begin pod

=head1 NAME

Font::FreeType::GlyphImage - glyph images from font typefaces

=head1 SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    for $face.glyph-images('ABC') {
        # Read vector outline.
        my $svg = .outline.svg;
        my $bitmap = .bitmap;
    }

=head1 DESCRIPTION

This class represents individual glyph images (character image) loaded from
a font.

=head3 bold(int strength)

Embolden the glyph. This needs to be done before calling either the
`bitmap()` or `outline()` methods.

=head3 bitmap(:render-mode])

If the glyph is from a bitmap font, the bitmap image is returned.  If
it is from a vector font, then it is converted into a bitmap glyph. The
outline is rendered into a bitmap at the face's current size.

If anti-aliasing is used then shades of grey between 0 and 255 may occur.
Anti-aliasing is performed by default, but can be turned off by passing
the `FT_RENDER_MODE_MONO` option.

The size of the bitmap can be obtained as follows:

    my $bitmap = $glyph-image.bitmap;
    my $width =  $bitmap.width;
    my $height = $bitmap.height;

The optional `:render-mode` argument can be any one of the following:

    =begin item
    I<FT_RENDER_MODE_NORMAL>

    The default.  Uses anti-aliasing.
    =end item

    =begin item
    I<FT_RENDER_MODE_LIGHT>

    Changes the hinting algorithm to make the glyph image closer to it's
    real shape, but probably more fuzzy.

    Only available with Freetype version 2.1.4 or newer.
    =end item

    =begin item
    I<FT_RENDER_MODE_MONO>

    Render with anti-aliasing disabled.  Each pixel will be either 0 or 255.
    =end item

    =begin item
    I<FT_RENDER_MODE_LCD>

    Render in colour for an LCD display, with three times as many pixels
    across the image as normal.

    Only available with Freetype version 2.1.3 or newer.
    =end item

    =begin item
    I<FT_RENDER_MODE_LCD_V>

    Render in colour for an LCD display, with three times as many rows
    down the image as normal.

    Only available with Freetype version 2.1.3 or newer.
    =end item

=head3 bitmap_magick( :render-mode_)   **** NYI ****

A simple wrapper around the `bitmap()` method.  Renders the bitmap as
normal and returns it as an Image::Magick object,
which can then be composited onto a larger bit-mapped image, or manipulated
using any of the features available in Image::Magick.

The image is in the 'gray' format, with a depth of 8 bits.

The left and top distances in pixels are returned as well, in the
same way as for the `bitmap()` method.

This method, particularly the use of the left and top offsets for
correct positioning of the bitmap, is demonstrated in the
_magick.pl_ example program.

=head3 is-outline()

True if the glyph has a vector outline, in which case it is safe to
call `outline`. Otherwise, the glyph only has a bitmap image.

=head3 outline()

Returns an object of type [Font::FreeType::Outline](Outline.md)

=head1 SEE ALSO

[Font::FreeType](../../../README.md),
[Font::FreeType::Face](Face.md)

=head1 AUTHORS

Geoff Richards <qef@laxan.com>

David Warring <david.warring@gmail.com> (Perl 6 Port)

=head1 COPYRIGHT

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=end pod
