#!/usr/bin/env perl6

use v6;

use lib 'lib';

use Test;



BEGIN %*ENV<PERL6_TEST_DIE_ON_FAIL> = 1;

# plan 1;

say "testing V4 constants for accuracy";

use-ok("Net::ZMQ::V4::Constants :EVENT, :DEPRECATED , :DRAFT, :RADIO, :IOPLEX, :SECURITY"); 

use Net::ZMQ::V4::Constants :EVENT, :DEPRECATED, :DRAFT, :RADIO, :IOPLEX, :SECURITY;

ok  ZMQ_BACKLOG == 19, 'ZMQ_BACKLOG imported correctlty:' ~ (ZMQ_BACKLOG + 0);
ok  ZMQ_IMMEDIATE == 39, 'ZMQ_IMMEDIATE imported correctly:' ~ (ZMQ_IMMEDIATE + 0);
ok  ZMQ_USE_FD == 89, 'ZMQ_USE_FD imported correctly:' ~ (ZMQ_USE_FD + 0);

eval-dies-ok "ZMQ_HAVE_TIMERS", 'ZMQ_HAVE_TIMERS constant is not imported';


ok  EINPROGRESS == 156384712 + 8, 'ERROR 1 constants:' ~ (EINPROGRESS + 0 );

ok  ENOCOMPATPROTO == 156384712 + 52, 'ERROR 2 constants: ' ~ (ENOCOMPATPROTO + 0)	;

ok ZMQ_HAVE_TIMERS, 'ZMQ_HAVE_TIMERS constant';

ok  ZMQ_IMMEDIATE == 39, 'ZMQ_IMMEDIATE imported correctly:' ~ (ZMQ_IMMEDIATE + 0);
ok  ZMQ_USE_FD == 89, 'ZMQ_USE_FD imported correctly:' ~ (ZMQ_USE_FD + 0);

eval-dies-ok "ZMQ_HAVE_TIMERS", 'ZMQ_HAVE_TIMERS constant is not imported';


done-testing;
