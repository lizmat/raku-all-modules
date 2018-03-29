use NativeCall;
use Git::Object;

class Git::Tag is repr('CPointer') does Git::Objectish
{
    sub git_tag_peel(Pointer is rw, Git::Tag --> int32)
        is native('git2') {}

    method peel(--> Git::Objectish)
    {
        my Pointer $ptr .= new;
        check(git_tag_peel($ptr, self));
        Git::Objectish.object($ptr)
    }

    submethod DESTROY { self.free }
}
