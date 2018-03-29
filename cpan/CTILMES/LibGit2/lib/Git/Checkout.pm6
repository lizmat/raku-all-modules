use NativeCall;
use Git::Error;
use Git::Strarray;
use Git::Tree;
use Git::Index;
use Git::Diff;

enum Git::Checkout::Strategy (
    GIT_CHECKOUT_NONE                         => 0,
    GIT_CHECKOUT_SAFE                         => 1 +< 0,
    GIT_CHECKOUT_FORCE                        => 1 +< 1,
    GIT_CHECKOUT_RECREATE_MISSING             => 1 +< 2,
    GIT_CHECKOUT_ALLOW_CONFLICTS              => 1 +< 4,
    GIT_CHECKOUT_REMOVE_UNTRACKED             => 1 +< 5,
    GIT_CHECKOUT_REMOVE_IGNORED               => 1 +< 6,
    GIT_CHECKOUT_UPDATE_ONLY                  => 1 +< 7,
    GIT_CHECKOUT_DONT_UPDATE_INDEX            => 1 +< 8,
    GIT_CHECKOUT_NO_REFRESH                   => 1 +< 9,
    GIT_CHECKOUT_SKIP_UNMERGED                => 1 +< 10,
    GIT_CHECKOUT_USE_OURS                     => 1 +< 11,
    GIT_CHECKOUT_USE_THEIRS                   => 1 +< 12,
    GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH       => 1 +< 13,
    GIT_CHECKOUT_UPDATE_SUBMODULES            => 1 +< 16,
    GIT_CHECKOUT_UPDATE_SUBMODULES_IF_CHANGED => 1 +< 17,
    GIT_CHECKOUT_SKIP_LOCKED_DIRECTORIES      => 1 +< 18,
    GIT_CHECKOUT_DONT_OVERWRITE_IGNORED       => 1 +< 19,
    GIT_CHECKOUT_CONFLICT_STYLE_MERGE         => 1 +< 20,
    GIT_CHECKOUT_CONFLICT_STYLE_DIFF3         => 1 +< 21,
    GIT_CHECKOUT_DONT_REMOVE_EXISTING         => 1 +< 22,
    GIT_CHECKOUT_DONT_WRITE_INDEX             => 1 +< 23,
);

enum Git::Checkout::Notify (
    GIT_CHECKOUT_NOTIFY_NONE      => 0,
    GIT_CHECKOUT_NOTIFY_CONFLICT  => 1 +< 0,
    GIT_CHECKOUT_NOTIFY_DIRTY     => 1 +< 1,
    GIT_CHECKOUT_NOTIFY_UPDATED   => 1 +< 2,
    GIT_CHECKOUT_NOTIFY_UNTRACKED => 1 +< 3,
    GIT_CHECKOUT_NOTIFY_IGNORED   => 1 +< 4,

    GIT_CHECKOUT_NOTIFY_ALL       => 0x0FFFF
);

class Git::Checkout::Perfdata is repr('CStruct')
{
    has size_t $.mkdir-calls;
    has size_t $.stat-calls;
    has size_t $.chmod-calls;
}

sub Git::Checkout::Notify(int32, Str, Git::Diff::File, Git::Diff::File,
                          Git::Diff::File, int64 --> int32)
{
    
}

class Git::Checkout::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    has uint32 $.checkout-strategy;
    has int32  $!disable-filters;
    has uint32 $.dir-mode;
    has uint32 $.file-mode;
    has int32  $.file-open-flags;
    has uint32 $.notify-flags;
    has Pointer $.notify-cb;
    has int64 $.notify-payload;
    has Pointer $.progress-cb;
    has Pointer $.progress-payload;
    HAS Git::Strarray $!paths;
    has Git::Tree $!baseline;
    has Git::Index $!baseline-index;
    has Str $!target-directory;
    has Str $!ancestor-label;
    has Str $!our-label;
    has Str $!their-label;
    has Pointer $.perfdata-cb;
    has Pointer $.perfdata-payload;

    submethod BUILD(Bool :$safe,
                    Bool :$force,
                    Bool :$recreate-missing,
                    Bool :$allow-conflicts,
                    Bool :$remove-untracked,
                    Bool :$remove-ignored,
                    Bool :$update-only,
                    Bool :$don't-update-index,
                    Bool :$no-refresh,
                    Bool :$skip-unmerged,
                    Bool :$use-ours,
                    Bool :$use-theirs,
                    Bool :$disable-pathspec-match,
                    Bool :$skip-locked-directories,
                    Bool :$don't-overwrite-ignored,
                    Bool :$conflict-style-merge,
                    Bool :$conflict-style-diff3,
                    Bool :$don't-remove-existing,
                    Bool :$don't-write-index,
                    Bool :$disable-filters,
                    uint32 :$!dir-mode,
                    uint32 :$!file-mode,
                    Bool :$notify-conflict,
                    Bool :$notify-dirty,
                    Bool :$notify-updated,
                    Bool :$notify-untracked,
                    Bool :$notify-ignored,
                    Bool :$notify-all,
                    :&notify,
                    Git::Tree :$baseline,
                    Git::Index :$baseline-index,
                    Str :$target-directory,
                    Str :$ancestor-label,
                    Str :$our-label,
                    Str :$their-label,
                    )
   {
        $!checkout-strategy =
               ($safe
                ?? GIT_CHECKOUT_SAFE !! 0)
            +| ($force
                ?? GIT_CHECKOUT_FORCE !! 0)
            +| ($recreate-missing
                ?? GIT_CHECKOUT_RECREATE_MISSING !! 0)
            +| ($allow-conflicts
                ?? GIT_CHECKOUT_ALLOW_CONFLICTS !! 0)
            +| ($remove-untracked
                ?? GIT_CHECKOUT_REMOVE_UNTRACKED !! 0)
            +| ($remove-ignored
                ?? GIT_CHECKOUT_REMOVE_IGNORED !! 0)
            +| ($update-only
                ?? GIT_CHECKOUT_UPDATE_ONLY !! 0)
            +| ($don't-update-index
                ?? GIT_CHECKOUT_DONT_UPDATE_INDEX !! 0)
            +| ($no-refresh
                ?? GIT_CHECKOUT_NO_REFRESH !! 0)
            +| ($skip-unmerged
                ?? GIT_CHECKOUT_SKIP_UNMERGED !! 0)
            +| ($use-ours
                ?? GIT_CHECKOUT_USE_OURS !! 0)
            +| ($use-theirs
                ?? GIT_CHECKOUT_USE_THEIRS !! 0)
            +| ($disable-pathspec-match
                ?? GIT_CHECKOUT_DISABLE_PATHSPEC_MATCH !! 0)
            +| ($skip-locked-directories
                ?? GIT_CHECKOUT_SKIP_LOCKED_DIRECTORIES !! 0)
            +| ($don't-overwrite-ignored
                ?? GIT_CHECKOUT_DONT_OVERWRITE_IGNORED !! 0)
            +| ($conflict-style-merge
                ?? GIT_CHECKOUT_CONFLICT_STYLE_MERGE !! 0)
            +| ($conflict-style-diff3
                ?? GIT_CHECKOUT_CONFLICT_STYLE_DIFF3 !! 0)
            +| ($don't-remove-existing
                ?? GIT_CHECKOUT_DONT_REMOVE_EXISTING !! 0)
            +| ($don't-write-index
                ?? GIT_CHECKOUT_DONT_WRITE_INDEX !! 0);

        $!notify-flags =
               ($notify-conflict  ?? GIT_CHECKOUT_NOTIFY_CONFLICT  !! 0)
            +| ($notify-dirty     ?? GIT_CHECKOUT_NOTIFY_DIRTY     !! 0)
            +| ($notify-updated   ?? GIT_CHECKOUT_NOTIFY_UPDATED   !! 0)
            +| ($notify-untracked ?? GIT_CHECKOUT_NOTIFY_UNTRACKED !! 0)
            +| ($notify-ignored   ?? GIT_CHECKOUT_NOTIFY_IGNORED   !! 0)
            +| ($notify-all       ?? GIT_CHECKOUT_NOTIFY_ALL       !! 0);

        $!disable-filters = $disable-filters ?? 1 !! 0;
        $!baseline := $baseline;
        $!baseline-index := $baseline-index;
        $!target-directory := $target-directory;
        $!ancestor-label := $ancestor-label;
        $!our-label := $our-label;
        $!their-label := $their-label;
    }
}

class Git::Checkout
{
    sub git_checkout_head(Pointer, Git::Checkout::Options --> int32)
        is native('git2') {}

    multi method checkout(:$head, :$repo, |opts)
    {
        my Git::Checkout::Options $opts;
        $opts = Git::Checkout::Options.new(|opts) if opts;
        check(git_checkout_head(nativecast(Pointer, $repo), $opts))
    }

    sub git_checkout_tree(Pointer, Git::Tree, Git::Checkout::Options
                          --> int32)
        is native('git2') {}

    multi method checkout(Git::Tree $tree, :$repo, |opts)
    {
        my Git::Checkout::Options $opts;
        $opts = Git::Checkout::Options.new(|opts) if opts;
        check(git_checkout_tree(nativecast(Pointer, $repo), $tree, $opts))
    }

    sub git_checkout_index(Pointer, Git::Index, Git::Checkout::Options
                           --> int32)
        is native('git2') {}

    multi method checkout(Git::Index $index, :$repo, |opts)
    {
        my Git::Checkout::Options $opts;
        $opts = Git::Checkout::Options.new(|opts) if opts;
        check(git_checkout_index(nativecast(Pointer, $repo), $index, $opts))
    }
}
