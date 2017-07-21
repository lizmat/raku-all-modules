#!perl6

use v6.c;

use Test;

use Audio::PortMIDI;
use LibraryCheck;

if library-exists('portmidi', v0) {
    lives-ok {
        CATCH {
            when /"Illegal error number"/ {
                diag "NO PERMISSION ON SEQUENCER DEVICE";
                skip "Can't open sequencer device";
                done-testing;
                exit;
            }
            default {
                die $_;
            }
        }
        my $pm = Audio::PortMIDI.new;
        my $dev = $pm.default-output-device;

        diag $dev.gist;


        my $stream = $pm.open-output($dev, 32);

        # Play 1/8th note middle C
        my $note-on = Audio::PortMIDI::Event.new(event-type => NoteOn, channel => 1, data-one => 60, data-two => 127, timestamp => 0);
        my $note-off = Audio::PortMIDI::Event.new(event-type => NoteOff, channel => 1, data-one => 60, data-two => 127, timestamp => 0);

        $stream.write($note-on);
        sleep .25;
        $stream.write($note-off);
        $stream.close;
        $pm.terminate;
    }, "run the synopsis code";
}
else {
    skip "no portmidi lbrary";
}


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
