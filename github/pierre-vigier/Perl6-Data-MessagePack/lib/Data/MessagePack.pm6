use v6;

unit module Data::MessagePack;
use Data::MessagePack::Packer;
use Data::MessagePack::Unpacker;

our sub pack( $params ) {
    Data::MessagePack::Packer::pack( $params );
}

our sub unpack( Blob $blob ) {
    Data::MessagePack::Unpacker::unpack( $blob );
}
=begin pod
=head1 NAME

Data::MessagePack - Perl 6 implementation of MessagePack

=head1 SYNOPSIS

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

=head1 DESCRIPTION

The present module proposes an implemetation of the MessagePack specification
as described on L<http://msgpack.org/>. The implementation is now in Pure Perl
which could come as a performance penalty opposed to some other packer
implemented in C.

=head1 WHY THAT MODULE

There are already some part of MessagePack implemented in Perl6, with for instance
MessagePack available here: L<https://github.com/uasi/messagepack-pm6>,
however that module only implements the unpacking part of the specification.
Futhermore, that module uses the unpack functionality which is tagged
as experimental as of today

=head1 FUNCTIONS

=head2 function pack

That function takes a data structure as parameter, and returns
a Blob with the packed version of the data structure.

=head2 function unpack

That function takes a MessagePack packed message as parameter, and returns
the deserialized data structure.

=head1 Author

Pierre VIGIER

=head1 Contributors

Timo Paulssen

=head1 License

Artistic License 2.0

=end pod
# vim: ft=perl6
