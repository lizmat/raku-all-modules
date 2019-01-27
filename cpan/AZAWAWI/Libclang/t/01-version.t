use v6;
use Test;

plan 1;

use Libclang;

my $version = Libclang.version;
diag $version.perl;
ok $version ~~ Str, "Version string";
