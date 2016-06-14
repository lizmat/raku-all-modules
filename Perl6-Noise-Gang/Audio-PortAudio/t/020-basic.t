#!perl6

use v6;

use Test;
use LibraryCheck;
use Audio::PortAudio;

if library-exists('portaudio', v2) {
    pass "got portaudio";
    diag "some drivers may emit some output when they are initialised, sorry about that";
    my $obj;
    lives-ok { $obj = Audio::PortAudio.new }, "create portaudio object";
    diag "testing with { $obj.version }";
    isa-ok $obj, Audio::PortAudio, "and it is the right thing";
    my $c;
    lives-ok { $c = $obj.device-count() }, "get device count";

    if $c > 0 {
        pass "got some devices";
        is $obj.devices.elems, $c, "devices returns the same number as device-count";
        for $obj.devices -> $dev {
            isa-ok $dev, Audio::PortAudio::DeviceInfo, "device { $dev.name } is the right kind of object";
            isa-ok $dev.host-api(), Audio::PortAudio::HostApiInfo, "and it has a valid host-api { $dev.host-api.name }";
        }

        isa-ok $obj.default-output-device(), Audio::PortAudio::DeviceInfo, "default-output-device";
        isa-ok $obj.default-input-device(), Audio::PortAudio::DeviceInfo, "default-input-device";

        my $stream;

        lives-ok { $stream = $obj.open-default-stream(0,2) }, "open-default-stream for write and defaults";
        isa-ok $stream, Audio::PortAudio::Stream, "and we got a stream";
        nok $stream.active, "and it isn't active";
        ok $stream.stopped, "and it is obviously stopped";
        lives-ok { $stream.start }, "start the stream";
        ok $stream.active, "and it is active now";
        is $stream.info.sample-rate, 44100e0, "got some info";
        nok $stream.stopped, "and it is obviously not stopped anymore";
        ok $stream.write-available, "and write-available gives us something";

        diag "may make a quick blip";
        use NativeCall;
        my $data = CArray[num32].new;
        for (0 .. 255).map({ sin(($_/(44100/440)) * (2 * pi))}) -> $val {
            $data[$++] = $val;
        }

        lives-ok { $stream.write($data, 256) }, "write something to the stream";
        lives-ok { $stream.close }, "and close the stream";
        throws-like { $stream.write($data, 256) }, X::StreamError, "write to closed stream";

        lives-ok { $stream = $obj.open-default-stream(2,0) }, "open-default-stream for read and defaults";
        isa-ok $stream, Audio::PortAudio::Stream, "and we got a stream";
        nok $stream.active, "and it isn't active";
        ok $stream.stopped, "and it is obviously stopped";
        lives-ok { $stream.start }, "start the stream";
        ok $stream.active, "and it is active now";
        nok $stream.stopped, "and it is obviously not stopped anymore";
        ok $stream.read-available.defined, "and read-available gives us something";
        lives-ok { $data = $stream.read(256,2, num32) }, "read some stuff";
        lives-ok { $stream.close }, "and close the stream";
        throws-like { $stream.read(256, 2, num32) }, X::StreamError, "read from closed stream";


        lives-ok { $obj.terminate }, "close the portaudio down";

    }
    else {
        skip "no devices present can't test any more";
    }


}
else {
    skip "no portaudio library";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
