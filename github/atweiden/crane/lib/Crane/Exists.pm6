use v6;
use Crane::At;
use Crane::Utils;
use X::Crane;
unit class Crane::Exists;

# method exists {{{

method exists(
    $container,
    :@path!,
    Bool :$k,
    Bool :$v
    --> Bool:D
)
{
    exists($container, :@path, :$k, :$v);
}

multi sub exists(
    $container,
    :@path!,
    Bool :k($),
    Bool:D :v($)! where .so
    --> Bool:D
)
{
    exists-value($container, @path);
}

multi sub exists(
    $container,
    :@path!,
    Bool:D :k($)! where .so,
    Bool :v($)
    --> Bool:D
)
{
    exists-key($container, @path);
}

multi sub exists(
    $container,
    :@path!,
    Bool :k($),
    Bool :v($)
    --> Bool:D
)
{
    exists-key($container, @path);
}

# --- sub exists-key {{{

multi sub exists-key(
    $container,
    @path where { .elems > 1 and exists-key($container, [@path[0]]) }
    --> Bool:D
)
{
    exists-key(Crane::At.at($container, @path[0]), @path[1..*]);
}

multi sub exists-key(
    $container,
    @path where { .elems > 1 }
    --> Bool:D
)
{
    False;
}

multi sub exists-key(
    Associative:D $container,
    @path where { .elems == 1 }
    --> Bool:D
)
{
    $container{@path[0]}:exists;
}

multi sub exists-key(
    Associative:D $container,
    @path where { .elems == 0 }
    --> Nil
)
{
    die(X::Crane::ExistsRootContainerKey.new);
}

multi sub exists-key(
    Positional:D $container,
    @path where { .elems == 1 and is-valid-positional-index(@path[0]) }
    --> Bool:D
)
{
    $container[@path[0]]:exists;
}

multi sub exists-key(
    Positional:D $container,
    @path where { .elems == 0 }
    --> Nil
)
{
    die(X::Crane::ExistsRootContainerKey.new);
}

multi sub exists-key(
    $container,
    @path where { .elems > 0 }
    --> Bool:D
)
{
    False;
}

# --- end sub exists-key }}}
# --- sub exists-value {{{

multi sub exists-value(
    $container,
    @path where { .elems > 1 and exists-value($container, [@path[0]]) }
    --> Bool:D
)
{
    exists-value(Crane::At.at($container, @path[0]), @path[1..*]);
}

multi sub exists-value(
    $container,
    @path where { .elems > 1 }
    --> Bool:D
)
{
    False;
}

multi sub exists-value(
    Associative:D $container,
    @path where { .elems == 1 }
    --> Bool:D
)
{
    $container{@path[0]}.defined;
}

multi sub exists-value(
    Associative:D $container,
    @path where { .elems == 0 }
    --> Bool:D
)
{
    $container.defined;
}

multi sub exists-value(
    Positional:D $container,
    @path where { .elems == 1 and is-valid-positional-index(@path[0]) }
    --> Bool:D
)
{
    $container[@path[0]].defined;
}

multi sub exists-value(
    Positional:D $container,
    @path where { .elems == 0 }
    --> Bool:D
)
{
    $container.defined;
}

multi sub exists-value(
    $container,
    @path where { .elems > 0 }
    --> Bool:D
)
{
    False;
}

# --- end sub exists-value }}}

# end method exists }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
