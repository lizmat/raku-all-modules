use NativeCall;
use Git::Error;
use Git::Signature;
use Git::Oid;

class Git::Note is repr('CPointer')
{
    sub git_note_free(Git::Note)
        is native('git2') {}

    submethod DESTROY { git_note_free(self) }

    method author(--> Git::Signature)
        is native('git2') is symbol('git_note_author') {}

    method committer(--> Git::Signature)
        is native('git2') is symbol('git_note_committer') {}

    method message(--> Str)
        is native('git2') is symbol('git_note_message') {}

    method id(--> Git::Oid)
        is native('git2') is symbol('git_note_id') {}
}
