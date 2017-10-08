#! env perl6

use RPi;

MAIN: {
  # List of the pins we're using.
  my @pin-ids = (8, 9, 7, 0);

  # Create a new RPi object.
  my $rpi = RPi.new();

  # Indicate we're going to use the WiringPi numbering scheme.
  $rpi.gpio(mode => WIRING);

  # Drop privileges from 'root' to the 'pi' user.
  $rpi.drop-privileges('pi', 'pi');

  # Get a list of all the GPIO pins.
  my @pins = $rpi.gpio.pins;

  # Clear all the pins by setting them to HIGH.
  for @pins -> $pin {
    $pin.mode(OUTPUT);
    $pin.write(HIGH);
  }

  # Walk through the list of pins we're using, turning them on and
  # off for half a second.
  for 1..10 -> $i {
    for @pin-ids -> $p {
      my $pin = @pins[$p];
      
      $pin.write(LOW);
      $rpi.delay(500);
      $pin.write(HIGH);
    }
  }

  # Restore the GPIO pins to their original state.
  $rpi.gpio.cleanup();
}
