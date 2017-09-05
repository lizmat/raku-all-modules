#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

# plan 1;

say 'testing packages and constants:'; 

use-ok 'Net::ZMQ::Version';
use-ok 'Net::ZMQ::V4::Constants';
use-ok 'Net::ZMQ::V4::LowLevel';

use Net::ZMQ::V4::Constants;
use Net::ZMQ::V4::LowLevel; 
use Net::ZMQ::Version; 

pass "loaded...";

ok  ZMQ_VERSION_MAJOR, 'Major Version Number Defined';

ok  version_major() , 'Major Version Number Defined: ' ~ version_major();
like  version(), / \d+ \. \d+ \. \d+ / , 'Version is: ' ~ version();

ok  Net::ZMQ::V4::Constants::EINPROGRESS == 156384712 + 8, 'Correct Fully qualified ERR1 constants :' ~ (Net::ZMQ::V4::Constants::EINPROGRESS + 0 );
ok  Net::ZMQ::V4::Constants::ENOCOMPATPROTO == 156384712 + 52, 'Correct Fully Qualified ERR2 constants: ' ~ (Net::ZMQ::V4::Constants::ENOCOMPATPROTO + 0)	;

ok ZMQ_LOW_LEVEL_FUNCTIONS_TESTED, "Functions tested list available";

done-testing;
