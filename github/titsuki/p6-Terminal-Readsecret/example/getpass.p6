use v6;
use lib $*PROGRAM.dirname ~ '/../lib';
use Terminal::Readsecret;

my $password = getsecret("password:" );
say "your password is: " ~ $password;
