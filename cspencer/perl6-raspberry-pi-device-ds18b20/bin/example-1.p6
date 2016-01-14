use RPi::Device::DS18B20;

MAIN: {
  my $ds18b20 = RPi::Device::DS18B20.new();

  my ($sensor) = $ds18b20.detect-sensors() or
    die "ERROR: No DS18B20 sensors detected";

  # Read the temperature directly from the sensor.
  loop {
    my $temperature = $sensor.read;

    if $temperature.defined {
      say "Temperature: sensor id=" ~ $sensor.id ~ ": temp=$temperature"
    } else {
      say "ERROR: Temperature reading not avaialable"
    }
  }
}
