use v6;
use Crane::At;
unit class Crane::List;

# method list {{{

method list(
    $container,
    :@path
    --> List:D
)
{
    list($container, :@path);
}

multi sub list(
    Associative:D $container,
    :@path
    --> List:D
)
{
    list('do', Crane::At.at($container, @path));
}

multi sub list(
    Positional:D $container,
    :@path
    --> List:D
)
{
    list('do', Crane::At.at($container, @path));
}

multi sub list(
    $container,
    :path(@)
    --> List:D
)
{
    list('do', $container);
}

multi sub list(
    'do',
    Associative:D $container where { .elems > 0 },
    :@carry = ()
    --> List:D
)
{
    my @tree;
    $container.keys.map(-> $toplevel {
        my @current = |@carry, $toplevel;
        push(
            @tree,
            |list('do', Crane::At.at($container, $toplevel), :carry(@current))
        );
    });
    @tree.sort.List;
}

multi sub list(
    'do',
    Positional:D $container where { .elems > 0 },
    :@carry = ()
    --> List:D
)
{
    my @tree;
    $container.keys.map(-> $toplevel {
        my @current = |@carry, $toplevel;
        push(
            @tree,
            |list('do', Crane::At.at($container, $toplevel), :carry(@current))
        );
    });
    @tree.sort.List;
}

multi sub list(
    'do',
    $container,
    :@carry = ()
    --> List:D
)
{
    List({:path(@carry), :value($container)});
}

# end method list }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
