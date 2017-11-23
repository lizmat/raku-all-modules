NAME
====

Font::FreeType::GlyphImage - glyph images from font typefaces

SYNOPSIS
========

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    for $face.glyph-images('ABC') {
        # Read vector outline.
        my $svg = .outline.svg;
        my $bitmap = .bitmap;
    }

DESCRIPTION
===========

This class represents individual glyph images (character image) loaded from a font.

### bold(int strength)

Embolden the glyph. This needs to be done before calling either the `bitmap()` or `outline()` methods.

### bitmap(:render-mode])

If the glyph is from a bitmap font, the bitmap image is returned. If it is from a vector font, then it is converted into a bitmap glyph. The outline is rendered into a bitmap at the face's current size.

If antialiasing is used then shades of grey between 0 and 255 may occur. Antialiasing is performed by default, but can be turned off by passing the `FT_RENDER_MODE_MONO` option.

The size of the bitmap can be obtained as follows:

    my $bitmap = $glyph-image.bitmap;
    my $width =  $bitmap.width;
    my $height = $bitmap.height;

The optional `:render-mode` argument can be any one of the following:

  * *FT_RENDER_MODE_NORMAL*

    The default. Uses antialiasing.

  * *FT_RENDER_MODE_LIGHT*

    Changes the hinting algorithm to make the glyph image closer to it's real shape, but probably more fuzzy.

    Only available with Freetype version 2.1.4 or newer.

  * *FT_RENDER_MODE_MONO*

    Render with antialiasing disabled. Each pixel will be either 0 or 255.

  * *FT_RENDER_MODE_LCD*

    Render in colour for an LCD display, with three times as many pixels across the image as normal.

    Only available with Freetype version 2.1.3 or newer.

  * *FT_RENDER_MODE_LCD_V*

    Render in colour for an LCD display, with three times as many rows down the image as normal.

    Only available with Freetype version 2.1.3 or newer.

### bitmap_magick( :render-mode_) **** NYI ****

A simple wrapper around the `bitmap()` method. Renders the bitmap as normal and returns it as an Image::Magick object, which can then be composited onto a larger bitmapped image, or manipulated using any of the features available in Image::Magick.

The image is in the 'gray' format, with a depth of 8 bits.

The left and top distances in pixels are returned as well, in the same way as for the `bitmap()` method.

This method, particularly the use of the left and top offsets for correct positioning of the bitmap, is demonstrated in the _magick.pl_ example program.

### is-outline()

True if the glyph has a vector outline, in which case it is safe to call `outline`. Otherwise, the glyph only has a bitmap image.

### outline()

Returns an object of type [Font::FreeType::Outline](Outline.md)

SEE ALSO
========

[Font::FreeType](../../../README.md), [Font::FreeType::Face](Face.md)

AUTHORS
=======

Geoff Richards <qef@laxan.com>

David Warring <david.warring@gmail>.com (Perl 6 Port)

COPYRIGHT
=========

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
