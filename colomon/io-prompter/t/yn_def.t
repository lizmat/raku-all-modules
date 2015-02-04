#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

OK have => prompt('Type "yes":', :yesno, :default<n>, in => IN('yes')),
   want => 1,
   desc => ':yesno with "yes"';

OK have => prompt('Type "y":', :yesno, :default<n>, in => IN('y')),
   want => 1,
   desc => ':yesno with "y"';

OK have => prompt('Type "n":', :yn, :default<n>, in => IN('huh?','no')),
   want => 0,
   desc => ':yn with "n"';

OK have => prompt('Just hit return:', :yesno, :default<n>, in => IN('')),
   want => 0,
   desc => ':yesno with default';
