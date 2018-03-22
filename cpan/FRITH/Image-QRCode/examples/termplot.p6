#!/usr/bin/env perl6

# Set your terminal colors to white background with black characters

use lib 'lib';
use Image::QRCode;

Image::QRCode.new.encode('https://perl6.org/').termplot;
