# Zavolaj!

This module implements native calling support for Rakudo Perl 6. It builds
on a set of native calling primitives in NQP, adding mapping of Perl 6
signatures and various other traits to make working with native libraries
an easier experience.

The project name is the Slovak translation of the imperative "call!", to
complement Blizkost, a Rakudo-to-Perl-5 integration project.

Thanks to NQP's underlying use of the dyncall library, Zavolaj can now
support arbitrary signatures.

Starting from 2015.02, the NativeCall module ships with the Rakudo Perl 6
compiler, so there is no need to install it separately.

## Getting Started
The simplest imaginable use of Zavolaj would look something like this:

    use NativeCall;
    sub some_argless_function() is native('libsomething') { * }
    some_argless_function();

The first line imports various traits and types. The next line looks like
a relatively ordinary Perl 6 sub declaration - with a twist. We use the
"native" trait in order to specify that the sub is actually defined in a
native library. The platform-specific extension (e.g. .so or .dll) will be
added for you.

The first time you call "some_argless_function", the "libsomething" will be
loaded and the "some_argless_function" will be located in it. A call will then
be made. Subsequent calls will be faster, since the symbol handle is retained.

Of course, most functions take arguments or return values - but everything else
that you can do is just adding to this simple pattern of declaring a Perl 6
sub, naming it after the symbol you want to call and marking it with the "native"
trait.

## Changing names
Sometimes you want the name of your Perl subroutine to be different from the name
used in the library you're loading.  Maybe the name is long or has different casing
or is otherwise cumbersome within the context of the module you are trying to
create.

Zavolaj provides a "symbol" trait for you to specify the name of the native
routine in your library that may be different from your Perl subroutine name.

    module Foo;
    use NativeCall;
    our sub Init() is native('libfoo') is symbol('FOO_INIT') { * }

Inside of "libfoo" there is a routine called "FOO\_INIT" but, since we're
creating a module called Foo and we'd rather call the routine as Foo::Init, 
we use the "symbol" trait to specify the name of the symbol in "libfoo" 
and call the subroutine whatever we want ("Init" in this case).

## Passing and Returning Values
Normal Perl 6 signatures and the "returns" trait are used in order to convey
the type of arguments a native function expects and what it returns. Here is
an example.

    sub add(int32, int32) returns int32 is native("libcalculator") { * }

Here, we have declared that the function takes two 32-bit integers and returns
a 32-bit integer. Here are some of the other types that you may pass (this will
likely grow with time).

    int8     (char in C)
    int16    (short in C)
    int32    (int in C)
    long     (32- or 64-bit, depends what long means locally)
    Int      (always 64-bit, long long in C)
    num32    (float in C)
    num64    (double in C)
    num      (same as num64)
    Str      (C string)

Note that the lack of a "returns" trait is used to indicate void return type.

For strings, there is an additional "encoded" trait to give some extra hints on
how to do the marshalling.

    sub message_box(Str is encoded('utf8')) is native('libgui') { * }

To specify how to marshall string return types, just apply this trait to the
routine itself.

    sub input_box() returns Str is encoded('utf8') is native('libgui') { * }

Note that a null string can be passed by passing the Str type object; a null
return will also be represented by the type object.

## Opaque Pointers
Sometimes you need to get a pointer (for example, a library handle) back from a
C library. You don't care about what it points to - you just need to keep hold
of it. The OpaquePointer type provides for this.

    sub Foo_init() returns OpaquePointer is native("libfoo") { * }
    sub Foo_free(OpaquePointer) is native("libfoo") { * }

This works out OK, but you may fancy working with a type named something better
than OpaquePointer. It turns out that any class with the representation "CPointer"
can serve this role. This means you can expose libraries that work on handles
by writing a class like this:

    class FooHandle is repr('CPointer') {
        # Here are the actual Zavolaj functions.
        sub Foo_init() returns FooHandle is native("libfoo") { * }
        sub Foo_free(FooHandle) is native("libfoo") { * }
        
        # Here are the methods we use to expose it to the outside world.
        method new() { Foo_init() }
        method free() { Foo_free(self) }
    }

Note that the CPointer representation can do nothing more than hold a C pointer.
This means that your class cannot have extra attributes. However, for simple
libraries this may be a neat way to expose an object oriented interface to it.

Of course, you can always have an empty class:

    class DoorHandle is repr('CPointer') { }

And just use the class as you would use OpaquePointer, but with potential for
better type safety and more readable code.

Once again, type objects are used to represent nulls.

## Arrays
Zavolaj currently has some basic support for arrays. It is constrained to only
working with machine-size integers, doubles and strings at the moment; the sized
numeric types, arrays of pointers, arrays of structs and arrays of arrays are in
development.

Perl 6 arrays, which support amongst other things laziness, are laid out in memory
in a radically different way to C arrays. Therefore, the NativeCall library offers
a much more primitive CArray type, which you must use if working with C arrays.

Here is an example of passing a C array.

    sub RenderBarChart(Str, int, CArray[Str], CArray[num]) is native("libchart") { * }
    my @titles := CArray[Str].new();
    @titles[0] = 'Me';
    @titles[1] = 'You';
    @titles[2] = 'Your Mom';
    my @values := CArray[num].new();
    @values[0] = 59.5e0;
    @values[1] = 61.2e0;
    @values[2] = 120.7e0;
    RenderBarChart('Weights (kg)', 3, @titles, @values);

Note that binding was used to @titles, *NOT* assignment! If you assign, you
are putting the values into a Perl 6 array, and it will not work out. If this
all freaks you out, forget you ever knew anything about the "@" sigil and just
use "$" all the way when using Zavolaj. :-)

    my $titles = CArray[Str].new();
    $titles[0] = 'Me';
    $titles[1] = 'You';
    $titles[2] = 'Your Mom';

Getting return values for arrays works out just the same.

The memory management of arrays is important to understand. When you create an
array yourself, then you can add elements to it as you wish and it will be
expanded for you as required. However, this may result in it being moved in
memory (assignments to existing elements will never cause this, however). This
means you'd best know what you're doing if you twiddle with an array after passing
it to a C library.

By contrast, when a C library returns an array to you, then the memory can not
be managed by Zavolaj, and it doesn't know where the array ends. Presumably,
something in the library API tells you this (for example, you know that when
you see a null element, you should read no further). Note that Zavolaj can offer
you no protection whatsoever here - do the wrong thing, and you will get a
segfault or cause memory corruption. This isn't a shortcoming of Zavolaj, it's
the way the big bad native world works. Scared? Here, have a hug. Good luck! :-)

## Structs
Thanks to representation polymorphism, it's possible to declare a normal looking
Perl 6 class that, under the hood, stores its attributes in the same way a C
compiler would lay them out in a similar struct definition. All it takes is a
quick use of the "repr" trait:

    class Point is repr('CStruct') {
        has num64 $.x;
        has num64 $.y;
    }

The attributes can only be of the types that Zavolaj knows how to marshall into
struct fields. Currently, structs can contain machine-sized integers, doubles,
strings, and other Zavolaj objects (CArrays, and those using the CPointer and
CStruct reprs). Other than that, you can do the usual set of things you would with
a class; you could even have some of the attributes come from roles or have them
inherited from another class. Of course, methods are completely fine too. Go wild!

The memory management rules are very much like for arrays, though simpler since a
struct is never resized. When you create a struct, the memory is managed for you and
when the variable(s) pointing to the instance of a CStruct go away, the memory will
be freed when GC gets to it. When a CStruct-based type is used for the return type,
the memory is not managed for you.

Zavolaj currently doesn't put object members in containers, so assigning new values
to them (with =) doesn't work. Instead, you have to bind new values to the private
members: $!struct-member := StructObj.new;

As you may have predicted by now, a null is represented by the type object of the
struct type.

## Function arguments
Zavolaj also supports native functions that take functions as arguments.  One example
of this is using function pointers as callbacks in an event-driven system.  When
binding these functions via Zavolaj, one need only provide the equivalent signature
as a constraint on the code parameter:

    # void SetCallback(int (*callback)(const char *))
    my sub SetCallback(&callback (Str --> int32)) is native('mylib') { * }

## The Future
See the TODO file. In general, though, it's mostly about making arrays and structs
much more capable, providing more options for memory management and supporting
callbacks. Something missing that's blocking you? Talk to jnthn on #perl6 - the
TODO list can be shuffled around to suit what potential users are after. Or just
send in a patch. ;-)

## Running the Examples

The examples directory contains various examples of how to use Zavolaj.

More examples can be found in the lib/DBDish/ directory of the DBIsh repository
at https://github.com/perl6/DBIish/.

### MySQL

There is an exmaple of using the MySQL client library. There is a Rakudo project
http://github.com/mberends/minidbi that wraps these functions with a DBI
compatible interface. You'll need that library to hand; on Debian-esque systems
it can be installed with something like:

    sudo apt-get install libmysqlclient-dev

Prepare your system along these lines before trying out the examples:

    $ mysql -u root -p
    CREATE DATABASE zavolaj;
    CREATE USER 'testuser'@'localhost' IDENTIFIED BY 'testpass';
    GRANT CREATE      ON zavolaj.* TO 'testuser'@'localhost';
    GRANT DROP        ON zavolaj.* TO 'testuser'@'localhost';
    GRANT INSERT      ON zavolaj.* TO 'testuser'@'localhost';
    GRANT DELETE      ON zavolaj.* TO 'testuser'@'localhost';
    GRANT SELECT      ON zavolaj.* TO 'testuser'@'localhost';
    GRANT LOCK TABLES ON zavolaj.* TO 'testuser'@'localhost';
    GRANT SELECT      ON   mysql.* TO 'testuser'@'localhost';
    # or maybe otherwise
    GRANT ALL PRIVILEGES ON zavolaj.* TO 'testuser'@'localhost';

You can look at the results via a normal mysql connection:

    $ mysql -utestuser -ptestpass
    USE zavolaj;
    SHOW TABLES;
    SELECT * FROM nom;

### Microsoft Windows

The win32-api-call.p6 script shows a Windows API call done from Perl 6.
