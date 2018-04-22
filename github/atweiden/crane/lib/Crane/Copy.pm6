use v6;
use Crane::Add;
use Crane::Get;
use Crane::Utils;
use X::Crane;
unit class Crane::Copy;

# method copy {{{

method copy(
    \container,
    :@from!,
    :@path!,
    Bool :$in-place = False
    --> Any:D
)
{
    # the Crane.copy operation will fail when @from or @path DNE in
    # $container with rules similar to JSON Patch
    # (X::Crane::CopyFromNotFound, X::Crane::CopyPathNotFound,
    # X::Crane::CopyPathOutOfRange)
    #
    # the Crane.copy operation will fail when @from is to be copied into
    # one of its children (X::Crane::CopyParentToChild)
    #
    # the Crane.copy operation will fail when @from[*-1] or @path[*-1]
    # is invalid for the container type according to Crane syntax rules:
    #
    #   if @from[*-2] is Positional, then @from[*-1] must be
    #   Int/WhateverCode
    #
    #   if @path[*-2] is Positional, then @path[*-1] must be
    #   Int/WhateverCode
    #
    # the Crane.copy operation will fail when it's invalid to set
    # $container at @path to the value of $container at @from,
    # such as when $container at @path is an immutable value
    # (X::Crane::CopyPath::RO)
    CATCH
    {
        when X::Crane::AddPathNotFound
        { die(X::Crane::CopyPathNotFound.new) }
        when X::Crane::AddPathOutOfRange
        { die(X::Crane::CopyPathOutOfRange.new(:add-path-out-of-range(.message))) }
        when X::Crane::Add::RO
        { die(X::Crane::CopyPath::RO.new(:typename(.typename))) }
        when X::Crane::GetPathNotFound
        { die(X::Crane::CopyFromNotFound.new) }
    }

    # a location cannot be copied into one of its children
    path-is-child-of-from(@from, @path).not
        or die(X::Crane::CopyParentToChild.new);

    copy(container, :@from, :@path, :$in-place);
}

proto sub copy(|) {*}
multi sub copy(
    Positional \container,
    :@from!,
    :@path!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $value = Crane::Get.get(container, :path(@from), :v);
    my $root := container;
    Crane::Add.add($root, :@path, :$value, :in-place);
    |$root;
}

multi sub copy(
    \container,
    :@from!,
    :@path!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $value = Crane::Get.get(container, :path(@from), :v);
    my $root := container;
    Crane::Add.add($root, :@path, :$value, :in-place);
    $root;
}

multi sub copy(
    Positional \container,
    :@from!,
    :@path!,
    Bool :in-place($)
    --> Any:D
)
{
    my $value = Crane::Get.get(container, :path(@from), :v);
    my $root = container.deepmap({ .clone });
    Crane::Add.add($root, :@path, :$value, :in-place);
    |$root;
}

multi sub copy(
    \container,
    :@from!,
    :@path!,
    Bool :in-place($)
    --> Any:D
)
{
    my $value = Crane::Get.get(container, :path(@from), :v);
    my $root = container.deepmap({ .clone });
    Crane::Add.add($root, :@path, :$value, :in-place);
    $root;
}

# end method copy }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
