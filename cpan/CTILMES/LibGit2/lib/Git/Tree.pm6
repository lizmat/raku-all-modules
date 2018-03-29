use NativeCall;
use Git::Error;
use Git::Object;
use Git::Oid;
use Git::FileMode;
use Git::Channel;

enum Git::Treewalk::Mode <
    GIT_TREEWALK_PRE
    GIT_TREEWALK_POST
>;

class Git::Tree::Entry is repr('CPointer')
{
    sub git_tree_entry_type(Git::Tree::Entry --> int32)
        is native('git2') {}

    method type() { Git::Type(git_tree_entry_type(self)) }

    method name(--> Str)
        is native('git2') is symbol('git_tree_entry_name') {}

    sub git_tree_entry_filemode(Git::Tree::Entry --> int32)
        is native('git2') {}

    sub git_tree_entry_filemode_raw(Git::Tree::Entry --> int32)
        is native('git2') {}

    multi method filemode()
    {
        Git::FileMode(git_tree_entry_filemode(self))
    }

    multi method filemode(Bool :$raw!)
    {
        git_tree_entry_filemode_raw(self)
    }

    method free()
        is native('git2') is symbol('git_tree_entry_free') {}

    method gist
    {
        "Git::Tree::Entry($.type():$.name())"
    }
}

sub treewalk(Str $root, Git::Tree::Entry $entry, int64 $nonce --> int32)
{
    try Git::Channel.channel($nonce).send([$root, $entry]);
    $! ?? -1 !! 0
}

class Git::Tree is repr('CPointer') does Git::Objectish
{
    method elems(--> size_t)
        is native('git2') is symbol('git_tree_entrycount') {}

    multi method entry(size_t $idx --> Git::Tree::Entry)
        is native('git2') is symbol('git_tree_entry_byindex') {}

    multi method entry(Git::Oid $oid --> Git::Tree::Entry)
        is native('git2') is symbol('git_tree_entry_byid') {}

    multi method entry(Str $name --> Git::Tree::Entry)
        is native('git2') is symbol('git_tree_entry_byname') {}

    sub git_tree_entry_bypath(Pointer is rw, Git::Tree, Str --> int32)
        is native('git2') {}

    method entry-bypath(Str:D $path --> Git::Tree::Entry)
    {
        my Pointer $ptr .= new;
        check(git_tree_entry_bypath($ptr, self, $path));
        nativecast(Git::Tree::Entry, $ptr)
    }

    sub git_tree_walk(Git::Tree, int32,
                      &callback (Str, Git::Tree::Entry, int64 --> int32),
                      int64 --> int32)
        is native('git2') {}

    method walk(Bool :$post = False)
    {
        my $mode = $post ?? GIT_TREEWALK_POST !! GIT_TREEWALK_PRE;

        my $channel = Git::Channel.new;

        start
        {
            my $ret = git_tree_walk(self, $mode, &treewalk, $channel.Int);
            $channel.fail(X::Git.new(code => Git::ErrorCode($ret)))
                unless $ret == 0;
            Git::Channel.done($channel.Int)
        }

        $channel
    }

    submethod DESTROY { self.free }
}
