#!/usr/bin/env perl6
use v6;

use HTTP::Status;
use Test;

my @tests =
    # code, info, succ, redir, error, clierr, serverr
    102, True, False, False, False, False, False,
    202, False, True, False, False, False, False,
    226, False, True, False, False, False, False,
    300, False, False, True, False, False, False,
    308, False, False, True, False, False, False,
    449, False, False, False, True, True, False,
    599, False, False, False, True, False, True,
;

plan @tests.elems - @tests.elems / 7;

for @tests -> $code, $i, $s, $r, $e, $c, $v {
    is is-info($code), $i, "$code is-info? $i";
    is is-success($code), $s, "$code is-success? $s";
    is is-redirect($code), $r, "$code is-redirect? $r";
    is is-error($code), $e, "$code is-error? $e";
    is is-client-error($code), $c, "$code is-client-error? $c";
    is is-server-error($code), $v, "$code is-server-error? $v";
}
