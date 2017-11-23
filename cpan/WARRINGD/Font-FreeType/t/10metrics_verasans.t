# Metrics obtained from Vera.ttf by hand using PfaEdit
# version 08:28 11-Jan-2004 (040111).
#
# 268 chars, 266 glyphs
# weight class 400 (Book), width class medium (100%), line gap 410
# styles (SubFamily) 'Roman'

use v6;
use Test;
plan 63 + 256 * 2;
use Font::FreeType;
use Font::FreeType::Native::Types;

# Load the Vera Sans face.
my Font::FreeType $ft .= new;
# Load the BDF file.
my $vera = $ft.face: 't/fonts/Vera.ttf';
ok $vera.defined, 'FreeType.face returns an object';
isa-ok $vera, (require ::('Font::FreeType::Face')),
    'FreeType.face returns face object';

# Test general properties of the face.
is $vera.num-faces, 1, '$face.num-faces';
is $vera.face-index, 0, '$face.face-index';

is $vera.postscript-name, 'BitstreamVeraSans-Roman', '$face.postscript-name';
is $vera.family-name, 'Bitstream Vera Sans', '$face.family-name';
is $vera.style-name, 'Roman', '$face->style-name';


# Test face flags.
my %expected-flags = (
    :has-glyph-names(True),
    :has-horizontal-metrics(True),
    :has-kerning(True),
    :has-reliable-glyph-names(False),
    :has-vertical-metrics(False),
    :is-bold(False),
    :is-fixed-width(False),
    :is-italic(False),
    :is-scalable(True),
    :is-sfnt(True),
);

for %expected-flags.pairs.sort {
    is-deeply $vera."{.key}"(), .value, "\$face.{.key}";
}

# Some other general properties.
is $vera.num-glyphs, 268, '$face.number-of-glyphs';
is $vera.units-per-EM, 2048, '$face.units-per-em';
my $underline-position = $vera.underline-position;
ok $underline-position <= -213 || $underline-position >= -284, 'underline position';

is $vera.underline-thickness, 143, 'underline thickness';
# italic angle 0
is $vera.ascender, 1901, 'ascender';
is $vera.descender, -483, 'descender';
is $vera.height, 2384, 'height';

# Test getting the set of fixed sizes available.
my @fixed-sizes = $vera.fixed-sizes;
is +@fixed-sizes, 0, 'Vera has no fixed sizes';

subtest {
    plan 2;
    subtest {
        plan 4;
        my $default-cm = $vera.charmap;
        ok $default-cm;
        is $default-cm.platform-id, 3;
        is $default-cm.encoding-id, 1;
        is $default-cm.encoding, FT_ENCODING_UNICODE;
    }, "default charmap";

    subtest {
        plan 3;
        my $charmaps = $vera.charmaps;
        ok $charmaps.defined;
        isa-ok $charmaps, Array;
        is +$charmaps, 2;
    }, "available charmaps"

}, "charmaps";

subtest {
    my $infos = $vera.named-infos;
    ok $infos;
    ok $infos.elems, 22;
    my $copy-info = $infos[0];
    like $copy-info.Str, rx/'Copyright'.*'Bitstream, Inc.'/;
    is $copy-info.language-id, 0;
    is $copy-info.platform-id, 1;
    is $copy-info.name-id, 0;
    is $copy-info.encoding-id, 0;
}, "named-info";

subtest "bounding box" => sub {
    my $bb = $vera.bounding-box;
    ok $bb;
    is $bb.x-min, -375, "x-min is correct";
    is $bb.y-min, -483, "y-min is correct";
    is $bb.x-max, 2636, "x-max is correct";
    is $bb.y-max, 1901, "y-max is correct";
};


# Test iterating over all the characters.  256*2 tests.
# Note that this only gets us 256 glyphs, because there are another 10 which
# don't have corresponding Unicode characters and for some reason aren't
# reported by this, and another 2 which have Unicode characters but no glyphs.
# The expected Unicode codes and names of the glyphs are in a text file.
# TODO - how can we iterate over the whole lot?
my $glyph-list-filename = 't/fonts/vera_glyphs.txt';
my @glyph-list = $glyph-list-filename.IO.lines;
my $i = 0;
$vera.forall-chars: -> $_ {
    my $line = @glyph-list[$i++];
    die "not enough characters in listing file '$glyph-list-filename'"
        unless defined $line;
    my ($unicode, $name) = split /\s+/, $line;
    $unicode = :16($unicode);
    is .char-code, $unicode,
       "glyph $unicode char code in foreach-char()";
    is .name, $name, "glyph $unicode name in foreach-char";
};
is $i, +@glyph-list, "we aren't missing any glyphs";

# Test metrics on some particlar glyphs.
my %glyph-metrics = (
    'A' => { name => 'A', advance => 1401,
             LBearing => 16, RBearing => 17 },
    '_' => { name => 'underscore', advance => 1024,
             LBearing => -20, RBearing => -20 },
    '`' => { name => 'grave', advance => 1024,
             LBearing => 170, RBearing => 375 },
    'g' => { name => 'g', advance => 1300,
             LBearing => 113, RBearing => 186 },
    '|' => { name => 'bar', advance => 690,
             LBearing => 260, RBearing => 260 },
);

# Set the size to match the em size, so that the values are in font units.
$vera.set-char-size(2048, 2048, 72, 72);

# 5*2 tests.
my $chars = %glyph-metrics.keys.sort.join;
$vera.for-glyphs: $chars, -> $glyph {
    my $char = $glyph.Str;
    with %glyph-metrics{$char} {
        is $glyph.name, .<name>,
           "name of glyph '$char'";
        is $glyph.horizontal-advance, .<advance>,
           "advance width of glyph '$char'";
        is $glyph.left-bearing, .<LBearing>,
           "left bearing of glyph '$char'";
        is $glyph.right-bearing, .<RBearing>,
           "right bearing of glyph '$char'";
        is $glyph.width, .<advance> - .<LBearing> - .<RBearing>,
           "width of glyph '$char'";
    }
}

# Test kerning.
my %kerning = (
    __ => 0,
    AA => 57,
    AV => -131,
    'T.' => -243,
);

for %kerning.keys.sort {
    my ($left, $right) = .comb;
    my $kern = $vera.kerning( $left, $right);
    is $kern.x, %kerning{$_}, "horizontal kerning of '$_'";
    is $kern.y, 0, "vertical kerning of '$_'";
}

lives-ok {$vera.set-pixel-sizes(100, 120)}, 'set pixel sizes';

