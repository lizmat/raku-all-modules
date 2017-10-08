#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

OK have => prompt(:number, in => IN('a','4.2a','1.2')),
   want => 1.2,
   desc => "Require a number";

OK have => prompt(:n, in => IN('a','4.2a','1.2')),
   want => 1.2,
   desc => "Require a number (short form)";
