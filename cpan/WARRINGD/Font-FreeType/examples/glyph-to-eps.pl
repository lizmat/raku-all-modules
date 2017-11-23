use Font::FreeType;
use Font::FreeType::Native::Types;

sub MAIN(Str $filename, Str $char is copy, UInt :$bold) {

    my $face = Font::FreeType.new.face($filename,
                                       :load-flags(FT_LOAD_NO_HINTING));
    $face.set-char-size(24, 0, 600, 600);

    # Accept character codes in hex or decimal, otherwise assume it's the
    # actual character itself.
    $char = :16($char).chr
        if $char ~~ /^(<xdigit>**2..*)$/;

    $face.for-glyphs: $char, {
        die "Glyph has no outline.\n" unless .is-outline;

        my $outline = .glyph-image.outline;
        $outline.bold($_) with $bold;
        my ($xmin, $ymin, $xmax, $ymax) = $outline.Array;

        print "%\%!PS-Adobe-3.0 EPSF-3.0\n",
        "%%Creator: $*PROGRAM-NAME\n",
        "%%BoundingBox: $xmin $ymin $xmax $ymax\n",
        "%%Pages: 1\n",
        "%\%EndComments\n\n",
        "%\%Page: 1 1\n",
        "gsave newpath\n",
        $outline.postscript,
        "closepath fill grestore\n",
        "%\%EOF\n";
    }
}
