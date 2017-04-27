#! /usr/bin/env false

use v6.c;

use Config::Exception::UnimplementedMethodException;

class Config::Parser
{
    #| Attempt to read the file at a given $path, and returns its
    #| parsed contents as a Hash.
    method read(Str $path --> Hash)
    {
        Config::Exception::UnimplementedMethodException.new(
            method => "read"
        ).throw();
    }

    #| Attempt to write the $config Hash at a given $path. Returns
    #| True on success, False on failure.
    method write(Str $path, Hash $config --> Bool)
    {
        Config::Exception::UnimplementedMethodException.new(
            method => "write"
        ).throw();
    }
}
