Perl 6 - RPi
============
An interface to the Raspberry Pi's GPIO and other peripherals

Overview
--------

RPi is a Perl 6 interface to the Raspberry Pi's GPIO and other peripherals.  It is still very early in development and should not be considered remotely stable or suitable for a production environment.

Installation
------------

To use the RPi packages, you will require a Raspberry Pi, the WiringPi libraries, and an installation of a Perl 6 compiler.

The WiringPi libraries should be installed before installing the Perl 6 modules.  To install WiringPi, as the root user, run the following:

    ~# apt-get install wiringpi

The Perl 6 compiler can be installed easily using the rakudobrew installer.  You can find its installation documentation here:

    https://github.com/tadzik/rakudobrew

Once rakudobrew has been installed, build the Panda package manager with:

    ~$ rakudobrew build-panda

Panda will allow you to easily download and install the RPi package, as well as its dependencies.  Once Panda has been installed, you should be able to download the RPi module using with:

    ~$ panda RPi

Usage
-----

    # Load the RPi module.
    use RPi;
  
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
      # Indicate we want to use the pin for OUTPUT.
      $pin.mode(OUTPUT);
      # Set the pin to HIGH.
      $pin.write(HIGH);
    }
  
    # Walk through the list of pins we're using, turning them on and
    # off for half a second.
    for 1..10 -> $i {
      for @pins -> $pin {
        # Set the pin to LOW.
        $pin.write(LOW);
        # Sleep for 500ms. 
        $rpi.delay(500);
        # Set the pin to HIGH
        $pin.write(HIGH);
      }
    }
  
    # Restore the GPIO pins to their original state.
    $rpi.gpio.cleanup();

Supported Devices
-----------------

* RPi::Device::DS18B20 - Module for the DS18B20 family of temperature sensors.

Author
------

Cory Spencer <cspencer@sprocket.org>