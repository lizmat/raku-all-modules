use NativeCall;
use Git::Error;
use Git::Reference;

enum Git::Branch::Type (
    GIT_BRANCH_LOCAL  => 1,
    GIT_BRANCH_REMOTE => 2,
    GIT_BRANCH_ALL    => 3,
);

class Git::Branch::Iterator is repr('CPointer') does Iterator
{
    sub git_branch_iterator_new(Pointer is rw, Pointer, int32 --> int32)
        is native('git2') {}

    multi method new($repo, Bool :$local, Bool :$remote)
    {
        my Git::Branch::Type $type =
            $local && $remote ?? GIT_BRANCH_ALL
                              !! $local ?? GIT_BRANCH_LOCAL
                                        !! $remote ?? GIT_BRANCH_REMOTE
                                                   !! GIT_BRANCH_ALL;

        my Pointer $ptr .= new;
        check(git_branch_iterator_new($ptr, nativecast(Pointer, $repo), $type));
        nativecast(Git::Branch::Iterator, $ptr);
    }

    sub git_branch_next(Pointer is rw, int32 is rw, Git::Branch::Iterator
                        --> int32)
        is native('git2') {}

    method pull-one
    {
        my Pointer $ptr .= new;
        my int32 $type = 0;
        my $ret = git_branch_next($ptr, $type, self);
        return IterationEnd if $ret == GIT_ITEROVER;
        check($ret);
        nativecast(Git::Reference, $ptr)
    }

    sub git_branch_iterator_free(Git::Branch::Iterator)
        is native('git2') {}

    submethod DESTROY { git_branch_iterator_free(self) }
}
