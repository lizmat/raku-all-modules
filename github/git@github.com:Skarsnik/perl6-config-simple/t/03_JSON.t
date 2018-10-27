use Test;

plan 4;

EVAL('my $format="JSON"; my $file = "t/test.json";'~slurp('t/basetest.plt'));

