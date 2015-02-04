#!/usr/bin/perl6
use v6;
use Test;
plan 8;

use lib 'lib';
use IDNA::Punycode;

is encode_punycode('abcdef'), 'abcdef', 'abcdef is left unchanged';
is decode_punycode('abcdef'), 'abcdef', 'abcdef is left unchanged';

is encode_punycode('schön'), 'xn--schn-7qa', 'german umlauts encode correctly';
is decode_punycode('xn--schn-7qa'), 'schön', 'german umlauts decode correctly';

is encode_punycode('ยจฆฟคฏข'), 'xn--22cdfh1b8fsa', 'unicode encodes to a..z0..9 only';
is decode_punycode('xn--22cdfh1b8fsa'), 'ยจฆฟคฏข', 'unicode roundtrips okay';

is encode_punycode('☺'), 'xn--74h', 'smiling face encodes to xn--74h';
is decode_punycode('xn--74h'), '☺', 'xn--74h decodes to smiling face';
