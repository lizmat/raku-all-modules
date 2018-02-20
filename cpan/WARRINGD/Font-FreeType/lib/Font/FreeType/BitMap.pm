class Font::FreeType::BitMap {

    use NativeCall;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    has FT_Bitmap $!struct handles <rows width pitch num-grays pixel-mode pallette>;
    has FT_Library $!library;
    has Int $.left is required;
    has Int $.top is required;
    has FT_ULong     $.char-code is required;

    submethod TWEAK(:$!struct!, :$!library!) {
        $!top *= 3
            if $!struct.pixel-mode == +FT_PIXEL_MODE_LCD_V;
    }

    constant Dpi = 72.0;
    constant Px = 64.0;

    method size { $!struct.size / Px }
    multi method x-res(:$ppem! where .so) { $!struct.x-ppem / Px }
    multi method x-res(:$dpi!  where .so) { Dpi/Px * $!struct.x-ppem / self.size }
    multi method y-res(:$ppem! where .so) { $!struct.y-ppem / Px }
    multi method y-res(:$dpi!  where .so) { Dpi/Px * $!struct.y-ppem / self.size }

    method convert(UInt :$alignment = 1) {
        my FT_Bitmap $target .= new;
        ft-try({ $!library.FT_Bitmap_Convert($!struct, $target, $alignment); });
        self.new: :$!library, :struct($target), :$!left, :$!top;
    }

    method depth {
        constant @BitsPerPixel = [Mu, 1, 8, 2, 4, 8, 8, 24];
        with $!struct.pixel-mode {
            @BitsPerPixel[$_];
        }
    }

    method pixels(Bool :$color = False) {
        my $buf = $!struct.buffer;
        my \rows = $.rows;
        my \width = $.width;
        my uint8 @pixels[rows;width];
        my uint32 $bits;
        given $.pixel-mode {
            when FT_PIXEL_MODE_GRAY
                | FT_PIXEL_MODE_LCD
                | FT_PIXEL_MODE_LCD_V {
                for ^rows -> int $y {
                    my int $i = $y * $.pitch;
                    for ^width -> int $x {
                        @pixels[$y;$x] = $buf[$i++];
                    }
                }
            }
            when FT_PIXEL_MODE_MONO {
                for ^rows -> int $y {
                    my int $i = $y * $.pitch;
                    for ^width -> int $x {
                        $bits = $buf[$i++]
                            if $x %% 8;
                        @pixels[$y;$x] = $bits +& 0x80 ?? 0xFF !! 0x00;
                        $bits +<= 1;
                    }
                }
            }
            when FT_PIXEL_MODE_GRAY2 {
                for ^rows -> int $y {
                    my int $i = $y * $.pitch;
                    for ^width -> int $x {
                        $bits = $buf[$i++]
                            if $x %% 4;
                        @pixels[$y;$x] = $bits +& 0xC0;
                        $bits +<= 2;
                    }
                }
            }
            when FT_PIXEL_MODE_GRAY4 {
                for ^rows -> int $y {
                    my int $i = $y * $.pitch;
                    for ^width -> int $x {
                        $bits = $buf[$i++]
                            if $x %% 2;
                        @pixels[$y;$x] = $bits +& 0xF0;
                        $bits +<= 4;
                    }
                }
            }
            default {
                die "unsupported pixel mode: $_";
            }
        }
        @pixels;
    }

    method Str {
        return "\n" x $.rows
            unless $.width;
        constant on  = '#'.ord;
        constant off = ' '.ord;
        my buf8 $row .= allocate($.width);
        my $pixbuf = $.pixels;
        my Str @lines;
        for ^$.rows -> $y {
            for ^$.width -> $x {
                $row[$x] = $pixbuf[$y;$x] ?? on !! off;
            }
            @lines.push: $row.decode("latin-1");
        }
        @lines.join: "\n";
    }

    method pgm returns Buf {
        my $pixels = self.pixels;
        my UInt ($ht, $wd) = $pixels.shape.list;
        my Buf $buf = buf8.new: "P5\n$wd $ht\n255\n".encode('latin-1');
        $buf.append: $pixels.list;
        $buf;
    }

    method clone {
        return self unless self.defined;
        my $bitmap = $!struct.clone($!library);
        self.new: :$!library, :struct($bitmap), :$!top, :$!left; 
    }

    method DESTROY {
        ft-try({ $!library.FT_Bitmap_Done($!struct) });
        $!struct = Nil;
        $!library = Nil;
    }

    class Size {
        submethod BUILD(:$!struct) {}
        has FT_Bitmap_Size $!struct is required handles <width height x-ppem y-ppem>;
        method size { $!struct.size / Px }
        multi method x-res(:$ppem! where .so) { $!struct.x-ppem / Px }
        multi method x-res(:$dpi!  where .so) { Dpi/Px * $!struct.x-ppem / self.size }
        multi method y-res(:$ppem! where .so) { $!struct.y-ppem / Px }
        multi method y-res(:$dpi!  where .so) { Dpi/Px * $!struct.y-ppem / self.size }
    }

}

=begin pod
=head1 NAME

Font::FreeType::BitMap - bitmaps from rendered glyphs

=head1 SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    for $face.glyph-images('Hi') {
        print .outline.svg
            if .is-outline;

        # Render into an array of strings, one byte per pixel.
        my $bitmap = .bitmap;
        my $top = $bitmap.top;
        my $left = $bitmap.left;

        # print a string representation
        print $bitmap.Str;
    }

=head1 DESCRIPTION

This class represents the bitmap image of a rendered glyph.

=head1 METHODS

=head3 pixel-mode()

The rendering mode. One of:

    =begin item
    I<FT_PIXEL_MODE_NONE>

    Value 0 is reserved.
    =end item

    =begin item
    I<FT_PIXEL_MODE_MONO>

    A monochrome bitmap, using 1 bit per pixel. Note that pixels are stored in most-significant order (MSB), which means that the left-most pixel in a byte has value 128.
    =end item

    =begin item
    I<FT_PIXEL_MODE_GRAY>

    An 8-bit bitmap, generally used to represent anti-aliased glyph images. Each pixel is stored in one byte. Note that the number of ‘gray’ levels is stored in the ‘num_grays’ field of the FT_Bitmap structure (it generally is 256).
    =end item

    =begin item
    I<FT_PIXEL_MODE_GRAY2>

    A 2-bit per pixel bitmap, used to represent embedded anti-aliased bitmaps in font files according to the OpenType specification. We haven't found a single font using this format, however.
    =end item

    =begin item
    I<FT_PIXEL_MODE_GRAY4>

    A 4-bit per pixel bitmap, representing embedded anti-aliased bitmaps in font files according to the OpenType specification. We haven't found a single font using this format, however.
    =end item

    =begin item
    I<FT_PIXEL_MODE_LCD>

    An 8-bit bitmap, representing RGB or BGR decimated glyph images used for display on LCD displays; the bitmap is three times wider than the original glyph image. See also FT_RENDER_MODE_LCD.
    =end item

    =begin item
    I<FT_PIXEL_MODE_LCD_V>

    An 8-bit bitmap, representing RGB or BGR decimated glyph images used for vertical display on LCD displays; the bitmap is three times taller than the original glyph image. See also FT_RENDER_MODE_LCD.
    =end item

    =begin item
    I<FT_PIXEL_MODE_BGRA>

    An 8-bit bitmap, representing BGRA decimated glyph images used for vertical display on LCD displays; the bitmap is three times taller than the original glyph image. See also FT_RENDER_MODE_LCD.
    =end item

=head3 depth()

The calculated color depth in bits. For example **FT_PIXEL_MODE_GRAY** has a color depth of 8.

=head3 width()

The width of each row, in bytes

=head3 rows()

The number of rows in the image

=head3 pitch()

Used to calculate the padding at the end of each row.

=head3 pixels

Returns a numeric shaped array of dimensions $.width and $height.
Each item represents one pixel of the image, starting from the
top left.  A value of 0 indicates background (outside the
glyph outline), and 255 represents a point inside the outline.

If anti-aliasing is used then shades of grey between 0 and 255 may occur.
Anti-aliasing is performed by default, but can be turned off by passing
the `FT_RENDER_MODE_MONO` option.

=head3 pgm

Renders the bitmap and constructs it into a PGM (portable grey-map) image file,
which it returns as a Buf, suitable for output to a binary file.

The PGM image returned is in the 'binary' format, with one byte per
pixel.  It is not an efficient format, but can be read by many image
manipulation programs.  For a detailed description of the format
see [http://netpbm.sourceforge.net/doc/pgm.html](http://netpbm.sourceforge.net/doc/pgm.html)

The _render-glyph.pl_ example program uses this method.

=head3 Str()

Returns an ASCII display representation of the rendered glyph.

=head3 convert()

produces a new bitmap, re-rendered as eight bit FT_PIXEL_MODE_GRAY.

=head1 AUTHORS

Geoff Richards <qef@laxan.com>

David Warring <david.warring@gmail.com> (Perl 6 Port)

=head1 COPYRIGHT

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring <david.warring@gmail.com>
Copyright 2017.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=end pod
