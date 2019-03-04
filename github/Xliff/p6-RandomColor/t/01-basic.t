use v6.c;

use Test;

plan 46;

my token fp { (\d+) [ '.' (\d+) ]? }

# Can use RandomColor
use-ok 'RandomColor', 'Can use the RandomColor module';

# Can get a random color
use RandomColor;

ok RandomColor.new, 'Can get a random color';

# Test all formatting options

my $rc;
for <hslarray hsvarray> {
  $rc = RandomColor.new( format => $_ ).list[0];
  ok
    $rc.elems == 3,
    "'$_' format output produces a list with 3 elements";
  ok
    0 <= $rc[0] <= 360,
    'Hue value is within range';
  my @sv-or-sl = $_ eq 'hslarray' ?? <Saturation Light> !! <Saturation Value>;
  for @sv-or-sl.kv -> $k, $v {
    ok 0 <= $rc[$k + 1] <= 100, "{ $v } is within range";
  }
}

$rc = RandomColor.new( format => 'rgbarray' ).list[0];
ok $rc.elems == 3, "'rgbarray' format value produces a list with 3 elements";
for <Red Green Blue>.kv -> $k, $v {
  ok 0 <= $rc[$k] <= 255, "'{$v} value is within range";
}

for <hsv hsl> {
  $rc = RandomColor.new( format => 'hsl' ).list[0];
  ok
    $rc ~~ /'hsl(' (\d+) ',' \s* <fp> ** 2 %% [',' \s*] ')'/,
    "'hsl' format pases parse test";
  ok     0 <= $/[0] <= 360, 'Hue value is within range';
  my @sv-or-sl = $_ eq 'hsl' ?? <Saturation Light> !! <Saturation Value>;
  for @sv-or-sl.kv -> $k, $v {
    ok 0 <= $/<fp>[$k] <= 100, "{$v} value is within range";
  }
}

$rc = RandomColor.new( format => 'hsla' ).list[0];
ok
  $rc ~~ /'hsla(' (\d+) ',' \s* <fp> ** 3 %% [',' \s*] ')'/,
  "'hsla' format passes parse test";
ok     0 <= $/[0] <= 360, 'Hue value is within range';
ok 0 <= $/<fp>[0] <= 100, 'Saturation value is within range';
ok 0 <= $/<fp>[1] <= 100, 'Light value is within range';
ok 0 <= $/<fp>[2] <= 1,   'Alpha value is within range';

$rc = RandomColor.new( format => 'rgb' ).list[0];
ok $rc ~~ /'rgb(' (\d+) ** 3 %% [',' \s*] ')'/,
  "'rgb' format passes parse test";
for <Red Green Blue>.kv -> $k, $v {
  ok 0 <= $/[0][$k] <= 255, "{$v} value is within range";
}

$rc = RandomColor.new( format => 'rgba' ).list[0];
ok $rc ~~ /'rgba(' (\d+) ** 3 %% [',' \s*] <fp> \s* ')'/,
  "'rgba' format passes parse test";
for <Red Green Blue>.kv -> $k, $v {
  ok 0 <= $/[0][$k] <= 255, "{$v} value is within range";
}
ok 0 <= $/<fp> <= 1, 'Alpha value is within range';

$rc = RandomColor.new.list[0];
ok $rc ~~ / '#' <xdigit> ** 6 /, 'Default format passes parse test';

# Test if color output using same seed produces same output
$rc = RandomColor.new( seed => 1 ).list[0];
ok
  $rc eq '#7ed65e',
  'Random color(hex) with seeded value gives expected result.';

$rc = RandomColor.new( seed => 1, format => 'rgb' ).list[0];
ok
  $rc eq 'rgb(126, 214, 94)',
  'Random color(rgb) with seeded value gives expected result.';

$rc = RandomColor.new( seed => 1, format => 'hsl').list[0];
ok
  $rc eq 'hsl(104, 59.51, 60.48)',
  'Random color(hsl) with seeded value gives expected result.';

# Test for hue predominately among R, G, B
for ( ['red', 0],  ['green', 1], ['blue', 2] ) -> $ct {
  $rc = RandomColor.new( hue => $ct[0], count => 5, format => 'rgbarray' );
  skip 'Will not test color predominance due to bug in upstream code', 1;
  # ok
  #   $rc.map( *[ $ct[1] ] ).sum == $rc.map( *.max ).sum,
  #   "Using hue of '{ $ct[0] }', color list is predominately { $ct[0] }";
}

# Test bright
skip 'Will not test brightness due to bug in upstream code.', 1;
# $rc = RandomColor.new(
#   luminosity => 'bright', count => 5, format => 'hslarray'
# ).list;
# ok
#   $rc.map( *[1] ).grep( * < 55 ).elems == 0,
#   'Setting luminosity to bright results in bright colors';


# Test dark
$rc = RandomColor.new(
  luminosity => 'dark', count => 5, format => 'hsvarray'
).list;
ok
  $rc.map( *[1] ).grep( * != 10 ).elems == 0,
  'Setting luminosity to dark results in dark colors';

# Optional test for color support
try require ::('Color');
if ::('Color') !~~ Failure {
  $rc = RandomColor.new( format => 'color', count => 5 ).list;
  ok $rc.all ~~ ::('Color'), 'Color object support is functioning properly';
} else {
  pass 'Color object tests skipped!'
}
