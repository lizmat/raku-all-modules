use v6;
use Font::FreeType;

sub MAIN(Str $filename, Str $char is copy, Numeric $size? is copy, Str :$save-as) {

    my $dpi = 100;

    my $face = Font::FreeType.new.face($filename);

    # If the size wasn't specified, and it's a bitmap font, then leave the size
    # to the default, which will be right.
    if $face.is-scalable || $size {
        $size ||= 72;
        $face.set-char-size($size, $size, $dpi, $dpi);
    }

    # Accept character codes in hex or decimal, otherwise assume it's the
    # actual character itself.
    $char = :16($char).chr
        if $char ~~ /^(<xdigit>**2..*)$/;

    my $glyph = $face.glyph-images($char)[0]
        or die "No glyph for character '$char'.\n";

    my $pgm = $glyph.bitmap.pgm;
    with $save-as {
        .IO.open(:bin, :w).write: $pgm
    }
    else {
        $*OUT.write: $pgm;
    }
}
