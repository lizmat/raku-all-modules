use NativeCall;
use Git::Error;
use Git::Repository;
use Git::Config;
use Git::Tree;
use Git::Object;
use Git::Message;
use Git::Index;
use Git::Status;
use Git::FileMode;
use Git::Channel;

my package EXPORT::DEFAULT {}

BEGIN  # Re-export some enums defined in other modules
{
    for Git::Config::Level, Git::Status::Flags, Git::FileMode,
        Git::Type, Git::ErrorCode -> $enum
    {
        for $enum.enums
        {
            EXPORT::DEFAULT::{.key} = ::(.key)
        }
    }
}

sub git_libgit2_init(--> int32) is native('git2') {}
sub git_libgit2_shutdown(--> int32) is native('git2') {}

INIT git_libgit2_init;
END git_libgit2_shutdown;

enum Git::Feature (
    GIT_FEATURE_THREADS => 1 +< 0,
    GIT_FEATURE_HTTPS   => 1 +< 1,
    GIT_FEATURE_SSH     => 1 +< 2,
    GIT_FEATURE_NSEC    => 1 +< 3,
);

enum Git::Trace <
    GIT_TRACE_NONE
    GIT_TRACE_FATAL
    GIT_TRACE_ERROR
    GIT_TRACE_WARN
    GIT_TRACE_INFO
    GIT_TRACE_DEBUG
    GIT_TRACE_TRACE
>;

sub git-trace(int32 $level, Str $msg)
{
    say "{Git::Trace($level)} $msg"
}

class LibGit2:ver<0.2>
{
    sub git_libgit2_version(int32 is rw, int32 is rw, int32 is rw)
        is native('git2') {}

    method version
    {
        my int32 $major;
        my int32 $minor;
        my int32 $rev;
        git_libgit2_version($major, $minor, $rev);
        "$major.$minor.$rev"
    }

    sub git_libgit2_features(--> int32)
        is native('git2') {}

    method features
    {
        my $features = git_libgit2_features;
        do for Git::Feature.enums { .key if $features +& .value }
    }

    sub git_trace_set(int32, &callback (int32, Str) --> int32)
        is native('git2') {}

    method trace(Str $level where 'none'|'fatal'|'error'|
                                  'warn'|'info'|'debug'|'trace',
                 &callback = &git-trace)
    {
        check(git_trace_set(Git::Trace::{"GIT_TRACE_$level.uc()"},
                            &callback))
    }

}
