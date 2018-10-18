# Perl 6 bindings for TCC, the Tiny C Compiler

[![Build Status](https://travis-ci.org/CurtTilmes/perl6-tcc.svg)](https://travis-ci.org/CurtTilmes/perl6-tcc)

# Description

TCC provides Perl 6 bindings for [tcc](https://bellard.org/tcc/), the
Tiny C Compiler, an extremely fast C compiler that can compile C code
directly into a memory block that is then callable by Perl.  You can
also expose your perl functions to C which can call them, and pass
data back and forth.

The interface between Perl and C makes extensive use of the Perl 6
[NativeCall](https://docs.perl6.org/language/nativecall) capabilities,
and is subject to its types and other restrictions.

# Installation

You have to build [tcc](https://bellard.org/tcc/), the Tiny C Compiler
by hand since it doesn't install the shared library by default, and
most distributions don't include it.

```
git clone https://github.com/run4flat/tinycc.git
cd tinycc
./configure
make libtcc.so   # Have to do this first to compile with PIC for shared
make
sudo make install
sudo cp libtcc.so /usr/local/lib # or somewhere convenient
```

# Synopsis
See [eg/testit.pl6](eg/testit.pl6)

```perl6
use v6;
use TCC;

# Make a new Tiny C Compiler
my $tcc = TCC.new('-I/usr/local/include -L/usr/local/lib -DDEBUG=0');

# Compile a C program into memory
$tcc.compile:
'
    #include <stdio.h>
    int add(int a, int b);  /* declare perl functions to quiet warnings */
    void print_something(char *my_string);

    int x = 7;

    int fib(int n)
    {
        if (n <= 2)
            return 1;
        else
            return fib(n-1) + fib(n-2);
    }

    int foo(int n)
    {
        printf("Hello World!\n");
        printf("fib(%d) = %d\n", n, fib(n));
        printf("add(%d, %d) = %d\n", n, 2 * n, add(n, 2 * n));

        print_something("this is just a test");

        if (DEBUG) { print_something("debug is on"); }

        return 0;
    }

    int set_x(int n)
    {
        x = n;
    }
';

# These are just perl subs for C to call
sub add(int32 $a, int32 $b --> int32)
{
    return $a + $b;
}

# This one gets renamed to 'print_something' for C
sub print-something(Str $my-string)
{
    say $my-string;
}

# Add some perl subs for C to call
$tcc.add-symbol(&add);
$tcc.add-symbol(&print-something, name => 'print_something');

# You just have to do this, so do it.
$tcc.relocate;

# Bind C functions to perl callable variables, must pass in signature
my &fib   := $tcc.bind('fib', :(int32 --> int32));
my &foo   := $tcc.bind('foo', :(int32 --> int32));
my &set_x := $tcc.bind('set_x', :(int32 --> int32));

# Bind Perl variable to C symbol, pass in type and an optional function
# to set the variable if you want to go both ways
my $x     := $tcc.bind('x', int32, &set_x);

# Once everything is compiled and bound, just work in Perl land like normal:

say fib(12);

foo(17);

say $x;

set_x(12345);

say $x;

$x = 752;

say $x;
```

Output:
```
144
Hello World!
fib(17) = 1597
add(17, 34) = 51
this is just a test
7
12345
752
```


# NOTES

* Some assumptions on 64-bit architecture, but everyone has that
  anyway, right?

* Not really set up for Windows yet -- patches welcome!

* For now you have to manually write a store function if you want
  two-way variable binding.  Could probably do this automatically.

* The Tiny C Compiler also includes an assembler, so if even C is too
  slow for you, you can embed x86 assembly language into your critical
  portions for super speed!

# Acknowledgements

Developed after presentation and discussion with David Mertens about
the Perl 5 module [C::Blocks](https://metacpan.org/pod/C::Blocks) and
how one might approach that in Perl 6.

# SEE ALSO

[Inline](https://github.com/FROGGS/p6-Inline-C)

`Inline::C` uses a slower C compiler, and goes to temp files on disk
for compiling and library linking but should generate more optimized
code.  It also doesn't seem to have as nice an interface for
interacting back and forth with perl.
