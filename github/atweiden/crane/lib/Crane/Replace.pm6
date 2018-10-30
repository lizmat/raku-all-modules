use v6;
use Crane::At;
use Crane::Exists;
use Crane::Utils;
use X::Crane;
unit class Crane::Replace;

# method replace {{{

method replace(
    \container,
    :@path!,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    # the Crane.replace operation will fail when @path DNE in $container
    # with rules similar to JSON Patch (X::Crane::ReplacePathNotFound)
    #
    # the Crane.replace operation will fail when @path[*-1] is invalid
    # for the container type according to Crane syntax rules:
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.replace operation will fail when it's invalid to set
    # $container at @path to $value, such as when $container at @path
    # is an immutable value (X::Crane::Replace::RO)
    CATCH
    {
        when X::Assignment::RO
        { die(X::Crane::Replace::RO.new(:typename(.typename))) }
        when X::Multi::NoMatch
        {
            my rule cannot-resolve-caller-splice-list
            { 'Cannot resolve caller splice(List' }
            .message !~~ &cannot-resolve-caller-splice-list
                or die(X::Crane::Replace::RO.new(:typename<List>));
        }
        when X::Method::NotFound
        {
            my rule no-such-method-splice
            { No such method \'splice\' for invocant of type \'(\w+)\' }
            .message !~~ &no-such-method-splice
                or die(X::Crane::Replace::RO.new(:typename(~$0)));
        }
    }

    # route replace operation based on path length
    replace(container, :@path, :$value, :$in-place);
}

multi sub replace(
    \container,
    :@path! where { .elems > 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Exists.exists(container, :@path)
        or die(X::Crane::ReplacePathNotFound.new);
    my $what = Crane::At.at(container, @path[0..^*-1]).WHAT;
    replace($what, container, :@path, :$value, :$in-place);
}

multi sub replace(
    Associative,
    \container,
    :@path! where { .elems > 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    replace-in-associative(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub replace(
    Positional,
    \container,
    :@path! where { .elems > 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    is-valid-positional-index(@path[*-1]);
    replace-in-positional(
        container,
        :path(@path[0..^*-1]),
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub replace(
    Any,
    \container,
    :@path! where { .elems > 1 },
    :$value!,
    Bool :$in-place = False
    --> Nil
)
{
    die('✗ Crane accident: replace operation failed, invalid path');
}

multi sub replace(
    Associative \container,
    :@path! where { .elems == 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Exists.exists(container, :@path)
        or die(X::Crane::ReplacePathNotFound.new);
    replace-in-associative(
        container,
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub replace(
    Positional \container,
    :@path! where { .elems == 1 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Exists.exists(container, :@path)
        or die(X::Crane::ReplacePathNotFound.new);
    is-valid-positional-index(@path[*-1]);
    replace-in-positional(
        container,
        :step(@path[*-1]),
        :$value,
        :$in-place
    );
}

multi sub replace(
    \container,
    :@path! where { .elems == 1 },
    :$value!,
    Bool :$in-place = False
    --> Nil
)
{
    Crane::Exists.exists(container, :@path)
        or die(X::Crane::ReplacePathNotFound.new);
    die('✗ Crane accident: replace operation failed, invalid path');
}

multi sub replace(
    Associative \container,
    :@path! where { .elems == 0 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    replace-in-associative(container, :$value, :$in-place);
}

multi sub replace(
    Positional \container,
    :@path! where { .elems == 0 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    replace-in-positional(container, :$value, :$in-place);
}

multi sub replace(
    \container,
    :@path! where { .elems == 0 },
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    replace-in-any(container, :$value, :$in-place);
}

# --- type Associative handling {{{

multi sub replace-in-associative(
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

multi sub replace-in-associative(
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

multi sub replace-in-associative(
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

multi sub replace-in-associative(
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

multi sub replace-in-associative(
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

multi sub replace-in-associative(
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

multi sub replace-in-associative(
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

multi sub replace-in-associative(
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

multi sub replace-in-associative(
    \container,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    container = $value;
    container;
}

multi sub replace-in-associative(
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

multi sub replace-in-positional(
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
    Crane::At.at($root, @path).splice($step, 1, $@value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    Crane::At.at($root, @path).splice($step, 1, $value);
    |$root;
}

multi sub replace-in-positional(
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
    Crane::At.at($root, @path).splice($step, 1, $@value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :@path!,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    Crane::At.at($root, @path).splice($step, 1, $value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    my @value = $value;
    $root.splice($step, 1, $@value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$step!,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    $root.splice($step, 1, $value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$step!,
    :$value! where { $_ ~~ Positional },
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    my @value = $value;
    $root.splice($step, 1, $@value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$step!,
    :$value!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    $root.splice($step, 1, $value);
    |$root;
}

multi sub replace-in-positional(
    \container,
    :$value! where { $_ ~~ Positional },
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    container = $value.clone;
    |container;
}

multi sub replace-in-positional(
    \container,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    container = $value;
    |container;
}

multi sub replace-in-positional(
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

multi sub replace-in-any(
    \container,
    :$value!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    container = $value;
    container;
}

multi sub replace-in-any(
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

# end method replace }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
