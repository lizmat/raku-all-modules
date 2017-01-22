# DispatchMap

A map that uses Perl 6 multi dispatch to link keys to values

## Synopsis

``` perl6
need DispatchMap;

my $map = DispatchMap.new(
         foo => (
           (Int) =>  "an Int!",
           (subset :: of Int:D where * > 5) => "Wow, an Int greater than 5",
           ("literal text")           => "The text 'literal text'",
           (π)               => "pi",
           (Str)             => "one string",
           (Stringy)         => "something stringy",
           (Str,Str)         => "two strings";
         ),
         bar => ( (τ) => "Tau > pi" )).compose;

say $map.get("foo",2); #-> an Int!
say $map.get("foo",6); #-> Wow, an Int greater than 5
say $map.get("foo","literal text"); #-> A literal foo;
say $map.get-all("foo","literal text"); #-> ("The text 'literal text'","one string","something stringy");
say $map.get("foo",π); #-> pi
say $map.get("foo","one","two"); #-> two strings
say $map.get("bar",τ); # Tau > pi
```

## Description

**warning** this is module is experimental and subject to change

**warning** this module uses unspec'd rakudo internals and could break without warning

Perl 6 has a very sophisticated routine dispatch system based on
finding the candidate that matches the call's arguments most
narrowly. Unfortunately there is no way (yet) to make use of the
dispatching logic outside of routine calls. This module exposes that
logic in a map like interface.

The following are different ways of achieving the same result:

``` perl6
# Using builtin dispatchers
class Parent {
    multi method foo(Str:D $str) { "a string: $str" }
    multi method foo(Int:D $int) { "an int: $int"   }
    multi method foo(42)         { "a special int"  }
}

say Parent.foo("lorem");
say Parent.foo(42);
my $meth = Stuff.find_method("foo").cando(\("lorem"))[0];

class Child is Parent {
    multi method foo(π) { "pi"  }
}

say Child.foo(π);
say Child.foo(42);
```


```perl6
# Using DispatchMap
use DispatchMap;
my $parent = DispatchMap.new(
    foo => (
        (Str:D) => -> $str { "a string: $str" },
        (Int:D) => -> $int { "an int: $int" },
        (21 + 21)    => -> $int { "a special int" }
    )
).compose;

say $parent.dispatch("foo","lorem");
say $parent.dispatch("foo",42);
my $block = $map.get("foo","lorem");

my $child = DispatchMap.new
.add-parent($parent)
.append(foo => ( (π) => { "pi" } ))
.compose;


say $child.dispatch('foo',π);
say $child.dispatch('foo',42);
```

The main use of a DispatchMap is to create method signatures at
runtime that dispatch in the same order as normal methods. Internally,
DispatchMap creates new meta-objects at runtime and attaches methods
to them with signatures created from the keys with nqp. As a result,
`.compose` must be called before the DispatchMap can be used

## Methods

### new(*%namespaces)

```perl6
my $map = DispatchMap.new(
  foo => ((Int,Array) => "Foo", (Cool) => "Bar") ),
  bar => ((Str) => "Baz")
);
#or
my $map = DispatchMap.new(
  foo => ((Int,Array),"Foo",(Cool),"Bar"),
  bar => ( (Str), "Baz" )
);
#or
my $map = DispatchMap.new(
  foo => [(Int,Array),"Foo",(Cool),"Bar"],
  bar => [ (Str),"Baz" ]
);
```

Makes a new DispatchMap where the keys are the namespaces and the
values are signature-value pairs.

Presently, the psudo-signatures you pass to `.new` and `.append` are limited to
non-slurpy positional parameters. If it's passed a type object that
will be used as the nominal type of the parameter. If a literal is
passed the `.WHAT` of the object is used as the nominal type and the
literal is used as a `where` constraint.

**note** you won't be able to use the map until you've called `compose`.

### compose

``` perl6
my $map = DispatchMap.new(
  foo => ((Int,Array) => "Foo", (Cool) => "Bar") ),
  bar => ((Str) => "Baz")
).compose;
```

Composes the dispatcher.

### namespaces

``` perl6
my $map = DispatchMap.new(
  foo => ((Int,Array) => "Foo", (Cool) => "Bar") ),
  bar => ((Str) => "Baz")
).compose;
say $map.namespaces; #-> foo, bar
```

Gets the all the namespaces in the DispatchMap. Won't work until
`.compose` has been called.

### keys(Str:D $ns)

```perl6
my $map = DispatchMap.new( foo => ((Int,Array) => "Foo", (Cool) => "Bar") ).compose;
say $map.keys('foo'); #-> (Int,Array),(Cool)
```

Gets the keys for a namepsace as a list of lists. Won't work until
`.compose` has been called.

### values(Str:D $ns)

```perl6
my $map = DispatchMap.new( foo => ((Int,Array) => "Foo", (Cool) => "Bar") ).compose;
say $map.values('foo'); #-> (Int,Array),(Cool)
```

Gets the values for a name pace. Won't work until `.compose` has been called.

### pairs(Str:D $ns)

```perl6
my $map = DispatchMap.new( foo => ((Int,Array) => "Foo", (Cool) => "Bar") ).compose;
say $map.pairs('foo'); #-> (Int,Array) => "Foo",(Cool) => "Bar"
```

Gets the key-value pairs for a namespace. Won't work until `.compose` has been called.

### list(Str:D $ns)

```perl6
my $map = DispatchMap.new( foo => ((Int,Array) => "Foo", (Cool) => "Bar") ).compose;
say $map.list('foo'); #-> (Int,Array),"Foo",(Cool),"Bar"
```

Returns a list of keys and values for a namespace. Won't work until `.compose` has been called.

### get(Str:D $ns,|c)

``` perl6
my $map = DispatchMap.new( foo => ((Int,Array) => "Foo", (Cool) => "Bar") ).compose;
say $map.get('foo',1,["one","two"]); #-> Foo
```

Dispatches to a namespace, returning the associated value. The capture
of the arguments after the namespace is used as the key.

Won't work until `.compose` has been called.

**note** this method won't dispatch properly until after `.compose` has been called

### get-all(Str:D $ns,|c)

``` perl6
my $map = DispatchMap.new(
  number-types => (
    Numeric => "A number",
    Real => "A real number",
    Int => "An int",
    (π)  => "pi"
  )
).compose;
say $map.get-all('number-types',π); # "pi", "Real", "Numeric";
```

Dispatches to a namespace, returning the values that match the capture in order of narrowness
(internally uses [cando](https://docs.perl6.org/type/Routine#method_cando)). The capture
of the arguments after the namespace is used as the key.

**note** this method won't dispatch properly until after `.compose` has been called

### dispatch(Str:D $ns,|c)

``` perl6
my $map = DispatchMap.new(
  abstract-join => (
    (Str:D,Str:D) => { $^a ~ $^b },
    (Iterable:D,Iterable:D) => { |$^a,|$^b },
    (Numeric:D,Numeric:D) => { $^a + $^b }
  )
).compose;

say $map.dispatch('abstract-join',"foo","bar"),"foobar"; #-> foobar
say $map.dispatch('abstract-join',<one two>,<three four>); #-> one two three four
say $map.dispatch('abstract-join',1,2); #-> 3
```

**note** this method won't dispatch properly until after `.compose` has been called

### append(*%namespaces)
``` perl6
my $map = DispatchMap.new( my-namespace => ((Int,Array) => "Foo", (Cool) => "Bar") );
$map.append(my-namespace => ((Real,Real) => "Super Real!")).compose;
say $map.get('my-namespace',π,τ); #-> Super Real!
```

Appends the values to the corresponding namespaces. Takes the
arguments in the same format as `.new`.

**note** this method won't affect dispatching until `.compose` is called

`.dispatch` works like `.get` except the if the result is a `Callable`
it will invoke it with the arguments you pass to `.dispatch` and return the result.


### ns-meta(Str:D $ns) is rw

``` perl6
my $map = DispatchMap.new(
   foo => (
     (Real,Str) => "real str",
     (Int,Str) => "int str",
   ),
   bar => ((Int,Int) => "int int")
).compose;

$map.ns-meta('foo') = "foo stores some number and string dispatches";
$map.ns-meta('bar') = "bar just has some ints";

```

Returns a writeable container associated with the given namespace. You
can think of this a map that runs in parallel to the dispatching
map. it is inherited by child DipatchMaps and overwritten by
`.override`.

`ns-meta` will work before or after `.compose` has been called.

### add-parent(DispatchMap:D $parent)

``` perl6
my $parent = DispatchMap.new(
  number-types => (
    (Numeric) => "A number",
    (Int) => "An int",
  )
).compose;

my $child = DispatchMap.new
.add-parent($parent)
.append( number-types => ( (π) => "pi" ),)
.compose;

say $child.get('number-types',3.14); #-> A number
say $parent.get('number-types',π); #-> A number
say $child.get('number-types',π); #-> pi
```

Makes another DispatchMap the parent of the DispatchMap. This means
the internal object used to hang methods on will inherit from the parent.

**note** Will error if `.compose` has already been called.

### override(*%namespaces)

``` perl6
my $parent = DispatchMap.new(
  number-types => (
    (Numeric) => "A number",
    (Int) => "An int",
  )
).compose;

my $child = DispatchMap.new
.add-parent($parent)
.override( number-types => ( (π) => "pi" ) )
.compose;


say $child.get('number-types',3.14); #-> Nil
say $child.get('number-types',π); #-> pi
```

Overrides the dispatcher for a namepsace rather than adding to
it. Overridden namespaces also have their `.ns-meta` cleared.

**note** this method won't affect dispatching until `.compose` is called
