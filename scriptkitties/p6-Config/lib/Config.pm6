#! /usr/bin/env false

use v6.c;

use Config::Exception::MissingParserException;
use Config::Exception::UnknownTypeException;
use Config::Exception::FileNotFoundException;
use Config::Type;
use Config::Parser;

class Config is export
{
    has $!content = {};
    has $!path;
    has $!parser;

    multi method get(Str $key, Any $default = Nil)
    {
        my $index = $!content;

        for $key.split(".") -> $part {
            return $default unless defined($index{$part});

            $index = $index{$part};
        }

        $index;
    }

    multi method get(@keyparts, Any $default = Nil)
    {
        my $index = $!content;

        for @keyparts -> $part {
            return $default unless defined($index{$part});

            $index = $index{$part};
        }

        $index;
    }

    method get-parser(Str $path, Str $parser = "")
    {
        if ($parser ne "") {
            return $parser;
        }

        my $type = self.get-parser-type($path);

        Config::Exception::UnknownTypeException.new(
            type => $type
        ).throw() if $type eq Config::Type::unknown;

        "Config::Parser::" ~ $type;
    }

    method get-parser-type(Str $path)
    {
        given ($path) {
            when .ends-with(".yml") { return Config::Type::yaml; };
        }

        my $file = $path;

        if (defined($path.index("/"))) {
            $file = $path.split("/")[*-1];
        }

        if (defined($file.index("."))) {
            return $file.split(".")[*-1];
        }

        return Config::Type::unknown;
    }

    method has(Str $key) {
        my $index = $!content;

        for $key.split(".") -> $part {
            return False unless defined($index{$part});

            $index = $index{$part};
        }

        True;
    }

    multi method read()
    {
        return self.load($!path);
    }

    multi method read(Str $path, Str $parser = "")
    {
        Config::Exception::FileNotFoundException.new(
            path => $path
        ).throw() unless $path.IO.f;

        $!parser = self.get-parser($path, $parser);

        try {
            CATCH {
                when X::CompUnit::UnsatisfiedDependency {
                    Config::Exception::MissingParserException.new(
                        parser => $parser
                    ).throw();
                }
            }

            require ::($!parser);
            $!content = ::($!parser).read($path);
        }

        return True;
    }

    multi method read(Hash $hash)
    {
        $!content = $hash;
    }

    method set(Str $key, Any $value)
    {
        my $index := $!content;

        for $key.split(".") -> $part {
            $index{$part} = {} unless defined($index{$part});

            $index := $index{$part};
        }

        $index = $value;

        self;
    }

    method write(Str $path, Str $parser = "")
    {
        $parser = self.get-parser($path, $parser);

        require ::($parser);
        return ::($parser).write($path, $!content);
    }
}
