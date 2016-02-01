NAME
====

Serialize::Naive - recursive serialization and deserialization interface

SYNOPSIS
========

        use Serialize::Naive;

        class Point does Serialize::Naive
        {
            has Rat $.x;
            has Rat $.y;
        }

        class Circle does Serialize::Naive
        {
            has Point $.center;
            has Int $.radius;
        }

        class Polygon does Serialize::Naive
        {
            has Str $.label;
            has Point @.vertices;
        }

        my %data = radius => 5, center => { x => 0.5, y => 1.5 };
        my Circle $c .= deserialize(%data);

        my %coords = $c.center.serialize;
        say "X %coords<x> Y %coords<y>";

        my Polygon $sq .= new(:label("A. Square"),
            :vertices(Array[Point].new(
                Point.new(:x(0.0), :y(0.0)),
                Point.new(:x(1.0), :y(0.0)),
                Point.new(:x(1.0), :y(1.0)),
                Point.new(:x(0.0), :y(1.0)),
        )));
        %data = $sq.serialize;
        say %data;

        %data<weird> = 'ness';
        %data<vertices>[1]<unhand> = 'me';

        say 'Warnings silently ignored';
        $sq .= deserialize(%data);

        say 'Warnings displayed';
        $sq .= deserialize(%data, :warn(&note));

DESCRIPTION
===========

This role provides two methods to recursively serialize Perl 6 objects to Perl 6 data structures and, later, deserialize them back. No attempt is made to preserve type information in the serialized data; the caller of the `deserialize()` method should take care to pass the proper data structure for the top-level class, and the inner objects and classes will be discovered and recursed into automatically.

METHODS
=======

  * method serialize

        method serialize()

    Return a hash containing key/value pairs for all the public attributes of the object's class. Attributes are classified in several categories:

      * Basic types

        The value of the attribute is stored directly as the hash pair value.

      * Typed arrays or hashes

        The value of the attribute is stored as respectively an array or a hash containing the recursively serialized values of the elements.

      * Other classes

        The value of the attribute is recursively serialized to a hash using the same algorithm.

  * method deserialize

        method deserialize(%data, Sub :$warn);

    Instantiate a new object of the invocant's type, initializing its attributes with the values from the provided hash. Any attributes of composite or complex types are handled recursively in the reverse manner as the serialization described above.

    The optional `$warn` parameter is a handler for warnings about any inconsistencies detected in the data. For the present, the only problem detected is hash keys that do not correspond to class attributes.

FUNCTIONS
=========

The `Serialize::Naive` module also exports two functions:

  * sub serialize

        sub serialize($obj)

    Serialize the specified object just as `$obj.serialize()` would.

  * sub deserialize

        sub deserialize($type, %data, Sub :$warn)

    Deserialize an object of the specified type just as `$type.deserialize(%data, :warn($warn))` would.

SEE ALSO
========

[Serialize::Tiny](https://modules.perl6.org/dist/Serialize::Tiny)

AUTHOR
======

Peter Pentchev <[roam@ringlet.net](mailto:roam@ringlet.net)>

COPYRIGHT
=========

Copyright (C) 2016 Peter Pentchev

LICENSE
=======

The Serialize::Naive module is distributed under the terms of the Artistic License 2.0. For more details, see the full text of the license in the file LICENSE in the source distribution.
