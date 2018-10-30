#!/usr/bin/env perl6

use v6;

use Test;
use Uni63;

plan 4;

is Uni63::enc("\c[CR]\c[LF]"), '_1d_1a', 'encode CRLF';
is Uni63::dec('_1d_1a'), "\c[CR]\c[LF]", 'decode encoded CRLF';
is Uni63::dec(Uni63::enc("\c[CR]\c[LF]")), "\c[CR]\c[LF]", 'round trip CRLF';
is Uni63::enc(Uni63::dec('_1d_1a')), '_1d_1a', 'round trip encoded CRLF';
