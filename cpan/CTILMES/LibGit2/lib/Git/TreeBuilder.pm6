use NativeCall;
use Git::Error;
use Git::Oid;
use Git::Tree;

class Git::TreeBuilder is repr('CPointer')
{
    sub git_treebuilder_free(Git::TreeBuilder)
        is native('git2') {}

    sub git_treebuilder_write(Git::Oid, Git::TreeBuilder --> int32)
        is native('git2') {}

    sub git_treebuilder_insert(Pointer is rw, Git::TreeBuilder, Str, Git::Oid,
                               int32 --> int32)
        is native('git2') {}

    sub git_treebuilder_remove(Git::TreeBuilder, Str --> int32)
        is native('git2') {}

    method entrycount(--> uint32)
        is native('git2') is symbol('git_treebuilder_entrycount') {}

    method clear()
        is native('git2') is symbol('git_treebuilder_clear') {}

    method get(Str $filename --> Git::Tree::Entry)
        is native('git2') is symbol('git_treebuilder_get') {}

    method insert(Str:D $filename, Git::Oid:D $oid, Git::FileMode:D $filemode)
    {
        check(git_treebuilder_insert(Pointer, self, $filename, $oid, $filemode))
    }

    method remove(Str:D $filename)
    {
        check(git_treebuilder_remove(self, $filename))
    }

    method write(--> Git::Oid)
    {
        my Git::Oid $oid .= new;
        check(git_treebuilder_write($oid, self));
        $oid
    }

    submethod DESTROY { git_treebuilder_free(self) }
}
