use v6;
use Crane::Utils;
use X::Crane;
unit class Crane::At;

# method at {{{

method at(
    $container,
    *@steps
    --> Any
) is rw
{
    my $root := $container;
    return-rw at($root, @steps);
}

# --- type Associative handling {{{

multi sub at(
    Associative:D $container,
    @steps where { .elems > 1 and $container{@steps[0]}:exists }
    --> Any
) is rw
{
    my $root := $container;
    $root := $root{@steps[0]};
    return-rw at($root, @steps[1..*]);
}

multi sub at(
    Associative:D $container,
    @steps where { .elems > 1 }
    --> Nil
) is rw
{
    die(X::Crane::AssociativeKeyDNE.new);
}

multi sub at(
    Associative:D $container,
    @steps where { .elems == 1 and $container{@steps[0]}:exists }
    --> Any
) is rw
{
    my $root := $container;
    $root := $root{@steps[0]};
    return-rw $root;
}

multi sub at(
    Associative:D $container,
    @steps where { .elems == 1 }
    --> Nil
) is rw
{
    die(X::Crane::AssociativeKeyDNE.new);
}

multi sub at(
    Associative:D $container,
    @steps where { .elems == 0 }
    --> Any
) is rw
{
    return-rw $container;
}

multi sub at(
    Associative:D $container
    --> Any
) is rw
{
    return-rw $container;
}

# --- end type Associative handling }}}
# --- type Positional handling {{{

multi sub at(
    Positional:D $container,
    @steps where {
        .elems > 1
            and is-valid-positional-index(@steps[0])
            and $container[@steps[0]]:exists
    }
    --> Any
) is rw
{
    my $root := $container;
    $root := $root[@steps[0]];
    return-rw at($root, @steps[1..*]);
}

multi sub at(
    Positional:D $container,
    @steps where { .elems > 1 }
    --> Nil
) is rw
{
    die(X::Crane::PositionalIndexDNE.new);
}

multi sub at(
    Positional:D $container,
    @steps where {
        .elems == 1
            and is-valid-positional-index(@steps[0])
            and $container[@steps[0]]:exists
    }
    --> Any
) is rw
{
    my $root := $container;
    $root := $root[@steps[0]];
    return-rw $root;
}

multi sub at(
    Positional:D $container,
    @steps where { .elems == 1 }
    --> Nil
) is rw
{
    die(X::Crane::PositionalIndexDNE.new);
}

multi sub at(
    Positional:D $container,
    @steps where { .elems == 0 }
    --> Any
) is rw
{
    return-rw $container;
}

multi sub at(
    Positional:D $container
    --> Any
) is rw
{
    return-rw $container;
}

# --- end type Positional handling }}}

# end method at }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
