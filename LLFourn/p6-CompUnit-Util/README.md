<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
- [CompUnit::Util](#compunitutil)
  - [General Utilities](#general-utilities)
    - [load](#load)
    - [find-loaded](#find-loaded)
    - [all-loaded](#all-loaded)
    - [at-unit](#at-unit)
    - [unit-to-hash](#unit-to-hash)
    - [capture-import](#capture-import)
  - [Re-Exporting](#re-exporting)
    - [re-export](#re-export)
    - [re-exporthow](#re-exporthow)
    - [steal-export-sub](#steal-export-sub)
    - [steal-globalish](#steal-globalish)
    - [re-export-everything](#re-export-everything)
  - [Symbol setting](#symbol-setting)
    - [set-export](#set-export)
    - [set-globalish](#set-globalish)
    - [set-unit](#set-unit)
    - [set-lexical](#set-lexical)
    - [mixin_LANG](#mixin_lang)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# CompUnit::Util [![Build Status](https://travis-ci.org/LLFourn/p6-CompUnit-Util.svg?branch=master)](https://travis-ci.org/LLFourn/p6-CompUnit-Util)

Utility functions for introspecting `CompUnit`s and re-exporting their symbols.

Apart from `load` none of the routines here will load a compunit. All
parameters named `$handle` are converted to a `CompUnit::Handle`
automatically. If the `$handle` you pass is not a defined `CompUnit` or
`CompUnit::Handle`, `&find-loaded` will be used to search for an
loaded compunit matching it.

**warning** this module relies on unspec'd rakudo internals and could
break without warning

## General Utilities

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

Returns all presently loaded `CompUnit`s.

### at-unit
`($handle,Str:D $key)`

``` perl6
use CompUnit::Util :at-unit;
say at-unit('CompUnit::Util','$=pod');
```

Gets a symbol from the `UNIT` scope of the compunit.

### set-in-WHO
`($WHO,$key,$value)`

``` perl6
use CompUnit::Util :set-in-who;
my package Example {};
BEGIN set-in-who(Example.WHO,'Foo::Bar::Baz','win');

say Example::Foo::Bar::<$Baz>; #-> win
```

Convenience routine for setting a symbol's value inside a package that
might not exist yet. Only useful outside the currently
compiling compunit (where you can just use the normal syntax).

### descend-WHO
`($WHO,Str:D $path)`

``` perl6
my package Example {};
BEGIN set-in-who(Example.WHO,'Foo::Bar::Baz','win');
BEGIN note descend-who(Example.WHO,'Foo::Bar::Baz'); #-> win
```

Convenience routine for getting a symbol's value with a path from a
`Stash` like `.WHO`. Only useful outside the currently compiling
compunit (where you can just use the normal syntax).

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

### set-export
`(%syms, :$tag = 'DEFAULT')`

```perl6
# anything that imports from this module will export &foo under DEFAULT
sub EXPORT {
    use CompUnit::Util :set-export;
    set-export( %( '&foo' => my sub foo { } ) );
    {};
}
```

Inserts name/value pairs into the present `UNIT::EXPORT` under `$tag`.

### set-globalish
`(%syms)`

```perl6
# inserts a class under a dynamic name into GLOBALish
sub EXPORT($name) {
    use CompUnit::Util :set-export;
    set-globalish( %( $name => my class { } ) );
    {};
}
```
Inserts the name/value pairs into the present `GLOBALish`.

**this routine can only be called at `BEGIN` time**

### set-unit
`(%syms)`

```perl6
# inserts a class under a dynamic name into UNIT

sub EXPORT($name) {
    use CompUnit::Util :set-export;
    set-unit( %( $name => my class { } ) )
    {};
}
```

Inserts the name/value pairs into the present `UNIT`.

**this routine can only be called at `BEGIN` time**

### set-lexical
`(%syms)`

``` perl6
# inserts a class under a dynamic name into lexical scope
sub EXPORT($name) {
    use CompUnit::Util :set-export;
    set-lexical( %( $name => my class { } ) );
    {};
}
```

Inserts the name/value pairs into the present lexical scope being
compiled.

**this routine can only be called at `BEGIN` time**

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

Modifies the `%*LANG` of the present lexical scope being compiled.
Presently this is the best way to modify rakudo's parser and create a
*slang*. You will need to know about
[QAST](https://github.com/perl6/nqp/blob/master/docs/qast.markdown) to
do anything useful with this.

**this routine can only be called at `BEGIN` time**
