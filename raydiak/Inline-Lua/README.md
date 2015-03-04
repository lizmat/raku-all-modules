# Inline::Lua

This is a Perl 6 module which allows execution of Lua code from Perl 6 code
with inspiration, APIs, and techniques from Inline::Perl5 and Inline::Python.

## Synopsis

    use Inline::Lua;

    my $L = Inline::Lua.new;

    my $code = q:to/END/;
        local args = {...}
        local n = 0

        for i = 1, args[1] do
            n = n + i
        end

        return n
    END
    my $arg = 1e8;
    my $sum;

    $sum = $L.run: $code, $arg;

    # OR

    $L.run: "function sum (...)\n $code\n end";
    $sum = $L.call: 'sum', $arg;

    # OR

    my &sum = $L.get-global: 'sum';
    $sum = sum $arg;

    say $sum;

## Status

Both Lua 5.1 and LuaJIT are supported. Evaluating Lua code works. A LuaJIT demo
game split across several files with OpenGL and SDL FFI bindings was even
successfully tested. LuaJIT can be explicitly enabled or disabled, but by
default will be auto-detected (which adds a little to loading time, regardless
of precompilation).

Any number of values can be passed to and returned from Lua. Simple values
(boolean, nil, number, string) all work. Tables work as arrays, hashes,
objects, and roles. Functions work as values, subs, and methods. See Values
further down.

Accessing referenced objects, table fields, and global variables can be done
from Perl without calling Lua code. Named global tables can be used as roles.

## To Do

The API is incomplete, and error reporting is crude. The "Inline::" part is
arguably NYI, as the present interface is object-oriented.

Composing roles from Lua objects doesn't work well when multiple Inline::Lua
instances are in use. This is because it would be extremely difficult for the
user to provide the Lua table object itself at composition time and still have
their own code survive precompilation, so the table is specified as a name to
look up at runtime as a global variable. When using multiple instances, the
named global is looked up in the most recently created Inline::Lua instance,
which is stored in the Inline::Lua.default-lua class attribute.

Translation between Lua and Perl does not yet allow for writing new values to
tables from Perl, and does not implement binary userdata. Also, metatables are
mostly absent as a concept in the API and entirely untested, though they are
likely to behave as expected in most situations, except for operator
overloading when using Lua tables from Perl code.

There is not yet any way to expose Perl-native constructs to Lua code, other
than simple copy conversion when passing them in. Directly accessing Perl data
structures and calling Perl code from Lua is not implemented.

No provisions are made for growing Lua's stack beyond its initial size (which
defaults to 20). Therefore, passing deeply-nested data structures to Lua may
result in an overflow.

## Requirements

Any Rakudo backend with a NativeCall implementation is expected to work, but
testing has only been done under MoarVM on x86-64 Linux.

Compatible with Lua 5.1 and LuaJIT. Support for other versions of Lua is
planned.

Lua version is switched per Inline::Lua instance automatically, by trying JIT
first and falling back to standard Lua 5.1. To skip autodetection and use
LuaJIT explicitly, pass :lua<JIT> to Inline::Lua.new(). To disable the
auto-detection without using LuaJIT, either pass another version (currently
only 5.1), or pass :!auto to use the non-JIT default.

To point to a specific library instead of only trying the standard name and
library paths, :lib can be passed to Inline::Lua.new to specify a more explicit
name/path. In this case all auto-detection is disabled and :lua is ignored.

## Values

Inline::Lua currently allows passing and returning any number of boolean,
number, string, table, function, and nil values, according to the following
table.

    Lua         from Perl               to Perl
    nil         * where {!.defined}     Any
    boolean     Bool                    Bool
    number      Numeric                 Num
    string      Stringy                 Str
    table or    any( Positional,        Inline::Lua::Object; either:
      function  Associative,                Inline::Lua::Table
                Inline::Lua::Object )       Inline::Lua::Function

In Lua, there is no difference between Positional and Associative containers;
both are a table. Lua tables use 1-based indexing when acting as an array, so
Positional objects passed in from Perl will have Integer indices increased by
one in the resulting table.

Tables returned from Lua are exposed as Inline::Lua::Table instances, which can
be accessed directly with hash or array subscripts (including slicing),
converted to a .hash or .list, or used as an object (or role via LuaParent).
Positional access will apply the appropriate index adjustment. Passing any
Numeric value to either subscripting operation will coerce it to some variety
of Num in the process, as Lua values are double-precision floats by default.

In contrast to tables, multiple return values (not packed in a table) from Lua
back to Perl will result in an ordinary Perl list instead of an
Inline::Lua::Table.

The Inline::Lua::Table object is actually an interface to the instance of the
table in Lua, so all access to it calls into Lua immediately. Calling .list or
.hash returns a Perl copy of the current state of the table, which is no longer
tied to the underlying Lua object.

Calling any method on the object which isn't found from Perl will attempt to
call the method in the table, since tables also serve as objects and classes in
Lua. You can also call .obj to get an Inline::Lua::TableObj, which has no
methods other than the ones inherited from Mu and Any, to minimize conflicts.
The exception is ::TableObj.inline-lua-table which returns the original
::Table. In spite of these measures, several public methods with short, common
names are required for a class to function in Rakudo. ::Table.invoke is
provided to access a Lua method or attribute with one of these names, which
takes the method name as its first positional argument. .invoke() also bypasses
most of the overhead of searching the Perl object's entire MRO before falling
back to Lua.

To use a table as a role, assign the table to a global variable (e.g. with
.set-global), and use it with the LuaParent role.

    role MyRole does LuaParent['global-table'] { ... }

To use a table as a class, LuaParent can be instantiated via .new(). To inherit
from a table, inherit from a class which composes the role, as inheriting from
a parameterized role doesn't seem to work. Using LuaParent with multiple
instances of Inline::Lua is unlikely to work correctly; see To Do above.

Function object are also supported as Inline::Lua::Functions, and can be called
like normal Perl routines. There is currently no checking of declared function
parameters on either the Perl or Lua sides; it simply assumes varargs
everywhere. This usually isn't a visible issue, other than arity-checking not
yet working as might be expected.

Attributes and methods are semantically equivalent in Lua, and accessing them
as one or the other is syntactically ambiguous in Perl. Consider the case of
"$bar = $foo.bar": is it getting the result of a method call, or an attribute's
stored value? In Perl 6 it doesn't matter because public methods are exposed
via accessor routines, and also because methods and attributes are declared
differently. Since Lua doesn't have the Perl 6 "method vs has" distinction, but
Perl folks will expect to be able to do either thing with the same-looking
syntax, Inline::Lua will call a function rather than return it from an
attribute access. This extra call only happens for method-looking access to
Inline::Lua::Tables (either by delegation or by .invoke). By contrast, when it
is retrieved as a hash or table element, or returned from Lua code or
.get-global(), you will always get the value directly, even if it is an
Inline::Lua::Function. Auto-calling can also be disabled by passing :!call with
the invocation. These considerations are only noticeable in cases where method
access is desired to retrieve a function object (e.g. a callback which isn't
meant to be used as a method). As accessors are ubiquitous in Perl 6, any of
the method call forms including .invoke() also work perfectly well for
non-function attributes, and will simply return the value.

A new Perl object is created for each Lua value being returned, making it
useless for identity comparison on the Perl side (e.g. === on the same Lua
table returned from separate calls will be False).

Inline::Lua::Objects can of course be passed back in to Lua, and represent the
same referenced Lua table or function which they were originally attached to.

## Usage

### Inline::Lua

Represents a Lua instance with it's own global environment. Multiple
Inline::Lua instances may be used, but passing ::Objects between different
instances is not supported, and using LuaParent does not work well with
multiple instances (both of which are described further down).

#### method new ()

Creates, initializes, and returns a new Inline::Lua instance with the standard
Lua libraries loaded.

#### method run (Str:D $code, \*@args)

Compiles $code, runs it with @args, and returns any resulting value(s).

#### method call (Str:D $name, \*@args)

Calls the named global function with @args, and returns any resulting value(s).

To compile Lua code for subsequent use, pass it as a global function definition
to the .run method, then use .call to execute it.

#### method get-global (Str:D $name)

Returns the value stored in the named global Lua variable.

#### method set-global (Str:D $name, $value)

Sets the value of the named global Lua variable.

### Inline::Lua::Object

Base role for values which Lua regards as "objects" (tables and functions are
currently implemented). This role manages references and allows the object to
be pushed on to the Lua stack, none of which is part of the intended public
interface. The object types can not be meaningfully instantiated from Perl at
this time, rather they always result from a value being returned to Perl from
Lua.

### Inline::Lua::Function

A Lua function which can be called directly from Perl. It is a Callable object
and so can be invoked like any other Routine, and can be stored in an &-sigiled
variable. Parameters are exposed in Perl as slurpy positionals with no current
regard for the actual parameter list of the Lua function.

### Inline::Lua::Table

A table in Lua represents the concepts which Perl regards as variously arrays,
hashes, objects, classes, roles, and more. Therefore this type attempts to
provide an interface as all of these things. Underneath, however, all calls to
a ::Table perform the operation on the referenced Lua table, not a Perl copy.

### TODO finish documenting Table, TableObj, and LuaParent.

## Contact

https://github.com/raydiak/Inline-Lua

raydiak@cyberuniverses.com

raydiak on #perl6 on irc.freenode.net

