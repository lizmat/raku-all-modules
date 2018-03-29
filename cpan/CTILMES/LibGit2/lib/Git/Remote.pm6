use NativeCall;
use Git::Error;
use Git::Buffer;
use Git::Proxy;
use Git::Strarray;
use Git::Oid;
use Git::Refspec;
use Git::Cred;
use Git::Callback;

sub memcpy(Pointer, Pointer is rw, size_t --> Pointer) is native {}

sub cred-acquire-cb(Pointer $cred-ptr, Str $url, Str $username-from-url,
                    uint32 $allowed-types, Pointer $payload --> int32)
{
    memcpy($cred-ptr, $payload, nativesizeof(Pointer));
    return 0;
}

# git_remote_callbacks
class Git::Remote::Callbacks is repr('CStruct')
{
    has int32 $.version = 1;
    has Pointer $.sideband-progress;
    has Pointer $.completion;
    has Pointer $.credentials;
    has Pointer $.certificate_check;
    has Pointer $.transfer-progress;
    has Pointer $.update-tips;
    has Pointer $.pack-progress;
    has Pointer $.push-transfer-progress;
    has Pointer $.push-update-reference;
    has Pointer $.push-negotiation;
    has Pointer $.transport;
    has Pointer $.payload;

    submethod BUILD(Git::Cred :$cred)
    {
        if $cred
        {
            $!credentials := callback-pointer(&cred-acquire-cb);
            $!payload := nativecast(Pointer, $cred);
        }
    }
}

# git_fetch_prune_t
enum Git::Fetch::Prune <
    GIT_FETCH_PRUNE_UNSPECIFIED
    GIT_FETCH_PRUNE
    GIT_FETCH_NO_PRUNE
>;

# git_remote_autotag_option_t
enum Git::Remote::Autotag::Option <
    GIT_REMOTE_DOWNLOAD_TAGS_UNSPECIFIED
    GIT_REMOTE_DOWNLOAD_TAGS_AUTO
    GIT_REMOTE_DOWNLOAD_TAGS_NONE
    GIT_REMOTE_DOWNLOAD_TAGS_ALL
>;

# git_fetch_options
class Git::Fetch::Options is repr('CStruct')
{
    has int32 $.version = 1;
    HAS Git::Remote::Callbacks $.callbacks;
    has int32 $.prune;
    has int32 $.update-fetchhead;
    has int32 $.download-tags;
    HAS Git::Proxy::Options $.proxy-opts;
    HAS Git::Strarray $.custom-headers;

    sub git_fetch_init_options(Git::Fetch::Options, int32 --> int32)
        is native('git2') {}

    submethod BUILD(Bool :$prune,
                    Str  :$tags,
                    int32 :$!update-fetchhead,
                    |opts)
    {
        check(git_fetch_init_options(self, 1));

        with $prune { $!prune = $_ ?? GIT_FETCH_PRUNE !! GIT_FETCH_NO_PRUNE }

        $!download-tags = self.autotag-lookup($_) with $tags;

        if (opts)
        {
            $!callbacks.BUILD(|opts);
#            $!proxy-opts.BUILD(|opts);
        }
    }

    method autotag-lookup(Str $tag-flag)
    {
        Git::Remote::Autotag::Option::{"GIT_REMOTE_DOWNLOAD_TAGS_$tag-flag.uc()"}
        // die "Unknown Remote Autotag Option $tag-flag"
    }

}

# git_push_options
class Git::Push::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    has uint32 $.pb-parallelism;
    HAS Git::Remote::Callbacks $.callbacks;
    HAS Git::Proxy::Options $.proxy-opts;
    HAS Git::Strarray $.custom-headers;

    sub git_push_init_options(Git::Push::Options, uint32 --> int32)
        is native('git2') {}

    submethod BUILD(|opts)
    {
        check(git_push_init_options(self, 1));

        if (opts)
        {
            $!callbacks.BUILD(|opts);
#            $!proxy-opts.BUILD(|opts);
        }
    }
}

# git_remote_head
class Git::Remote::Head is repr('CStruct')
{
    has int32 $.local;
    HAS Git::Oid $.oid;
    HAS Git::Oid $.loid;
    has Str $.name;
    has Str $.symref-target;
}

class Git::Remote is repr('CPointer')
{
    sub git_remote_free(Git::Remote)
        is native('git2') {}

    submethod DESTROY { git_remote_free(self) }

    sub git_remote_create_detached(Pointer is rw, Str --> int32)
        is native('git2') {}

    multi method new(Str:D $url)
    {
        my Pointer $ptr .= new;
        check(git_remote_create_detached($ptr, $url));
        nativecast(Git::Remote, $ptr)
    }

    method stop
        is native('git2') is symbol('git_remote_stop') {}

    method url(--> Str)
        is native('git2') is symbol('git_remote_url') {}

    method pushurl(--> Str)
        is native('git2') is symbol('git_remote_pushurl') {}

    method name(--> Str)
        is native('git2') is symbol('git_remote_name') {}

    sub git_remote_owner(Git::Remote --> Pointer)
        is native('git2') {}

    method owner
    {
        nativecast(::('Git::Repository'), git_remote_owner(self))
    }

    sub git_remote_autotag(Git::Remote --> int32)
        is native('git2') {}

    method autotag
    {
        Git::Remote::Autotag::Option(git_remote_autotag(self))
    }

    sub git_remote_connected(Git::Remote --> int32)
        is native('git2') {}

    method connected { git_remote_connected(self) == 1 }

    sub git_remote_default_branch(Git::Buffer, Git::Remote --> int32)
        is native('git2') {}

    method default-branch
    {
        my Git::Buffer $buf .= new;
        check(git_remote_default_branch($buf, self));
        $buf.str
    }

    sub git_remote_connect(Git::Remote, int32, Git::Remote::Callbacks,
                           Git::Proxy::Options, Git::Strarray --> int32)
        is native('git2') {}

    method connect(Str :$dir where 'fetch'|'push', |opts)
    {
        my int32 $direction = $dir eq 'fetch' ?? GIT_DIRECTION_FETCH
                                              !! GIT_DIRECTION_PUSH;

        my Git::Remote::Callbacks $callbacks .= new(|opts);

        my Git::Proxy::Options $proxy-opts .= new(|opts);

        my Git::Strarray $custom-headers .= new;

        check(git_remote_connect(self, $direction, $callbacks, $proxy-opts,
                                 $custom-headers));
        self
    }

    method disconnect()
        is native('git2') is symbol('git_remote_disconnect') {}

    sub git_remote_ls(Pointer is rw, size_t is rw, Git::Remote
                      --> int32)
        is native('git2') {}


    method ls()
    {
        my Pointer $ptr .= new;
        my size_t $size .= new;
        check(git_remote_ls($ptr, $size, self));
        nativecast(CArray[Git::Remote::Head], $ptr)[^$size];
    }

    sub git_remote_download(Git::Remote, Git::Strarray, Git::Fetch::Options
                            --> int32)
        is native('git2') {}

    method download(*@refspecs, |opts)
    {
        my Git::Strarray $refspecs;
        $refspecs .= new(@refspecs) if @refspecs;
        my Git::Fetch::Options $opts .= new(|opts);
        check(git_remote_download(self, $refspecs, $opts))
    }

    sub git_remote_upload(Git::Remote, Git::Strarray, Git::Push::Options
                          --> int32)
        is native('git2') {}

    method upload(|opts)
    {
        my Git::Strarray $refspecs;
        my Git::Push::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_remote_upload(self, $refspecs, $opts))
    }

    sub git_remote_update_tips(Git::Remote, Git::Remote::Callbacks, int32,
                               int32, Str --> int32)
        is native('git2') {}

    method update-tips(Bool :$update-fetchhead,
                       Str :$tags,
                       Str :$message,
                       |opts)
    {
        check(git_remote_update_tips(self,
                                     Git::Remote::Callbacks.new(|opts),
                                     $update-fetchhead ?? 1 !! 0,
                                     $tags ?? $.autotag-lookup($tags) !! 0,
                                     $message))
    }

    sub git_remote_get_fetch_refspecs(Git::Strarray, Git::Remote --> int32)
        is native('git2') {}

    method get-fetch-refspecs
    {
        my Git::Strarray $array .= new;
        check(git_remote_get_fetch_refspecs($array, self));
        $array.list(:free)
    }

    sub git_remote_get_push_refspecs(Git::Strarray, Git::Remote --> int32)
        is native('git2') {}

    method get-push-refspecs
    {
        my Git::Strarray $array .= new;
        check(git_remote_get_push_refspecs($array, self));
        $array.list(:free)
    }

    method refspec-count(--> size_t)
        is native('git2') is symbol('git_remote_refspec_count') {}

    method get-refspec(size_t $n --> Git::Refspec)
        is native('git2') is symbol('git_remote_get_refspec') {}

    method refspecs
    {
        do for ^$.refspec-count { $.get-refspec($_) }
    }

    sub git_remote_fetch(Git::Remote, Git::Strarray, Git::Fetch::Options,
                         Str --> int32)
        is native('git2') {}

    method fetch(Str :$message, *@refspecs, |opts)
    {
        my Git::Strarray $array;
        $array .= new(@refspecs) if @refspecs;
        my Git::Fetch::Options $opts .= new(|opts);
        check(git_remote_fetch(self, $array, $opts, $message))
    }

    sub git_remote_push(Git::Remote, Git::Strarray, Git::Push::Options --> int32)
        is native('git2') {}

    method push(*@refspecs, |opts)
    {
        my Git::Strarray $array;
        $array .= new(@refspecs) if @refspecs;
        my Git::Push::Options $opts .= new(|opts);
        check(git_remote_push(self, $array, $opts))
    }
}
