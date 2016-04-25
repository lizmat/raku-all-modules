#!perl6

use v6;

use Test;
use LibraryCheck;

use Audio::PortMIDI;


if library-exists('portmidi', v0) {
    pass "got portmidi library";
    my $obj;
    lives-ok { $obj = Audio::PortMIDI.new }, "create new Audio::PortMIDI object";
    isa-ok $obj, Audio::PortMIDI, "and it actually is one";
    my $count;
    lives-ok { $count = $obj.count-devices }, "get device count";
    if $count > 0 {
        pass "got some devices";
        for $obj.devices -> $device {
            isa-ok $device, Audio::PortMIDI::DeviceInfo, "a device info for { $device.interface } device { $device.name }";
            nok $device.opened, "and it is not opened";
        }



    }
    else {
        skip "no devices";

    }
}
else {
    skip "no portmidi";
}



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
