use NativeCall;
use Font::FreeType::Native;
use Font::FreeType::Native::Types;

class Font::FreeType::CharMap {
    has FT_CharMap $.struct handles <platform-id encoding-id>;
    method encoding { FT_ENCODING($!struct.encoding) }
}

=begin pod
=head1 NAME

Font::FreeType::CharMap - character map from font typefaces loaded from Font::FreeType

=head1 SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');
    my $charmap = $face.charmap;
    say $charmap.platform-id;
    say $charmap.encoding-id;
    say $charmap.encoding;

=head1 DESCRIPTION

A charmap is used to translate character codes in a given encoding into glyph
indexes for its parent's face. Some font formats may provide several charmaps
per font.

=head1 CONSTANTS

The following encoding constants are exported by default by [Font::FreeType](FreeType.md).
See [freetype documentation](http://www.freetype.org/freetype2/docs/reference/ft2-base_interface.html#FT_Encoding)

- FT_ENCODING_NONE

- FT_ENCODING_UNICODE

- FT_ENCODING_MS_SYMBOL

- FT_ENCODING_SJIS

- FT_ENCODING_GB2312

- FT_ENCODING_BIG5

- FT_ENCODING_WANSUNG

- FT_ENCODING_JOHAB

- FT_ENCODING_ADOBE_LATIN_1

- FT_ENCODING_ADOBE_STANDARD

- FT_ENCODING_ADOBE_EXPERT

- FT_ENCODING_ADOBE_CUSTOM

- FT_ENCODING_APPLE_ROMAN

- FT_ENCODING_OLD_LATIN_2

- FT_ENCODING_MS_SJIS

  Same as FT_ENCODING_SJIS. Deprecated.

- FT_ENCODING_MS_GB2312

  Same as FT_ENCODING_GB2312. Deprecated.

- FT_ENCODING_MS_BIG5

  Same as FT_ENCODING_BIG5. Deprecated.

- FT_ENCODING_MS_WANSUNG

  Same as FT_ENCODING_WANSUNG. Deprecated.

- FT_ENCODING_MS_JOHAB

  Same as FT_ENCODING_JOHAB. Deprecated.

=head1 METHODS

=head3 platform-id

An ID number describing the platform for the following encoding ID. This comes directly from the TrueType specification and should be emulated for other formats.

For details please refer to the TrueType or OpenType specification.

=head3 encoding-id

A platform specific encoding number. This also comes from the TrueType specification and should be emulated similarly.

For details please refer to the TrueType or OpenType specification.

=head3 encoding

A FreeType Encoding tag (constant) identifying the charmap.

=head1 COPYRIGHT

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring <david.warring@gmail.com>
Copyright 2017.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
=end pod
