# JsonC

Using NativeCall this module binds to the popular json-c library, offering a different
approach to JSON handling in Perl6.

In adition to the traditional `to-json` and `from-json` routines this module provides
a `JSON` class.

## Usage

```perl6
use JsonC;

# The traditional API use the same semantincs of other JSON modules.

my %h = from-json('{ "foo": "mamá", "arr": [ 1, 4, 10 ] }');

my $str = to-json(%h, :pretty);
```

So JsonC can be used as a drop-in replacement, see "pros" and "cons" ahead.

If you need finer grained control over the process, or the JSON data is big,
you can use the full power of this module:

```perl6
use JsonC;

my $json = JSON.new-from-file('foo.json');

given $json {
    when Associative {
       # You got an object.
       say $_<foo>;
       say so $_<bar>:exists;
       for %$_.pairs {
            # Do someting
       }
    }
    when Positional {
       # You got an array
       my @a := $_;         # You can bind to one
       say @a[10..20];

       say @a.elems;        # How many

       my $foo = @a.shift;

       # But beware:
       say so @a ~~ Array;  # False, not a Perl6's Array
       say so @a ~~ JSON-P; # True   but a JSON Positional

       # Need a real Array?
       my @foo = @a;         # Do a copy to an Array;
       my @bar := Array(@a); # Or cast to one, better
    }
    when Int { ... }
    when Bool { ... }
    when Str { ... }
    when Any { ... } # null
}
```
