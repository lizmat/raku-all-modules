use v6;

=head1 TITLE
Algorithm::LCS
=head1 SYNOPSIS
=begin code
    use Algorithm::LCS;

    # regular usage
    say lcs(<A B C D E F G>, <A C F H J>); # prints T<A C F>

    # custom comparator via :compare
    say lcs(<A B C>, <D C F>, :compare(&infix:<eq>));

    # extra special custom comparison via :compare-i
    my @a        = slurp('one.txt');
    my @b        = slurp('two.txt');
    my @a-hashed = @a.map({ hash-algorithm($_) });
    my @b-hashed = @b.map({ hash-algorithm($_) });
    say lcs(@a, @b, :compare-i({ @a-hashed[$^i] eqv @b-hashed[$^j] }));
=end code
=begin head1
DESCRIPTION

This module contains a single subroutine, C<lcs>, that calculates
the longest common subsequence between two sequences of data.  C<lcs>
takes two lists as required parameters; you may also specify the comparison
function (which defaults to C<eqv>) via the C<&compare> named parameter).
Sometimes you may want to maintain a parallel array of information to
consult during calculation (for example, if you're comparing long lines
of a file, and you'd like a speedup by comparing their hashes rather than
their contents); for that, you may use the C<&compare-i> named parameter.

=end head1

=begin head1
SEE ALSO

http://en.wikipedia.org/wiki/Longest_common_subsequence_problem
=end head1

module Algorithm::LCS:ver<0.0.1>:auth<hoelzro> {
    my sub strip-prefix(@a, @b, &compare-i) {
        my $i = 0;
        my @prefix;

        while $i < (@a&@b) && &compare-i($i, $i) {
            @prefix.push: @a[$i++];
        }

        @prefix
    }

    my sub strip-suffix(@a, @b, &compare-i) {
        # XXX could be optimized, but this is easy for now
        strip-prefix(@a.reverse, @b.reverse, -> $i, $j {
            &compare-i(@a.end - $i, @b.end - $j)
        }).reverse
    }

    my sub build-lcs-matrix(@a, @b, &compare-i) {
        my @matrix  = 0 xx ((@a + 1) * (@b + 1));
        my $row-len = @a + 1;

        for 1 .. @b X 1 .. @a -> ($row, $offset) {
            my $index = $row * $row-len + $offset;

            if &compare-i($offset - 1, $row - 1) {
                @matrix[$index] = @matrix[$index - $row-len - 1] + 1;
            } else {
                @matrix[$index] = [max] @matrix[ $index - $row-len, $index - 1 ];
            }
        }

        @matrix
    }

    #| Returns the longest common subsequence of two sequences of data.
    our sub lcs(
        @a,                     #= The first sequence
        @b,                     #= The second sequence
        :&compare=&infix:<eqv>, #= The comparison function (defaults to C<eqv>)
        :&compare-i is copy     #= The compare-by-index function (defaults to using &compare)
    ) is export {
        unless &compare-i.defined {
            &compare-i = -> $i, $j {
                &compare(@a[$i], @b[$j])
            };
        }

        my @prefix = strip-prefix(@a, @b, &compare-i);
        my @suffix = strip-suffix(@a[+@prefix .. *], @b[+@prefix .. *], -> $i, $j {
            &compare-i($i + @prefix, $j + @prefix)
        });
        my @a-middle = @a[+@prefix .. @a.end - @suffix];
        my @b-middle = @b[+@prefix .. @b.end - @suffix];

        if @a-middle && @b-middle {
            my @matrix = build-lcs-matrix(@a-middle, @b-middle, -> $i, $j {
                &compare-i($i + @prefix, $j + @prefix)
            });

            my $matrix-row-len = @a-middle + 1;
            my $i = @matrix.end;

            my @result := gather while $i > 0 && @matrix[$i] > 0 {
                my $current-length  = @matrix[$i];
                my $next-row-length = @matrix[$i - $matrix-row-len];
                my $next-col-length = @matrix[$i - 1];

                if $current-length > $next-row-length && $next-row-length == $next-col-length {
                    take @b-middle[$i div $matrix-row-len - 1];
                    $i -= $matrix-row-len + 1;
                } elsif $next-row-length < $next-col-length {
                    $i--;
                } elsif $next-col-length <= $next-row-length {
                    $i -= $matrix-row-len;
                } else {
                    die "this should never be reached!";
                }
            }.list;

            ( @prefix, @result.reverse, @suffix ).flat
        } else {
            ( @prefix, @suffix ).flat
        }
    }
}
