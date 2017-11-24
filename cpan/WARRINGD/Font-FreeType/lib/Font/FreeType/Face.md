NAME
====

Font::FreeType::Face - font typefaces loaded from Font::FreeType

SYNOPSIS
========

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');

DESCRIPTION
===========

This class represents a font face (or typeface) loaded from a font file. Usually a face represents all the information in the font file (such as a TTF file), although it is possible to have multiple faces in a single file.

Never 'use' this module directly; the class is loaded automatically from Font::FreeType. Use the `Font::FreeType.face()` method to create a new Font::FreeType::Face object from a filename and then use the `forall-chars()` or `for-glyphs()` methods to iterate through the glyphs.

METHODS
=======

Unless otherwise stated, all methods will die if there is an error.

### ascender()

The height above the baseline of the 'top' of the font's glyphs, scaled to the current size of the face.

### attach-file(_filename_) *** NYI ***

Informs FreeType of an ancillary file needed for reading the font. Hasn't been tested yet.

### font-format()

Return a string describing the format of a given face. Possible values are ‘TrueType’, ‘Type 1’, ‘BDF’, ‘PCF’, ‘Type 42’, ‘CID Type 1’, ‘CFF’, ‘PFR’, and ‘Windows FNT’.

### face-index()

The index number of the current font face. Usually this will be zero, which is the default. See `Font::FreeType.face()` for how to load other faces from the same file.

### descender()

The depth below the baseline of the 'bottom' of the font's glyphs, scaled to the current size of the face. Actually represents the distance moving up from the baseline, so usually negative.

### family-name()

A string containing the name of the family this font claims to be from.

### fixed-sizes()

Returns an array of Font::FreeType::BitMap::Size objects which detail sizes. Each object has the following available methods:

  * *size*

    Size of the glyphs in points. Only available with Freetype 2.1.5 or newer.

  * *height*

    Height of the bitmaps in pixels.

  * *width*

    Width of the bitmaps in pixels.

  * *x-res(:dpi)*, *y-res(:dpi)*

    Resolution the bitmaps were designed for, in dots per inch. Only available with Freetype 2.1.5 or newer.

  * *x-res(:ppem)*, *y-res(:ppem)*

    Resolution the bitmaps were designed for, in pixels per em. Only available with Freetype 2.1.5 or newer.

### glyph-images(str)

Returns an array of [glyphs-images](GlyphImage.md) for the Unicode string.

### forall-chars(_code-ref_)

Iterates through all the characters in the font, and calls _code-ref_ for each of them in turn. Glyphs which don't correspond to Unicode characters are ignored. There is currently no facility for iterating over all glyphs.

Each time your callback code is called, a [Font::FreeType::Glyph](Glyph.md) object is passed for the current glyph. For an example see the program _list-characters.pl_ provided in the distribution.

### for-glyphs(str, _code-ref_)

Execute a callback for each glyph in a string.

### has-glyph-names()

True if individual glyphs have names. If so, the names can be retrieved with the `name()` method on [Font::FreeType::Glyph](Glyph.md) objects.

See also `has-reliable-glyph-names()` below.

### has-horizontal-metrics()

### has-vertical-metrics()

These return true if the font contains metrics for the corresponding directional layout. Most fonts will contain horizontal metrics, describing (for example) how the characters should be spaced out across a page when being written horizontally like English. Some fonts, such as Chinese ones, may contain vertical metrics as well, allowing typesetting down the page.

### has-kerning()

True if the font provides kerning information. See the `kerning()` method below.

### has-reliable-glyph-names()

True if the font contains reliable PostScript glyph names. Some Some fonts contain bad glyph names.

See also `has-glyph-names()` above.

### height()

The line height of the text, i.e. distance between baselines of two lines of text.

### is-bold()

True if the font claims to be in a bold style.

### is-fixed-width()

True if all the characters in the font are the same width. Will be true for mono-spaced fonts like Courier.

### is-italic()

Returns true if the font claims to be in an italic style.

### is-scalable()

True if the font has a scalable outline, meaning it can be rendered nicely at virtually any size. Returns false for bitmap fonts.

### is-sfnt()

True if the font file is in the 'sfnt' format, meaning it is either TrueType or OpenType. This isn't much use yet, but future versions of this library might provide access to extra information about sfnt fonts.

### kerning(_left-char_, _right-char_, :mode)

Returns a vector for the the suggested kerning adjustment between two glyphs.

For example:

    my $kern = $face.kerning('A', 'V');
    my $kern-distance = $kern.x;

The `mode` option controls how the kerning is calculated, with the following options available:

  * *FT_KERNING_DEFAULT*

    Grid-fitting (hinting) and scaling are done. Use this when rendering glyphs to bitmaps to make the kerning take the resolution of the output in to account.

  * *FT_KERNING_UNFITTED*

    Scaling is done, but not hinting. Use this when extracting the outlines of glyphs. If you used the `FT_LOAD_NO_HINTING` option when creating the face then use this when calculating the kerning.

  * *FT_KERNING_UNSCALED*

    Leave the measurements in font units, without scaling, and without hinting.

### number-of-faces()

The number of faces contained in the file from which this one was created. Usually there is only one. See `Font::FreeType.face()` for how to load the others if there are more.

### number-of-glyphs()

The number of glyphs in the font face.

### postscript-name()

A string containing the PostScript name of the font, or _undef_ if it doesn't have one.

### set-char-size(_width_, _height_, _x-res_, _y-res_)

Set the size at which glyphs should be rendered. Metrics are also scaled to match. The width and height will usually be the same, and are in points. The resolution is in dots-per-inch.

When generating PostScript outlines a resolution of 72 will scale to PostScript points.

### set-pixel-size(_width_, _height_)

Set the size at which bit-mapped fonts will be loaded. Bitmap fonts are automatically set to the first available standard size, so this usually isn't needed.

### style-name()

A string describing the style of the font, such as 'Roman' or 'Demi Bold'. Most TrueType fonts are just 'Regular'.

### underline-position()

### underline-thickness()

The suggested position and thickness of underlining for the font, or _undef_ if the information isn't provided. Currently in font units, but this is likely to be changed in a future version.

### units-per-EM()

The size of the em square used by the font designer. This can be used to scale font-specific measurements to the right size, although that's usually done for you by FreeType. Usually this is 2048 for TrueType fonts.

### charmap()

The current active [charmap](CharMap.md) for this face.

### charmaps()

An array of the [charmaps](CharMap.md) of the face.

### bounding-box()

The outline's bounding box for this face.

SEE ALSO
========

[Font::FreeType](../../../README.md), [Font::FreeType::Glyph](Glyph.md) [Font::FreeType::GlyphImage](GlyphImage.md)

AUTHOR
======

Geoff Richards <qef@laxan.com>

Ivan Baidakou <dmol@cpan.org>

David Warring <david.warring@gmail.com> (Perl 6 Port)

COPYRIGHT
=========

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring Copyright 2017.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
