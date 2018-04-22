use v6;
use Crane::Add;
use Crane::Get;
use Crane::Remove;
use Crane::Utils;
use X::Crane;
unit class Crane::Move;

# method move {{{

method move(
    \container,
    :@from!,
    :@path!,
    Bool :$in-place = False
    --> Any:D
)
{
    # the Crane.move operation will fail when @from or @path DNE in
    # $container with rules similar to JSON Patch
    # (X::Crane::MoveFromNotFound, X::Crane::MovePathNotFound,
    # X::Crane::MovePathOutOfRange)
    #
    # the Crane.move operation will fail when @from is to be moved into
    # one of its children (X::Crane::MoveParentToChild)
    #
    # the Crane.move operation will fail when @from[*-1] or @path[*-1]
    # is invalid for the container type according to Crane syntax rules:
    #
    #   if @from[*-2] is Positional, then @from[*-1] must be
    #   Int/WhateverCode
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.move operation will fail when it's invalid to move the
    # value of $container at @from, such as when $container at @from is
    # an immutable value (X::Crane::MoveFrom::RO)
    #
    # the Crane.move operation will fail when it's invalid to set
    # $container at @path to the value of $container at @from,
    # such as when $container at @path is an immutable value
    # (X::Crane::MovePath::RO)
    CATCH
    {
        when X::Crane::AddPathNotFound
        { die(X::Crane::MovePathNotFound.new) }
        when X::Crane::AddPathOutOfRange
        { die(X::Crane::MovePathOutOfRange.new(:add-path-out-of-range(.message))) }
        when X::Crane::Add::RO
        { die(X::Crane::MovePath::RO.new(:typename(.typename))) }
        when X::Crane::GetPathNotFound
        { die(X::Crane::MoveFromNotFound.new) }
        when X::Crane::Remove::RO
        { die(X::Crane::MoveFrom::RO.new(:typename(.typename))) }
    }

    # a location cannot be moved into one of its children
    path-is-child-of-from(@from, @path).not
        or die(X::Crane::MoveParentToChild.new);

    move(container, :@from, :@path, :$in-place);
}

proto sub move(|) {*}
multi sub move(
    Positional \container,
    :@from!,
    :@path!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $value = Crane::Get.get(container, :path(@from), :v);
    my $root := container;
    Crane::Remove.remove($root, :path(@from), :in-place);
    Crane::Add.add($root, :@path, :$value, :in-place);
    |$root;
}

multi sub move(
    \container,
    :@from!,
    :@path!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $value = Crane::Get.get(container, :path(@from), :v);
    my $root := container;
    Crane::Remove.remove($root, :path(@from), :in-place);
    Crane::Add.add($root, :@path, :$value, :in-place);
    $root;
}

multi sub move(
    Positional \container,
    :@from!,
    :@path!,
    Bool :in-place($)
    --> Any:D
)
{
    my $value = Crane::Get.get(container, :path(@from), :v);
    my $root = container.deepmap({ .clone });
    Crane::Remove.remove($root, :path(@from), :in-place);
    Crane::Add.add($root, :@path, :$value, :in-place);
    |$root;
}

multi sub move(
    \container,
    :@from!,
    :@path!,
    Bool :in-place($)
    --> Any:D
)
{
    my $value = Crane::Get.get(container, :path(@from), :v);
    my $root = container.deepmap({ .clone });
    Crane::Remove.remove($root, :path(@from), :in-place);
    Crane::Add.add($root, :@path, :$value, :in-place);
    $root;
}

# end method move }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
