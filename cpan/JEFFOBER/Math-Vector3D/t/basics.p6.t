use v6.c;
use Test;
use lib 'lib';
use Math::Vector3D;

isa-ok my $vec = vec(42, 10), 'Math::Vector3D', 'ctor';
is $vec.z, 0, 'default value';

is $vec.length-squared, (42 * 42 + 10 * 10), 'length-squared';
is $vec.length.round(0.001), 43.174, 'length';

cmp-ok vec() + vec(1, 1, 1), '==', vec(1, 1, 1), 'add';
cmp-ok vec() + 1, '==', vec(1, 1, 1), 'add scalar';

cmp-ok vec() - vec(1, 1, 1), '==', vec(-1, -1, -1), 'sub';
cmp-ok vec() - 1, '==', vec(-1, -1, -1), 'sub scalar';

cmp-ok vec(10, 10, 10) * vec(10, 10, 10), '==', vec(100, 100, 100), 'mul';
cmp-ok vec(10, 10, 10) * 10, '==', vec(100, 100, 100), 'mul scalar';

cmp-ok vec(10, 10, 10) / vec(5, 5, 5), '==', vec(2, 2, 2), 'div';
cmp-ok vec(10, 10, 10) / 5, '==', vec(2, 2, 2), 'div';

cmp-ok vec(1, 1, 1).negate, '==', vec(-1, -1, -1), 'negate';

cmp-ok vec(1, 2, 3).cross(vec(4, 5, 6)), '==', vec(-3, 6, -3), 'cross';

is vec(3, 3, 3).dot(vec(2, 2, 2)), 18, 'dot';

is-approx vec(3, 3, 3).angle-to(vec(2, 2, 2)), 0.9586, 0.0001, 'angle-to';

is vec(2, 2, 2).distance-to-squared(vec(3, 3, 3)), 3, 'distance-to-squared';

is vec(2, 2, 2).distance-to(vec(3, 3, 3)), sqrt(3), 'distance-to';

subtest 'normalize' => {
  my $len = sqrt 14;
  my $vec = vec(1, 2, 3).normalize;
  is $vec.x, 1 / $len, 'x';
  is $vec.y, 2 / $len, 'y';
  is $vec.z, 3 / $len, 'z';
};

subtest 'set-length' => {
  my $vec = vec 1, 2, 3;
  my $len = $vec.length;
  $vec.set-length(10);
  is $vec.x, 1 / $len * 10, 'x';
  is $vec.y, 2 / $len * 10, 'y';
  is $vec.z, 3 / $len * 10, 'z';
};

subtest 'lerp' => {
  my $v1 = vec 1, 2, 3;
  my $v2 = vec 10, 20, 30;
  $v1.lerp($v2, 10);
  is $v1.x, 1 + ((10 - 1) * 10), 'x';
  is $v1.y, 2 + ((20 - 2) * 10), 'y';
  is $v1.z, 3 + ((30 - 3) * 10), 'z';
};

is vec(1, 2, 3).List, [1, 2, 3], 'List';

done-testing;
