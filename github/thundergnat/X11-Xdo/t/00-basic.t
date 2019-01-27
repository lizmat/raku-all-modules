use Test;

#plan 3;

use-ok('X11::libxdo', 'is usable');

use X11::libxdo;
my $xdo = Xdo.new;
is($xdo.^name, 'X11::libxdo::Xdo', 'is an Xdo instance');
isa-ok( $xdo.version, Str, 'returns a version string');

done-testing;
