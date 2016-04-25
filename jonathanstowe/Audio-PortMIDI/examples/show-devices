#!perl6

use Audio::PortMIDI;

sub MAIN(Bool :$input = False, Bool :$output = False) {
    my $pm = Audio::PortMIDI.new;

    my Bool $both = $input == $output;
    for $pm.devices -> $device {
        if $both || ( $input && $device.input ) || ( $output && $device.output ) {
            say $device;
        }
    }
}


# vim: expandtab shiftwidth=4 ft=perl6
