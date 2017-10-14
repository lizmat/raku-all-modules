#! /usr/bin/env false

use v6.c;

class Config::Exception::MissingParserException is Exception
{
    has Str $.parser;

    method message()
    {
        "$!parser is not a valid parser. Are you sure its installed?"
    }
}
