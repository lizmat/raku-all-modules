use v6;
use Crane::Add;
use Crane::Copy;
use Crane::Move;
use Crane::Remove;
use Crane::Replace;
use Crane::Test;
use X::Crane;
unit class Crane::Patch;

# method patch {{{

method patch(
    \container,
    @patch,
    Bool :$in-place = False
    --> Any:D
)
{
    patch(container, @patch, :$in-place);
}

multi sub patch(
    \container,
    @patch,
    Bool:D :in-place($)! where .so
    --> Any:D
)
{
    my $root := container;
    patch('do', $root, @patch);
}

multi sub patch(
    \container,
    @patch,
    Bool :in-place($)
    --> Any:D
)
{
    my $root = container.deepmap({ .clone });
    patch('do', $root, @patch);
}

multi sub patch(
    'do',
    \container,
    @patch,
    --> Any:D
)
{
    @patch.map(-> %patch {
        try
        {
            CATCH
            {
                when X::Crane::PatchAddFailed
                { die(X::Crane::Patch.new(:help-text(.message))) }
                when X::Crane::PatchRemoveFailed
                { die(X::Crane::Patch.new(:help-text(.message))) }
                when X::Crane::PatchReplaceFailed
                { die(X::Crane::Patch.new(:help-text(.message))) }
                when X::Crane::PatchMoveFailed
                { die(X::Crane::Patch.new(:help-text(.message))) }
                when X::Crane::PatchCopyFailed
                { die(X::Crane::Patch.new(:help-text(.message))) }
                when X::Crane::PatchTestFailed
                { die(X::Crane::Patch.new(:help-text(.message))) }
                default
                { die('✗ Crane accident: patch operation failed') }
            }
            patch(container, %patch);
        }
    });
    container;
}

# add
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'add'}, :@path!, :$value!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchAddFailed.new.throw } }
    Crane::Add.add(container, :@path, :$value, :in-place);
}

# remove
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'remove'}, :@path!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchRemoveFailed.new.throw } }
    Crane::Remove.remove(container, :@path, :in-place);
}

# replace
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'replace'}, :@path!, :$value!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchReplaceFailed.new.throw } }
    Crane::Replace.replace(container, :@path, :$value, :in-place);
}

# move
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'move'}, :@from!, :@path!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchMoveFailed.new.throw } }
    Crane::Move.move(container, :@from, :@path, :in-place);
}

# copy
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'copy'}, :@from!, :@path!)
    --> Any:D
)
{
    CATCH { default { X::Crane::PatchCopyFailed.new.throw } }
    Crane::Copy.copy(container, :@from, :@path, :in-place);
}

# test
multi sub patch(
    \container,
    %patch (:op($)! where {$_ eq 'test'}, :@path!, :$value!)
    --> Bool:D
)
{
    Crane::Test.test(container, :@path, :$value)
        or X::Crane::PatchTestFailed.new.throw;
}

# end method patch }}}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
