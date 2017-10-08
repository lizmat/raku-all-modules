use v6;
use Test;
use RPi::GpioDirect;

plan 20;

my $pi = RPi::GpioDirect.new;
isa-ok $pi, RPi::GpioDirect;

# GPIO pins
my @pins = $pi.gpio-pins;
is +@pins, 28, 'has 28 usable GPIO pins';
is @pins[0], 3, 'first usable GPIO is pin 3';
is @pins.tail, 40, 'last usable GPIO is pin 40';

# pin GPIO numbers
dies-ok { $pi.pin-gpio(0) }, 'pin-gpio: 0 is not a valid pin number';
dies-ok { $pi.pin-gpio(41) }, 'pin-gpio: 41 is not a valid pin number';
dies-ok { $pi.pin-gpio(1) }, 'Pin 1 is not a GPIO';
is $pi.pin-gpio(3), 2, 'Pin 3 is a GPIO';
is $pi.pin-gpio(40), 21, 'Pin 40 is a GPIO';

# pin GPIO names
dies-ok { $pi.pin-name(0) }, 'pin-name: 0 is not a valid pin number';
dies-ok { $pi.pin-name(41) }, 'pin-name: 41 is not a valid pin number';
is $pi.pin-name(1), '3.3v', 'Pin 1 is 3.3v';
is $pi.pin-name(40), 'GPIO.21', 'Pin 40 is GPIO.21';

# Out
$pi.set-function(11, Out);
is $pi.function(11), Out, 'Can set pin 11 function to Out';
$pi.write(11, On);
is $pi.read(11), On, 'Can set pin 11 value to On';
$pi.write(11, Off);
is $pi.read(11), Off, 'Can set pin 11 value to Off';

# In
$pi.set-function(11, In);
is $pi.function(11), In, 'Can set pin 11 function to In';
$pi.set-pull(11, Down);
is $pi.read(11), Off, 'Can set pin 11 to pull down';
$pi.set-pull(11, Up);
is $pi.read(11), On, 'Can set pin 11 to pull up';
$pi.set-pull(11, Down);
is $pi.read(11), Off, 'Can set pin 11 back to pull down';
