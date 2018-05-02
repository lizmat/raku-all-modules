use v6;
use Test;
plan 53;
use Font::FreeType;
use Font::FreeType::Native::Types;

# Load the Vera Sans face.
my Font::FreeType $ft .= new;
# Load the Postcript file.
my $tnr = $ft.face: 't/fonts/TimesNewRomPS.pfb';
ok $tnr.defined, 'FreeType.face returns an object';
isa-ok $tnr, (require ::('Font::FreeType::Face')),
    'FreeType.face returns face object';

# Test general properties of the face.
is $tnr.num-faces, 1, '$face.num-faces';
is $tnr.face-index, 0, '$face.face-index';

is $tnr.postscript-name, 'TimesNewRomanPS', '$face.postscript-name';
is $tnr.family-name, 'Times New Roman PS', '$face.family-name';
is $tnr.style-name, 'Regular', '$face->style-name';


# Test face flags.
my %expected-flags = (
    :has-glyph-names(True),
    :has-horizontal-metrics(True),
    :has-kerning(False),
    :has-reliable-glyph-names(True),
    :has-vertical-metrics(False),
    :is-bold(False),
    :is-fixed-width(False),
    :is-italic(False),
    :is-scalable(True),
    :is-sfnt(False),
);

for %expected-flags.pairs.sort {
    is-deeply $tnr."{.key}"(), .value, "\$face.{.key}";
}

# Some other general properties.
is $tnr.num-glyphs, 229, '$face.number-of-glyphs';
is $tnr.units-per-EM, 1000, '$face.units-per-em';
my $underline-position = $tnr.underline-position;
ok $underline-position <= -213 || $underline-position >= -284, 'underline position';

is $tnr.underline-thickness, 50, 'underline thickness';
# italic angle 0
is $tnr.ascender, 878, 'ascender';
is $tnr.descender, -216, 'descender';
is $tnr.height, 1200, 'height';

# Test getting the set of fixed sizes available.
my @fixed-sizes = $tnr.fixed-sizes;
is +@fixed-sizes, 0, 'Tnr has no fixed sizes';

subtest {
    plan 2;
    subtest {
        plan 4;
        my $default-cm = $tnr.charmap;
        ok $default-cm;
        is $default-cm.platform-id, 3;
        is $default-cm.encoding-id, 1;
        is $default-cm.encoding, FT_ENCODING_UNICODE;
    }, "default charmap";

    my @charmaps = $tnr.charmaps;
    is +@charmaps, 2, "available charmaps"

}, "charmaps";

subtest "bounding box" => sub {
    my $bb = $tnr.bounding-box;
    ok $bb;
    is $bb.x-min, -167, "x-min is correct";
    is $bb.y-min, -216, "y-min is correct";
    is $bb.x-max, 1009, "x-max is correct";
    is $bb.y-max, 878, "y-max is correct";
};


# Test metrics on some particlar glyphs.
my %glyph-metrics = (
    'A' => { name => 'A', advance => 1479,
             LBearing => 20, RBearing => 50 },
    '_' => { name => 'underscore', advance => 1024,
             LBearing => -17, RBearing => 4 },
    '`' => { name => 'grave', advance => 682,
             LBearing => 116, RBearing => 245 },
    'g' => { name => 'g', advance => 1024,
             LBearing => 56, RBearing => 56 },
    '|' => { name => 'bar', advance => 410,
             LBearing => 160, RBearing => 169 },
);

# Set the size to match the em size, so that the values are in font units.
$tnr.set-char-size(2048, 2048, 72, 72);

# 5*2 tests.
my $chars = %glyph-metrics.keys.sort.join;
$tnr.for-glyphs: $chars, -> $glyph {
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

lives-ok {$tnr.set-pixel-sizes(100, 120)}, 'set pixel sizes';

