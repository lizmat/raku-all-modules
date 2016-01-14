=begin pod

=head1 NAME

RPi::Device::DS18B20::Sensor - A DS18B20 temperature sensors object, as returned by the RPi::Device::DS18B20 "detect-sensors" and "get-sensor" methods.

=head1 CONSTRUCTOR

RPi::Device::DS18B20::Sensor is not intended to be instantiated directly.  Instead, use the RPi::Device::DS18B20 class's "detect-sensors" and "get-sensor" methods.

=head1 METHODS

=item method read() returns Rat - Returns a temperature reading from the sensor.  By default, all temperatures are provided in degrees Celsius.  To convert the temperature to degrees Fahrenheit, set the units attribute to F

=item method interval(Numeric $interval, Numeric $delay = 0) returns Supply - Returns a live Supply that will emit a new temperature reading every $interval seconds.  If specified, the Supply will wait $delay seconds before emitting the first reading.

=head1 ATTRIBUTES

=item units - Controls whether temperature readings are provided in degrees Celsius or degrees Fahrenheit.  Set to C for Celsius (the default) and F for Fahrenheit.

=head1 SEE ALSO

=item RPi

=item RPi::GPIO

=item RPi::Device::DS18B20

=head1 AUTHOR

Cory Spencer <cspencer@sprocket.org>

=end pod

enum DegreeUnits <C F>;

grammar RPi::Device::DS18B20::Grammar {
  token TOP {
    <data> ': crc=' <hexcode> ' ' $<valid> = ['YES' || 'NO'] \n
    <data> 't=' $<temperature> = [ \d+ ] \n
  }

  token data {
    (<hexcode> ' ') ** 9
  }
  
  token hexcode {
    <[ a..f 0..9 ]> ** 2
  }
}
  
class RPi::Device::DS18B20::Sensor {
  has DegreeUnits $.units is rw = C;
  has Str $.id;
  has Str $.path;
    
  method read() returns Rat {
    # Ensure the file exists that we're going to take readings from.  An
    # exception is thrown if the sensor is not present, or is disconnected
    # during operation.
    die "Can't take sensor reading: $!path not found" if ! $.path.IO.e;

    # Parse the output present in the sensor's device file.
    my $match = RPi::Device::DS18B20::Grammar.parse(~$.path.IO.slurp);

    # The sensor will print 'YES' if the input is valid, and 'NO' if not.
    # When valid, convert to the request degree units and return.
    if (~$<valid> eq 'YES') {
      # Temperature is reported in 1/1000's of a degree - divide by 100 to
      # get the actual value.
      my $temp = (+$<temperature>)/1000;

      # If needed, do conversion to the Fahrenheit temperature scale.
      ($!units == C) ?? $temp !! self.convert-to-fahrenheit($temp);
    } else {
      return Nil;
    }
  }

  method convert-to-fahrenheit(Rat $temp) returns Rat {
    return ($temp * 1.8) + 32
  }

  method interval(Numeric $interval where { $interval >= 0 },
                  Numeric $delay    where { $delay    >= 0 } = 0)
         returns Supply {
    my $s = Supplier.new;

    # Start a new thread to run the Supplier factory in.
    start {
      my $start-time = now;

      loop {
        # Emit a new temperature reading if at least $delay seconds have
        # elapsed.
        $s.emit(self.read()) if (now - $start-time) >= $delay;

        sleep $interval;
      }
    }

    # Return a live Supply.
    return $s.Supply.share;
  }
}
