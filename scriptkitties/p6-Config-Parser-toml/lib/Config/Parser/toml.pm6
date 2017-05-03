#! /usr/bin/env false

use v6.c;

use Config::Parser;
use Config::TOML;

class Config::Parser::toml is Config::Parser
{
    method read(Str $path --> Hash)
    {
        from-toml(slurp $path);
    }

    method write(Str $path, Hash $config --> Bool)
    {
        spurt $path, to-toml($config);

        True;
    }
}
