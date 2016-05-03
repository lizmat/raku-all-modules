use v6;

use Test;
plan *;

my $proc = shell 'perl6-debug-m -DDevel::Trace t/example.p6', :out;
my $captured-output = $proc.out.slurp-rest;

my $answer =  "./t/example.p6:4: print \"Statement 1 at line 4\\n\"\n" ~
              "Statement 1 at line 4\n" ~
	      "./t/example.p6:5: print \"Statement 2 at line 5\\n\"\n" ~
	      "Statement 2 at line 5\n" ~
	      "./t/example.p6:6: print \"Call to sub x returns \", \&x\(\), \" at line 6.\\n\"\n" ~
              "./t/example.p6:21: print \"In sub x at line 21.\\n\"\n" ~
              "In sub x at line 21.\n" ~
	      "./t/example.p6:22: return 13\n" ~
	      "Call to sub x returns 13 at line 6.\n" ~
	      "./t/example.p6:8: if 5 > 3\n" ~
	      "./t/example.p6:9: say \"True\"\n" ~
	      "True\n" ~
	      "./t/example.p6:14: if 6 > 10\n" ~
	      "./t/example.p6:18: exit 0\n";
is $captured-output, $answer, 'Easy check is done';

done-testing;
