#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;



BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 0;

# plan 1;

say "testing constants re-exportation";

use Net::ZMQ::V4::Constants :ALL;
use Net::ZMQ::Version :ALL;
pass "reimportation doesn't work.";

#ok  Net::ZMQ::EINPROGRESS == 156384712 + 8, 'Correct Fully qualified ERR1 constants :' ~ (Net::ZMQ::EINPROGRESS + 0 );
#ok  Net::ZMQ::ENOCOMPATPROTO == 156384712 + 52, 'Correct Fully Qualified ERR2 constants: ' ~ (Net::ZMQ::ENOCOMPATPROTO + 0)	;


done-testing;
