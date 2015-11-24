use Test;
use POSIX;

plan 1;

{
  my $uid = +$*USER;
  my $res = setuid($uid);
  ok(1, 'Called setuid($uid)');
}
