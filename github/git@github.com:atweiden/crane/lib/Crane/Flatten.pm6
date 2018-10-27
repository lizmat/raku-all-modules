use v6;
use Crane::List;
unit class Crane::Flatten;

# method flatten {{{

method flatten(
    $container,
    :@path
    --> Hash[Any:D,List:D]
)
{
    my Any:D %tree{List:D} =
        Crane::List.list($container, :@path).map({ .<path> => .<value> });
}

# end method flatten }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
