use NativeCall;
use Git::Error;
use Git::Channel;

class Git::Reference is repr('CPointer') {...}

class Git::Reference::Iterator is repr('CPointer') does Iterator
{
    sub git_reference_iterator_new(Pointer is rw, Pointer --> int32)
        is native('git2') {}

    sub git_reference_iterator_glob_new(Pointer is rw, Pointer, Str --> int32)
        is native('git2') {}

    method new($repo, Str $glob?)
    {
        my $repoptr = nativecast(Pointer, $repo);
        my Pointer $ptr .= new;
        check($glob ?? git_reference_iterator_glob_new($ptr, $repoptr, $glob)
                    !! git_reference_iterator_new($ptr, $repoptr));
        nativecast(Git::Reference::Iterator, $ptr)
    }

    sub git_reference_next(Pointer is rw, Git::Reference::Iterator --> int32)
        is native('git2') {}

    method pull-one
    {
        my Pointer $ptr .= new;
        my $ret = git_reference_next($ptr, self);
        return IterationEnd if $ret == GIT_ITEROVER;
        check($ret);
        nativecast(Git::Reference, $ptr)
    }

    sub git_reference_iterator_free(Git::Reference::Iterator)
        is native('git2') {}

    submethod DESTROY { git_reference_iterator_free(self) }
}

class Git::Reference
{
    sub git_reference_free(Git::Reference)
        is native('git2') {}

    sub git_reference_is_branch(Git::Reference --> int32)
        is native('git2') {}

    sub git_reference_is_tag(Git::Reference --> int32)
        is native('git2') {}

    sub git_reference_is_note(Git::Reference --> int32)
        is native('git2') {}

    sub git_reference_is_remote(Git::Reference --> int32)
        is native('git2') {}

    sub git_reference_delete(Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_is_checked_out(Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_is_head(Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_delete(Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_name(Pointer is rw, Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_set_upstream(Git::Reference, Str --> int32)
        is native('git2') {}

    sub git_branch_upstream(Pointer is rw, Git::Reference --> int32)
        is native('git2') {}

    sub git_branch_move(Pointer is rw, Git::Reference, Str, int32 --> int32)
        is native('git2') {}

    sub git_reference_resolve(Pointer is rw, Git::Reference --> int32)
        is native('git2') {}

    method name(--> Str)
        is native('git2') is symbol('git_reference_name') {}

    method short(--> Str)
        is native('git2') is symbol('git_reference_shorthand') {}

    method is-branch(--> Bool)
    {
        git_reference_is_branch(self) == 1
    }

    method is-tag(--> Bool)
    {
        git_reference_is_tag(self) == 1
    }

    method is-note(--> Bool)
    {
        git_reference_is_note(self) == 1
    }

    method is-remote(--> Bool)
    {
        git_reference_is_remote(self) == 1
    }

    method is-checked-out(--> Bool)
    {
        git_branch_is_checked_out(self) == 1
    }

    method is-head(--> Bool)
    {
        git_branch_is_head(self) == 1
    }

    method delete()
    {
        check(git_reference_delete(self));
    }

    method branch-delete()
    {
        check(git_branch_delete(self))
    }

    method branch-name()
    {
        my Pointer $ptr .= new;
        check(git_branch_name($ptr, self));
        nativecast(Str, $ptr)
    }

    method branch-set-upstream(Str $upstream-name = Str)
    {
        check(git_branch_set_upstream(self, $upstream-name))
    }

    method branch-upstream()
    {
        my Pointer $ptr .= new;
        my $ret = git_branch_upstream($ptr, self);
        return if $ret == GIT_ENOTFOUND;
        check($ret);
        nativecast(Git::Reference, $ptr)
    }

    method branch-move(Str $new-branch-name, Bool :$force = False)
    {
        my Pointer $ptr .= new;
        check(git_branch_move($ptr, self, $new-branch-name,
                              $force ?? 1 !! 0));
        nativecast(Git::Reference, $ptr)
    }

    method resolve
    {
        my Pointer $ptr .= new;
        check(git_reference_resolve($ptr, self));
        nativecast(Git::Reference, $ptr)
    }

    submethod DESTROY { git_reference_free(self) }
}
