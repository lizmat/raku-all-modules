NAME
====

RPi::Device::ST7036 - Support for the ST7036 dot matrix display.

SYNOPSIS
========

    use RPi::Wiring::Pi;
    use RPi::Wiring::SPI;
    use RPi::Device::ST7036;

    wiringPiSPISetup 0, 1_000_000;

    my RPi::Device::ST7036 $lcd .= new(
        setup       => RPi::Device::ST7036::Setup.DOGM081_3_3V,
        rs-pin      => 25,
        spi-channel => 0
    );

    $lcd.init;

    $lcd.write: 'Shiny!';

DESCRIPTION
===========

Display driver for ST7036 based matrix displays.

METHODS
=======

new
---

Takes the following parameters:

  * rs-pin

RPi pin number connected to the register select pin of the display. This library uses the Wiring Pi pin numbering.

  * spi-channel

The SPI channel the display is connected to. Either 0 or 1.

  * setup

An RPi::Device::ST7036::Setup object. Instances of this class contain all configuration options that are always the same for a specific display.

If you have a display for which there is not yet an entry in the Setup class ready to use, please write one and create a pull request!

  * cursor

Whether to display a cursor.

  * cursor-blink

Whether the cursor should blink.

  * contrast

A contrast value between 0 and 63.

  * double-height

Whether a double hight line should be used (irrelevant for single line displays).

  * display-on

Whether the display should be turned on initially.

init
----

Initialize the display. Must be called before anything else works.

write
-----

Write some text on the display.

home
----

Return the cursor to position 0.

clear
-----

Clear the display.
