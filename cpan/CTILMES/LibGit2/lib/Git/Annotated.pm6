use NativeCall;
use Git::Oid;

class Git::Annotated::Commit is repr('CPointer')
{
    sub git_annotated_commit_free(Git::Annotated::Commit)
        is native('git2') {}

    submethod DESTROY { git_annotated_commit_free(self) }

    method id(--> Git::Oid)
        is native('git2') is symbol('git_annotated_commit') {}
}
