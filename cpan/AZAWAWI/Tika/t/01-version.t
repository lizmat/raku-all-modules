use v6;
use Test;

plan 1;

use Tika;

my $t = Tika.new;
$t.start;
#TODO find if server is up or not...
sleep 3;

my $version = $t.version;
diag $version.perl;
ok $version ~~ Str, "Version string";

LEAVE {
    $t.stop if $t.defined;
}
