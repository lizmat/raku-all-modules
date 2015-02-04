use IO::Capture::Simple;

my $in = capture_stdin { $*IN.get(); prompt "input> " } ;

capture_stdin_on($in);
prompt "input2 = ";
capture_stdin_off;

say $in;
