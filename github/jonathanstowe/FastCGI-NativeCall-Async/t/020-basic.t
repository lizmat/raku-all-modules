#!/usr/bin/env perl6

use v6.c;

use Test;

use FastCGI::NativeCall::Async;

my $path = $*TMPDIR.child("fna-{ $*PID }-test.sock").Str;

my $fna = FastCGI::NativeCall::Async.new(:$path);
isa-ok $fna, FastCGI::NativeCall::Async;

nok $path.IO.e, "socket doesn't exist because we haven't started it yet";

isa-ok $fna.Supply, Supply, "Supply returns a Supply";

ok $fna.promise.defined, "Promise is defined";

Promise.in(2).then({ $fna.done });

react {
    whenever $fna -> $f {
        # nothing will happen here
    }
    whenever Promise.in(5) {
        flunk "done didn't work";
        done;
    }
    whenever $fna.promise {
        pass "thread finished ok";
        done;
    }
}

END {
    unlink $path;
}

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
