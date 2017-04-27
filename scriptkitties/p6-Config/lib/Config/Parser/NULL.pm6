#! /usr/bin/env false

use v6.c;

use Config::Parser;

#| The Config::Parser::NULL is a parser to mock with for testing purposes.
#| It exposes an additional method, set-config, so you can set a config
#| Hash to return when calling `read`.
class Config::Parser::NULL is Config::Parser
{
    my $mock-config;

    #| Return the mock config, skipping the file entirely.
    method read(Str $path --> Hash)
    {
        $mock-config;
    }

    #| Set the mock config to return on read.
    method set-config(Hash $config)
    {
        $mock-config = $config;
    }

    #| Return True, as if writing succeeded.
    method write(Str $path, Hash $config --> Bool)
    {
        True;
    }
}
