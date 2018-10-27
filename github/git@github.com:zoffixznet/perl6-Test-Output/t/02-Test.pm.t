#!perl6

use lib 'lib';
use Test;
use Test::Output;

ok 1, 1;

done-testing;

#my &test-code = sub {
#     EVAL "use Test; is 1, 1; is 1, 2; done-testing";
# };

# my $stderr = "ok 1 -\nnot ok 2 -\n\n# Failed test at -e line 1\n# expected:"
#     ~ " '2'\n#      got: '1'\n1..2\n# Looks like you failed 1 test of 2";

# output-is   &test-code, $stderr;
# output-like &test-code, /^ $stderr $/, 'testing output-like';
# stdout-is   &test-code, '';
# stdout-like &test-code, /^$/;
# stderr-is   &test-code, $stderr;
# stderr-like &test-code, /^ $stderr $/;

# is output-from( &test-code ), $stderr, 'output-from works';
# is stdout-from( &test-code ), '',      'stdout-from works';
# is stderr-from( &test-code ), $stderr, 'stderr-from works';

# # done-testing;
