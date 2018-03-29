use NativeCall;
use Git::Error;
use Git::Buffer;

class Git::Patch is repr('CPointer') {...}

class Git::Patch::Hunk is Positional
{
    has Git::Patch $.patch;
    has size_t $.hunk-index;

    sub git_patch_get_hunk(Pointer is rw, Pointer, Git::Patch, size_t
                           --> int32)
        is native('git2') {}

    method diff(size_t $idx)
    {
        my Pointer $ptr .= new;
        check(git_patch_get_hunk($ptr, Pointer, $!patch, $!hunk-index));
        nativecast(::('Git::Diff::Hunk'), $ptr)
    }

    sub git_patch_num_lines_in_hunk(Git::Patch, size_t --> int32)
        is native('git2') {}

    method elems
    {
        git_patch_num_lines_in_hunk($!patch, $!hunk-index);
    }

    sub git_patch_get_line_in_hunk(Pointer is rw, Git::Patch, size_t, size_t
                                   --> int32)
        is native('git2') {}

    method line(size_t $line-of-hunk)
    {
        my Pointer $ptr .= new;
        check(git_patch_get_line_in_hunk($ptr, $!patch, $!hunk-index,
                                         $line-of-hunk));
        nativecast(::('Git::Diff::Line'), $ptr)
    }

    method lines
    {
        Seq.new: class :: does Iterator
        {
            has Git::Patch::Hunk $.hunk;
            has size_t $.index;
            has size_t $.max;
            method pull-one
            {
                $!index == $!max ?? IterationEnd !! $!hunk.line($!index++)
            }
        }.new(hunk => self, max => self.elems)
    }
}

class Git::Patch
{
    sub git_patch_free(Git::Patch)
        is native('git2') {}

    sub git_patch_to_buf(Git::Buffer, Git::Patch --> int32)
        is native('git2') {}

    method Str
    {
        my Git::Buffer $buf .= new;
        check(git_patch_to_buf($buf, self));
        $buf.str
    }

    sub git_patch_get_delta(Git::Patch --> Pointer)
        is native('git2') {}

    method delta
    {
        nativecast(::('Git::Diff::Delta'), git_patch_get_delta(self))
    }

    method elems(--> size_t)
        is native('git2') is symbol('git_patch_num_hunks') {}

    method hunk(size_t $hunk-index where 0 <= * <= $.elems)
    {
        Git::Patch::Hunk.new(patch => self, :$hunk-index)
    }

    method hunks
    {
        Seq.new: class :: does Iterator
        {
            has Git::Patch $.patch;
            has size_t $.index;
            has size_t $.max;
            method pull-one
            {
                $!index == $!max ?? IterationEnd !! $!patch.hunk($!index++)
            }
        }.new(patch => self, max => self.elems)
    }

    submethod DESTROY { git_patch_free(self) }
}
