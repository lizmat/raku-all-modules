use Test;
use POSIX;

plan 1;

{
  my $gid   = +$*GROUP;
  my $GROUP = getgrgid($gid);
  ok(1, 'Called getgrgid()');
}
