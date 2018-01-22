use v6.c;

class Tie::StdHash:ver<0.0.2> {

    # Note that we *must* have an embedded Hash rather than just subclassing
    # from Hash, because .STORE on Hash has different semantics than the
    # .STORE that is being expected by tie().
    has %.tied;
    has $!iterator;

    method TIEHASH() { self.new }
    method FETCH($k)             is raw { %!tied.AT-KEY($k)           }
    method STORE($k,\value)      is raw { %!tied.ASSIGN-KEY($k,value) }
    method EXISTS($k --> Bool:D)        { %!tied.EXISTS-KEY($k)       }
    method DELETE($k)            is raw { %!tied.DELETE-KEY($k)       }
    method CLEAR()                      { %!tied = ()                 }
    method FIRSTKEY() {
        $!iterator := %!tied.keys.iterator;
        (my $key := $!iterator.pull-one) =:= IterationEnd ?? Nil !! $key
    }
    method NEXTKEY(Mu $) {
        (my $key := $!iterator.pull-one) =:= IterationEnd ?? Nil !! $key
    }
    method SCALAR()  { %!tied.elems }
    method UNTIE()   {              }
    method DESTROY() {              }
}

=begin pod

=head1 NAME

Tie::StdHash - Implement Perl 5's Tie::StdHash core module

=head1 SYNOPSIS

  use Tie::StdHash;

=head1 DESCRIPTION

Tie::StdHash is a module intended to be subclassed by classes using the
L<P5tie|tie()> interface.  It uses the standard C<Hash> implementation as its
"backend".

=head1 SEE ALSO

L<P5tie>, L<Tie::StdHash>

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Tie-StdHash . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
