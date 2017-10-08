use Test;
use POSIX;

plan 4;

{
  my $gid = getgid();

  ok(1, 'Called getgid()');

  ok($gid.defined, '$gid is defined');

  ok($gid.isa(Int), '$gid is an Int');

  ok($gid == +$*GROUP, '$gid matches current $*GROUP');
}
