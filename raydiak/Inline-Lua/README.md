# Inline::Lua

This is a Perl 6 module which allows execution of Lua code from Perl 6 code.

## Synopsis

    use Inline::Lua;
    # or use Inline::Lua::JIT;

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

    my $func = "function sum (...)\n $code\n end";
    $L.run: $func;

    $sum = $L.call: 'sum', $arg;

    # OR

    my &sum = $L.get-global: 'sum';
    $sum = sum $arg;

    say $sum;

## Status

Both Lua 5.1 and LuaJIT are supported. Evaluating Lua code works. A LuaJIT demo
game split across several files with OpenGL and SDL FFI bindings was even
successfully tested.

Any number of values can be passed to and returned from Lua. Simple values
(boolean, nil, number, string) all work. Tables work with some conversion
caveats. See Values further down.

Reading and writing global variables can be done from Perl directly without
calling Lua code, and global functions can be called or wrapped in a Perl
routine for later (re)use.

## To Do

The API is incomplete, and error reporting is crude. The "Inline::" part is
arguably NYI, as the present interface is object-oriented.

There is no auto-detection of available Lua versions, and switching between
them isn't composable; see Requirements below.

Translation between Lua and Perl has no concept of references yet.
Particularly, this makes it mostly impossible to use tables as objects or
classes from Perl; see Values further down.

No provisions are made for growing Lua's stack beyond its initial size (which
defaults to 20). Therefore, passing deeply-nested data structures to Lua may
result in an overflow.

## Requirements

Any Rakudo backend with a NativeCall implementation is expected to work, but
testing has only been done under MoarVM on x86-64 Linux.

Compatible with Lua 5.1 and LuaJIT. Support for other versions of Lua is
planned.

To use LuaJIT, you can load Inline::Lua with

    use Inline::Lua::JIT;

or

    use Lua::Raw <JIT>;
    use Inline::Lua;

The version is determined the first time Inline::Lua (or Lua::Raw) is loaded;
subsequent "use" calls will have no effect on it. As such, it is currently not
possible to use different Lua versions from different modules, scopes, etc.

## Values

Inline::Lua currently allows passing and returning any number of boolean,
number, string, table, and nil values, according to the following table.

    Lua     from Perl               to Perl
    nil     * where {!.defined}     Any
    boolean Bool                    Bool
    number  Numeric                 Num
    string  Stringy                 Str
    table   Positional|Associative  Hash[Any, Any]

Functions, userdata, and any other types are not implemented, though a Perl
wrapper can be returned for a global function; see the get-global method below.

In Lua, there is no difference between Positional and Associative containers;
both are a table. Lua tables use 1-based indexing when acting as an array, so
Positional objects passed in from Perl will have Integer indices increased by
one in the resulting table.

Tables returned from Lua are directly mapped to object hashes; there is no
attempt at array detection or index adjustment, since hashes and arrays coming
from Lua can't be reliably distinguished. The object hash is keyed by the same
conversions as everything else which means, of particular note, numeric keys
are Perl Nums instead of Ints. In the future a table will be represented as an
object which implements both Positional and Associative interfaces, similar to
a Perl 6 Capture.

In contrast to tables, multiple Lua return values (not packed in a table) will
result in an ordinary Perl list instead of an object hash.

A new Perl object is created for each Lua value being returned, making it
useless for identity comparison (e.g. === on the same Lua table returned from
separate calls will be False).

## Usage

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

If the value is a function, it returns a Perl wrapper routine which calls the
function as if .call had been used. Note this means the function is looked up
by name for each call; if the variable changes, any of its wrappers will
attempt to call the new value (even if it isn't a function). As with other
values, a separate wrapper object is returned for every call to this method.

### method set-global (Str:D $name, $value)

Sets the value of the named global Lua variable.

## Contact

https://github.com/raydiak/Inline-Lua

raydiak@cyberuniverses.com

raydiak on #perl6 on irc.freenode.net

