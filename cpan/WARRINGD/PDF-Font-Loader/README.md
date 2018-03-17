[![Build Status](https://travis-ci.org/p6-pdf/PDF-Font-Loader-p6.svg?branch=master)](https://travis-ci.org/p6-pdf/PDF-Font-Loader-p6)

NAME
====

PDF::Font::Loader

SYNPOSIS
========

    use PDF::Lite;
    use PDF::Font::Loader;
    my $deja = PDF::Font::Loader.load-font: :file<t/fonts/DejaVuSans.ttf>;

    use PDF::Font::Loader :load-font;
    my $deja = load-font( :file<t/fonts/DejaVuSans.ttf> );

    # requires fontconfig
    use PDF::Font::Loader :load-font. :find-font;
    $deja = load-font( :name<DejaVu>, :slant<italic> );

    my $file = find-font( :name<DejaVu>, :slant<italic> );
    my $deja-vu = load-font: :$file;

    my PDF::Lite $pdf .= new;
    $pdf.add-page.text: {
       .font = $deja;
       .text-position = [10, 600];
       .say: 'Hello, world';
    }
    $pdf.save-as: "/tmp/example.pdf";

DESCRIPTION
===========

This module provdes font loading and handling for [PDF::Lite](PDF::Lite), [PDF::API6](PDF::API6) and other PDF modules.

METHODS
=======

### load-font

A class level method to create a new font object.

#### `PDF::Font::Loader.load-font(Str :$file);`

Loads a font file.

parameters:

  * `:$file`

    Font file to load. Currently supported formats are:

        * Open-Type (`.otf`)

        * True-Type (`.ttf`)

        * Postscript (`.pfb`, or `.pfa`)

#### `PDF::Font::Loader.load-font(Str :$name);`

    my $vera = PDF::Font::Loader.load-font: :name<vera>;
    my $deja = PDF::Font::Loader.load-font: :name<Deja>, :weight<bold>, :width<condensed> :slant<italic>);

Loads a font by a fontconfig name and attributes.

Note: Requires fontconfig to be installed on the system.

parameters:

  * `:$name`

    Name of an installed system font to load.

### find-font

    find-font(Str $family-name,
              Str :$weight,     # thin|extralight|light|book|regular|medium|semibold|bold|extrabold|black|100..900
              Str :$stretch,    # normal|[ultra|extra]?[condensed|expanded]
              Str :$slant,      # normal|oblique|italic
              );

Locates a matching font-file. Doesn't actually load it.

    my $file = PDF::Font::Loader.find-font('Deja', :weight<bold>, :width<condensed>, :slant<italic>);
    say $file;  # /usr/share/fonts/truetype/dejavu/DejaVuSansCondensed-BoldOblique.ttf
    my $font = PDF::Font::Loader.load-font( :$file )';

BUGS AND LIMITATIONS
====================

  * Font subsetting is not yet implemented. I.E. fonts are always fully embedded, which may result in large PDF files.

