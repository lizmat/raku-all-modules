#!perl6

use v6;

use Test;

use Device::Velleman::K8055;

my $obj;

if try $obj = Device::Velleman::K8055.new {
    pass "can open board";
    diag "the tests may cause the lights on the board to flash";
    isa-ok $obj, Device::Velleman::K8055, "got the right object";
    lives-ok { $obj.set-all-digital(255) }, "all digital on";

    my @in;
    lives-ok { @in = $obj.get-all-output() }, "get all output";
    is @in[0], 255, "and the digital is 255";

    lives-ok { $obj.set-all-digital(0) }, "all digital off";
    lives-ok { @in = $obj.get-all-output() }, "get all output";
    is @in[0], 0, "and the digital is 0";

    for ^8 -> $i {
        lives-ok { $obj.set-digital($i, True) }, "set digital $i on";
        lives-ok { $obj.set-digital($i, False) }, "set digital $i off";
    }

    lives-ok { $obj.set-all-analog(255,255) }, "set both analog full";
    lives-ok { @in = $obj.get-all-output() }, "get all output";
    is @in[1], 255, "and the analog0 is 255";
    is @in[2], 255, "and the analog1 is 255";

    lives-ok { $obj.set-all-analog(0,0) }, "set both analog off";
    lives-ok { @in = $obj.get-all-output() }, "get all output";
    is @in[1], 0, "and the analog0 is 0";
    is @in[2], 0, "and the analog1 is 0";

    for ^2 -> $i {
        lives-ok { $obj.set-analog($i, 255) }, "set analog $i full";
        lives-ok { $obj.set-analog($i, 0) }, "set analog $i off";
    }

    for ^2 -> $i {
        lives-ok { $obj.reset-counter($i) }, "reset counter $i";
        lives-ok { $obj.set-debounce-time($i, 100) }, "set-debounce-time for counter $i";

    }

    lives-ok { @in = $obj.get-all-input() }, "get input";
    is @in.elems, 5, "and we got five items anyway";

    lives-ok { $obj.close(:reset) }, "close and reset";
}
else {
    plan 43;
    skip-rest "can't open board won't test";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
