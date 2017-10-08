use lib <lib ../lib>;
use IO::MiddleMan;

my $mm = IO::MiddleMan.hijack: $*OUT;
say "Can't see this yet!";
$mm.mode = 'normal';
say "Want to see what I said?";
say "Well, fine. I said $mm";