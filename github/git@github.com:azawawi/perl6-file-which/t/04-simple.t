use v6;

use Test;
use File::Which;

plan *;

is which(''), Any, 'Null-length false result';

is which('non_existent_very_unlinkely_thingy_executable'), Any, 'Positive length false result';

my $test-bin = $*SPEC.catdir('t', 'corpus', $*DISTRO.is-win ?? 'test-bin-win' !! 'test-bin-unix');
ok $test-bin.IO.e, 'Found test-bin';
if $*DISTRO.is-win {
  %*ENV<PATH> ~= ";$test-bin";
} else {
  %*ENV<PATH> ~= ":$test-bin";
}
unless (File::Which::MacOSX || File::Which::Win32) {
  my $test3 = $*SPEC.catfile($test-bin, 'test3');
  chmod 0o755, $test3;
}

if $*KERNEL ~~ 'linux' {
  is which('test3'), $*SPEC.catfile($test-bin, 'test3'), 'Check test3 for Unix';
}

if $*DISTRO.is-win {
  is which('test1').lc, $*SPEC.catfile($test-bin, "test1.exe"), 'Looking for test1.exe';
  is which('test2').lc, $*SPEC.catfile($test-bin, "test2.bat"), 'Looking for test2.bat';
  is which('test3'), Any, 'test3 returns Any';
  chdir($test-bin);
  is which('test1').lc, $*SPEC.catfile($*SPEC.curdir, 'test1.exe'), 'Looking for test1.exe in curdir';
}

done-testing;
