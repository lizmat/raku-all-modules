use NativeCall;
use Git::Error;
use Git::Oid;

class Git::Transfer::Progress is repr('CStruct')
{
    has int32 $.total-objects;
    has int32 $.indexed-objects;
    has int32 $.received-objects;
    has int32 $.local-objects;
    has int32 $.total-deltas;
    has int32 $.indexed-deltas;
    has size_t $.received-bytes;
}

class Git::Indexer is repr('CPointer')
{
    sub git_indexer_append(Git::Indexer, Blob, size_t, Git::Transfer::Progress
                           --> int32)
        is native('git2') {}

    method hash(--> Git::Oid)
        is native('git2') is symbol('git_indexer_hash') {}

    sub git_indexer_free(Git::Indexer)
        is native('git2') {}

    submethod DESTROY { git_indexer_free(self) }
}
