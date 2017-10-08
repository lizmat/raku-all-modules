use v6;
use lib $*PROGRAM.dirname ~ '/../lib';
use Terminal::Readsecret;

my Timespec $timeout .= new(tv-sec => 5, tv-nsec => 0);
my $password = getsecret("password:", $timeout);
say "your password is: " ~ $password;
