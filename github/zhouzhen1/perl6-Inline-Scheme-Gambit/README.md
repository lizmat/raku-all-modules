# Inline::Scheme::Gambit [![Build Status](https://travis-ci.org/zhouzhen1/perl6-Inline-Scheme-Gambit.svg?branch=master)](https://travis-ci.org/zhouzhen1/perl6-Inline-Scheme-Gambit)

This is a Perl 6 module which allows execution of Gambit Scheme code from
Perl 6 code with inspiration from other Inline:: modules like
Inline::Python, Inline::Lua, Inline::Scheme::Guile, etc.

## Synopsis

    use Inline::Scheme::Gambit;

    my $gambit = Inline::Scheme::Gambit.new;

    my $code = q:to/END/;
        (define (fib n)
         (if (< n 2) n (+ (fib (- n 1)) (fib (- n 2)))))
    END

    $gambit.run($code);
    say $gambit.call('fib', 8);

    say $gambit.call('map',
                     $gambit.run(q{(lambda (n) (fib n))}),
                     [0 .. 8]);

## Status

Testing has only been done under Rakudo MoarVM on x86-64 Linux. It requires
Gambit-C 4, and Gambit-C 4.8.3 and 4.2.8 have been tested by the author. 

Values can be passed to and returned from Gambit-C. Simple types
like boolean, integer, number, string, list, table, vector should
work. Present mapping between Gambit-C and Perl 6 types is as
following table. 

    Gambit-C            from Perl                       to Perl
    boolean             Bool                            Bool
    integer(exact)      Int                             Int
    rational(exact)     Rat                             Rat
    rational(inexact)   Num                             Num
    complex             Complex                         Complex
    string              Stringy                         Str
    list                Positional                      Array            
    table               Associative                     Hash            
    vector                                              Array
    procedure                                           OpaquePointer
    other objects       OpaquePointer                   OpaquePointer

Note that at present both scheme list and vector converts to Array
in Perl 6, but through the call() method (see below) Perl 6 Array only
converts to list. 

The API is incomplete and experimental. It may change in future if
necessary.

### To Do

* Think about wrapping OpaquePointer for scheme-object, so that it can
do better on scheme list/vector/procedure/etc.
* Support scheme record type. 
* Improve error handling. 

## Install

    panda install Inline::Scheme::Gambit

It by default tries to use 'gsc-script' or 'gsc' as the gsc command,
and dynamically link to libgambc.so. It supports several environment
variables to override the default behavior. 

For example to override gsc in case 'gsc-script' or 'gsc' is not in
PATH, or 'gsc-script' is an incorrect symlink. 

    GSC=/usr/bin/gsc panda install Inline::Scheme::Gambit

Or if you would like to static link to some libgambit.a

    LIBS=-lutil MYEXTLIB=/usr/lib/gambit-c/libgambit.a panda install Inline::Scheme::Gambit

You can refer to Makefile.in and Build.pm to know more details.

## Usage

### Inline::Scheme::Gambit

Object of Inline::Scheme::Gambit represents a global Gambit-C instance. 

#### method new()

Returns the global Inline::Scheme::Gambit singleton. The first call to
new() initializes the singleton. 

#### method run(Str:D $code)

Runs $code and returns any resulting value.

#### method call(Str:D $name, \*\*@args)

Calls the named function with @args, and returns any resulting value.

## Contact

https://github.com/zhouzhen1/perl6-Inline-Scheme-Gambit

zhouzhen1@gmail.com

