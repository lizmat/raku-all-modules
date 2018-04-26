# JSON::Pointer

A JSON Pointer implementation in Perl 6.

## Synopsis

    use JSON::Pointer;

    # An example document to resolve pointers in
    my $sample-json = {
        foo => [
            {
                bar => 42
            },
            {
                'weird~odd/name' => 101
            }
        ]
    }

    # Simple usage
    my $p = JSON::Pointer.parse('/foo/0/bar');
    say $p.tokens; # [foo 0 bar]
    say $p.resolve($sample-json); # 42

    # ~ and / are escaped as ~0 and ~1
    my $p2 = JSON::Pointer.parse('/foo/1/weird~0odd~1name');
    say $p2.tokens; # [foo 1 weird~odd/name]
    say $p2.resolve($sample-json); # 101

    # A Failure is returned upon resolution failure
    my $p3 = JSON::Pointer.parse('/foo/2/missing');
    without $p3.resolve($sample-json) {
        say "Could not resolve";
    }

    # Construct a JSON pointer
    my $p4 = JSON::Poiner.new('foo', 0, 'weird~odd/name');
    say ~$p4; # /foo/0/weird~0odd~1name

## Description

JSON::Pointer is a Perl 6 module that implements JSON Pointer conception.

## Author

Alexander Kiryuhin <alexander.kiryuhin@gmail.com>

## Copyright and License

Copyright 2018 Edument Central Europe sro.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
