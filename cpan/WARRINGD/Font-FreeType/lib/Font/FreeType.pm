class Font::FreeType:ver<0.0.9> {

    use v6;
    use NativeCall;
    use Font::FreeType::Face;
    use Font::FreeType::Error;
    use Font::FreeType::Native;
    use Font::FreeType::Native::Types;

    has FT_Library $!library;
    has Bool $!cleanup = False; # temporarily disabled
    our $lock = Lock.new;

    submethod BUILD {
        my $p = Pointer[FT_Library].new;
        ft-try({ FT_Init_FreeType( $p ); });
        $!library = $p.deref;
    }

    submethod DESTROY {
        if $!cleanup {
            $lock.protect: {
                with $!library {
                    ft-try({ .FT_Done_FreeType });
                    $_ = Nil;
                }
            }
        }
    }

    multi method face(Str $file-path-name, Int :$index = 0, |c) {
        my $p = Pointer[FT_Face].new;
        $lock.protect: {
            ft-try({ $!library.FT_New_Face($file-path-name, $index, $p); });
        }
        my FT_Face $struct = $p.deref;
        Font::FreeType::Face.new: :$struct, |c;
    }

    multi method face(Blob $file-buf,
                      Int :$size = $file-buf.bytes,
                      Int :$index = 0,
                      |c
        ) {
        my $p = Pointer[FT_Face].new;
        ft-try({ $!library.FT_New_Memory_Face($file-buf, $size, $index, $p); });
        my FT_Face $struct = $p.deref;
        Font::FreeType::Face.new: :$struct, |c;
    }

    method version returns Version {
        $!library.FT_Library_Version(my FT_Int $major, my FT_Int $minor, my FT_Int $patch);
        Version.new: "{$major}.{$minor}.{$patch}";
    }
}

=begin pod

=head1 NAME

Font::FreeType - read font files and render glyphs from Perl using FreeType2

=head1 SYNOPSIS

    use Font::FreeType;

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('t/fonts/Vera.ttf');

    $face.set-char-size(24, 24, 100, 100);
    for $face.glyph-images('ABC') {
        my $outline = .outline;
        my $bitmap = .bitmap;
        # ...
    }

=head1 DESCRIPTION

This module allows Perl programs to conveniently read information from
font files.  All the font access is done through the FreeType2 library,
which supports many formats.  It can render images of characters with
high-quality hinting and anti-aliasing, extract metrics information, and
extract the outlines of characters in scalable formats like TrueType.

The quickest way to get started with this library is to look at the
examples in the _examples_ directory of the distribution.  Full
details of the API are contained in this documentation, and (more
importantly) the documentation for the
Font::FreeType::Face class.

To use the library, first create a Font::FreeType object.  This can
be used to load **faces** from files, for example:

    my Font::FreeType $freetype .= new;
    my $face = $freetype.face('Vera.ttf');

If your font is scalable (i.e., not a bit-mapped font) then set the size
and resolution you want to see it at, for example 24pt at 100dpi:

    $face.set-char-size(24, 24, 100, 100);

Then load particular glyphs (an image of a character):

    for $face.glyph-images('ABC') {
        # Glyphs can be rendered to bitmap images, among other things:
        my $bitmap = .bitmap;
        say $bitmap.Str;
    }

=head1 METHODS

Unless otherwise stated, all methods will die if there is an error.

=head3 new()

Create a new 'instance' of the freetype library and return the object.
This is a class method, which doesn't take any arguments.  If you only
want to load one face, then it's probably not even worth saving the
object to a variable:

    my $face = Font::FreeType.new.face('Vera.ttf');

=head3 face(_filename_|_blob_, :$index, :load-flags)

Return a Font::FreeType::Face object representing
a font face from the specified file or Blob.

The :index option specifies which face to load from the file.  It
defaults to 0, and since most fonts only contain one face it rarely
needs to be provided.

The :load-flags option takes various flags which alter the way
glyphs are loaded.  The default is usually OK for rendering fonts
to bitmap images.  When extracting outlines from fonts, be sure to
set the FT\_LOAD\_NO\_HINTING flag.

The following load flags are available.  They can be combined with
the bit-wise OR operator (`|`).  The symbols are exported by the
module and so will be available once you do `use Font::FreeType`.

    =begin item
    I<FT_LOAD_DEFAULT>

    The same as doing nothing special.
    =end item

    =begin item
    I<FT_LOAD_CROP_BITMAP>

    Remove extraneous black bits round the edges of bitmaps when loading
    embedded bitmaps.
    =end item

    =begin item
    I<FT_LOAD_FORCE_AUTOHINT>

    Use FreeType's own automatic hinting algorithm rather than the normal
    TrueType one.  Probably only useful for testing the FreeType library.
    =end item

    =begin item
    I<FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH>

    Probably only useful for loading fonts with wrong metrics.
    =end item

    =begin item
    I<FT_LOAD_IGNORE_TRANSFORM>

    Don't transform glyphs.  This module doesn't yet have support for
    transformations.
    =end item

    =begin item
    I<FT_LOAD_LINEAR_DESIGN>

    Don't scale the metrics.
    =end item

    =begin item
    I<FT_LOAD_NO_AUTOHINT>

    Don't use the FreeType auto-hinting algorithm.  Hinting with other
    algorithms (such as the TrueType one) will still be done if possible.
    Apparently some fonts look worse with the auto-hinter than without
    any hinting.

    This option is only available with FreeType 2.1.3 or newer.
    =end item

    =begin item
    I<FT_LOAD_NO_BITMAP>

    Don't load embedded bitmaps provided with scalable fonts.  Bitmap
    fonts are still loaded normally.  This probably doesn't make much
    difference in the current version of this module, as embedded
    bitmaps aren't deliberately used.
    =end item

    =begin item
    I<FT_LOAD_NO_HINTING>

    Prevents the coordinates of the outline from being adjusted ('grid
    fitted') to the current size.  Hinting should be turned on when rendering
    bitmap images of glyphs, and off when extracting the outline
    information if you don't know at what resolution it will be rendered.
    For example, when converting glyphs to PostScript or PDF, use this
    to turn the hinting off.
    =end item

    =begin item
    I<FT_LOAD_NO_SCALE>

    Don't scale the font's outline or metrics to the right size.  This
    will currently generate bad numbers.  To be fixed in a later version.
    =end item

    =begin item
    I<FT_LOAD_PEDANTIC>

    Raise errors when a font file is broken, rather than trying to work
    around it.
    =end item

    =begin item
    I<FT_LOAD_VERTICAL_LAYOUT>

    Return metrics and glyphs suitable for vertical layout.  This module
    doesn't yet provide any intentional support for vertical layout, so
    this probably won't be much use.
    =end item

=head3 version()

Returns the version number of the underlying FreeType library being
used.  If called in scalar context returns a Version consisting of
a number in the format "major.minor.patch".

=head1 SCRIPTS

=head3 font-say

 font-say [--resolution=<Int>] [--kern] [--hint] [--ascend=<Int>] [--descend=<Int>] [--char-spacing=<Int>] [--word-spacing=<Int>] [--bold=<Int>] [--mode=<Mode> (lcd lcd-v light mono normal)] [--verbose] <font-file> <text>

This script displays text as bitmapped characters, using a given font. For example:

 % bin/font-say t/fonts/Vera.ttf 'FreeType!'
 ##########                                     ##############                                       ##
 ##########                                     ##############                                       ##
 ###             ###      ###          ###            ###                      ####         ###      ##
 ###        ########    #######      #######          ###    ###      ###  #########      #######    ##
 ###        ########   #########    #########         ###     ###    ###   ##########    #########   ##
 #########  ####      ####   ###   ####   ###         ###     ###    ###   ####   ####  ####   ###   ##
 #########  ####      ###     ###  ###     ###        ###     ####  ###    ####    ###  ###     ###  ##
 #########  ###       ###########  ###########        ###      ###  ###    ###     ###  ###########  ##
 ###        ###       ###########  ###########        ###      ###  ###    ###     ###  ###########  ##
 ###        ###       ###          ###                ###       ######     ###     ###  ###          ##
 ###        ###       ###          ###                ###       ######     ####    ###  ###
 ###        ###       ####     #   ####     #         ###       #####      ####   ####  ####     #   ##
 ###        ###        #########    #########         ###        ####      ##########    #########   ##
 ###        ###         ########     ########         ###        ####      #########      ########   ##
                         #####        #####                      ###       ### ####        #####
                                                                 ###       ###
                                                              #####        ###
                                                              #####        ###
                                                              ###          ###



=head1 SEE ALSO

=item [Font::FreeType::Face](https://github.com/p6-pdf/Font-FreeType-p6/blob/master/lib/Font/FreeType/Face.md) - Font Properties
=item  [Font::FreeType::Glyph](https://github.com/p6-pdf/Font-FreeType-p6/blob/master/lib/Font/FreeType/Glyph.md) - Glyph properties
=item2    [Font::FreeType::GlyphImage](https://github.com/p6-pdf/Font-FreeType-p6/blob/master/lib/Font/FreeType/GlyphImage.md) - Glyph outlines and bitmaps
=item2    [Font::FreeType::Outline](https://github.com/p6-pdf/Font-FreeType-p6/blob/master/lib/Font/FreeType/Outline.md) - Scalable glyph images
=item2    [Font::FreeType::BitMap](https://github.com/p6-pdf/Font-FreeType-p6/blob/master/lib/Font/FreeType/BitMap.md) - Rendered glyph bitmaps
=item [Font::FreeType::CharMap](https://github.com/p6-pdf/Font-FreeType-p6/blob/master/lib/Font/FreeType/CharMap.md) - Font Encodings
=item [Font::FreeType::Native](https://github.com/p6-pdf/Font-FreeType-p6/blob/master/lib/Font/FreeType/Native.md) - Bindings to the FreeType library
=item2   [Font::FreeType::Native::Types](https://github.com/p6-pdf/Font-FreeType-p6/blob/master/lib/Font/FreeType/Native/Types.md) - Data types and enumerations

=head1 AUTHORS

Geoff Richards <qef@laxan.com>

Ivan Baidakou <dmol@cpan.org>

David Warring <david.warring@gmail.com> (Perl 6 Port)

=head1 COPYRIGHT

Copyright 2004, Geoff Richards.

Ported from Perl 5 to 6 by David Warring <david.warring@gmail.com> Copyright 2017.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=end pod
