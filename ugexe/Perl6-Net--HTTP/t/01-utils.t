use Test;
plan 1;

use Net::HTTP::Utils;

subtest {
    is hc("content-tyPE"),      'Content-Type',      'The basics';
    is hc("X-XSS-Blah"),        'X-Xss-Blah',        'Not perfect, but good enough';
    is hc("Transfer-encoding"), 'Transfer-Encoding';

}, 'Header case works [&hc]';
