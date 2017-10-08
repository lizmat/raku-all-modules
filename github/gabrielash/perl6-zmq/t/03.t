#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;
use Local::Test;


BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

say "testing errors";

# plan 1;

use-ok  'Net::ZMQ::Error' , 'Module Error can load';
use-ok  'Net::ZMQ::V4::LowLevel' , 'Module V4::LowLevel can load';

use Net::ZMQ::V4::LowLevel;
use Net::ZMQ::Error;


dies-ok { try-say-rethrow( throw-error ); }, "Exception succesful";


done-testing;
