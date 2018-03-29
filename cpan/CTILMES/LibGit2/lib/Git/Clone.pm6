use NativeCall;
use Git::Error;
use Git::Checkout;
use Git::Remote;

# git_clone_local_t
enum Git::Clone::Local <
    GIT_CLONE_LOCAL_AUTO
    GIT_CLONE_LOCAL
    GIT_CLONE_NO_LOCAL
    GIT_CLONE_LOCAL_NOLINKS
>;

class Git::Clone::Options is repr('CStruct')
{
    has uint32 $.version = 1;
    HAS Git::Checkout::Options $.checkout-opts;
    HAS Git::Fetch::Options $.fetch-opts;
    has int32 $.bare;
    has int32 $.local;
    has Str $.checkout-branch;
    has Pointer $.repository-cb;
    has Pointer $.repository-cb-payload;
    has Pointer $.remote-cb;
    has Pointer $.remote-cb-payload;

    sub git_clone_init_options(Git::Clone::Options, uint32 --> int32)
        is native('git2') {}

    submethod BUILD(Bool :$bare,
                    Str :$local where 'auto'|'local'|'no'|'no-links' = 'auto',
                    Str :$checkout-branch,
                    |opts)
    {
        check(git_clone_init_options(self, 1));

        if opts
        {
            $!checkout-opts.BUILD(|opts);
            $!fetch-opts.BUILD(|opts);
        }

        $!bare = $bare ?? 1 !! 0;

        $!local = do given $local
        {
            when 'auto'     { GIT_CLONE_LOCAL_AUTO    }
            when 'local'    { GIT_CLONE_LOCAL         }
            when 'no'       { GIT_CLONE_NO_LOCAL      }
            when 'no-links' { GIT_CLONE_LOCAL_NOLINKS }
        }

        $!checkout-branch := $checkout-branch if $checkout-branch;
    }
}

=begin pod

=head1 NAME

Git::Clone::Options

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 OPTIONS

=item B<:bare> - Set for a bare repo

=item Str B<:local >

Options for bypassing the git-aware transport on clone. Bypassing it
means that instead of a fetch, libgit2 will copy the object database
directory instead of figuring out what it needs, which is faster. If
possible, it will hardlink the files to save space.

  'auto' - Auto-detect (default), libgit2 will bypass the git-aware
	 transport for local paths, but use a normal fetch for
	 C<file://> urls.

  'local' - Bypass the git-aware transport even for a C<file://> url.

  'no' - Do no bypass the git-aware transport

  'no-links' - Bypass the git-aware transport, but do not try to use
	 hardlinks.

=item Str B<:checkout-branch> - The name of the branch to checkout
instead of the remote's default branch.


=end pod
