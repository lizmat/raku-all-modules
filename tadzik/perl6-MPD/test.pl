use v6;
use lib 'lib';
use MPD;

my $a = MPD.new('localhost', 6600);
say "State: {$a.state}";
say $a.current-song;
