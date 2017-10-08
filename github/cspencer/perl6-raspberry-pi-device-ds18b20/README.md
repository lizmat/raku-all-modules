RPi::Device::DS18B20
====================

RPi::Device::DS18B20 provides support for the DS18B20 family of temperature sensors.

SYNOPSIS
--------

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

Or, for use in an asynchronous environment:

    use RPi::Device::DS18B20;

    MAIN: {
      my $ds18b20 = RPi::Device::DS18B20.new();
    
      my ($sensor) = $ds18b20.detect-sensors();
    
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

DESCRIPTION
-----------

RPi::Device::DS18B20 provides access to the DS18B20 family of temperature sensors that can be connected to the Raspberry Pi.  The DS18B20 sensors uses the Dallas 1-Wire protocol to connect to the RPi, and will require loading of w1-gpio kernel module.

Adafruit has an excellent tutorial on getting the Raspberry Pi set up to use the DS18B20 sensors here:

  [https://www.adafruit.com/products/381](https://www.adafruit.com/products/381)

AUTHOR
------

Cory Spencer <cspencer@sprocket.org>
