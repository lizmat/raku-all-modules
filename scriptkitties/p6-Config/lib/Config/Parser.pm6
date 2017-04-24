#! /usr/bin/env false

use v6.c;

use Config::Exception::UnimplementedMethodException;

class Config::Parser
{
    method read(Str $path --> Hash)
    {
        Config::Exception::UnimplementedMethodException.new.throw();
    }

    method write(Str $path, Hash $config --> Hash)
    {
        Config::Exception::UnimplementedMethodException.new.throw();
    }
}
