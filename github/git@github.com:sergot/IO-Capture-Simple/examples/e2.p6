use v6;
use IO::Capture::Simple;

my ($out, $err, $in) = capture { print "OUT"; note "ERR"; prompt "IN> " }

say $out, $err, $in;
