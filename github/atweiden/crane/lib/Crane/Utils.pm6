use v6;
use X::Crane;
unit class Crane::Utils;

# helper functions {{{

# --- sub is-valid-callable-signature {{{

sub is-valid-callable-signature(&c --> Bool:D) is export
{
    &c.signature.params.elems == 1
        && &c.signature.params.grep(*.positional).elems == 1;
}

# --- end sub is-valid-callable-signature }}}
# --- sub is-valid-positional-index {{{

# INT0P: Int where * >= 0 (valid)
# WEC: WhateverCode (valid)
# INTM: Int where * < 0 (invalid)
# OTHER: everything else (invalid)
my enum Classifier <INT0P INTM OTHER WEC>;

multi sub is-valid-positional-index($step --> Bool:D) is export
{
    $step
    ==> is-valid-positional-index('classify')
    ==> is-valid-positional-index('do');
}

# classify positional index requests for better error messages
multi sub is-valid-positional-index(
    'classify',
    Int:D $ where * >= 0
    --> Classifier:D
)
{
    INT0P;
}

multi sub is-valid-positional-index(
    'classify',
    Int:D $ where * < 0
    --> Classifier:D
)
{
    INTM;
}

multi sub is-valid-positional-index(
    'classify',
    WhateverCode:D $
    --> Classifier:D
)
{
    WEC;
}

multi sub is-valid-positional-index(
    'classify',
    $
    --> Classifier:D
)
{
    OTHER;
}

multi sub is-valid-positional-index('do', INT0P --> Bool:D)
{
    True;
}

multi sub is-valid-positional-index('do', WEC --> Bool:D)
{
    True;
}

multi sub is-valid-positional-index('do', INTM --> Nil)
{
    die(X::Crane::PositionalIndexInvalid.new(:classifier<INTM>));
}

multi sub is-valid-positional-index('do', OTHER --> Nil)
{
    die(X::Crane::PositionalIndexInvalid.new(:classifier<OTHER>));
}

# --- end sub is-valid-positional-index }}}
# --- sub path-is-child-of-from {{{

multi sub path-is-child-of-from(
    @from,
    @path
    --> Bool:D
) is export
{
    path-is-child-of-from('do', @from, @path);
}

multi sub path-is-child-of-from(
    'do',
    @from,
    @path where { .elems == @from.elems }
    --> Bool:D
)
{
    # @path can't be child of @from if both are at the same depth
    False;
}

multi sub path-is-child-of-from(
    'do',
    @from,
    @path where { .elems < @from.elems }
    --> Bool:D
)
{
    # @path can't be child of @from if @path is shallower than @from
    False;
}

# @path is at deeper level than @from
# verify @from[$_] !eqv @path[$_] for 0..@from.end
multi sub path-is-child-of-from(
    'do',
    @from,
    @path
    --> Bool:D
)
{
    (0..@from.end)
        .map({ @from[$_] eqv @path[$_] })
        .grep(*.so)
        .elems == @from.elems;
}

# --- end sub path-is-child-of-from }}}

# end helper functions }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
