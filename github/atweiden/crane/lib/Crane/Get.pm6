use v6;
use Crane::At;
use Crane::Exists;
use Crane::Utils;
use X::Crane;
unit class Crane::Get;

# method get {{{

method get(
    $container,
    :@path!,
    *%h (
        Bool :k($),
        Bool :v($),
        Bool :p($)
    )
    --> Any:D
)
{
    get($container, :@path, |%h);
}

multi sub get(
    $container,
    :@path!,
    Bool:D :k($)! where .so,
    Bool :v($) where .not,
    Bool :p($) where .not
    --> Any:D
)
{
    get-key($container, @path);
}

multi sub get(
    $container,
    :@path!,
    Bool :k($) where .not,
    Bool:D :v($)! where .so,
    Bool :p($) where .not
    --> Any:D
)
{
    get-value($container, @path);
}

multi sub get(
    $container,
    :@path!,
    Bool :k($) where .not,
    Bool :v($) where .not,
    Bool:D :p($)! where .so
    --> Any:D
)
{
    get-pair($container, @path);
}

multi sub get(
    $container,
    :@path!,
    Bool :k($),
    Bool :v($),
    Bool :p($)
    --> Any:D
)
{
    get-value($container, @path);
}

# --- sub get-key {{{

multi sub get-key(
    $container,
    @path where {
        .elems > 1
            and Crane::Exists.exists($container, :path([@path[0]]), :k)
    }
    --> Any:D
)
{
    get-key(Crane::At.at($container, @path[0]), @path[1..*]);
}

multi sub get-key(
    $container,
    @path where { .elems > 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-key(
    Associative:D $container,
    @path where {
        .elems == 1
            and Crane::Exists.exists($container, :path([@path[0]]), :k)
    }
    --> Any:D
)
{
    $container{@path[0]}:!k;
}

multi sub get-key(
    Associative:D $container,
    @path where { .elems == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-key(
    Associative:D $container,
    @path where { .elems == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new);
}

multi sub get-key(
    Positional:D $container,
    @path where {
        .elems == 1
            and is-valid-positional-index(@path[0])
            and Crane::Exists.exists($container, :path([@path[0]]), :k)
    }
    --> Any:D
)
{
    $container[@path[0]]:!k;
}

multi sub get-key(
    Positional:D $container,
    @path where { .elems == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-key(
    Positional:D $container,
    @path where { .elems == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new);
}

multi sub get-key(
    $container,
    @path where { .elems > 0 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-key(
    $container,
    @path where { .elems == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new);
}

# --- end sub get-key }}}
# --- sub get-pair {{{

multi sub get-pair(
    $container,
    @path where {
        .elems > 1
            and Crane::Exists.exists($container, :path([@path[0]]), :k)
    }
    --> Any:D
)
{
    get-pair(Crane::At.at($container, @path[0]), @path[1..*]);
}

multi sub get-pair(
    $container,
    @path where { .elems > 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-pair(
    Associative:D $container,
    @path where {
        .elems == 1
            and Crane::Exists.exists($container, :path([@path[0]]), :k)
    }
    --> Any:D
)
{
    $container{@path[0]}:!p;
}

multi sub get-pair(
    Associative:D $container,
    @path where { .elems == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-pair(
    Associative:D $container,
    @path where { .elems == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new);
}

multi sub get-pair(
    Positional:D $container,
    @path where {
        .elems == 1
            and is-valid-positional-index(@path[0])
            and Crane::Exists.exists($container, :path([@path[0]]), :k)
    }
    --> Any:D
)
{
    $container[@path[0]]:!p;
}

multi sub get-pair(
    Positional:D $container,
    @path where { .elems == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-pair(
    Positional:D $container,
    @path where { .elems == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new);
}

multi sub get-pair(
    $container,
    @path where { .elems > 0 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-pair(
    $container,
    @path where { .elems == 0 }
    --> Nil
)
{
    die(X::Crane::GetRootContainerKey.new);
}

# --- end sub get-pair }}}
# --- sub get-value {{{

multi sub get-value(
    $container,
    @path where {
        .elems > 1
            and Crane::Exists.exists($container, :path([@path[0]]), :k)
    }
    --> Any:D
)
{
    get-value(Crane::At.at($container, @path[0]), @path[1..*]);
}

multi sub get-value(
    $container,
    @path where { .elems > 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-value(
    Associative:D $container,
    @path where {
        .elems == 1
            and Crane::Exists.exists($container, :path([@path[0]]), :k)
    }
    --> Any:D
)
{
    $container{@path[0]}:!v;
}

multi sub get-value(
    Associative:D $container,
    @path where { .elems == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-value(
    Associative:D $container,
    @path where { .elems == 0 }
    --> Any:D
)
{
    $container;
}

multi sub get-value(
    Positional:D $container,
    @path where {
        .elems == 1
            and is-valid-positional-index(@path[0])
            and Crane::Exists.exists($container, :path([@path[0]]), :k)
    }
    --> Any:D
)
{
    $container[@path[0]]:!v;
}

multi sub get-value(
    Positional:D $container,
    @path where { .elems == 1 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-value(
    Positional:D $container,
    @path where { .elems == 0 }
    --> Any:D
)
{
    $container;
}

multi sub get-value(
    $container,
    @path where { .elems > 0 }
    --> Nil
)
{
    die(X::Crane::GetPathNotFound.new);
}

multi sub get-value(
    $container,
    @path where { .elems == 0 }
    --> Any:D
)
{
    $container;
}

# --- end sub get-value }}}

# end method get }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
