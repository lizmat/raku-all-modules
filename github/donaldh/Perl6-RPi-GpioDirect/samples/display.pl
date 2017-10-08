use v6;

use RPi::GpioDirect;

my $pi = RPi::GpioDirect.new;

say 'Pin  Name      Value  Mode';
for $pi.gpio-pins -> $pin {
    say sprintf('%2s   %-8s  %5s  %4s',
                $pin, $pi.pin-name($pin), $pi.read($pin), $pi.function($pin)
               );
}

$pi.close;
