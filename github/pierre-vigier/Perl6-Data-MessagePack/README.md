# Perl6-Data-MessagePack

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Data-MessagePack.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Data-MessagePack)

NAME
====

Data::MessagePack - Perl 6 implementation of MessagePack

SYNOPSIS
========

    use Data::MessagePack;

    my $data-structure = {
        key => 'value',
        k2 => [ 1, 2, 3 ]
    };

    my $packed = Data::MessagePack::pack( $data-structure );

    my $unpacked = Data::MessagePack::unpack( $packed );

Or for streaming:

    use Data::MessagePack::StreamingUnpacker;

    my $supplier = Some Supplier; #Could be from IO::Socket::Async for instance

    my $unpacker = Data::MessagePack::StreamingUnpacker.new(
        source => $supplier.Supply
    );

    $unpacker.tap( -> $value {
        say "Got new value";
        say $value.perl;
    }, done => { say "Source supply is done"; } );

DESCRIPTION
===========

The present module proposes an implemetation of the MessagePack specification as described on [http://msgpack.org/](http://msgpack.org/). The implementation is now in Pure Perl which could come as a performance penalty opposed to some other packer implemented in C.

WHY THAT MODULE
===============

There are already some part of MessagePack implemented in Perl6, with for instance MessagePack available here: [https://github.com/uasi/messagepack-pm6](https://github.com/uasi/messagepack-pm6), however that module only implements the unpacking part of the specification. Futhermore, that module uses the unpack functionality which is tagged as experimental as of today

FUNCTIONS
=========

function pack
-------------

That function takes a data structure as parameter, and returns a Blob with the packed version of the data structure.

function unpack
---------------

That function takes a MessagePack packed message as parameter, and returns the deserialized data structure.

Author
======

Pierre VIGIER

License
=======

Artistic License 2.0
