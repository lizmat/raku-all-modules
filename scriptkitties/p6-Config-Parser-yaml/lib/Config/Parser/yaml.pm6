#! /usr/bin/env false

use v6.c;

use Config::Parser;
use YAMLish;

class Config::Parser::yaml is Config::Parser
{
    method read(Str $path --> Hash)
    {
        say $path;
        load-yaml(slurp $path);
    }
}
