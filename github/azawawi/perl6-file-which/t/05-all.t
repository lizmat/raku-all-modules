use v6;

use Test;
use File::Which;

plan *;

my $test-bin = $*SPEC.catdir('t', 'corpus', $*DISTRO.is-win ?? 'test-bin-win' !! 'test-bin-unix');
ok $test-bin.IO.e, 'Found test-bin';
if $*DISTRO.is-win {
  %*ENV<PATH> ~= ";$test-bin";
} else {
  %*ENV<PATH> ~= ":$test-bin";
}

if $*KERNEL ~~ 'linux' {
  # On linux we need to have an execution bit.
  my $all = $*SPEC.catfile($test-bin, 'all');
  chmod 0o755, $all;
}

my @result = which('all');
like @result[0], rx/all/, 'Found all';
ok @result.defined, 'Found at least one result';

if $*KERNEL ~~ 'linux' {
  # On linux we need to have an execution bit.
  my $zero = $*SPEC.catfile($test-bin, '0');
  chmod 0o755, $zero;
}

my $zero = which '0';
ok $zero.defined, 'Zero is defined';

my $empty-string = which '';
is $empty-string, Any, 'Empty string';

done-testing;
