#!/usr/bin/env perl6

use v6;
use RPi::Wiring::Pi;
use RPi::Wiring::SPI;
use RPi::Device::ST7036;

wiringPiSetup;
wiringPiSPISetup 1, 1_000_000;

my RPi::Device::ST7036 $lcd .= new(
    rs-pin      => 25,
    spi-channel => 1,
    setup       => RPi::Device::ST7036::Setup.DOGM081_3_3V,
    cursor      => True,
    cursorBlink => True,
    contrast    => 0b010000
);

$lcd.init;

$lcd.write: 'Display!';

