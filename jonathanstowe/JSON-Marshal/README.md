# JSON::Marshal

Make JSON from an Object (the opposite of JSON::Unmarshal)

## Synopsis

```
   use JSON::Marshal;

    class SomeClass {
      has Str $.string;
      has Int $.int;
      has Version $.version is marshalled-by('Str');
    }

    my $object = SomeClass.new(string => "string", int => 42, version => Version.new("0.0.1"));


    my Str $json = marshal($object); # -> "{ "string" : "string", "int" : 42, "version" : "0.0.1" }'


```

## Description

This provides a single exported subroutine to create a JSON representation
of an object.  It should round trip back into an object of the same class
using [JSON::Unmarshal](https://github.com/tadzik/JSON-Unmarshal).

It only outputs the "public" attributes (that is those with accessors
created by declaring them with the '.' twigil. Attributes without acccessors
are ignored.


If you want to ignore any attributes without a value you can use the
```:skip-null``` adverb to ```marshal```, which will supress the
marshalling of any undefined attributes.  Additionally if you want a
finer-grained control over this behaviour there is a 'json-skip-null'
attribute trait which will cause the specific attribute to be skipped
if it isn't defined irrespective of the ```skip-null```.


To allow a finer degree of control of how an attribute is marshalled an
attribute trait ```is marshalled-by``` is provided, this can take either
a Code object (an anonymous subroutine,) which should take as an argument
the value to be marshalled and should return a value that can be completely
represented as JSON, that is to say a string, number or boolean or a Hash
or Array who's values are those things. Alternatively the name of a method
that will be called on the value, the return value being constrained as
above.

## Installation

Assuming you have a working Rakudo perl 6 installation, you can install this
with ```panda``` :

    # From the source directory
   
    panda install .

    # Remote installation

    panda install JSON::Marshal

I haven't tested this with "zef", but I see no reason why it shouldn't
work or any other equally capable package management tool.

## Support

Suggestions/patches are welcomed via github at

   https://github.com/jonathanstowe/JSON-Marshal

## Licence

Please see the LICENCE file in the distribution

© Jonathan Stowe 2015, 2016
