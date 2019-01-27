NAME
====

JSON::Schema - an implementation of the [JSON Schema specification](https://json-schema.org/specification.html)

SYNOPSIS
========

    use JSON::Schema;
    my $schema = JSON::Schema.new(
        schema => from-json '{ "type": "string" }'
    );

    # Validate it and use the result as a boolean.
    say so $schema.validate("foo");     # True
    say so $schema.validate(42);        # False
    say so $schema.validate(Str);       # False

DESCRIPTION
===========

JSON::Schema is a module which allows JSON validation with set of rules described
in JSON Schema format.

AUTHOR
======

Alexander Kiryuhin alexander.kiryuhin@gmail.com

COPYRIGHT AND LICENSE
=====================

Copyright © Alexander Kiryuhin alexander.kiryuhin@gmail.com

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.
