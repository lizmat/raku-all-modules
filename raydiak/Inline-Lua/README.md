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

    # TODO show off tables

## Requirements

Any Rakudo backend with a NativeCall implementation is expected to work, but
testing has only been done under MoarVM on x86-64 Linux.

Compatible with Lua 5.1 and LuaJIT. Support for other versions of Lua is
planned.

## Status

Both Lua 5.1 and LuaJIT are supported. Evaluating Lua code works. A LuaJIT demo
game split across several files with OpenGL and SDL FFI bindings was even
successfully tested. LuaJIT can be explicitly enabled or disabled, but by
default will be auto-detected (which adds a little to loading time, regardless
of precompilation).

Any number of values can be passed to and returned from Lua. Simple values of
boolean, nil, number, string, and light userdata all work. Most common object
types work as well: table, function, full userdata, and cdata. Tables can be
accessed as arrays, hashes, objects, and roles. Functions work as values, subs,
and methods. Any Lua object may be called or indexed which supports it, even
via metatable behaviors. Full userdata as well as LuaJIT cdata also works for
metatable access or passing back in to another Lua call. See Values further
down.

Accessing referenced objects, table fields, and global variables can be done
from Perl without calling Lua code. Named global tables can be used as roles.

## To Do

The API is incomplete, and error reporting is crude. The "Inline::" part is
arguably NYI, as the present interface is solely object-oriented.

There is no way to pass Perl-native constructs to Lua code, other than simple
copy conversion of values; directly accessing Perl data structures and calling
Perl code from Lua is not implemented.

Metatables are respected for calling and indexing semantics, however they
cannot yet be accessed directly nor are Lua operator overloads exposed in Perl.

Both light and full userdata are supported for passing and returning, but the
only way to create one from Perl is to pass in a Pointer. In particular, direct
support for Perl-native binary types like Buf/Blob does not exist.

Composing roles from Lua objects doesn't work well when multiple Inline::Lua
instances are in use. This is because it would be extremely difficult for the
user to provide the Lua table object itself at composition time and still have
their own code survive precompilation, so the table is specified as a name to
look up at runtime as a global variable. When using multiple instances, the
named global is looked up in the most recently created Inline::Lua instance,
which is stored in the Inline::Lua.default-lua class attribute.

No provisions are made for growing Lua's stack beyond its initial size (which
defaults to 20). Therefore, passing deeply-nested data structures to Lua may
result in an overflow.

## Values

Inline::Lua currently allows passing and returning any number of boolean,
number, string, nil, table, function, light or full userdata, and cdata values
according to the following table.

    Lua             from Perl               to Perl
    nil             * where {!.defined}     Any
    boolean         Bool                    Bool
    number          Numeric                 Num
    string          Stringy                 Str
    light userdata  Pointer                 Pointer[void]
    table/          any( Positional,        Inline::Lua::Object; any of:
    function/       Associative,                Inline::Lua::Table
    full userdata/  Inline::Lua::Object )       Inline::Lua::Function
    cdata                                       Inline::Lua::Userdata
                                                Inline::Lua::Cdata

Not counting floating-point values like NaN, nil is the only "undefined" value
in Lua. All undefined Perl values will be translated as nil, and when it is
returned from Lua it will yield Any.

Numbers in default Lua are C doubles, and so are coerced to some type of Num
(possibly a variation of it like num64) when passing to and from Lua. Accessing
table keys (below) also applies this coercion.

Tables are exposed as Inline::Lua::Table instances, which can be accessed
directly with hash or array subscripts (including slicing), converted to a
.hash or .list, or used as an object (or role via LuaParent). See Usage below
for details. Arrays and hashes can also be passed in to Lua, and will be
translated as a newly-created table.

In contrast to tables acting as arrays, multiple return values (not packed in a
table) from Lua will result in an ordinary Perl list instead of an
Inline::Lua::Table.

Lua functions as values themselves are returned as Inline::Lua::Function
objects, which can be called like any other anonymous routine in Perl,
including assigning it to an &-sigiled variable to be able to call it with
ordinary-looking sub call syntax.

Full userdata and LuaJIT cdata types are exposed as Inline::Lua::Userdata and
Inline::Lua::Cdata. Light userdata is a simple pointer value (not an object),
and is passed to and from Perl as a NativeCall Pointer.

Metatables in Lua allow any object type to define behaviors for calling,
indexing, comparing, and calculating operators, even when the type in question
does not usually support such operations. This is allowed for by the object
types, meaning e.g. a ::Table also does the Callable role and can be invoked
(though the attempt will fail if there isn't a corresponding metatable
handler).

A new Perl object is created for each Lua value being returned, making the
::Object types useless for identity comparison on the Perl side (e.g. === on
the same Lua table returned from separate calls will be False).

Inline::Lua::Objects can of course be passed back in to Lua, and represent the
same referenced Lua object which they were originally attached to.

## Usage

For illustrative purposes, the signatures shown here may differ from the actual
implementation. Undocumented differences also include parameters meant for
internal use and experimental features.

### Inline::Lua

Represents a Lua instance with it's own global environment and internal stack.
Multiple Inline::Lua instances may be used, though passing ::Objects between
different instances is not supported, and using LuaParent does not work well
with multiple instances (both of which are described further down).

#### method new (:$lua, :$auto, :$lib)

Creates, initializes, and returns a new Inline::Lua instance with the standard
Lua libraries loaded.

Lua version is switched per Inline::Lua instance automatically, by trying JIT
first and falling back to standard Lua 5.1. To skip autodetection and use
LuaJIT explicitly, pass :lua\<JIT>. To disable the auto-detection without using
LuaJIT, either pass another version (currently only 5.1), or pass :!auto to use
the non-JIT default.

To point to a specific library instead of only trying the standard name and
library paths, :lib can be passed to specify a more explicit name/path. In this
case all auto-detection is disabled and :lua is ignored.

#### method run (Str:D $code, \*@args)

Compiles $code, runs it with @args, and returns any resulting value(s).

#### method call (Str:D $name, \*@args)

Calls the named global function with @args, and returns any resulting value(s).

#### method get-global (Str:D $name)

Returns the value stored in the named global variable.

#### method set-global (Str:D $name, $value)

Sets the value of the named global variable.

### Inline::Lua::Object

Base role for values which Lua regards as "objects". This role manages
references and allows the object to be pushed on to the Lua stack, none of
which is part of the intended public interface. None of the object types except
table can be meaningfully instantiated from Perl at this time, rather they
usually result from a value being returned to Perl from Lua.

All Lua objects also support what are called metatables, which hold callbacks
that may allow any object to respond to calls like a function, key access like
a table (which is also used to implement inheritance), and concatenation,
arithmetic, and comparison like a value. Inline::Lua::Objects support
metatable-backed indexing and invocation, but do not perform any Perl operator
overloading. In particular this means that /all/ Inline::Lua::Objects may be
used as a Perl hash, array, object, role, or routine, and include the
Positional, Associative, and Callable roles, even if it is not an object type
which directly supports such features.

To keep this documentation understandable, the expected features are documented
under e.g. ::Function and ::Table, even when such features also work on any
object via metatables. Some methods, however, are truly generic to all object
types regardless of metatable, and so are documented directly below.

#### method ptr ()

Returns a NativeCall Pointer[void] to the object.

### Inline::Lua::Function

A Lua function which can be called directly from Perl. It can be invoked like
any other Routine, and is often stored in an &-sigiled variable to call like a
named Perl sub. Parameters are exposed in Perl as slurpy positionals with no
current regard for the actual parameter list of the Lua function.

### Inline::Lua::Table

A table in Lua represents the concepts which Perl regards as variously arrays,
hashes, objects, classes, roles, and more. Therefore this type attempts to
provide an interface as all of these things. Underneath, however, calls to a
::Table perform the operation on the referenced Lua table, not a Perl copy.
All the usual Positional and Associative subscripts work on a ::Table including
slicing and possibly various adverbs (untested).

When accessed as a hash, a ::Table appears as an object hash (:{} or
Hash[Any,Any] in Perl code), in keeping with the semantics of Lua tables. All
numeric keys will be Num (or possibly some precision and/or native variant
thereof) because default Lua handles any number as a C double. Numeric values
used as hash subscripts to a ::Table will be automatically coerced to a num.

Positional indices, on the other hand, are treated as integers in Perl as
always. Lua tables use 1-based indexing when treated as an array, while Perl
uses zero-based indexing. When accessed as an array, the index is offset
accordingly. In other words, $table[0] is the same element as $table{1}.

A method call which cannot be resolved by the ::Table object is attempted as a
method call or attribute access on the table by the usual Lua OO conventions,
allowing a table to be seemlessly used as an object from Perl code, as long as
required method and attribute names don't overlap with any existing methods in
Inline::Lua::Table's inheritance tree. For ways around this limitation, see
.dispatch(), .obj(), and LuaParent, below.

Unlike objects behaving as tables via metatable-backed indexing, an actual
::Table can be iterated over and its full set of keys and values can be known.
This means that tables can accept list assignments in Perl (though they
intentionally do not themselves flatten in list context), and they also are
able to provide the .list, .hash and related methods. While these
iteration-backed features only work on ::Table itself, table-like array and
hash subscripting is supported for all ::Objects with suitable metamethods, as
well as the OO features described later in this class like .dispatch and .obj.

#### method new (Inline::Lua:D :$lua!)

Creates a new empty table in the given Inline::Lua instance and returns it.

#### method hash ()
#### method keys ()
#### method values ()
#### method kv ()
#### method pairs ()

These methods return a shallow copy of the table which is independent of the
original Lua object. The structure returned is the same as the corresponding
Hash methods, with the exception that .hash returns an object hash
(Hash[Any,Any]) instead of Perl's default (Hash[Mu,Str]). This difference is
entirely transparent if the values are stored via ordinary hash assignment
(e.g. my %results = some-lua-func().hash), since the keys will be coerced to
strings when being assigned to %results.

#### method list ()

Returns a shallow copy of the positional portion of the table, which is
independent of the original Lua object.

#### method elems ()
#### method end ()

Lua has a nondeterministic notion of where the end of a sparse array is, while
Perl always considers the end to be after the defined element with the highest
index, which always includes any holes within the array. Perl arguably doesn't
even support arrays with missing elements so much as arrays with undefined
elements, unless using a type of hash instead, as Lua does. To compensate, a
bit of slower but far more correct code iterates over all the table's keys to
find the highest defined whole number key, instead of Lua's length operation.
This is also done when the end needs to be found for other operations like
.list or slicing/indexing with Whatever ([\*]) and WhateverCode ([\*-1]).

#### method dispatch ($method, Bool:D :$call = True, \*@args)

Calls the named method using the table as the invocant, also passing @args, and
returns the result. Notably, this is currently the only 100% guaranteed way to
call a Lua method on a ::Table object which might be masked out by a Perl
method.

Besides a method name string, $method can also be an Inline::Lua::Function (or
even any other callable perl object) which will be called directly instead of
retrieving the method by name from the table. Passing a Callable directly is
mainly intended to allow a method to be looked up before hand to skip the table
key lookup, value return, and associated marshalling overhead of .dispatch
without rearranging the calling code by allowing method names and method
objects to be used interchangably.

Since it is ubiquitous in Perl 6 to expose attributes via accessors, calling
.dispatch with the name of something which contains a non-function value will
return the value attached to that table key, effectively acting as an implicit
accessor. When acting as an accessor, @args is ignored.

If it is intended to retrieve an Inline::Lua::Function object rather than
calling it, :!call can be passed. This also applies to ordinary-looking
"$table.attr" method calls. This is also necessary to call non-method functions
in a table, since .dispatch will pass the table itself as the first argument
whether the function is actually a method or not, because there is no reliable
way to tell the difference in Lua.  To ensure a function is not called, you can
also access the function via a hash subscript instead of a method call on the
same object, which always returns the value, function or otherwise.

#### method obj ()

Returns an Inline::Lua::WrapperObj instance for the object; see directly below.

### Inline::Lua::WrapperObj

To ease method name conflicts, this class exposes a Lua object as a Perl
object, but it does not inherit or compose anything besides Any and Mu.
Fallback-based dispatch works as previously described, just with fewer
attributes and methods to get in the way (meaning it lacks all other features
and methods in this document). A ::WrapperObj can be passed back to Lua just as
if the associated ::Object had been passed.

#### has $.inline-lua-object

The actual ::Object for this ::WrapperObj instance, and the only non-default
name to conflict with Lua attributes and methods (thus the slightly-awkward
identifier).

### Inline::Lua::Userdata

Full userdata is supported for passing and returning. This class doesn't do
much else directly but supports metatable behaviors like any
Inline::Lua::Object, or might be used for passing it's .ptr() to other Perl
NativeCall code.

### Inline::Lua::Cdata

LuaJIT cdata is supported in the same way as ::Userdata, directly above.

### LuaParent

To use a table as a role, assign the table to a global variable (e.g. with
.set-global), and use it with the LuaParent role.

    role MyRole does LuaParent['global-table'] { ... }

To use a table as a class, LuaParent can be instantiated via .new(). To inherit
from a table, inherit from a class which composes the role, as inheriting
directly from a parameterized role doesn't seem to work. Using LuaParent with
multiple instances of Inline::Lua is unlikely to work correctly; see To Do
further above.

## Contact

https://github.com/raydiak/Inline-Lua

raydiak@cyberuniverses.com

raydiak on #perl6 on irc.freenode.net

