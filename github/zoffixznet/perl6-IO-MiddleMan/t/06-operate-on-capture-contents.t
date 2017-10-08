use lib 'lib';
use Test;
use IO::MiddleMan;

constant $test-file-name = 'test-file' ~ rand;
END { unlink $test-file-name };

my $fh = $test-file-name.IO.open: :w;
my $mm = IO::MiddleMan.capture: $fh;
$fh.say: 'test', 42;

is-deeply $mm.data, ["test42\n"], '.data has correct data';

$mm.data = ();
is-deeply $mm.data, [], 'overrode .data';

$fh.say: 'test2', 72;
$fh.say: 'test3', 75;
is-deeply $mm.data, ["test272\n", "test375\n"], '.data has correct data';
is "$mm", "test272\ntest375\n";

done-testing;
