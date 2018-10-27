#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

OK have => prompt(fail => /bye/, in => IN('hello')),
   want => 'hello',
   desc => "Don't fail";

OK have => prompt(fail => /bye/, in => IN('bye')),
   want => !*,
   desc => "Fail";
