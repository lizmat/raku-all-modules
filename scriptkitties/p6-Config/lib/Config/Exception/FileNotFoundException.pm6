#! /usr/bin/env false

use v6.c;

class Config::Exception::FileNotFoundException is Exception
{
    method message()
    {
        "Could not find file"
    }
}
