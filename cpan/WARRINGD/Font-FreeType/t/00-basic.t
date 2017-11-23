use v6;
use Test;
use Font::FreeType;
use Font::FreeType::Face;
use Font::FreeType::Error;
use Font::FreeType::Native;
use Font::FreeType::Native::Types;

my Font::FreeType $freetype;
lives-ok { $freetype .= new }, 'font freetype creation';
my Version $version;
lives-ok { $version = $freetype.version }, 'got version';
note "FreeType2 version is $version";
die "FreeType2 version $version is too old"
    unless $version >= v2.1.1;
my Font::FreeType::Face $face;
lives-ok {$face = $freetype.face('t/fonts/DejaVuSans.ttf') }, 'face creation from file';
is $face.font-format, 'TrueType', 'font format';
is $face.num-faces, 1, 'num-faces';
is $face.family-name, 'DejaVu Sans', 'face family name';
is $face.num-glyphs, 6253, 'num-glyphs';
my $bbox = $face.bounding-box;
ok $bbox.defined, 'got bounding-box';
is $bbox.x-min, -2090, 'bbox.x-min';
is $bbox.x-max, 3673, 'bbox.x-max';
is $bbox.y-min, -948, 'bbox.y-min';
is $bbox.y-max, 2524, 'bbox.y-max';
is $face.units-per-EM, 2048, '.units-per-EM';
is $face.ascender, 1901, '.ascender';
is $face.descender, -483, '.ascender';

lives-ok { $face = $freetype.face('t/fonts/DejaVuSerif.ttf'.IO.slurp(:bin)) }, 'face creation from buffer';
is $face.num-faces, 1, 'num-faces';
is $face.family-name, 'DejaVu Serif', 'face family name';

$face.set-char-size(2048, 2048, 72, 72);
$face.for-glyphs: 'AI', -> $gslot {
    ok $gslot, '.for-glyphs';

    my $g-image1 = $gslot.glyph-image;
    ok $g-image1.outline, '.load-glyph.outline';
    lives-ok {$g-image1.bold(1)}, 'outline bold';

    my $g-image2 = $gslot.glyph-image;
    ok $g-image2.bitmap, '.bitmap';
    lives-ok {$g-image2.bold(1)}, 'bitmap bold';

    ok $g-image1.is-outline, 'outline glyph 1';
    nok $g-image1.is-bitmap, 'outline glyph 2';
    isa-ok $g-image1.outline, Font::FreeType::Outline, 'outline glyph 3';

    nok $g-image2.is-outline, 'bitmap glyph 1';
    ok $g-image2.is-bitmap, 'bitmap glyph 2';
    isa-ok $g-image2.bitmap, Font::FreeType::BitMap, 'bitmap glyph 3';
}

is $face.glyph-name('&'), 'ampersand', 'glyph name';

$face.for-glyphs('A', {
    is .index, 36, '.index';
    is .char-code, 65, '.char-code';
});

lives-ok {$face.DESTROY}, 'face DESTROY';
lives-ok {$freetype.DESTROY}, 'freetype DESTROY';

done-testing;
