#! /usr/bin/env false

use v6.c;

class Config::Exception::UnknownTypeException is Exception
{
    method message()
    {
        "Could not deduce loader type."
    }
}
