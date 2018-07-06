#!perl6

use v6;

use Test;
use LibraryCheck;
use Audio::PortMIDI;

# fake this
my $timestamp = 0;
if library-exists('portmidi', v0) {
    # Want to test a "large number" to weed out bit manipulation errors
    for NoteOn, NoteOff, ControlChange -> $event-type {
        for ^16 -> $channel {
            for ^12 -> $data-one { # note or control
                for ^12 -> $data-two { # velocity or value
                    my $ev;
                    lives-ok { $ev = Audio::PortMIDI::Event.new(:$channel, :$event-type, :$data-one, :$data-two, :$timestamp) }, "create an event";
                    my $int;
                    lives-ok { $int = $ev.Int }, "get the int value";
                    ok $int > 0, "and it is at least greater than 0";
                    my $ev2;
                    #lives-ok { 
                    $ev2 = Audio::PortMIDI::Event.new(event => $int); # }, "create one from an int";
                    is $ev2.channel, $ev.channel, "channel is right";
                    is $ev2.event-type, $ev.event-type, "event-type is right";
                    is $ev2.data-one, $ev.data-one, "data-one is right";
                    is $ev2.data-two, $ev.data-two, "data-two is right";
                    is $ev2.timestamp, $ev.timestamp, "timestamp is right";
                    is $ev2.Int, $int, "and better check it round trip";
                    $timestamp++;
                }
            }
        }
    }

}
else {
    skip "no portmidi library";
}



done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
