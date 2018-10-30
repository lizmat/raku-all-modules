use v6;
use IO::Capture::Simple;

my $result;
capture_stdout_on($result);

print "OH ";
say "HAI!";

capture_stdout_off;

print "RESULT: $result";
