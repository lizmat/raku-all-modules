use NativeCall;
use Git::Error;
use Git::Buffer;

enum Git::Worktree::Prune::Flags
(
    GIT_WORKTREE_PRUNE_VALID        => 1 +< 0,
    GIT_WORKTREE_PRUNE_LOCKED       => 1 +< 1,
    GIT_WORKTREE_PRUNE_WORKING_TREE => 1 +< 2,
);

class Git::Worktree::Prune::Options is repr('CStruct')
{
    has int32 $.version = 1;
    has uint32 $.flags;

    submethod BUILD(Bool :$valid,
                    Bool :$locked,
                    Bool :$working-tree)
    {
        $!flags = ($valid        ?? GIT_WORKTREE_PRUNE_VALID        !! 0)
               +| ($locked       ?? GIT_WORKTREE_PRUNE_LOCKED       !! 0)
               +| ($working-tree ?? GIT_WORKTREE_PRUNE_WORKING_TREE !! 0);
    }
}

class Git::Worktree::Add::Options is repr('CStruct')
{
    has int32 $.version = 1;
    has int32 $.lock;

    submethod BUILD(Bool :$lock) { $!lock = $lock ?? 1 !! 0 }
}

class Git::Worktree is repr('CPointer')
{
    sub git_worktree_free(Git::Worktree)
        is native('git2') {}

    submethod DESTROY { git_worktree_free(self) }

    sub git_worktree_is_locked(Git::Buffer, Git::Worktree --> int32)
        is native('git2') {}

    method is-locked
    {
       my Git::Buffer $buf .= new;
       my $ret = git_worktree_is_locked($buf, self);
       check($ret) if $ret < 0;
       $ret > 0 ?? $buf.str !! False
    }

    sub git_worktree_is_prunable(Git::Worktree, Git::Worktree::Prune::Options
                                 --> int32)
        is native('git2') {}

    method is-prunable(|opts)
    {
        my Git::Worktree::Prune::Options $opts .= new(|opts);
        git_worktree_is_prunable(self, $opts) > 0
    }

    sub git_worktree_prune(Git::Worktree, Git::Worktree::Prune::Options
                           --> int32)
        is native('git2') {}

    method prune(|opts)
    {
        my Git::Worktree::Prune::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_worktree_prune(self, $opts))
    }

    sub git_worktree_lock(Git::Worktree, Str $reason --> int32)
        is native('git2') {}

    method lock(Str $reason)
    {
        check(git_worktree_lock(self, $reason))
    }

    sub git_worktree_unlock(Git::Worktree --> int32)
        is native('git2') {}

    method unlock
    {
        check(git_worktree_unlock(self))
    }

    sub git_worktree_validate(Git::Worktree --> int32)
        is native('git2') {}

    method validate
    {
        check(git_worktree_validate(self));
        True
    }
}
