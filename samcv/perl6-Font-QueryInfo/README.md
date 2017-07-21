[![Build Status](https://travis-ci.org/samcv/perl6-Font-QueryInfo.svg?branch=master)](https://travis-ci.org/samcv/perl6-Font-QueryInfo)

NAME
====

Font::QueryInfo — Queries information about fonts, including name, style, family, foundry, and the character set the font covers.

DESCRIPTION
===========

Easy to use routines query information about the font and return it in a hash. The keys are the names of the properties and the values are the property values.

These are the properties that are available:

    family          String  Font family names
    familylang      String  Languages corresponding to each family
    style           String  Font style. Overrides weight and slant
    stylelang       String  Languages corresponding to each style
    fullname        String  Font full names (often includes style)
    fullnamelang    String  Languages corresponding to each fullname
    slant           Int     Italic, oblique or roman
    weight          Int     Light, medium, demibold, bold or black
    size            Double  Point size
    width           Int     Condensed, normal or expanded
    aspect          Double  Stretches glyphs horizontally before hinting
    pixelsize       Double  Pixel size
    spacing         Int     Proportional, dual-width, monospace or charcell
    foundry         String  Font foundry name
    antialias       Bool    Whether glyphs can be antialiased
    hinting         Bool    Whether the rasterizer should use hinting
    hintstyle       Int     Automatic hinting style
    verticallayout  Bool    Use vertical layout
    autohint        Bool    Use autohinter instead of normal hinter
    globaladvance   Bool    Use font global advance data (deprecated)
    file            String  The filename holding the font
    index           Int     The index of the font within the file
    ftface          FT_Face Use the specified FreeType face object
    rasterizer      String  Which rasterizer is in use (deprecated)
    outline         Bool    Whether the glyphs are outlines
    scalable        Bool    Whether glyphs can be scaled
    scale           Double  Scale factor for point->pixel conversions
    dpi             Double  Target dots per inch
    rgba            Int     unknown, rgb, bgr, vrgb, vbgr, none - subpixel geometry
    lcdfilter       Int     Type of LCD filter
    minspace        Bool    Eliminate leading from line spacing
    charset         CharSet Unicode chars encoded by the font
    lang            String  List of RFC-3066-style languages this font supports
    fontversion     Int     Version number of the font
    capability      String  List of layout capabilities in the font
    embolden        Bool    Rasterizer should synthetically embolden the font
    fontfeatures    String  List of the feature tags in OpenType to be enabled
    prgname         String  String  Name of the running program

Strings return Str, Bool returns Bool's, Int returns Int's, Double's listed above return Rat's. CharSet returns a List of Range objects. The rest all return Str. The exception to this is lang, which returns a set of languages the font supports.

If the property is not defined, it will return a type object of the type which would normally be returned.

**Note:** FreeType v2.11.91 or greater is required for the `charset` property.

### sub font-query-all

```
sub font-query-all(
    IO::Path:D $file, 
    *@except, 
    Bool:D :$suppress-errors = Bool::False, 
    Bool:D :$no-fatal = Bool::False
) returns Mu
```

Queries all of the font's properties. If supplied properties it will query all properties except for the ones given.

### sub font-query-all

```
sub font-query-all(
    Str:D $file, 
    *@except, 
    Bool:D :$suppress-errors = Bool::False, 
    Bool:D :$no-fatal = Bool::False
) returns Mu
```

Queries all of the font's properties and accepts a Str for the filename instead of an IO::Path

### sub font-query

```
sub font-query(
    IO::Path:D $file, 
    *@list, 
    Bool:D :$suppress-errors = Bool::False, 
    Bool:D :$no-fatal = Bool::False
) returns Mu
```

Queries the font for the specified list of properties. Use :suppress-errors to hide all errors and never die or warn (totally silent). Use :no-fatal to warn instead of dying. Accepts an IO::Path object.

### sub font-query

```
sub font-query(
    Str:D $file, 
    *@list, 
    Bool:D :$suppress-errors = Bool::False, 
    Bool:D :$no-fatal = Bool::False
) returns Mu
```

Accepts an string of the font's path.

AUTHOR
======

Samantha McVey <samantham@posteo.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Samantha McVey

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
