#! /usr/bin/env false

use v6.c;

class Config::Exception::UnimplementedMethodException is Exception
{
    has Str $.method;

    method message()
    {
        "The $!method method is not implemented"
    }
}
