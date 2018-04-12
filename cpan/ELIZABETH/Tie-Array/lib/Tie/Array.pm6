use v6.c;

class Tie::Array:ver<0.0.3> {
    method EXTEND($) { }
    method DESTROY() { }
    method CLEAR() { self.STORESIZE(0) }

    method UNSHIFT(*@args) { self.SPLICE(0,0,@args) }
    method SHIFT()  is raw {
        self.FETCHSIZE
          ?? self.SPLICE(0,1).AT-POS(0)
          !! Nil
    }

    method PUSH(*@args) {
        my int $sz = self.FETCHSIZE;
        self.STORE($sz++, @args.shift) while @args;
    }
    method POP() is raw {
        if self.FETCHSIZE -> $size {
            LEAVE self.STORESIZE($size - 1);
            self.FETCH($size - 1)
        }
        else {
            Nil
        }
    }
    method SPLICE(*@args) {
        my int $sz  = self.FETCHSIZE;
        my int $off = @args ?? @args.shift !! 0;
        $off += $sz if $off < 0;
        my int $len = @args ?? @args.shift !! $sz - $off;
        $len += $sz - $off if $len < 0;
        my @result;

        my int $i = $off - 1;
        push(@result, self.FETCH(++$i)) for ^$len;
        $off = $sz if $off > $sz;
        $len -= $off + $len - $sz if $off + $len > $sz;

        if @args > $len {
            # Move items up to make room
            my int $d = @args - $len;
            my int $e = $off + $len;
            self.EXTEND($sz + $d);
            loop (my int $i = $sz-1; $i >= $e; --$i) {
                self.STORE($i + $d, self.FETCH($i));
            }
        }
        elsif @args < $len {
            # Move items down to close the gap
            my int $d = $len - @args;
            my int $e = $off + $len;
            loop (my int $i =$off + $len; $i < $sz; ++$i) {
                self.STORE($i - $d, self.FETCH($i));
            }
            self.STORESIZE($sz - $d);
        }

        self.STORE($off + $_, @args[$_]) for ^@args;

        @result
    }

    method EXISTS($) { die self.^name ~ " doesn't define an EXISTS method" }
    method DELETE($) { die self.^name ~ " doesn't define an DELETE method" }
    method UNTIE()   { die self.^name ~ " doesn't define an UNTIE method"  }
}

=begin pod

=head1 NAME

Tie::Array - Implement Perl 5's Tie::Array core module

=head1 SYNOPSIS

  use Tie::Array;

=head1 DESCRIPTION

Tie::Array is a module intended to be subclassed by classes using the
</P5tie|tie()> interface.  It depends on the implementation of methods
C<FETCH>, C<STORE>, C<FETCHSIZE> and C<STORESIZE>.

The C<EXISTS> method should be implemented if C<exists> functionality is needed.
The C<DELETE> method should be implemented if C<delete> functionality is needed.
Apart from these, all other interfaces methods are provided in terms of
C<FETCH>, C<STORE>, C<FETCHSIZE> and C<STORESIZE>.

=head1 SEE ALSO

L<P5tie>, L<Tie::StdArray>

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Tie-Array . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
