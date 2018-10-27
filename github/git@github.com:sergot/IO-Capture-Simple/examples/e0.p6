use v6;
use IO::Capture::Simple;

my $r = capture_stdout { print "OH"; print " HAI", "!"; };

say "RESULT: $r";
