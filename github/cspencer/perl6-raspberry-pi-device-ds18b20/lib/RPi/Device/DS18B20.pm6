=begin pod

=head1 NAME

RPi::Device::DS18B20 provides support for the DS18B20 family of temperature sensors.

=head1 SYNOPSIS

    use RPi::Device::DS18B20;
    
    MAIN: {
      my $ds18b20 = RPi::Device::DS18B20.new();

      # Get a list of all DS18B20 sensors connected to the RPi.
      my @sensors = $ds18b20.detect-sensors();
    
      loop {
        for @sensors -> $sensor {
          # Set the units to Celcius (the default - use F for Fahrenheit scale).
          $sensor.units = C;
    
          # Get a temperature reading from the sensor.
          my $temp = $sensor.read();
    
          # If we were able to read a temperature, the result will be defined -
          # .read() will return Nil if the sensor was not able to provide a
          # temperature value.
          say "Temperature is: $temp" ~ $sensor.units()
            if $temp.defined;
        }
    
        sleep 1;
      }
    }

=head1 DESCRIPTION

RPi::Device::DS18B20 provides access to the DS18B20 family of temperature sensors that can be connected to the Raspberry Pi.  The DS18B20 sensors uses the Dallas 1-Wire protocol to connect to the RPi, and will require loading of w1-gpio kernel module.

Adafruit has an excellent tutorial on getting the Raspberry Pi set up to use the DS18B20 sensors here:

  https://www.adafruit.com/products/381

=head1 CONSTRUCTOR

The RPi::Device::DS18B20 takes no parameters.  The constructor will check to see if the "/sys/bus/w1/device/" directory exists, and will throw an error if not. If your program is getting an exception during object construction, check to ensure that the 'w1-gpio' kernel module is loaded.

=head1 METHODS

=item method detect-sensors() returns Array - Returns an Array of RPi::Device::DS18B20::Sensor objects that were detected on the RPi.

=item method get-sensor(Str $id) returns RPi::Device::DS18B20::Sensor - Returns the RPi::Device::DS18B20::Sensor corresponding to the provided ID $id.  If a sensor with the provided id wasn't found, returns Nil.

=head1 SEE ALSO

=item RPi

=item RPi::GPIO

=item RPi::Device::DS18B20::Sensor

=head1 AUTHOR

    Cory Spencer <cspencer@sprocket.org>

=end pod

use RPi::Device::DS18B20::Sensor;

class RPi::Device::DS18B20 {
  has $.base-path;

  submethod BUILD {
    $!base-path = "/sys/bus/w1/devices";
      
    if (! $!base-path.IO.e) {
      die "Unable to locate: $!base-path - is the wp-gpio kernel module loaded?"
    }
  }
    
  method detect-sensors() returns Array {
    my $path = $!base-path;
      
    # Get a list of the unique ID's for each potential sensor plugged into the RPi.
    my @sensors = flat $path.IO.dir.map: { m/^ $path "/28-" (<[ a..f 0..9]>+) $/ ?? $/[0].Str !! () };

    # Create a new Sensor object for each matching ID.
    return (@sensors.map: {
                            RPi::Device::DS18B20::Sensor.new(id   => $_,
                                                             path => $path ~ "/28-$_/w1_slave")
                          }).Array;
  }

  method get-sensor(Str $id) returns RPi::Device::DS18B20::Sensor {
    # Search for the specified sensor ID in the list of detected devices
    # and return it if found.
    return (self.detect-sensors.first: { $_.id eq $id } || Nil)
  }
}
