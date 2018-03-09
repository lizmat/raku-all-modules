use v6;
use Crane::In;
use X::Crane;
unit class Crane::Set;

# method set {{{

method set(
    \container,
    :@path!,
    :$value!
    --> Any:D
)
{
    # the Crane.set operation will fail when @path[*-1] is invalid for
    # the container type according to Crane syntax rules:
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.set operation will fail when it's invalid to set
    # $container at @path to $value, such as when $container at @path
    # is an immutable value (X::Crane::OpSet::RO)
    CATCH
    {
        when X::Assignment::RO
        { die(X::Crane::OpSet::RO.new(:typename(.typename))) }
    }

    set(container, :@path, :$value);
}

multi sub set(
    Positional \container,
    :@path!,
    :$value! where { $_ ~~ Positional }
    --> Any:D
)
{
    Crane::In.in(container, @path) = $value.clone;
    |container;
}

multi sub set(
    \container,
    :@path!,
    :$value! where { $_ ~~ Positional }
    --> Any:D
)
{
    Crane::In.in(container, @path) = $value.clone;
    container;
}

multi sub set(
    Positional \container,
    :@path!,
    :$value!
    --> Any:D
)
{
    Crane::In.in(container, @path) = $value;
    |container;
}

multi sub set(
    \container,
    :@path!,
    :$value!
    --> Any:D
)
{
    Crane::In.in(container, @path) = $value;
    container;
}

# end method set }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
