use v6;

use RPi::GpioDirect;

my $pi = RPi::GpioDirect.new;

say 'Pin  Name      Value';

for 11, 12 -> $pin {
    $pi.set-function($pin, In);
    for [ Down, Up, Down, None ] -> $x {
        $pi.set-pull($pin, $x);
        say sprintf('%2i   %-8s  %5s',
                    $pin, $pi.pin-name($pin), $pi.read($pin));
    }
}

$pi.close;
