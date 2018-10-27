use v6;
use Crane::Add;
use Crane::At;
use Crane::Copy;
use Crane::Flatten;
use Crane::Get;
use Crane::In;
use Crane::List;
use Crane::Move;
use Crane::Patch;
use Crane::Remove;
use Crane::Replace;
use Crane::Set;
use Crane::Test;
use Crane::Transform;
use X::Crane;
unit class Crane;

# method at {{{

method at(
    $container,
    *@steps
    --> Any
) is rw
{
    Crane::At.at($container, @steps);
}

# end method at }}}
# method in {{{

method in(
    \container,
    *@steps
    --> Any
) is rw
{
    Crane::In.in(container, @steps);
}

# end method in }}}

# method exists {{{

method exists(
    $container,
    :@path!,
    Bool :$k,
    Bool :$v
    --> Bool:D
)
{
    Crane::Exists.exists($container, :@path, :$k, :$v);
}

# end method exists }}}
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
    Crane::Get.get($container, :@path, |%h);
}

# end method get }}}

# method set {{{

method set(
    \container,
    :@path!,
    :$value!
    --> Any:D
)
{
    Crane::Set.set(container, :@path, :$value);
}

# end method set }}}

# method add {{{

method add(
    \container,
    :@path!,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Add.add(container, :@path, :$value, :$in-place);
}

# end method add }}}
# method remove {{{

method remove(
    \container,
    :@path!,
    Bool :$in-place = False
    --> Any
)
{
    Crane::Remove.remove(container, :@path, :$in-place);
}

# end method remove }}}
# method replace {{{

method replace(
    \container,
    :@path!,
    :$value!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Replace.replace(container, :@path, :$value, :$in-place);
}

# end method replace }}}

# method move {{{

method move(
    \container,
    :@from!,
    :@path!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Move.move(container, :@from, :@path, :$in-place);
}

# end method move }}}
# method copy {{{

method copy(
    \container,
    :@from!,
    :@path!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Copy.copy(container, :@from, :@path, :$in-place);
}

# end method copy }}}

# method test {{{

method test(
    $container,
    :@path!,
    :$value!
    --> Bool:D
)
{
    Crane::Test.test($container, :@path, :$value);
}

# end method test }}}

# method list {{{

method list(
    $container,
    :@path
    --> List:D
)
{
    Crane::List.list($container, :@path);
}

# end method list }}}
# method flatten {{{

method flatten(
    $container,
    :@path
    --> Hash[Any:D,List:D]
)
{
    my Any:D %tree{List:D} = Crane::Flatten.flatten($container, :@path);
}

# end method flatten }}}

# method transform {{{

method transform(
    \container,
    :@path!,
    :&with!,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Transform.transform(container, :@path, :&with, :$in-place);
}

# end method transform }}}

# method patch {{{

method patch(
    \container,
    @patch,
    Bool :$in-place = False
    --> Any:D
)
{
    Crane::Patch.patch(container, @patch, :$in-place);
}

# end method patch }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
