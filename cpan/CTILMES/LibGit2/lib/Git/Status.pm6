use NativeCall;
use Git::Error;
use Git::Strarray;
use Git::Tree;
use Git::Diff;

enum Git::Status::Show <
    GIT_STATUS_SHOW_INDEX_AND_WORKDIR
    GIT_STATUS_SHOW_INDEX_ONLY
    GIT_STATUS_SHOW_WORKDIR_ONLY
>;

enum Git::Status::Flags (
    GIT_STATUS_CURRENT          => 0,

    GIT_STATUS_INDEX_NEW        => 1 +< 0,
    GIT_STATUS_INDEX_MODIFIED   => 1 +< 1,
    GIT_STATUS_INDEX_DELETED    => 1 +< 2,
    GIT_STATUS_INDEX_RENAMED    => 1 +< 3,
    GIT_STATUS_INDEX_TYPECHANGE => 1 +< 4,

    GIT_STATUS_WT_NEW           => 1 +< 7,
    GIT_STATUS_WT_MODIFIED      => 1 +< 8,
    GIT_STATUS_WT_DELETED       => 1 +< 9,
    GIT_STATUS_WT_TYPECHANGE    => 1 +< 10,
    GIT_STATUS_WT_RENAMED       => 1 +< 11,
    GIT_STATUS_WT_UNREADABLE    => 1 +< 12,

    GIT_STATUS_IGNORED          => 1 +< 14,
    GIT_STATUS_CONFLICTED       => 1 +< 15,
);

class Git::Status::File
{
    has int32 $.flags handles<Int>;
    has Str $.path;

    method is-current             { $!flags == 0 }

    method is-index-new           { so $!flags +& GIT_STATUS_INDEX_NEW        }
    method is-index-modified      { so $!flags +& GIT_STATUS_INDEX_MODIFIED   }
    method is-index-deleted       { so $!flags +& GIT_STATUS_INDEX_DELETED    }
    method is-index-renamed       { so $!flags +& GIT_STATUS_INDEX_RENAMED    }
    method is-index-typechange    { so $!flags +& GIT_STATUS_INDEX_TYPECHANGE }

    method is-workdir-new         { so $!flags +& GIT_STATUS_WT_NEW           }
    method is-workdir-modified    { so $!flags +& GIT_STATUS_WT_MODIFIED      }
    method is-workdir-deleted     { so $!flags +& GIT_STATUS_WT_DELETED       }
    method is-workdir-typechange  { so $!flags +& GIT_STATUS_WT_TYPECHANGE    }
    method is-workdir-renamed     { so $!flags +& GIT_STATUS_WT_RENAMED       }
    method is-workdir-unreadable  { so $!flags +& GIT_STATUS_WT_UNREADABLE    }

    method is-ignored             { so $!flags +& GIT_STATUS_IGNORED          }
    method is-conflicted          { so $!flags +& GIT_STATUS_CONFLICTED       }

    method status
    {
        return (GIT_STATUS_CURRENT,) unless $!flags;
        do for Git::Status::Flags.enums
        {
            Git::Status::Flags(.value) if $!flags +& .value
        }
    }

    method gist
    {
        ($!path ?? "$!path = " !! '') ~ $.status
    }
}

enum Git::Status::Opt (
    GIT_STATUS_OPT_INCLUDE_UNTRACKED                => 1 +< 0,
    GIT_STATUS_OPT_INCLUDE_IGNORED                  => 1 +< 1,
    GIT_STATUS_OPT_INCLUDE_UNMODIFIED               => 1 +< 2,
    GIT_STATUS_OPT_EXCLUDE_SUBMODULES               => 1 +< 3,
    GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS           => 1 +< 4,
    GIT_STATUS_OPT_DISABLE_PATHSPEC_MATCH           => 1 +< 5,
    GIT_STATUS_OPT_RECURSE_IGNORED_DIRS             => 1 +< 6,
    GIT_STATUS_OPT_RENAMES_HEAD_TO_INDEX            => 1 +< 7,
    GIT_STATUS_OPT_RENAMES_INDEX_TO_WORKDIR         => 1 +< 8,
    GIT_STATUS_OPT_SORT_CASE_SENSITIVELY            => 1 +< 9,
    GIT_STATUS_OPT_SORT_CASE_INSENSITIVELY          => 1 +< 10,
    GIT_STATUS_OPT_RENAMES_FROM_REWRITES            => 1 +< 11,
    GIT_STATUS_OPT_NO_REFRESH                       => 1 +< 12,
    GIT_STATUS_OPT_UPDATE_INDEX                     => 1 +< 13,
    GIT_STATUS_OPT_INCLUDE_UNREADABLE               => 1 +< 14,
    GIT_STATUS_OPT_INCLUDE_UNREADABLE_AS_UNTRACKED  => 1 +< 15,
);

class Git::Status::Options is repr('CStruct')
{
    has uint32        $.version = 1;
    has int32         $.show;
    has uint32        $.flags;
    HAS Git::Strarray $.pathspec;
    has Git::Tree     $.baseline;

    submethod BUILD(Bool :$show-index-only,
                    Bool :$show-workdir-only,
                    Bool :$include-untracked,
                    Bool :$include-ignored,
                    Bool :$include-unmodified,
                    Bool :$exclude-submodules,
                    Bool :$recurse-untracked-dirs,
                    Bool :$disable-pathspec-match,
                    Bool :$recurse-ignored-dirs,
                    Bool :$renames-head-to-index,
                    Bool :$renames-index-to-workdir,
                    Bool :$renames,
                    Bool :$sort-case-sensitively,
                    Bool :$sort-case-insensitively,
                    Bool :$renames-from-rewrites,
                    Bool :$no-refresh,
                    Bool :$update-index,
                    Bool :$include-unreadable,
                    Bool :$include-unreadable-as-untracked,
                    Git::Strarray :$pathspec,
                    Git::Tree :$baseline)
    {
        die "Can't show only index and show only workdir"
            if $show-index-only && $show-workdir-only;

        $!show = $show-index-only   ?? GIT_STATUS_SHOW_INDEX_ONLY
              !! $show-workdir-only ?? GIT_STATUS_SHOW_WORKDIR_ONLY
                                    !! GIT_STATUS_SHOW_INDEX_AND_WORKDIR;

        $!flags =
            ($include-untracked
             ?? GIT_STATUS_OPT_INCLUDE_UNTRACKED !! 0)
         +| ($include-ignored
             ?? GIT_STATUS_OPT_INCLUDE_IGNORED   !! 0)
         +| ($include-unmodified
             ?? GIT_STATUS_OPT_INCLUDE_UNMODIFIED !! 0)
         +| ($exclude-submodules
             ?? GIT_STATUS_OPT_EXCLUDE_SUBMODULES !! 0)
         +| ($recurse-untracked-dirs
             ?? GIT_STATUS_OPT_RECURSE_UNTRACKED_DIRS !! 0)
         +| ($disable-pathspec-match
             ?? GIT_STATUS_OPT_DISABLE_PATHSPEC_MATCH !! 0)
         +| ($recurse-ignored-dirs
             ?? GIT_STATUS_OPT_RECURSE_IGNORED_DIRS !! 0)
         +| ($renames-head-to-index || $renames
             ?? GIT_STATUS_OPT_RENAMES_HEAD_TO_INDEX !! 0)
         +| ($renames-index-to-workdir || $renames
             ?? GIT_STATUS_OPT_RENAMES_INDEX_TO_WORKDIR !! 0)
         +| ($sort-case-sensitively
             ?? GIT_STATUS_OPT_SORT_CASE_SENSITIVELY !! 0)
         +| ($sort-case-insensitively
             ?? GIT_STATUS_OPT_SORT_CASE_INSENSITIVELY !! 0)
         +| ($renames-from-rewrites || $renames
             ?? GIT_STATUS_OPT_RENAMES_FROM_REWRITES !! 0)
         +| ($no-refresh
             ?? GIT_STATUS_OPT_NO_REFRESH !! 0)
         +| ($update-index
             ?? GIT_STATUS_OPT_UPDATE_INDEX !! 0)
         +| ($include-unreadable
             ?? GIT_STATUS_OPT_INCLUDE_UNREADABLE !! 0)
         +| ($include-unreadable-as-untracked
             ?? GIT_STATUS_OPT_INCLUDE_UNREADABLE_AS_UNTRACKED !! 0);

        $!pathspec := $pathspec;
        $!baseline := $baseline;
    }
}

class Git::Status::Entry is repr('CStruct')
{
    has int32 $.flags;
    has Git::Diff::Delta $.head-to-index;
    has Git::Diff::Delta $.index-to-workdir;

    method status { Git::Status::File.new(:$!flags) }
}

class Git::Status::List is repr('CPointer') does Positional
{
    sub git_status_list_free(Git::Status::List)
        is native('git2') {}

    sub git_status_list_entrycount(Git::Status::List --> size_t)
        is native('git2') {}

    multi method elems { git_status_list_entrycount(self) }

    sub git_status_byindex(Git::Status::List, size_t --> Git::Status::Entry)
        is native('git2') {}

    multi method AT-POS($index) { git_status_byindex(self, $index) }

    multi method EXISTS-POS($index) { so git_status_byindex(self, $index) }

    submethod DESTROY { git_status_list_free(self) }
}

sub status-callback(Str $path, uint32 $flags, int64 $nonce --> int32)
{
    try Git::Channel.channel($nonce).send(Git::Status::File.new(:$flags,:$path));

    $! ?? -1 !! 0
}

class Git::Status
{
    sub git_status_foreach(Pointer, &callback (Str, uint32, int64 --> int32),
                           int64 --> int32)
        is native('git2') {}

    sub git_status_foreach_ext(Pointer, Git::Status::Options,
        &callback (Str, uint32, int64 --> int32), int64 --> int32)
        is native('git2') {}

    multi method foreach(Pointer:D $ptr, Git::Status::Options $opts?,
                         int64 :$nonce = nativecast(int64, $ptr))
    {
        my $channel = Git::Channel.new;

        start
        {
            my $ret = $opts
                ?? git_status_foreach_ext($ptr, $opts, &status-callback,
                                          $channel.Int)
                !! git_status_foreach($ptr, &status-callback, $channel.Int);
            if $ret != 0
            {
                $channel.fail: X::Git.new(code => Git::ErrorCode($ret))
            }
            Git::Channel.done($channel.Int)
        }

        $channel
    }
}
