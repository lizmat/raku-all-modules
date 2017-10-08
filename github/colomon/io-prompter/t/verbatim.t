#! /Users/damian/bin/rakudo*
use v6;

use Testing;
use IO::Prompter;

OK have       => prompt(in => IN('hello')),
   want       => none(Str),
   desc       => "Non-verbatim doesn't return Str";

OK have => prompt(:verbatim, in => IN('hello')),
   want => Str & 'hello',
   desc => "Verbatim returns Str";
