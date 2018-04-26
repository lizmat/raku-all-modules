use v6.c;

class Tie::StdArray:ver<0.0.3>:auth<cpan:ELIZABETH> {

    # Note that we *must* have an embedded Array rather than just subclassing
    # from Array, because .STORE on Array has different semantics than the
    # .STORE that is being expected by tie().
    has @.tied;

    method TIEARRAY() { self.new }
    method FETCH($i)        is raw { @!tied.AT-POS($i)           }
    method STORE($i,\value) is raw { @!tied.ASSIGN-POS($i,value) }
    method FETCHSIZE()             { @!tied.elems                }
    method STORESIZE(\size) {
        my \end = @!tied.end;
        if size > end {
            @!tied.ASSIGN-POS( size - 1, Nil )
        }
        elsif size < end {
            @!tied.splice(size)
        }
    }
    method EXTEND(\size) {
        if size >= @!tied.elems {
            @!tied.ASSIGN-POS( size - 1, Nil );
            @!tied.splice(size)
        }
    }
    method EXISTS($i --> Bool:D)        { @!tied.EXISTS-POS($i)               }
    method DELETE($i --> Bool:D) is raw { @!tied.DELETE-POS($i)               }
    method CLEAR()                      { @!tied = ()                         }
    method POP()                 is raw { @!tied.elems ?? @!tied.pop !! Nil   }
    method PUSH(\value)          is raw { @!tied.push(value)                  }
    method SHIFT()               is raw { @!tied.elems ?? @!tied.shift !! Nil }
    method UNSHIFT(\value)       is raw { @!tied.unshift(value)               }
    method SPLICE(*@args)               { @!tied.splice(@args)                }
    method UNTIE()                      {                                     }
    method DESTROY()                    {                                     }
}

=begin pod

=head1 NAME

Tie::StdArray - Implement Perl 5's Tie::StdArray core module

=head1 SYNOPSIS

  use Tie::StdArray;

=head1 DESCRIPTION

Tie::StdArray is a module intended to be subclassed by classes using the
</P5tie|tie()> interface.  It uses the standard C<Array> implementation as its
"backend".

=head1 SEE ALSO

L<P5tie>, L<Tie::StdArray>

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Tie-StdArray . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
