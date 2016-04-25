use v6;
unit module X::Crane;

# X::Crane::PathOutOfRange {{{

class PathOutOfRange is Exception
{
    has Str:D $.operation is required;
    has X::OutOfRange:D $.out-of-range is required;

    # parse stringified Range in X::OutOfRange
    grammar RangeStr
    {
        token integer
        {
            '-'? \d+
        }
        token range-str
        {
            <integer> '..' <integer>
        }
        token TOP
        {
            ^ <range-str> $
        }
    }
    class RangeStrActions
    {
        method integer($/)
        {
            make +$/;
        }
        method range-str($/)
        {
            my Range $r = @<integer>».made[0] .. @<integer>».made[1];
            make $r;
        }
        method TOP($/)
        {
            make $<range-str>.made;
        }
    }

    method message() returns Str
    {
        my Int $got = $.out-of-range.got;
        my RangeStrActions $actions .= new;
        my Range $range = RangeStr.parse($.out-of-range.range, :$actions).made;
        my Str $reason = $got cmp $range > 0
            ?? 'creating sparse Positional not allowed'
            !! 'Positional index out of range';
        $reason ~= ". Is $got, should be in {$range.gist}";
        "✗ Crane error: $.operation operation failed, $reason";
    }
}

# end X::Crane::PathOutOfRange }}}

# X::Crane::AddPathNotFound {{{

class AddPathNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: add operation failed, path not found in container';
    }
}

# end X::Crane::AddPathNotFound }}}

# X::Crane::AddPathOutOfRange {{{

class AddPathOutOfRange is PathOutOfRange {*}

# end X::Crane::AddPathOutOfRange }}}

# X::Crane::Add::RO {{{

class Add::RO is Exception
{
    has $.typename;
    method message() returns Str
    {
        "✗ Crane error: add requested modifying an immutable $.typename";
    }
}

# end X::Crane::Add::RO }}}

# X::Crane::AssociativeKeyDNE {{{

class AssociativeKeyDNE is Exception
{
    method message() returns Str
    {
        '✗ Crane error: associative key does not exist';
    }
}

# end X::Crane::AssociativeKeyDNE }}}

# X::Crane::CopyFromNotFound {{{

class CopyFromNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: copy operation failed, from location nonexistent';
    }
}

# end X::Crane::CopyFromNotFound }}}

# X::Crane::CopyParentToChild {{{

class CopyParentToChild is Exception
{
    method message() returns Str
    {
        '✗ Crane error: a location cannot be copied into one of its children';
    }
}

# end X::Crane::CopyParentToChild }}}

# X::Crane::CopyPathNotFound {{{

class CopyPathNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: copy operation failed, path nonexistent';
    }
}

# end X::Crane::CopyPathNotFound }}}

# X::Crane::CopyPathOutOfRange {{{

class CopyPathOutOfRange is Exception
{
    has Str $.add-path-out-of-range is required;
    method message() returns Str
    {
        $.add-path-out-of-range.subst(/'add operation'/, 'copy operation');
    }
}

# end X::Crane::CopyPathOutOfRange }}}

# X::Crane::CopyPath::RO {{{

class CopyPath::RO is Exception
{
    has $.typename;
    method message() returns Str
    {
        "✗ Crane error: requested copy path is immutable $.typename";
    }
}

# end X::Crane::CopyPath::RO }}}

# X::Crane::GetPathNotFound {{{

class GetPathNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: get operation failed, path nonexistent';
    }
}

# end X::Crane::GetPathNotFound }}}

# X::Crane::GetRootContainerKey {{{

class GetRootContainerKey is Exception
{
    method message() returns Str
    {
        '✗ Crane error: cannot request key operations on container root';
    }
}

# end X::Crane::GetRootContainerKey }}}

# X::Crane::ExistsRootContainerKey {{{

class ExistsRootContainerKey is Exception
{
    method message() returns Str
    {
        '✗ Crane error: cannot request key operations on container root';
    }
}

# end X::Crane::ExistsRootContainerKey }}}

# X::Crane::MoveFromNotFound {{{

class MoveFromNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: move operation failed, from location nonexistent';
    }
}

# end X::Crane::MoveFromNotFound }}}

# X::Crane::MoveFrom::RO {{{

class MoveFrom::RO is Exception
{
    has $.typename;
    method message() returns Str
    {
        "✗ Crane error: requested move from immutable $.typename";
    }
}

# end X::Crane::MoveFrom::RO }}}

# X::Crane::MoveParentToChild {{{

class MoveParentToChild is Exception
{
    method message() returns Str
    {
        '✗ Crane error: a location cannot be moved into one of its children';
    }
}

# end X::Crane::MoveParentToChild }}}

# X::Crane::MovePathNotFound {{{

class MovePathNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: move operation failed, path nonexistent';
    }
}

# end X::Crane::MovePathNotFound }}}

# X::Crane::MovePathOutOfRange {{{

class MovePathOutOfRange is Exception
{
    has Str $.add-path-out-of-range is required;
    method message() returns Str
    {
        $.add-path-out-of-range.subst(/'add operation'/, 'move operation');
    }
}

# end X::Crane::MovePathOutOfRange }}}

# X::Crane::MovePath::RO {{{

class MovePath::RO is Exception
{
    has $.typename;
    method message() returns Str
    {
        "✗ Crane error: requested move path is immutable $.typename";
    }
}

# end X::Crane::MovePath::RO }}}

# X::Crane::Patch {{{

class Patch is Exception
{
    has Str $.help-text;
    method message() returns Str
    {
        $.help-text;
    }
}

# end X::Crane::Patch }}}

# X::Crane::PatchAddFailed {{{

class PatchAddFailed is Exception
{
    method message() returns Str
    {
        '✗ Crane error: patch operation failed, add failed';
    }
}

# end X::Crane::PatchAddFailed }}}

# X::Crane::PatchCopyFailed {{{

class PatchCopyFailed is Exception
{
    method message() returns Str
    {
        '✗ Crane error: patch operation failed, copy failed';
    }
}

# end X::Crane::PatchCopyFailed }}}

# X::Crane::PatchMoveFailed {{{

class PatchMoveFailed is Exception
{
    method message() returns Str
    {
        '✗ Crane error: patch operation failed, move failed';
    }
}

# end X::Crane::PatchMoveFailed }}}

# X::Crane::PatchRemoveFailed {{{

class PatchRemoveFailed is Exception
{
    method message() returns Str
    {
        '✗ Crane error: patch operation failed, remove failed';
    }
}

# end X::Crane::PatchRemoveFailed }}}

# X::Crane::PatchReplaceFailed {{{

class PatchReplaceFailed is Exception
{
    method message() returns Str
    {
        '✗ Crane error: patch operation failed, replace failed';
    }
}

# end X::Crane::PatchReplaceFailed }}}

# X::Crane::PatchTestFailed {{{

class PatchTestFailed is Exception
{
    method message() returns Str
    {
        '✗ Crane error: patch operation failed, test failed';
    }
}

# end X::Crane::PatchTestFailed }}}

# X::Crane::PositionalIndexDNE {{{

class PositionalIndexDNE is Exception
{
    method message() returns Str
    {
        '✗ Crane error: positional index does not exist';
    }
}

# end X::Crane::PositionalIndexDNE }}}

# X::Crane::PositionalIndexInvalid {{{

class PositionalIndexInvalid is Exception
{
    has Str $.classifier;
    method message() returns Str
    {
        my Str $error-message;
        given $.classifier
        {
            when 'INTM'
            {
                $error-message =
                    'unsupported use of negative subscript to index Positional';
            }
            when 'OTHER'
            {
                $error-message = 'given Positional index invalid';
            }
        }
        "✗ Crane error: $error-message";
    }
}

# end X::Crane::PositionalIndexInvalid }}}

# X::Crane::RemovePathNotFound {{{

class RemovePathNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: remove operation failed, path not found in container';
    }
}

# end X::Crane::RemovePathNotFound }}}

# X::Crane::Remove::RO {{{

class Remove::RO is Exception
{
    has $.typename;
    method message() returns Str
    {
        "✗ Crane error: requested remove operation on immutable $.typename";
    }
}

# end X::Crane::Remove::RO }}}

# X::Crane::ReplacePathNotFound {{{

class ReplacePathNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: replace operation failed, path not found in container';
    }
}

# end X::Crane::ReplacePathNotFound }}}

# X::Crane::Replace::RO {{{

class Replace::RO is Exception
{
    has $.typename;
    method message() returns Str
    {
        "✗ Crane error: replace requested modifying an immutable $.typename";
    }
}

# end X::Crane::Replace::RO }}}

# X::Crane::OpSet::RO {{{

class OpSet::RO is Exception
{
    has $.typename;
    method message() returns Str
    {
        "✗ Crane error: set requested modifying an immutable $.typename";
    }
}

# end X::Crane::OpSet::RO }}}

# X::Crane::TestPathNotFound {{{

class TestPathNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: test operation failed, path nonexistent';
    }
}

# end X::Crane::TestPathNotFound }}}

# X::Crane::TransformCallableRaisedException {{{

class TransformCallableRaisedException is Exception
{
    method message() returns Str
    {
        '✗ Crane error: transform operation failed, callable raised exception';
    }
}

# end X::Crane::TransformCallableRaisedException }}}

# X::Crane::TransformCallableSignatureParams {{{

class TransformCallableSignatureParams is Exception
{
    method message() returns Str
    {
        '✗ Crane error: transform operation failed, faulty callable signature';
    }
}

# end X::Crane::TransformCallableSignatureParams }}}

# X::Crane::TransformPathNotFound {{{

class TransformPathNotFound is Exception
{
    method message() returns Str
    {
        '✗ Crane error: transform operation failed, path nonexistent';
    }
}

# end X::Crane::TransformPathNotFound }}}

# X::Crane::Transform::RO {{{

class Transform::RO is Exception
{
    has $.typename;
    method message() returns Str
    {
        "✗ Crane error: transform requested modifying an immutable $.typename";
    }
}

# end X::Crane::Transform::RO }}}

# vim: ft=perl6 fdm=marker fdl=0
