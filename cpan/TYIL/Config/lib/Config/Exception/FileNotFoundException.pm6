#! /usr/bin/env false

use v6.c;

class Config::Exception::FileNotFoundException is Exception
{
    has Str $.path;

    method message()
    {
        "Could not find file at $!path"
    }
}
