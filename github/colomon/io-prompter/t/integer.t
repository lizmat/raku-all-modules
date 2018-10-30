#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

OK have => prompt(:integer, in => IN('a','1.2','-42a','-12')),
   want => -12,
   desc => "Require an integer";

OK have => prompt(:i, in => IN('a','1.2','-42a','-12')),
   want => -12,
   desc => "Require an integer (short form)";
