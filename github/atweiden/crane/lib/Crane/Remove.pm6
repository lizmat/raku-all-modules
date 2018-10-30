use v6;
use Crane::At;
use Crane::Exists;
use Crane::Utils;
use X::Crane;
unit class Crane::Remove;

# method remove {{{

method remove(
    \container,
    :@path!,
    Bool :$in-place = False
    --> Any
)
{
    # the Crane.remove operation will fail when @path DNE in $container
    # with rules similar to JSON Patch (X::Crane::RemovePathNotFound)
    #
    # the Crane.remove operation will fail when @path[*-1] is invalid for
    # the container type according to Crane syntax rules:
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.remove operation will fail when it's invalid to remove
    # from $container at @path, such as when $container at @path is an
    # immutable value (X::Crane::Remove::RO)
    CATCH
    {
        when X::AdHoc
        {
            my rule can-not-remove
            { Can not remove [values|elements] from a (\w+) }
            .payload !~~ &can-not-remove
                or die(X::Crane::Remove::RO.new(:typename(~$0)));
        }
        when X::Multi::NoMatch
        {
            my rule cannot-resolve-caller-splice-list
            { 'Cannot resolve caller splice(List' }
            .message !~~ &cannot-resolve-caller-splice-list
                or die(X::Crane::Remove::RO.new(:typename<List>));
        }
        when X::Method::NotFound
        {
            my rule no-such-method-splice
            { No such method \'splice\' for invocant of type \'(\w+)\' }
            .message !~~ &no-such-method-splice
                or die(X::Crane::Remove::RO.new(:typename(~$0)));
        }
    }

    # route remove operation based on path length
    remove(container, :@path, :$in-place);
}

multi sub remove(
    \container,
    :@path! where { .elems > 1 },
    Bool :$in-place = False
    --> Any
)
{
    Crane::Exists.exists(container, :@path)
        or die(X::Crane::RemovePathNotFound.new);
    my $what = Crane::At.at(container, @path[0..^*-1]).WHAT;
    remove($what, container, :@path, :$in-place);
}

multi sub remove(
    Associative,
    \container,
    :@path! where { .elems > 1 },
    Bool :$in-place = False
    --> Any
)
{
    remove-from-associative(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$in-place
    );
}

multi sub remove(
    Positional,
    \container,
    :@path! where { .elems > 1 },
    Bool :$in-place = False
    --> Any
)
{
    is-valid-positional-index(@path[*-1]);
    remove-from-positional(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$in-place
    );
}

multi sub remove(
    Any,
    \container,
    :@path! where { .elems > 1 },
    Bool :$in-place = False
    --> Nil
)
{
    die('✗ Crane accident: remove operation failed, invalid path');
}

multi sub remove(
    Associative \container,
    :@path! where { .elems == 1 },
    Bool :$in-place = False
    --> Any
)
{
    Crane::Exists.exists(container, :@path)
        or die(X::Crane::RemovePathNotFound.new);
    remove-from-associative(container, :step(@path[*-1]), :$in-place);
}

multi sub remove(
    Positional \container,
    :@path! where { .elems == 1 },
    Bool :$in-place = False
    --> Any
)
{
    Crane::Exists.exists(container, :@path)
        or die(X::Crane::RemovePathNotFound.new);
    is-valid-positional-index(@path[*-1]);
    remove-from-positional(container, :step(@path[*-1]), :$in-place);
}

multi sub remove(
    \container,
    :@path! where { .elems == 1 },
    Bool :$in-place = False
    --> Nil
)
{
    Crane::Exists.exists(container, :@path)
        or die(X::Crane::RemovePathNotFound.new);
    die('✗ Crane accident: remove operation failed, invalid path');
}

multi sub remove(
    Associative \container,
    :@path! where { .elems == 0 },
    Bool :$in-place = False
    --> Any
)
{
    remove-from-associative(container, :$in-place);
}

multi sub remove(
    Positional \container,
    :@path! where { .elems == 0 },
    Bool :$in-place = False
    --> Any
)
{
    remove-from-positional(container, :$in-place);
}

multi sub remove(
    \container,
    :@path! where { .elems == 0 },
    Bool :$in-place = False
    --> Any
)
{
    remove-from-any(container, :$in-place);
}

# --- type Associative handling {{{

multi sub remove-from-associative(
    \container,
    :@path!,
    :$step!,
    Bool:D :in-place($)! where .so
    --> Any
)
{
    my $root := container;
    Crane::At.at($root, @path){$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    :@path!,
    :$step!,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap({ .clone });
    Crane::At.at($root, @path){$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    :$step!,
    Bool:D :in-place($)! where .so
    --> Any
)
{
    my $root := container;
    $root{$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    :$step!,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap({ .clone });
    $root{$step}:delete;
    $root;
}

multi sub remove-from-associative(
    \container,
    Bool:D :in-place($)! where .so
    --> Any
)
{
    container = Empty;
    container;
}

multi sub remove-from-associative(
    \container,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap({ .clone });
    $root = Empty;
    $root;
}

# --- end type Associative handling }}}
# --- type Positional handling {{{

multi sub remove-from-positional(
    \container,
    :@path!,
    :$step!,
    Bool:D :in-place($)! where .so
    --> Any
)
{
    my $root := container;
    Crane::At.at($root, @path).splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    :@path!,
    :$step!,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap({ .clone });
    Crane::At.at($root, @path).splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    :$step!,
    Bool:D :in-place($)! where .so
    --> Any
)
{
    my $root := container;
    $root.splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    :$step!,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap({ .clone });
    $root.splice($step, 1);
    |$root;
}

multi sub remove-from-positional(
    \container,
    Bool:D :in-place($)! where .so
    --> Any
)
{
    container = Empty;
    |container;
}

multi sub remove-from-positional(
    \container,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap({ .clone });
    $root = Empty;
    |$root;
}

# --- end type Positional handling }}}
# --- type Any handling {{{

multi sub remove-from-any(
    \container,
    Bool:D :in-place($)! where .so
    --> Any
)
{
    container = Nil;
    container;
}

multi sub remove-from-any(
    \container,
    Bool :in-place($)
    --> Any
)
{
    my $root = container.deepmap({ .clone });
    $root = Nil;
    $root;
}

# --- end type Any handling }}}

# end method remove }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
