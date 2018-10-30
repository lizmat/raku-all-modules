use v6;
use Crane::Utils;
unit class Crane::In;

# method in {{{

method in(
    \container,
    *@steps
    --> Any
) is rw
{
    return-rw in(container, @steps);
}

# --- type Associative handling {{{

multi sub in(
    Associative:D \container,
    @steps where { .elems > 1 }
    --> Any
) is rw
{
    return-rw in(container{@steps[0]}, @steps[1..*]);
}

multi sub in(
    Associative:D \container,
    @steps where { .elems == 1 }
    --> Any
) is rw
{
    return-rw container{@steps[0]};
}

multi sub in(
    Associative:D \container,
    @steps where { .elems == 0 }
    --> Any
) is rw
{
    return-rw container;
}

multi sub in(
    Associative:D \container
    --> Any
) is rw
{
    return-rw container;
}

# --- end type Associative handling }}}
# --- type Positional handling {{{

multi sub in(
    Positional:D \container,
    @steps where { .elems > 1 and is-valid-positional-index(@steps[0]) }
    --> Any
) is rw
{
    return-rw in(container[@steps[0]], @steps[1..*]);
}

multi sub in(
    Positional:D \container,
    @steps where { .elems == 1 and is-valid-positional-index(@steps[0]) }
    --> Any
) is rw
{
    return-rw container[@steps[0]];
}

multi sub in(
    Positional:D \container,
    @steps where { .elems == 0 }
    --> Any
) is rw
{
    return-rw container;
}

multi sub in(
    Positional:D \container
    --> Any
) is rw
{
    return-rw container;
}

# --- end type Positional handling }}}
# --- type Any handling {{{

multi sub in(
    \container,
    @steps where { .elems > 1 and @steps[0] ~~ Int and @steps[0] >= 0 }
    --> Any
) is rw
{
    return-rw in(container[@steps[0]], @steps[1..*]);
}

multi sub in(
    \container,
    @steps where { .elems > 1 and @steps[0] ~~ WhateverCode }
    --> Any
) is rw
{
    return-rw in(container[@steps[0]], @steps[1..*]);
}

multi sub in(
    \container,
    @steps where { .elems > 1 }
    --> Any
) is rw
{
    return-rw in(container{@steps[0]}, @steps[1..*]);
}

multi sub in(
    \container,
    @steps where { .elems == 1 and @steps[0] ~~ Int and @steps[0] >= 0 }
    --> Any
) is rw
{
    return-rw container[@steps[0]];
}

multi sub in(
    \container,
    @steps where { .elems == 1 and @steps[0] ~~ WhateverCode }
    --> Any
) is rw
{
    return-rw container[@steps[0]];
}

multi sub in(
    \container,
    @steps where { .elems == 1 }
    --> Any
) is rw
{
    return-rw container{@steps[0]};
}

multi sub in(
    \container,
    @steps where { .elems == 0 }
    --> Any
) is rw
{
    return-rw container;
}

multi sub in(
    \container
    --> Any
) is rw
{
    return-rw container;
}

# --- end type Any handling }}}

# end method in }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
