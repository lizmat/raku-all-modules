use v6;
use Crane::At;
use Crane::Exists;
use Crane::Utils;
use X::Crane;
unit class Crane::Add;

# method add {{{

method add(
    \container,
    :@path!,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    # the Crane.add operation will fail when @path DNE in $container
    # with rules similar to JSON Patch (X::Crane::AddPathNotFound,
    # X::Crane::AddPathOutOfRange)
    #
    # the Crane.add operation will fail when @path[*-1] is invalid for
    # the container type according to Crane syntax rules:
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.add operation will fail when it's invalid to set
    # $container at @path to $value, such as when $container at @path
    # is an immutable value (X::Crane::Add::RO)
    CATCH
    {
        when X::Multi::NoMatch
        {
            my rule cannot-resolve-caller-splice-list
            { 'Cannot resolve caller splice(List' }
            .message !~~ &cannot-resolve-caller-splice-list
                or die(X::Crane::Add::RO.new(:typename<List>));
        }
        when X::Assignment::RO
        { die(X::Crane::Add::RO.new(:typename(.typename))) }
        when X::Method::NotFound
        {
            my rule no-such-method-splice
            { No such method \'splice\' for invocant of type \'(\w+)\' }
            .message !~~ &no-such-method-splice
                or die(X::Crane::Add::RO.new(:typename(~$0)));
        }
        when X::OutOfRange
        { die(X::Crane::AddPathOutOfRange.new(:operation<add>, :out-of-range($_))) }
    }

    # route add operation based on path length
    add(container, :@path, :$value, :$in-place);
}

multi sub add(
    \container,
    :@path! where { .elems > 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Exists.exists(container, :path(@path[0..^*-1]), :v)
        or die(X::Crane::AddPathNotFound.new);
    my $what = Crane::At.at(container, @path[0..^*-1]).WHAT;
    add($what, container, :@path, :$value, :$in-place);
}

multi sub add(
    Associative,
    \container,
    :@path! where { .elems > 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    add-to-associative(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub add(
    Positional,
    \container,
    :@path! where { .elems > 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    is-valid-positional-index(@path[*-1]);
    add-to-positional(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub add(
    Any,
    \container,
    :@path! where { .elems > 1 },
    :$value!,
    Bool :$in-place = False
    --> Nil
)
{
    die('✗ Crane accident: add operation failed, invalid path');
}

multi sub add(
    Associative \container,
    :@path! where { .elems == 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Exists.exists(container, :path(), :v)
        or die(X::Crane::AddPathNotFound.new);
    add-to-associative(
        container,
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub add(
    Positional \container,
    :@path! where { .elems == 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Exists.exists(container, :path(), :v)
        or die(X::Crane::AddPathNotFound.new);
    is-valid-positional-index(@path[*-1]);
    add-to-positional(
        container,
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub add(
    \container,
    :@path! where { .elems == 1 },
    :$value!,
    Bool :$in-place = False
    --> Nil
)
{
    Crane::Exists.exists(container, :path(), :v)
        or die(X::Crane::AddPathNotFound.new);
    die('✗ Crane accident: add operation failed, invalid path');
}

multi sub add(
    Associative \container,
    :@path! where { .elems == 0 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    add-to-associative(container, :$value, :$in-place);
}

multi sub add(
    Positional \container,
    :@path! where { .elems == 0 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    add-to-positional(container, :$value, :$in-place);
}

multi sub add(
    \container,
    :@path! where { .elems == 0 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    add-to-any(container, :$value, :$in-place);
}

# --- type Associative handling {{{

multi sub add-to-associative(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    Crane::At.at($root, @path){$step} = $value.clone;
    $root;
}

multi sub add-to-associative(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    Crane::At.at($root, @path){$step} = $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    Crane::At.at($root, @path){$step} = $value.clone;
    $root;
}

multi sub add-to-associative(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    Crane::At.at($root, @path){$step} = $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    $root{$step} = $value.clone;
    $root;
}

multi sub add-to-associative(
    \container,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    $root{$step} = $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    $root{$step} = $value.clone;
    $root;
}

multi sub add-to-associative(
    \container,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    $root{$step} = $value;
    $root;
}

multi sub add-to-associative(
    \container,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    container = $value;
    container;
}

multi sub add-to-associative(
    \container,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    $root = $value;
    $root;
}

# --- end type Associative handling }}}
# --- type Positional handling {{{

# XXX when $value is a multi-dimensional array, splice ruins it by
# flattening it (splice's signature is *@target-to-splice-in)
#
# we have to inspect the structure of $value and work around this to
# provide a sane api
#
# weirdly, using C<where {$_ ~~ Positional}> makes a difference in type
# checking compared to C<Positional :$value!>
multi sub add-to-positional(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    my @value = $value;
    Crane::At.at($root, @path).splice($step, 0, $@value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    Crane::At.at($root, @path).splice($step, 0, $value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :@path!,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    my @value = $value;
    Crane::At.at($root, @path).splice($step, 0, $@value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    Crane::At.at($root, @path).splice($step, 0, $value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    my @value = $value;
    $root.splice($step, 0, $@value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    $root.splice($step, 0, $value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    my @value = $value;
    $root.splice($step, 0, $@value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    $root.splice($step, 0, $value);
    |$root;
}

multi sub add-to-positional(
    \container,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    container = $value.clone;
    |container;
}

multi sub add-to-positional(
    \container,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    container = $value;
    |container;
}

multi sub add-to-positional(
    \container,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    $root = $value.clone;
    |$root;
}

multi sub add-to-positional(
    \container,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    $root = $value;
    |$root;
}

# --- end type Positional handling }}}
# --- type Any handling {{{

multi sub add-to-any(
    \container,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    container = $value;
    container;
}

multi sub add-to-any(
    \container,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    $root = $value;
    $root;
}

# --- end type Any handling }}}

# end method add }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
