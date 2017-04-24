#! /usr/bin/env false

use v6.c;

class Config::Exception::UnsupportedTypeException is Exception
{
    method message()
    {
        "No parser support for the given file. Have you imported a correct parser?"
    }
}
