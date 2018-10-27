#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

OK have => prompt('Type "yes":', :yes, :default<n>, in => IN('yes')),
   want => 1,
   desc => ':yes with "yes"';

OK have => prompt('Type "y":', :yes, :default<n>, in => IN('y')),
   want => 1,
   desc => ':yes with "y"';

OK have => prompt('Type anything but "y":', :yes, :default<n>, in => IN('huh?')),
   want => 0,
   desc => ':yes with "n"';

OK have => prompt('Just hit return:', :y, :d<n>, in => IN('')),
   want => 0,
   desc => ':y with default (short forms)';
