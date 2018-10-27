use v6;
use X::Crane;
unit class Crane::Utils;

# sub is-valid-callable-signature {{{

sub is-valid-callable-signature(&c --> Bool:D) is export
{
    my Bool:D $is-valid-callable-signature =
        &c.signature.params.elems == 1
            && &c.signature.params.grep({ .positional }).elems == 1;
}

# end sub is-valid-callable-signature }}}
# sub is-valid-positional-index {{{

# INT0P: Int where * >= 0 (valid)
# WEC: WhateverCode (valid)
# INTM: Int where * < 0 (invalid)
# OTHER: everything else (invalid)
my enum Classifier <INT0P INTM OTHER WEC>;

multi sub is-valid-positional-index(INT0P --> Bool:D)
{
    my Bool:D $is-valid-positional-index = True;
}

multi sub is-valid-positional-index(WEC --> Bool:D)
{
    my Bool:D $is-valid-positional-index = True;
}

multi sub is-valid-positional-index(INTM --> Nil)
{
    die(X::Crane::PositionalIndexInvalid.new(:classifier<INTM>));
}

multi sub is-valid-positional-index(OTHER --> Nil)
{
    die(X::Crane::PositionalIndexInvalid.new(:classifier<OTHER>));
}

multi sub is-valid-positional-index($step --> Bool:D) is export
{
    my Classifier:D $classifier = gen-classifier($step);
    my Bool:D $is-valid-positional-index =
        is-valid-positional-index($classifier);
}

# classify positional index requests
multi sub gen-classifier(Int:D $ where * >= 0 --> Classifier:D)
{
    my Classifier:D $classify = INT0P;
}

multi sub gen-classifier(Int:D $ where * < 0 --> Classifier:D)
{
    my Classifier:D $classify = INTM;
}

multi sub gen-classifier(WhateverCode:D $ --> Classifier:D)
{
    my Classifier:D $classify = WEC;
}

multi sub gen-classifier($ --> Classifier:D)
{
    my Classifier:D $classify = OTHER;
}

# end sub is-valid-positional-index }}}
# sub path-is-child-of-from {{{

multi sub path-is-child-of-from(
    @from,
    @path
    --> Bool:D
) is export
{
    my Bool:D $path-is-child-of-from =
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
    my Bool:D $path-is-child-of-from = False;
}

multi sub path-is-child-of-from(
    'do',
    @from,
    @path where { .elems < @from.elems }
    --> Bool:D
)
{
    # @path can't be child of @from if @path is shallower than @from
    my Bool:D $path-is-child-of-from = False;
}

# @path is at deeper level than @from
multi sub path-is-child-of-from(
    'do',
    @from,
    @path
    --> Bool:D
)
{
    my Bool:D $path-is-child-of-from =
        (0..@from.end)
            .map(-> Int $from { @from[$from] eqv @path[$from] })
            .grep({ .so })
            .elems == @from.elems;
}

# end sub path-is-child-of-from }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
