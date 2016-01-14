class RPi::GPIO {
  use RPi::GPIO::Pin;
  use RPi::Wiring;
  use NativeCall;
  use POSIX;
  
  has RPiGPIOMode $.mode;

  has @.pins;
  has %!initial-state;
  
  submethod BUILD(:$mode)  {
    my $uid = getuid();

    # The GPIO setup routines must be run as the root user.
    die "RPi must be initialized as root" if ($uid != 0);

    my @pins;
    given $mode {
      when WIRING {
        # Use the simplified pin numbering scheme implemented by the WiringPi library.
        RPi::Wiring::setup();
        given RPi::Wiring::board-revision() {
          when 1 { @pins = 0..16 };
          when 2 { @pins = (flat 0..16, 21..31) };
        }
      }
      
      when BCM {
        # Use the Broadcom GPIO pin numberings.
        RPi::Wiring::setup-gpio();
        do given RPi::Wiring::board-revision() {
          when 1 { @pins = (flat 0, 1, 4, 7..11, 14, 15, 17, 18, 21..25) };
          when 2 { @pins = (flat 2, 3, 4, 7..11, 14, 15, 17, 18, 22..25) };
        }
      }
    }

    @!pins = @pins.map: { RPi::GPIO::Pin.new(id => $_) };
    $!mode = $mode;

    # Preserve the initial state of the GPIO pins so that they can be restored upon
    # exit, if requested.
    %!initial-state = @!pins.map: { ($_.id => $_.read()) };
  }
  
  
  method read(RPi::GPIO::Pin $pin) returns Int {
    return $pin.read();
  }

  method write(RPi::GPIO::Pin $pin, RPiPinValue $value) {
    $pin.value($value);
  }

  method cleanup() {
    # Restore the initial state of the GPIO pins.
    for keys %!initial-state -> $pin {
      RPi::Wiring::digital-write(+$pin, %!initial-state{$pin});
    }
  }
}
