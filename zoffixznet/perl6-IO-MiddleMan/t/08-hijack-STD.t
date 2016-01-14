use lib 'lib';
use Test;
use IO::MiddleMan;

my $mm = IO::MiddleMan.hijack: $*OUT;
say "Can't see this yet!";
$mm.mode = 'normal';
is $mm.Str, "Can't see this yet!\n", 'captured STDOUT';

$mm = IO::MiddleMan.hijack: $*ERR;
note "testy mactest";
$mm.mode = 'normal';
is $mm.Str, "testy mactest\n", 'captured STDERR';

done-testing;
