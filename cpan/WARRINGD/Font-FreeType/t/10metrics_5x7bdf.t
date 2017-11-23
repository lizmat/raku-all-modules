# Information obtained from looking at the BDF file.
use v6;
use Test;
plan 59 + 4 * 1 + 1836 * 1;
use Font::FreeType;
use Font::FreeType::Native::Types;

my Font::FreeType $ft .= new;
# Load the BDF file.
my $bdf = $ft.face: 't/fonts/5x7.bdf';
ok $bdf.defined, 'FreeType.face returns an object';
isa-ok $bdf, (require ::('Font::FreeType::Face')),
    'FreeType.face returns face object';

# Test general properties of the face.
is $bdf.num-faces, 1, '$face.num-faces';
is $bdf.face-index, 0, '$face.face-index';

is $bdf.postscript-name, Str, 'there is no postscript name';
is $bdf.family-name, 'Fixed', '$face->family-name() is right';
is $bdf.style-name, 'Regular', 'no style name, defaults to "Regular"';

my %expected-flags = (
    :has-glyph-names(False),
    :has-horizontal-metrics(True),
    :has-kerning(False),
    :has-reliable-glyph-names(False),
    :has-vertical-metrics(False),
    :is-bold(False),
    :is-fixed-width(True),
    :is-italic(False),
    :is-scalable(False),
    :is-sfnt(False),
);

for %expected-flags.pairs.sort {
    is-deeply $bdf."{.key}"(), .value, "\$face.{.key}";
}

# Some other general properties.
is $bdf.num-glyphs, 1837, '$face.num-glyphs';
is $bdf.units-per-EM, Mu, 'units-per-em() meaningless';
is $bdf.underline-position, Mu, 'underline position meaningless';
is $bdf.underline-thickness, Mu, 'underline thickness meaningless';
is $bdf.ascender, Mu, 'ascender meaningless';
is $bdf.descender, Mu, 'descender meaningless';

# Test getting the set of fixed sizes available.
is $bdf.num-fixed-sizes, 1, 'BDF files have a single fixed size';
my ($fixed-size) = $bdf.fixed-sizes;

is($fixed-size.width, 5, 'fixed size width');
is($fixed-size.height, 7, 'fixed size width');

ok(abs($fixed-size.size - (70 / 722.7 * 72)) < 0.1,
   "fixed size is 70 printer's decipoints");

ok(abs($fixed-size.x-res(:dpi) - 72) < 1, 'fixed size x resolution 72dpi');
ok(abs($fixed-size.y-res(:dpi) - 72) < 1, 'fixed size y resolution 72dpi');
ok(abs($fixed-size.size * $fixed-size.x-res(:dpi) / 72
       - $fixed-size.x-res(:ppem)) < 0.1, 'fixed size x resolution in ppem');
ok(abs($fixed-size.size * $fixed-size.y-res(:dpi) / 72
       - $fixed-size.y-res(:ppem)) < 0.1, 'fixed size y resolution in ppem');

is $bdf.named-infos, Mu, "no named infos for fixed size font";
is $bdf.bounding-box, Mu, "no bounding box for fixed size font";

my $glyph-list-filename = 't/fonts/bdf_glyphs.txt';
my @glyph-list = $glyph-list-filename.IO.lines;
my $i = 0;
$bdf.forall-chars: -> $_ {
    my $line = @glyph-list[$i++];
    die "not enough characters in listing file '$glyph-list-filename'"
        unless defined $line;
    my ($unicode, $name) = split /\s+/, $line;
    $unicode = :16($unicode);
    is .char-code, $unicode, "glyph $unicode char code in foreach-char()";
    # Can't test the name yet because it isn't implemented in FreeType.
    #is .name, $name, "glyph $unicode name in foreach-char";
};

is $i, +@glyph-list, "we aren't missing any glyphs";

subtest {
    plan 2;
    subtest {
        plan 4;
        my $default-cm = $bdf.charmap;
        ok $default-cm;
        is $default-cm.platform-id, 3;
        is $default-cm.encoding-id, 1;
        is $default-cm.encoding, FT_ENCODING_UNICODE;
    }, "default charmap";

    subtest {
        plan 3;
        my $charmaps = $bdf.charmaps;
        ok $charmaps.defined;
        isa-ok $charmaps, Array;
        is +$charmaps, 1;
    }, "available charmaps"

}, "charmaps";

# Test metrics on some particlar glyphs.
my %glyph-metrics = (
    'A' => { name => 'A', advance => 5,
             LBearing => 0, RBearing => 0 },
    '_' => { name => 'underscore', advance => 5,
             LBearing => 0, RBearing => 0 },
    '`' => { name => 'grave', advance => 5,
             LBearing => 0, RBearing => 0 },
    'g' => { name => 'g', advance => 5,
             LBearing => 0, RBearing => 0 },
    '|' => { name => 'bar', advance => 5,
             LBearing => 0, RBearing => 0 },
);

# 4*2 tests.
my $str = %glyph-metrics.keys.sort .join;
$bdf.for-glyphs: $str, -> $glyph {
    my $char = $glyph.Str;
    with %glyph-metrics{$char} {
        # Can't do names until it's implemented in FreeType.
        #is($glyph.name, .<name>,
        #   "name of glyph '$char'");
        is($glyph.horizontal-advance, .<advance>,
           "advance width of glyph '$char'");
        is($glyph.left-bearing, .<LBearing>,
           "left bearing of glyph '$char'");
        is($glyph.right-bearing, .<RBearing>,
           "right bearing of glyph '$char'");
        is($glyph.width, .<advance> - .<LBearing> - .<RBearing>,
           "width of glyph '$char'");
    }
}

# Test kerning.
my %kerning = (
    __ => 0,
    AA => 0,
    AV => 0,
    'T.' => 0,
);

for %kerning.keys.sort {
    my ($left, $right) = .comb;
    my $kern = $bdf.kerning( $left, $right);
    is $kern.x, %kerning{$_}, "horizontal kerning of '$_'";
    is $kern.y, 0, "vertical kerning of '$_'";
}

