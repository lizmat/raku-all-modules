#
# Knuth Arrow notation

use v6;

unit module Math::Arrow;

sub infix:<↑>($a, $b) is assoc<right> is export {$a ** $b}
sub infix:<↑↑>($a, $b) is assoc<right> is export { [↑] $a xx $b }
sub infix:<↑↑↑>($a, $b) is assoc<right> is export { [↑↑] $a xx $b }
sub infix:<↑↑↑↑>($a, $b) is assoc<right> is export { [↑↑↑] $a xx $b }
sub infix:<↑↑↑↑↑>($a, $b) is assoc<right> is export { [↑↑↑↑] $a xx $b }
sub arrow(
        Cool $a,
        Cool $b where { $b >= 2 and $b.Int == $b },
        Cool $arrows where {$arrows.Int == $arrows}) is export {

    die "Negative arrows not allowed" if $arrows < 0;
    return ($a ↑ $b) if $arrows <= 1 or $b <= 1;
    # Technically we should reverse this because of associativity,
    # but since the power tower are all identical...
    ($a xx $b).reduce: -> $x, $y { arrow($y, $x, $arrows-1) }
}

sub g_n($n where { $n >= 1 }) {
    my $arrows = ($n == 1 ?? 4 !! g_n($n-1));
    arrow(3, 3, $arrows);
}
sub term:<G> is export(:constants) { g_n(64) }

=begin pod

=head1 NAME

Math::Arrow - Handle Knuth-style arrow notation

=head1 SYNOPSIS

In Knuth arrow notation, one arrow is simple exponentiation:

    2 ↑ 3 # gives 8

Every additional arrow in the operator implies a layer of
reduction of the form:

    a ↑{n number of ↑'s} b =
        a ↑{n-1 ↑'s} ( a ↑{n-1 ↑'s (... a)...)

where there are C<b> number of C<a>s in the second form.

But this module only implements up to five arrows (really,
if you need more than five, I question what the hell
you think Perl is going to do for you...)

More concretely:

    4 ↑↑↑↑ 3 =
    4 ↑↑↑ ( 4 ↑↑↑ 4 ) =
    4 ↑↑↑ ( 4 ↑↑ ( 4 ↑↑ ( 4 ↑↑ 4 ))) =
    4 ↑↑↑ ( 4 ↑↑ ( 4 ↑↑ ( 4 ↑ (4 ↑ (4 ↑ 4 ))))) =
    4 ↑↑↑ ( 4 ↑↑ ( 4 ↑↑ ( 4 ** 4 ** 4 ** 4))) = ...

As you can see, this quickly gets out of hand. In fact, there
are very few arrow-notation expressions which can be
evaluated in a practical period of time (the above example
would take longer to fully evaluate than the universe has
been around, even on the fastest computers available, today.

Probably the best-known arrow-notation example is Graham's
Number (G) which is defined as:

    $g1 = 3 ↑↑↑↑ 3;
    $g2 = arrow(3, 3, $g1);
    ...
    $g64 = arrow(3, 3, $g63);
    use constant G = $g64;

=head2 operator ↑

The C<↑> operator is an infix operator which is equivalent
to C<arrow(left-hand-side, right-hand-side, 1)> and C<**>
and performs simple exponentiation. It is right-associative,
just like C<**>.

=head2 operator ↑↑

The C<↑↑> operator is also a right-associative infix operator
and is equivalent to C<arrow(lhs, rhs, 2)>.

=head2 operator ↑↑↑

See C<↑↑> for details. Equivalent to C<arrow(lhs, rhs, 3)>.

=head2 operator ↑↑↑↑

See C<↑↑> for details. Equivalent to C<arrow(lhs, rhs, 4)>.

=head2 operator ↑↑↑↑↑

See <↑↑> for details. Equivalent to C<arrow(lhs, rhs, 5)>.

=head2 arrow($a, $b, $arrows)

Returns the arrow-notation expansion for C<$a ↑[$arrows] $b>
where C<↑[$arrows]> denotes C<$arrows> many C<↑> in the final
operator. Thus these two are equivalent:

    arrow(3, 3, 4) == (3 ↑↑↑↑ 3)

=head2 term G

(only exported via the :constants tag)

The value C<G> is defined as a more-or-less humorous element
of this module. It can never be used for anything practical,
as evaluating its value would take such a mind-bogglingly large
amount of time and memory that you might as well simply shoot your
computer. But... don't do that.

This value is Graham's number, defined as described above.

=end pod

# vim: sw=4 softtabstop=4 ai expandtab filetype=perl6
