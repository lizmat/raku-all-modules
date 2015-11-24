use Test;
use POSIX;

plan 4;

{
  my $uid = getuid();

  ok(1, 'Called getuid()');

  ok($uid.defined, '$uid is defined');

  ok($uid.isa(Int), '$uid is an Int');

  ok($uid == +$*USER, '$uid matches current $*USER');
}
