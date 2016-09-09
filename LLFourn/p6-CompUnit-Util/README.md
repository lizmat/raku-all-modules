# CompUnit::Util [![Build Status](https://travis-ci.org/LLFourn/p6-CompUnit-Util.svg?branch=master)](https://travis-ci.org/LLFourn/p6-CompUnit-Util)

Utility functions for introspecting `CompUnit`s and re-exporting their symbols.

- [CompUnit Utilities](#general-utilities)
  - [load](#load)
  - [find-loaded](#find-loaded)
  - [all-loaded](#all-loaded)
  - [at-unit](#at-unit)
  - [unit-to-hash](#unit-to-hash)
  - [capture-import](#capture-import)
- [WHO Utilities](#who-utilities)
  - [descend-WHO](#descend-who)
  - [set-in-WHO](#set-in-who)
- [Re-Exporting](#re-exporting)
  - [re-export](#re-export)
  - [re-exporthow](#re-exporthow)
  - [steal-export-sub](#steal-export-sub)
  - [steal-globalish](#steal-globalish)
  - [re-export-everything](#re-export-everything)
- [Symbol Setting](#symbol-setting)
  - [set-unit](#set-unit)
  - [set-lexpad](#set-lexical)
- [Symbol Getting](#symbol-getting)
  - [get-unit](#get-unit)
  - [get-lexpad](#get-lexpad)
  - [get-lexical](#get-lexical)
- [Dispatcher Manipulation](#dispatcher-manipulation)
  - [push-multi](#push-multi)
  - [push-unit-multi](#push-unit-multi)
  - [push-lexpad-multi](#push-lexpad-multi)
  - [push-lexical-multi](#push-lexical-multi)
- [Slangs](#slangs)
  - [mixin_LANG](#mixin_lang)

CompUnit::Util contains set of utilities to introspect `CompUnit`
stuff and a bunch of compile time symbol manipulation tools. Its main
purpose is to encapsulate the compiler hacks needed to implement
features like 're-exporting' which don't exist in rakudo yet.

The API should now be stable enough to use.

**warning** this module relies on unspec'd rakudo internals and could
break without warning

## CompUnit Utilities

`CompUnit` introspection utilities.

Apart from `load` none of the routines here will load a compunit. All
parameters named `$handle` are converted to a `CompUnit::Handle`
automatically. If the `$handle` you pass is not a defined `CompUnit`
or `CompUnit::Handle`, `&find-loaded` will be used to search for an
loaded compunit matching it.

**warning** because of RT
 [#127302](https://rt.perl.org/Public/Bug/Display.html?id=127302), you
 should be very careful about manipulating `CompUnit` and
 `CompUnit::Handle` objects within `BEGIN` blocks. `CompUnit::Handle`s
 cannot be serialized at the moment. For example,

``` perl6
use CompUnit::Util :load;
BEGIN load('SomeModule');
```
should be written as

``` perl6
use CompUnit::Util :load;
BEGIN {
    load('SomeModule');
    Nil;
}
```

### load
`(Str:D $short-name,*%opts --> CompUnit:D)`

``` perl6
use CompUnit::Util :load;
my CompUnit $cu = load('Test');
# or even
my $cu = load('MyModule', version => v3);
```

Loads a compunit by name. All named arguments to
`CompUnit::DependencySpecification` are accepted (other than
`short-name` which is the positional argument). At the moment `load`
is just short for:

``` perl6
$*REPO.need(CompUnit::Dependencyspecification.new(:short_name<MyModule>));
```

### find-loaded
`($match --> CompUnit)`

``` perl6
use CompUnit::Util :find-loaded;
need SomeModule;
my CompUnit $some-module = find-loaded('SomeModule');
```

Searches all the `CompUnit::Repository`s until it finds a loaded
compunit matching `$match`. Returns a failure otherwise.

### all-loaded

```perl6
use CompUnit::Util :all-loaded;
.note for all-loaded;
```

Returns all loaded `CompUnit`s.

### at-unit
`($handle,Str:D $key)`

``` perl6
use CompUnit::Util :at-unit;
say at-unit('CompUnit::Util','$=pod');
```

Gets a symbol from the `UNIT` scope of the compunit. If you want to do
this at compile time while a compunit is loading see [get-unit](#get-unit).

### unit-to-hash
`($handle)`

``` perl6
use CompUnit::Util :unit-to-hash;
my %unit := unit-to-hash('SomeModule');
```

returns a `Hash` representing the `UNIT::` of the module.

### capture-import
`($handle, *@pos, *%named --> Hash:D)`

``` perl6
use CompUnit::Util :capture-import;
need SomeModule;
my %symbols = capture-import('SomeModule',:tag);
```

Attempts to simulate a `use` statement. Returns a hash of all the
symbols the compunit would export if it were `use`d.

## WHO Utilities

### set-in-WHO
`($WHO,$key,$value)`

``` perl6
use CompUnit::Util :who;
my package Example {};
BEGIN set-in-WHO(Example.WHO,'Foo::Bar::$Baz','win');

say Example::Foo::Bar::<$Baz>; #-> win
```

Convenience routine for setting a symbol's value inside a package that
might not exist yet. Only useful outside the compunit being compiled.

### descend-WHO
`($WHO,Str:D $path)`

``` perl6
use CompUnit::Util :who;
my package Example {};
BEGIN set-in-WHO(Example.WHO,'Foo::Bar::Baz','win');
BEGIN note descend-WHO(Example.WHO,'Foo::Bar::Baz'); #-> win
```

Convenience routine for getting a symbol's value with a path from a
`Stash` like `.WHO`. Only useful outside the currently compiling
compunit (where you can just use the normal syntax).

## Re-Exporting

The following routines provide re-exporting which is not yet implemented in rakudo.

### re-export
`($handle)`

``` perl6
use CompUnit::Util :re-export;
need SomeModule;
BEGIN re-export('SomeModule');
# This compunit will now export everything that SomeModule does
```

Merges the `EXPORT` package from `$handle` into the
present `UNIT::EXPORT`.

**this routine can only be called at `BEGIN` time**

### re-exporthow
`($handle)`

``` perl6
use CompUnit::Util :re-export;
need SomeModule;
BEGIN re-exporthow('SomeModule');
# This compunit now exports SomeModule's custom declarators
```

Merges the `EXPORTHOW` from `$handle` into the present
`UNIT::EXPORTHOW`. `UNIT::EXPORTHOW` will be created if it doesn't
exist but it won't clobber it if it does.

**this routine can only be called at `BEGIN` time**

### steal-export-sub
`($handle)`

``` perl6
use CompUnit::Util :re-export;
need SomeModule;
BEGIN steal-export-sub('SomeModule');
# This compunit now has the same &EXPORT as SomeModule
```

Sets `UNIT::<&EXPORT>` to `$handle`'s `&EXPORT`.

**this routine can only be called at `BEGIN` time**

### steal-globalish
`($handle)`

``` perl6
use CompUnit::Util :re-export,:load;
BEGIN steal-globalish(load('SomeModule'));
# This compunit now has everything in SomeModule in it's globalish
```

Merges the `GLOBALish` from `$handle` intot he present `UNIT::GLOBALish`.

This is the least interesting of all the re-exports, and if you've
already done `need SomeModule;` you won't need it. But it's here for
completeness. The above example should be the same as this anyway:

``` perl6
BEGIN require ::('SomeModule');
```

**this routine can only be called at `BEGIN` time**

### re-export-everything
`($handle)`

``` perl6
use CompUnit::Util :re-export;
BEGIN re-export-everything('SomeModule');
# use [this-module]; should now do the same thing as use SomeModule;
```

A convenience method for calling all the other functions under
re-export functions with the same argument.

**this routine can only be called at `BEGIN` time**

## Symbol setting

The following routines manipulate the symbols of the compunit being
compiled. They are probably of most use inside an `&EXPORT` sub or in
a trait.

They each take a map of symbol names to values and install them in
different places.

**note:** These subs will overwrite existing symbols without warning.

Inserts name/value pairs into the present `UNIT::EXPORT` under `$tag`.

### set-unit
`(Str:D $path,Mu $value)`

```perl6
# like is export, but prefixes the the exported name with 'fun-'
sub trait_mod:<is>(Routine:D $r, :$export-fun!) {
    my $exported-name = '&fun-' ~ $r.name;
    set-unit("EXPORT::DEFAULT::{$exported-name}",$r);
    {};}
```

Inserts the `$value` at `$path` in `UNIT` of the currently compiling
compunit.

**this routine can only be called at `BEGIN` time**

### set-lexpad
`(Str:D $path,Mu $value)`

The same as `set-unit` but inserts the $value into the lexical
scope being compiled.

**this routine can only be called at `BEGIN` time**

## Symbol Getting

### get-unit
`(Str:D $path)`

``` perl6
use CompUnit::Util :get-symbols;
sub foo is export { };
BEGIN note get-unit('EXPORT::DEFAULT::&foo') === &foo; #-> True
```

### get-lexpad
`(Str:D $path)`

The same as `get-unit` but looks for the symbol in the lexpad
being compiled.

### get-lexical
`(Str:D $name)`

Like `get-lexpad` but does a full lexical lookup. At the moment it can
only take a single `$name` with no `::`.

## Dispatcher Manipulation

These routines help you construct `multi` dispatchers *candidate by
candidate* in a procedural manner. Useful when you want to construct a
trait that adds a multi candidate each time it's called. Parameters
marked `$multi` can be any `Routine:D`. If you pass a dispatcher it
will just use it as the dispatcher or die if you are trying to push
onto an existing dispatcher.

If you try and push a non-multi/dispatcher onto an empty slot it will
not vivify one for you.

### push-multi
`(Routine:D $target where { .is_dispatcher },Routine:D $candidate)`

Adds the `$candidate` onto `$target`.

``` perl6
use CompUnit::Util :push-multi;
multi foo('one') { 'one' }
multi foo('two') { 'two' }

&foo.&push-multi(sub ('three') { "win" });
say foo('three') #-> "win"
```

**note** This is NYI in rakudo. The design docs says that protos should have a
`.push` method. see [S06](https://design.perl6.org/S06.html#Introspection).

### push-unit-multi
`(Str:D $path,Routine:D $mutli)`

``` perl6
## lib/SillyModule.pm6
use CompUnit::Util :push-multi
# exports the multi under a sub named after its first letter
sub trait_mod:<is>(Routine:D $r,:$one-letter-export!) {
    my $exported-name = '&' ~ $r.name.comb[0];
    push-unit-multi("EXPORT::DEFAULT::{$exported-name}",$r);
}

multi bar(Str) is one-letter-export { say "bar" }
multi baz(Int) is one-letter-export { say "baz" }

...
use SillyModule;

b("string"); #-> bar
b(1) #-> baz

```

Takes `$multi` and pushses it onto a dispatcher located at `$path`. If
one doesn't exist it will be created. You can pass a `proto` instead
of a multi but only when `$path` is empty (ie only the first time). It
will become the dispatcher for any further calls.

**this routine can only be called at `BEGIN` time**

### push-lexpad-multi

`(Str:D $path,Routine:D $mutli)`

The same as `push-unit-multi` but pushes onto a symbol in the lexical
scope currently being compiled.

**this routine can only be called at `BEGIN` time**

### push-lexical-multi

`(Str:D $name,Routine:D $mutli)`

The smart version of `push-lexpad-multi`. If it doesn't find a
dispatcher in the current lexpad it will do a lexical lookup for one
of the same `$name`. If it finds one it clones it, installs it in the
current lexpad and pushes `$multi` onto it. Like
[get-lexical](#get-lexical), it can't take a `$name` with `::` in it.

**this routine can only be called at `BEGIN` time**

## Slangs

### mixin_LANG
`($lang = 'MAIN',:$grammar,:$actions)`

``` perl6
# modifies the parser to create a term called foo which
# returns 'foo'. Obviously this is what sub term:<foo> { } is for, but this
# is the hard way to do it
sub EXPORT {
    use nqp;
    use QAST:from<NQP>;
    use CompUnit::Util :mixin-LANG;
    mixin_LANG(
        grammar => role {
            token term:sym<foo> { <sym> <.tok> }
        },
        actions => role {
            method term:sym<foo>(Mu $/){
                return $/.'!make'(QAST::SVal.new(:value("foo")));
            }
        }
    );
    {};
}
```

Modifies the `%*LANG` of the lexical scope currently being compiled.
Presently this is the best way to modify rakudo's parser and create a
*slang*. You will need to know about
[QAST](https://github.com/perl6/nqp/blob/master/docs/qast.markdown) to
do anything useful with this.

**this routine can only be called at `BEGIN` time**
