#! /usr/bin/env false

use v6.c;

class Config::Exception::UnknownTypeException is Exception
{
    has Str $.file;

    method message()
    {
        "Could not deduce loader type for $!file."
    }
}
