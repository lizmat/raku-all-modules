#!/usr/bin/perl -w
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

        my $path = $outline.svg;

        print "<?xml version='1.0' encoding='UTF-8'?>\n",
        "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\"\n",
        "    \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">\n\n",
        "<svg xmlns='http://www.w3.org/2000/svg' version='1.0'\n",
        "     width='$xmax' height='$ymax'>\n\n",
        # Transformation to flip it upside down and move it back down into
        # the viewport.
        " <g transform='scale(1 -1) translate(0 -$ymax)'>\n",
        "  <path d='$path'\n",
        "        style='fill: #77FFCC; stroke: #000000'/>\n\n",
        " </g>\n",
        "</svg>\n";
    }
}
