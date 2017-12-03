[![Build Status](https://travis-ci.org/p6-pdf/PDF-Font-p6.svg?branch=master)](https://travis-ci.org/p6-pdf/PDF-Font-p6)

NAME
====

PDF::Font

SYNPOSIS
========

    use PDF::Lite;
    use PDF::Font;
    my $deja = PDF::Font.load-font: :file<t/fonts/DejaVuSans.ttf>;

    # requires fontconfig
    my $deja-vu = PDF::Font.load-font: :name<DejaVuSans>;

    my PDF::Lite $pdf .= new;
    $pdf.add-page.text: {
       .font = $deja;
       .text-position = [10, 600];
       .say: 'Hello, world';
    }
    $pdf.save-as: "/tmp/example.pdf";

DESCRIPTION
===========

This module provdes font handling for [PDF::Lite](PDF::Lite), [PDF::API6](PDF::API6) and other PDF modules.

METHODS
=======

### load-font

A class level method to create a new font object.

#### `PDF::Font.load-font(Str :$file);`

Loads a font file.

parameters:

  * `:$file`

    Font file to load. Currently supported formats are:

        * Open-Type (`.otf`)

        * True-Type (`.ttf`)

        * Postscript (`.pfb`, or `.pfa`)

#### `PDF::Font.load-font(Str :$name);`

    my $vera = PDF::Font.load-font('vera');
    my $deja = PDF::Font.load-font('Deja:weight=bold:width=condensed:slant=italic');

Loads a font by a fontconfig name.

Note: Requires fontconfig to be installed on the system.

parameters:

  * `:$name`

    Name of an installed system font to load.

### find-font

Locates a font-file bya fontconfig name/pattern. Doesn't actually load it.

    my $file = PDF::Font.find-font('Deja:weight=bold:width=condensed:slant=italic');
    say $file;  # /usr/share/fonts/truetype/dejavu/DejaVuSansCondensed-BoldOblique.ttf
    my $font = PDF::Font.load-font( :$file )';

BUGS AND LIMITATIONS
====================

  * Font subsetting is not yet implemented. I.E. fonts are always fully embedded, which may result in large PDF files.
