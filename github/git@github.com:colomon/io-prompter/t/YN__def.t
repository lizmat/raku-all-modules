#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

OK have => prompt('Type "Yes":', :YesNo, :default<n>, in => IN('yes','no','Yes')),
   want => 1,
   desc => ':YesNo with "Yes"';

OK have => prompt('Type "Y":', :YN, :default<n>, in => IN('Y')),
   want => 1,
   desc => ':YN with "Y"';

OK have => prompt('Type "N":', :YesNo, :default<n>, in => IN('huh?','no','No')),
   want => 0,
   desc => ':YesNo with "N"';

OK have => prompt('Just hit return:', :YesNo, :default<N>, in => IN('')),
   want => 0,
   desc => ':YesNo with default';
