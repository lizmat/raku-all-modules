use RPi::Device::DS18B20;

MAIN: {
  my $ds18b20 = RPi::Device::DS18B20.new();

  my ($sensor) = $ds18b20.detect-sensors() or
    die "ERROR: No DS18B20 sensors detected";

  # Create a live Supply from the sensor that reads a new temperature every
  # 1.5 seconds.
  my $supply = $sensor.interval(1.5);

  # Read the temperature from the supply in an asychronous react loop.
  react {
    whenever $supply -> $temperature {
      if $temperature.defined {
        say "Temperature: sensor id=" ~ $sensor.id ~ ": temp=$temperature"
      } else {
        say "ERROR: Temperature reading not avaialable"
      }
    }
  }
}
