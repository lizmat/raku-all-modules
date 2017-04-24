#! /usr/bin/env false

use v6.c;

class Config::Exception::UnimplementedMethodException is Exception
{
    method message()
    {
        "This method is not implemented"
    }
}
