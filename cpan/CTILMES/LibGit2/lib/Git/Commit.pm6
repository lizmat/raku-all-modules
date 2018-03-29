use NativeCall;
use Git::Signature;
use Git::Buffer;
use Git::Error;
use Git::Oid;
use Git::Object;
use Git::Tree;
use Git::Describe;

class Git::Commit is repr('CPointer') does Git::Objectish
{
    sub git_commit_header_field(Git::Buffer, Git::Commit, Str --> int32)
        is native('git2') {}

    method author(--> Git::Signature)
        is native('git2') is symbol('git_commit_author') {}

    method summary(--> Str)
        is native('git2') is symbol('git_commit_summary') {}

    method body(--> Str)
        is native('git2') is symbol('git_commit_body') {}

    method message(--> Str)
        is native('git2') is symbol('git_commit_message') {}

    method encoding(--> Str)
        is native('git2') is symbol('git_commit_message_encoding') {}

    method committer(--> Git::Signature)
        is native('git2') is symbol('git_commit_committer') {}

    method header(Str $field --> Str)
    {
        my Git::Buffer $buf .= new;
        check(git_commit_header_field($buf, self, $field));
        $buf.str
    }

    method raw-header(--> Str)
        is native('git2') is symbol('git_commit_raw_header') {}

    sub git_commit_time(Git::Commit --> int64)
        is native('git2') {}

    sub git_commit_time_offset(Git::Commit --> int32)
        is native('git2') {}

    method time(--> DateTime)
    {
        DateTime.new(git_commit_time(self),
            timezone => 60 * git_commit_time_offset(self))
    }

    sub git_commit_tree_id(Git::Commit --> Pointer)
        is native('git2') {}

    method tree-id(--> Git::Oid)
    {
        my $ptr = git_commit_tree_id(self);
        Git::Oid.new($ptr)
    }

    sub git_commit_tree(Pointer is rw, Git::Commit --> int32)
        is native('git2') {}

    method tree(--> Git::Tree)
    {
        my Pointer $ptr .= new;
        check(git_commit_tree($ptr, self));
        nativecast(Git::Tree, $ptr)
    }

    method parentcount(--> uint32)
        is native('git2') is symbol('git_commit_parentcount') {}
    sub git_commit_parent_id(Git::Commit, uint32 --> Pointer)
        is native('git2') {}

    method parent-id(uint32 $n = 0 --> Git::Oid)
    {
        Git::Oid.new(git_commit_parent_id(self, $n) // return)
    }

    sub git_commit_parent(Pointer is rw, Git::Commit, uint32 --> int32)
        is native('git2') {}

    method parent(uint32 $n = 0 --> Git::Commit)
    {
        my Pointer $ptr .= new;
        check(git_commit_parent($ptr, self, $n));
        nativecast(Git::Commit, $ptr)
    }

    sub git_commit_nth_gen_ancestor(Pointer is rw, Git::Commit, uint32 --> int32)
        is native('git2') {}

    method ancestor(uint32 $n --> Git::Commit)
    {
        my Pointer $ptr .= new;
        check(git_commit_nth_gen_ancestor($ptr, self, $n));
        nativecast(Git::Commit, $ptr)
    }

    sub git_describe_commit(Pointer is rw, Git::Commit, Git::Describe::Options
                            --> int32)
        is native('git2') {}

    method describe(|opts)
    {
        my Git::Describe::Options $opts .= new(|opts);
        my Pointer $ptr .= new;
        check(git_describe_commit($ptr, self, $opts));
        nativecast(Git::Describe::Result, $ptr);
    }

    submethod DESTROY { self.free }
}
