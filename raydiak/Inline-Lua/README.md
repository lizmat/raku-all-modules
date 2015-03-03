# Inline::Lua

This is a Perl 6 module which allows execution of Lua code from Perl 6 code.

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

Reading and writing global variables can be done from Perl directly without
calling Lua code. Named global tables and be used as roles.

## To Do

The API is incomplete, and error reporting is crude. The "Inline::" part is
arguably NYI, as the present interface is object-oriented.

Composing roles from Lua objects doesn't work well when multiple Inline::Lua
instances are in use. This is because it would be difficult for the user to
provide the Lua table to mix in at composition time, so the table is specified
as a name to look up as a global variable. When using multiple instances, the
named global is always looked up in the most recently created instance.

Translation between Lua and Perl does not yet allow for writing new values to
tables from Perl, and does not implement binary userdata. Also, metatables are
mostly absent as a concept in the API and entirely untested, though they are
likely to behave as expected in most situations.

No provisions are made for growing Lua's stack beyond its initial size (which
defaults to 20). Therefore, passing deeply-nested data structures to Lua may
result in an overflow.

There is not yet any way to expose Perl constructs to inlined Lua code, other
than simple copy conversion when passing them in.

## Requirements

Any Rakudo backend with a NativeCall implementation is expected to work, but
testing has only been done under MoarVM on x86-64 Linux.

Compatible with Lua 5.1 and LuaJIT. Support for other versions of Lua is
planned.

Lua version is switched per Inline::Lua instance. To use LuaJIT explicitly
instead of auto-detecting it, pass :lua<JIT> to Inline::Lua.new(). To disable
the auto-detection without using LuaJIT, either pass another version (currently
only 5.1), or pass :!auto to use the default version without auto-detection.

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
::Table.

To use a table as a role, assign the table to a global variable (e.g. with
.set-global), and use it with the LuaParent role.

    role MyRole does LuaParent['global-table'] { ... }

To use a table as a class, LuaParent can be instantiated via .new(). To inherit
from a table, inherit from a class which composes the role, as inheriting from
a parameterized role doesn't seem to work. Note that using LuaParent with
multiple instances of Inline::Lua is unlikely to work correctly at this time.

Function object are also supported as Inline::Lua::Functions, and can be called
like normal perl routines. There is currently no checking of declared function
parameters on either the Perl or Lua sides, it simply assumes varargs
everywhere. This usually isn't a visible issue, other than arity-checking not
yet working as might be expected.

A new Perl object is created for each Lua value being returned, making it
useless for identity comparison on the Perl side (e.g. === on the same Lua
table returned from separate calls will be False).

Inline::Lua::Objects can of course be passed back in to Lua, and represent the
same referenced Lua table or function which they were originally attached to.

## Usage

*Note* everything here is accurate, but much is missing, mostly the API of the
::Object types (which is somewhat outlined above in Values). In the mean time,
also see the tests.

### method new ()

Creates, initializes, and returns a new Inline::Lua instance.

### method run (Str:D $code, \*@args)

Compiles $code, runs it with @args, and returns any resulting value(s).

### method call (Str:D $name, \*@args)

Calls the named global function with @args, and returns any resulting value(s).

To compile Lua code for subsequent use, pass it as a global function definition
to the .run method, then use .call to execute it.

### method get-global (Str:D $name)

Returns the value stored in the named global Lua variable.

### method set-global (Str:D $name, $value)

Sets the value of the named global Lua variable.

## Contact

https://github.com/raydiak/Inline-Lua

raydiak@cyberuniverses.com

raydiak on #perl6 on irc.freenode.net

