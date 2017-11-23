NAME
====

Font::FreeType::Outline - glyph outlines from font typefaces loaded from Font::FreeType

SYNOPSIS
========

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    $face.set-char-size(24, 24, 100, 100);

    $face.for-glyphs, 'A', {
        my $outline = .outline;
        say $outline.svg;
    }

DESCRIPTION
===========

This class represents scalable glyph images; known as outlines.

METHODS
=======

### bbox()

The bounding box of the glyph's outline. This box will enclose all the 'ink' that would be laid down if the outline were filled in. It is calculated by studying each segment of the outline, so may not be particularly efficient.

The bounding box is returned as a list of four values, so the method should be called as follows:

    my $bbox = $outline.bbox();
    my $xmin = $bbox.x-min;

### bold(Int $strength)

Embolden an outline. The new outline will be at most 4 times ‘strength’ pixels wider and higher. You may think of the left and bottom borders as unchanged.

Negative ‘strength’ values to reduce the outline thickness are possible also.

### postscript()

Generate PostScript code to draw the outline of the glyph. More precisely, the output will construct a PostScript path for the outline, which can then be filled in or stroked as you like.

The _glyph-to-eps.pl_ example program shows how to wrap the output in enough extra code to generate a complete EPS file.

If you pass a file-handle to this method then it will write the PostScript code to that file, otherwise it will return it as a string.

### outline.svg()

Turn the outline of the glyph into a string in a format suitable for including in an SVG graphics file, as the `d` attribute of a `path` element. Note that because SVG's coordinate system has its origin in the top left corner the outline will be upside down. An SVG transformation can be used to flip it.

The _glyph-to-svg.pl_ example program shows how to wrap the output in enough XML to generate a complete SVG file, and one way of transforming the outline to be the right way up.

If you pass a file-handle to this method then it will write the path string to that file, otherwise it will return it as a string.

### decompose( :$conic, :$shift, :$delta)

A lower level method to extract a description of the glyph's outline, scaled to the face's current size. It will die if the glyph doesn't have an outline (if it comes from a bitmap font).

It returns a struct of type Font::FreeType::Outline::ft\_shape\_t that describes the rendered outline.

Note: when you intend to extract the outline of a glyph, you most likely want to pass the `FT_LOAD_NO_HINTING` option when creating the face object, or the hinting will distort the outline.

AUTHORS
=======

Geoff Richards <qef@laxan.com>

David Warring <david.warring@gmail>.com (Perl 6 Port)

COPYRIGHT
=========

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.
