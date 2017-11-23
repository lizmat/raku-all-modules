[![Build Status](https://travis-ci.org/p6-pdf/Font-FreeType-p6.svg?branch=master)](https://travis-ci.org/p6-pdf/Font-FreeType-p6)

NAME
====

Font::FreeType - read font files and render glyphs from Perl using FreeType2

SYNOPSIS
========

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('t/fonts/Vera.ttf');

    $face.set-char-size(24, 24, 100, 100);
    for $face.glyph-images('ABC') {
        my $outline = .outline;
        my $bitmap = .bitmap;
        # ...
    }

DESCRIPTION
===========

This module allows Perl programs to conveniently read information from font files. All the font access is done through the FreeType2 library, which supports many formats. It can render images of characters with high-quality hinting and anti-aliasing, extract metrics information, and extract the outlines of characters in scalable formats like TrueType.

The quickest way to get started with this library is to look at the examples in the _examples_ directory of the distribution. Full details of the API are contained in this documentation, and (more importantly) the documentation for the Font::FreeType::Face class.

To use the library, first create a Font::FreeType object. This can be used to load **faces** from files, for example:

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');

If your font is scalable (i.e., not a bit-mapped font) then set the size and resolution you want to see it at, for example 24pt at 100dpi:

    $face.set-char-size(24, 24, 100, 100);

Then load particular glyphs (an image of a character):

    for $face.glyph-images('ABC') {
        # Glyphs can be rendered to bitmap images, among other things:
        my $bitmap = .bitmap;
        say $bitmap.Str;
    }

METHODS
=======

Unless otherwise stated, all methods will die if there is an error.

### new()

Create a new 'instance' of the freetype library and return the object. This is a class method, which doesn't take any arguments. If you only want to load one face, then it's probably not even worth saving the object to a variable:

    my $face = Font::FreeType.new.face('Vera.ttf');

### face(_filename_|_blob_, :$index, :load-flags)

Return a Font::FreeType::Face object representing a font face from the specified file or Blob.

The :index option specifies which face to load from the file. It defaults to 0, and since most fonts only contain one face it rarely needs to be provided.

The :load-flags option takes various flags which alter the way glyphs are loaded. The default is usually OK for rendering fonts to bitmap images. When extracting outlines from fonts, be sure to set the FT\_LOAD\_NO\_HINTING flag.

The following load flags are available. They can be combined with the bit-wise OR operator (`|`). The symbols are exported by the module and so will be available once you do `use Font::FreeType`.

  * *FT_LOAD_DEFAULT*

    The same as doing nothing special.

  * *FT_LOAD_CROP_BITMAP*

    Remove extraneous black bits round the edges of bitmaps when loading embedded bitmaps.

  * *FT_LOAD_FORCE_AUTOHINT*

    Use FreeType's own automatic hinting algorithm rather than the normal TrueType one. Probably only useful for testing the FreeType library.

  * *FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH*

    Probably only useful for loading fonts with wrong metrics.

  * *FT_LOAD_IGNORE_TRANSFORM*

    Don't transform glyphs. This module doesn't yet have support for transformations.

  * *FT_LOAD_LINEAR_DESIGN*

    Don't scale the metrics.

  * *FT_LOAD_NO_AUTOHINT*

    Don't use the FreeType auto-hinting algorithm. Hinting with other algorithms (such as the TrueType one) will still be done if possible. Apparently some fonts look worse with the auto-hinter than without any hinting.

    This option is only available with FreeType 2.1.3 or newer.

  * *FT_LOAD_NO_BITMAP*

    Don't load embedded bitmaps provided with scalable fonts. Bitmap fonts are still loaded normally. This probably doesn't make much difference in the current version of this module, as embedded bitmaps aren't deliberately used.

  * *FT_LOAD_NO_HINTING*

    Prevents the coordinates of the outline from being adjusted ('grid fitted') to the current size. Hinting should be turned on when rendering bitmap images of glyphs, and off when extracting the outline information if you don't know at what resolution it will be rendered. For example, when converting glyphs to PostScript or PDF, use this to turn the hinting off.

  * *FT_LOAD_NO_SCALE*

    Don't scale the font's outline or metrics to the right size. This will currently generate bad numbers. To be fixed in a later version.

  * *FT_LOAD_PEDANTIC*

    Raise errors when a font file is broken, rather than trying to work around it.

  * *FT_LOAD_VERTICAL_LAYOUT*

    Return metrics and glyphs suitable for vertical layout. This module doesn't yet provide any intentional support for vertical layout, so this probably won't be much use.

### version()

Returns the version number of the underlying FreeType library being used. If called in scalar context returns a Version consisting of a number in the format "major.minor.patch".

SEE ALSO
========

  * [Font::FreeType::Face](lib/Font/FreeType/Face.md) - Font Properties

  * [Font::FreeType::Glyph](lib/Font/FreeType/Glyph.md) - Glyph properties

    * [Font::FreeType::GlyphImage](lib/Font/FreeType/GlyphImage.md) - Glyph outlines and bitmaps

    * [Font::FreeType::Outline](lib/Font/FreeType/Outline.md) - Scalable glyph images

    * [Font::FreeType::BitMap](lib/Font/FreeType/BitMap.md) - Rendered glyph bitmaps

  * [Font::FreeType::CharMap](lib/Font/FreeType/CharMap.md) - Font Encodings

  * [Font::FreeType::Native](lib/Font/FreeType/Native.md) - Bindings to the FreeType library

    * [Font::FreeType::Native::Types](lib/Font/FreeType/Native/Types.md) - Data types and enumerations

AUTHORS
=======

Geoff Richards <qef@laxan.com>

Ivan Baidakou <dmol@cpan.org>

David Warring <david.warring@gmail>.com (Perl 6 Port)

COPYRIGHT
=========

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
