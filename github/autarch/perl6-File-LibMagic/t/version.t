use v6;
use lib 'lib';
use Test;

use File::LibMagic;

my $v = File::LibMagic.magic-version;
diag("libmagic version $v");
ok( $v.defined, 'got a version' );

done-testing;
