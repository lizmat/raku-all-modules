use v6;
use Crane::Exists;
use Crane::Replace;
use Crane::Utils;
use X::Crane;
unit class Crane::Transform;

# method transform {{{

method transform(
    \container,
    :@path!,
    :&with!,
    Bool :$in-place = False
    --> Any:D
)
{
    is-valid-callable-signature(&with)
        or die(X::Crane::TransformCallableSignatureParams.new);

    if @path.elems > 0
    {
        Crane::Exists.exists(container, :@path)
            or die(X::Crane::TransformPathNotFound.new);
    }

    transform(container, :@path, :&with, :$in-place);
}

multi sub transform(
    \container,
    :@path!,
    :&with!,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    transform('do', $root, :@path, :&with);
    $root;
}

multi sub transform(
    \container,
    :@path!,
    :&with!,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    transform('do', $root, :@path, :&with);
    $root;
}

multi sub transform(
    'do',
    \container,
    :@path!,
    :&with!,
    --> Any:D
)
{
    my $value = do try
    {
        CATCH { default { die(X::Crane::TransformCallableRaisedException.new) } }
        with(Crane::At.at(container, @path));
    }

    try
    {
        CATCH
        {
            when X::Crane::Replace::RO
            { die(X::Crane::Transform::RO.new(:typename(.typename))) }
            default
            { die('✗ Crane error: something went wrong during transform') }
        }
        Crane::Replace.replace(container, :@path, :$value, :in-place);
    }

    container;
}

# end method transform }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
