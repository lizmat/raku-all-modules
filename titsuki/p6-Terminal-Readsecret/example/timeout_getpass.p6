use v6;
use lib $*PROGRAM.dirname ~ '/../lib';
use Term::Readsecret;

my timespec $timeout .= new(tv_sec => 5, tv_nsec => 0);
my $password = getsecret("password:", $timeout);
say "your password is: " ~ $password;
