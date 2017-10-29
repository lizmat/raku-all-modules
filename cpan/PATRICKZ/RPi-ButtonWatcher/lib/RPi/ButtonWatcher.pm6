use v6.c;
use NativeCall;
use RPi::Wiring::Pi;

enum Edge < RISING FALLING BOTH >;
enum PUD < PULL_UP PULL_DOWN PULL_OFF >;

class RPi::ButtonWatcher:ver<0.0.1> {
    has %!gpio-to-wiring-pins{Int};
    has %!prev-vals{Int};
    has Edge $!edge;
    has $!button-supplier = Supplier.new;
    has $!debounce;

    submethod BUILD(:@pins, Edge:D :$!edge, PUD:D :$PUD, :$!debounce = 0.1) {
        %!gpio-to-wiring-pins{wpiPinToGpio($_)} = $_ for @pins;

        self!setup: $PUD;

        for %!gpio-to-wiring-pins.keys -> $gpio-pin {
            %!prev-vals{$gpio-pin} = slurp("/sys/class/gpio/gpio$gpio-pin/value").substr(0,1);
        }

        Thread.start({
            while True {
                sleep $!debounce;
                for %!gpio-to-wiring-pins.keys -> $gpio-pin {
                    my $res = slurp("/sys/class/gpio/gpio$gpio-pin/value").substr(0, 1);
                    if %!prev-vals{$gpio-pin} ne $res {
                        %!prev-vals{$gpio-pin} = $res;
                        self!callback: $gpio-pin, $res.ord;
                    }
                }
            }
        });
    }

    method !setup(PUD $PUD) {
        for %!gpio-to-wiring-pins.kv -> $gpio-pin, $wpi-pin {
            # Configure pin as input
            pinMode $wpi-pin, INPUT;

            # Set pin to pull up
            pullUpDnControl $wpi-pin, ($PUD == PULL_UP ?? PUD_UP !! $PUD == PULL_DOWN ?? PUD_DOWN !! PUD_OFF);

            # Setup the sysfs interface
            spurt '/sys/class/gpio/export', "$gpio-pin\n" if ! "/sys/class/gpio/gpio$gpio-pin".IO.d;
            die "Couldn't export pin $gpio-pin"           if ! "/sys/class/gpio/gpio$gpio-pin".IO.d;

            sleep 0.1; #Sleep a bit. Otherwise the following spurts will fail with an access denied exception.

            spurt "/sys/class/gpio/gpio$gpio-pin/direction", "in\n";
        }
    }

    method !callback(int32 $gpio-pin, uint8 $val) {
        my $observed-edge = $val == '1'.ord ?? RISING !! FALLING;
        if $!edge == BOTH || $!edge == $observed-edge {
            $!button-supplier.emit: {
                pin => %!gpio-to-wiring-pins{$gpio-pin},
                edge => $observed-edge,
            };
        }
    }

    method getSupply() {
        return $!button-supplier.Supply;
    }
}

=begin pod

=head1 NAME

RPi::ButtonWatcher - A button push event supplier

=head1 SYNOPSIS

    use RPi::Wiring::Pi;
    use RPi::ButtonWatcher;

    die if wiringPiSetup() != 0;

    # Takes WiringPi pin numbers.
    my $watcher = RPi::ButtonWatcher.new(pins => ( 4, 5, 6 ), edge => BOTH, PUD => PULL_UP);
    $watcher.getSupply.tap( -> %v {
        my $e = %v<edge> == Edge.RISING ?? 'up' !! 'down';
        say "Pin: %v<pin>, Edge: $e";
    });


=head1 DESCRIPTION

This library provides a supplier of GPIO pin state changes.

Read/write access to I</sys/class/gpio/export> and I</sys/class/gpio/gpioXX/>
is required for this library to work. This usually means the user running the
code has to be in the I<gpio> group.

This module uses polling to detect state changes. A polling interval of 0.1
seconds is usually fast enough for normal button pushes.

The Sysfs interface is documented here: L<https://www.kernel.org/doc/Documentation/gpio/sysfs.txt>

=head1 METHODS

=head2 new

Do initialize WiringPi before using this class using C<wiringPiSetup>!

Takes the following parameters:

=item1 pins

A list of WiringPi pin numbers to watch.

=item1 edge

The edges to listen for.

=item2 C<Edge.RISING>

Triggered when a button is released.

=item2 C<Edge.FALLING>

Triggered when a button is pressed.

=item2 C<Edge.BOTH>

Triggered on both, button presses and releases.

=item1 debounce

Time in seconds to sleep between polls. Faster means more responsive, but also
more system resource eating.
Defaults to 0.1 (100ms).

=head2 getSupply

Returns a supply that can be tapped. The supply will emit
hashes with two entries:

=item pin

The WiringPi pin number that was triggered.

=item edge

Either C<Edge.RISING> or C<Edge.FALLING>.

=end pod

