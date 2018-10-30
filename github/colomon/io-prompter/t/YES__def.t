#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

OK have => prompt('Type "Yes":', :Y, :default<n>, in => IN('yes','Yes')),
   want => 1,
   desc => ':Y with "yes"';

OK have => prompt('Type "Y":', :Yes, :default<n>, in => IN('Y')),
   want => 1,
   desc => ':Yes with "y"';

OK have => prompt('Type anything but "Y":', :Yes, :default<n>, in => IN('huh?')),
   want => 0,
   desc => ':Yes with "n"';

OK have => prompt('Just hit return:', :Yes, :default<n>, in => IN('')),
   want => 0,
   desc => ':Yes with default';
