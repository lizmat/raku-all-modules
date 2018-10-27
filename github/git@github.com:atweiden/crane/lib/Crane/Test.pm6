use v6;
use Crane::At;
use Crane::Exists;
use X::Crane;
unit class Crane::Test;

# method test {{{

method test(
    $container,
    :@path!,
    :$value!
    --> Bool:D
)
{
    Crane::Exists.exists($container, :@path)
        or die(X::Crane::TestPathNotFound.new);
    Crane::At.at($container, @path) eqv $value;
}

# end method test }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
