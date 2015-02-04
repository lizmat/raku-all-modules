use v6;

BEGIN { @*INC.push: 'lib' }

use MPD;

my $a = MPD.new('localhost', 6600);
say "State: {$a.state}";
say $a.current-song;
