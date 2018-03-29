use NativeCall;
use Git::Oid;
use Git::Signature;

enum Git::Blame::Flag
(
    GIT_BLAME_NORMAL                          => 0,
    GIT_BLAME_TRACK_COPIES_SAME_FILE          => 1 +< 0,
    GIT_BLAME_TRACK_COPIES_SAME_COMMIT_MOVES  => 1 +< 1,
    GIT_BLAME_TRACK_COPIES_SAME_COMMIT_COPIES => 1 +< 2,
    GIT_BLAME_TRACK_COPIES_ANY_COMMIT_COPIES  => 1 +< 3,
    GIT_BLAME_FIRST_PARENT                    => 1 +< 4,
);

class Git::Blame::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    has uint32 $.flags;
    has uint16 $.min-match-characters;
    HAS Git::Oid $.newest-commit;
    HAS Git::Oid $.oldest-commit;
    has size_t $.min-line;
    has size_t $.max-line;

    submethod BUILD(Bool :$track-copies-same-file,
                    Bool :$track-copies-same-commit-moves,
                    Bool :$track-copies-same-commit-copies,
                    Bool :$track-copies-any-commit-copies,
                    Bool :$first-parent,
                    uint16 :$!min-match-characters,
                    Git::Oid :$newest-commit,
                    Git::Oid :$oldest-commit,
                    size_t :$!min-line,
                    size_t :$!max-line)
    {
        $!flags =
            ($track-copies-same-file
                ?? GIT_BLAME_TRACK_COPIES_SAME_FILE !! 0)
         +| ($track-copies-same-commit-moves
                ?? GIT_BLAME_TRACK_COPIES_SAME_COMMIT_MOVES !! 0)
         +| ($track-copies-same-commit-copies
                ?? GIT_BLAME_TRACK_COPIES_SAME_COMMIT_COPIES !! 0)
         +| ($track-copies-any-commit-copies
                ?? GIT_BLAME_TRACK_COPIES_ANY_COMMIT_COPIES !! 0)
         +| ($first-parent
                ?? GIT_BLAME_FIRST_PARENT !! 0);

        $!newest-commit.copy($newest-commit) if $newest-commit;
        $!oldest-commit.copy($oldest-commit) if $oldest-commit;
    }
}

class Git::Blame::Hunk is repr('CStruct')
{
    has size_t $.lines-in-hunk;
    HAS Git::Oid $.final-commit-id;
    has size_t $.final-start-line-number;
    has Git::Signature $.final-signature;
    HAS Git::Oid $.orig-commit-id;
    has Str $.orig-path;
    has size_t $.orig-start-line-number;
    has Git::Signature $.orig-signature;
    has uint8 $.boundary;
}

class Git::Blame is repr('CPointer')
{
    sub git_blame_free(Git::Blame)
        is native('git2') {}

    method hunk-count(--> uint32)
        is native('git2') is symbol('git_blame_get_hunk_count') {}

    method hunk(uint32 $index --> Git::Blame::Hunk)
        is native('git2') is symbol('git_blame_get_hunk_byindex') {}

    method line(size_t $lineno --> Git::Blame::Hunk)
        is native('git2') is symbol('git_blame_get_hunk_byline') {}

    submethod DESTROY { git_blame_free(self) }
}
