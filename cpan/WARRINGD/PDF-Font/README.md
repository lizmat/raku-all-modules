[![Build Status](https://travis-ci.org/p6-pdf/PDF-Font-p6.svg?branch=master)](https://travis-ci.org/p6-pdf/PDF-Font-p6)

NAME
====

PDF::Font

SYNPOSIS
========

    use PDF::Lite;
    use PDF::Font;
    my $deja = PDF::Font.load-font("t/fonts/DejaVuSans.ttf");

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

    PDF::Font.load-font(Str $font-file);

A class level method to create a new font object from a font file.

parameters:

  * `$font-file`

    Font file to load. Currently supported formats are:

        * Open-Type (`.otf`)

        * True-Type (`.ttf`)

        * True-Type Collections (`.ttc`)

        * Postscript (`.pfb`, or `.pfa`)

BUGS AND LIMITATIONS
====================

  * Font subsetting is not yet implemented. Font are always fully embedded, which may result in large PDF files.
