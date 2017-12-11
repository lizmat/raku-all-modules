#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;

BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

# plan 1;

say 'testing packages and constants:'; 

use-ok 'Net::Jupyter::Common';
use-ok 'Net::Jupyter::Messages';
use-ok 'Net::Jupyter::ContextREPL';
use-ok 'Net::Jupyter::EvalError';
use-ok 'Net::Jupyter::Executer';
use-ok 'Net::Jupyter::Messenger';

use Net::Jupyter::Common;
use Net::Jupyter::Messages;
use Net::Jupyter::ContextREPL;
use Net::Jupyter::EvalError;
use Net::Jupyter::Executer;
use Net::Jupyter::Messenger;


pass "loaded...";

done-testing;
