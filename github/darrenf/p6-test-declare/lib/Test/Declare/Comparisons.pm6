use v6.c;
unit module Test::Declare::Comparisons;

sub infix:<superhashof>(Hash $left, Hash $right --> Bool) is export {
    return $left{$right.keys} eqv $right.values.List;
}

sub infix:<subhashof>(Hash $left, Hash $right --> Bool) is export {
    return $right superhashof $left;
}

class Roughly is export {
    # transparaently to the user, everything is actually a 'rough'
    # ccmparison - but our default operator is eqv.
    has Sub $.op is default(&[eqv]);
    has $.rhs is required;

    # curry the actual comparison, ready for performing it. there
    # may be no point in doing this, but I'm still learning Perl6
    # and like to leave things like this around to remind me of
    # features.
    has $!comparison = $!op.assuming(*, $!rhs);

    method compare($got) {
        return $!comparison($got);
    }
}

sub roughly(Sub $op, Any $rv --> Test::Declare::Comparisons::Roughly) is export {
    return Roughly.new(
        op => $op, rhs => $rv
    );
}

sub superhashof(Hash $right --> Roughly) is export {
    return roughly(&[superhashof], $right);
}

sub subhashof(Hash $right --> Roughly) is export {
    return roughly(&[subhashof], $right);
}

=begin pod

=head1 NAME

Test::Declare::Comparisons - fuzzy comparators for Test::Declare

=head1 SYNOPSIS

    expected => {
        return-value => roughly(&[>], 10),  # we'll get back a number bigger than 10
    }
    expected => {
        return-value => superhashof({ foo => 1, bar => 2 }),
    }

=head1 DESCRIPTION

When writing tests using L<Test::Declare>, exact comparisons may not always be
suitable or even possible.  In such cases you can use C<roughly> to change the
test behaviour to something more fuzzy. The syntax is:

    return-value => roughly($operator, $right-hand-side)

For example:

    # I don't know what the value is, only that it's less than 10
    return-value => roughly(&[<], 10),

C<$operator> is typically intended to be one of the builtin infix operators but
any L<Sub> which takes 2 positional arguments should do. C<roughly> works on all
expectations which involve data, i.e. C<return-value/stdout/stderr/mutates>.

Some L<Test::Deep> style operators are also exported from here:

    subhashof({some => 'hash'}),
    superhashof({some => hash', with => 'more', data => 'then we want to test'})

Note that unlike L<Test::Deep> these are not (currently?) available at arbitrary depths,
only as a top-level construct.

=end pod
