# DispatchMap

A map that uses Perl 6 multi dispatch to link keys to values

## Synopsis

``` perl6
need DispatchMap;

my $map = DispatchMap.new:
             (Int) =>  "an Int!",
             (subset :: of Int:D where * > 5) => "Wow, an Int greater than 5",
             ("foo")           => "A literal foo",
             (π)               => "pi",
             (Str)             => "one string",
             (Stringy)         => "something stringy",
             (Str,Str)         => "two strings",
             (Any:U) => { "Some tyoe object: {.gist}" };


say $map.get(2); #-> an Int!
say $map.get(6); #-> Wow, an Int greater than 5
say $map.get("foo"); #-> A literal foo;
say $map.get-all("foo"); #-> ("A literal foo","one string","something stringy");
say $map.get(π); #-> pi
say $map.get("foo","bar"); #-> two strings
say $map.get(Perl); # get the Block as a value -> ;; $_? is raw {  }
say $map.dispatch(Perl); # Not sure what this is: (Perl)
```

## Description

**warning** this is module is experimental and subject to change

**warning** this module uses unspec'd rakudo internals and could break without warning

Perl 6 has a very sophisticated routine dispatch system based on
finding the candidate that matches the call's arguments most
narrowly. Unfortunately there is no way (yet) to make use of the
dispatching logic outside of routine calls. This module exposes that
logic in a map like interface.

The following do the same sort of thing. The main difference is that
the DispatchMap can be defined at runtime.

``` perl6
    multi foo(Str:D $str) { "a string: $str" }
    multi foo(Int:D $int) { "an int: $int"   }
    multi foo(42)         { "a special int"  }

    say foo("lorem");
    say foo(42);
    my $sub = &foo.cando(\("lorem"))[0];
```


```perl6
    use DispatchMap;
    my $map = DispatchMap.new(
        (Str:D) => -> $str { "a string: $str" },
        (Int:D) => -> $int { "an int: $int" },
        (42)    => -> $int { "a special int" }
    );
    say $map.dispatch("lorem");
    say $map.dispatch(42);
    my $block = $map.get("lorem");
```

Presently, the psudo-signatures you pass to `.new` and `.set` are limited to
non-slurpy positional parameters. If it's passed a type object that
will be used as the nominal type of the parameter. If a literal is
passed the `.WHAT` of the object is used as the nominal type and the
literal is used as a `where` constraint.



``` perl6

```

## Methods

### new(**@args)

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
#or
my $map = DispatchMap.new( (Int,Array),"Foo",(Cool),"Bar" );
#or
my $map = DispatchMap.new( [(Int,Array),"Foo",(Cool),"Bar"] );
```

Makes a new DispatchMap from args in the same way.

### keys

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.keys; #-> (Int,Array),(Cool)
```

Gets the keys as a list of lists (each key is a list).

### values

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.values; #-> (Int,Array),(Cool)
```

Gets the values in the map as a list.

### pairs

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.pairs; #-> (Int,Array) => "Foo",(Cool) => "Bar"
```

Returns the map as a list of pairs.

### list

```perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.list; #-> (Int,Array),"Foo",(Cool),"Bar"
```

Returns the map a list of keys and values.

### get(|c)

``` perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
say $map.get(1,["one","two"]); #-> Foo
```

Gets a single value from the map. The Capture of the arguments to get
are used as the key.

### get-all(|c)

``` perl6
my $map = DispatchMap.new( Numeric => "A number",
                           Real => "A real number",
                           Int => "An int",
                           (π)  => "pi" );
say $map.get-all(π); # "pi", "Real", "Numeric";
```

Gets all the values that match the argument in order of narrowness
(internally uses [cando](https://docs.perl6.org/type/Routine#method_cando))

### append(**@args)
``` perl6
my $map = DispatchMap.new( (Int,Array) => "Foo", (Cool) => "Bar" );
$map.append((Real,Real) => "Super Real!");
say $map.get(π,τ); #-> Super Real!
```

Sets some values of maps. Takes the arguments in the same format as `.new`.

### dispatch(|c)

``` perl6
my $map = DispatchMap.new(
        (Str:D,Str:D) => { $^a ~ $^b },
        (Iterable:D,Iterable:D) => { |$^a,|$^b },
        (Numeric:D,Numeric:D) => { $^a + $^b }
    );

say $map.dispatch("foo","bar"),"foobar"; #-> foobar
say $map.dispatch(<one two>,<three four>); #-> one two three four
say $map.dispatch(1,2); #-> 3
```

`.dispatch` works like `.get` except the if the result is a `Callable`
it will invoke it with the arguments you pass to `.dispatch`.
