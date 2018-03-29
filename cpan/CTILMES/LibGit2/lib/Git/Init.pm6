use NativeCall;

enum Git::Repository::InitFlag ( # git_repository_init_flag
    GIT_REPOSITORY_INIT_BARE              => 1 +< 0,
    GIT_REPOSITORY_INIT_NO_REINIT         => 1 +< 1,
    GIT_REPOSITORY_INIT_NO_DOTGIT_DIR     => 1 +< 2,
    GIT_REPOSITORY_INIT_MKDIR             => 1 +< 3,
    GIT_REPOSITORY_INIT_MKPATH            => 1 +< 4,
    GIT_REPOSITORY_INIT_EXTERNAL_TEMPLATE => 1 +< 5,
    GIT_REPOSITORY_INIT_RELATIVE_GITLINK  => 1 +< 6,
);

enum Git::Repository::InitMode ( # git_repository_init_mode_t
    GIT_REPOSITORY_INIT_SHARED_UMASK => 0,
    GIT_REPOSITORY_INIT_SHARED_GROUP => 0o2775,
    GIT_REPOSITORY_INIT_SHARED_ALL   => 0o2777,
);

# git_repository_init_options
class Git::Repository::InitOptions is repr('CStruct')
{
    has uint32 $.version = 1;
    has uint32 $.flags;
    has uint32 $.mode;
    has Str $.workdir-path;
    has Str $.description;
    has Str $.template-path;
    has Str $.initial-head;
    has Str $.origin-url;

    submethod BUILD(Bool :$bare, Bool :$no-reinit, Bool :$no-dotgit-dir,
                    Bool :$mkdir, Bool :$mkpath, Bool :$external-template,
                    Bool :$relative-gitlink, uint32 :$!mode,
                    Bool :$shared-all, Bool :$shared-group,
                    Str :$workdir-path, Str :$description,
                    Str :$template-path, Str :$initial-head,
                    Str :$origin-url)
    {
        $!flags =
              ($bare              ?? GIT_REPOSITORY_INIT_BARE             !! 0)
           +| ($no-reinit         ?? GIT_REPOSITORY_INIT_NO_REINIT        !! 0)
           +| ($no-dotgit-dir     ?? GIT_REPOSITORY_INIT_NO_DOTGIT_DIR    !! 0)
           +| ($mkdir             ?? GIT_REPOSITORY_INIT_MKDIR            !! 0)
           +| ($external-template || $template-path
                  ?? GIT_REPOSITORY_INIT_EXTERNAL_TEMPLATE !! 0)
           +| ($relative-gitlink  ?? GIT_REPOSITORY_INIT_RELATIVE_GITLINK !! 0);

        $!mode = GIT_REPOSITORY_INIT_SHARED_GROUP if $shared-group;
        $!mode = GIT_REPOSITORY_INIT_SHARED_ALL   if $shared-all;

        $!workdir-path  := $workdir-path;
        $!description   := $description;
        $!template-path := $template-path;
        $!initial-head  := $initial-head;
        $!origin-url    := $origin-url;
    }
}

=begin pod

=head1 NAME

Git::Repository::InitOptions -- Init Options

=head1 SYNOPSIS

  # Make isolated B<Git::Repository::InitOptions> object.
  my $opts = Git::Repository::InitOptions.new(<options>);

  # More common, just pass the options into Git::Repository.init()
  my $repo = Git::Repository.init('/my/dir', <options>);

=head1 DESCRIPTION

Creates a B<Git::Repository::InitOptions> the extended options structure.

=head2 OPTIONS

=item B<:bare> - Create a bare repository with no working directory

=item B<:no-reinit> - Return an error if the repo_path appears to already
be an git repository

=item B<:no-dotgit-dir> - Normally a C</.git/> will be appended to the
repo path for non-bare repos (if it is not already there), but passing
this flag prevents that behavior.

=item B<:mkdir> - Make the C<repo-path> (and C<workdir-path>) as needed.
Init is always willing to create the C<.git> directory even without
this flag.  This flag tells init to create the trailing component of
the repo and workdir paths as needed.

=item B<:mkpath> - Recursively make all components of the repo and
workdir paths as necessary.

=item B<:external-template> - libgit2 normally uses internal templates to
initialize a new repo.  This flags enables external templates, looking
the <template_path> from the options if set, or the
C<init.templatedir> global config if not, or falling back on
C</usr/share/git-core/templates> if it exists.

=item B<:init-relative-gitlink> - If an alternate C<workdir> is
specified, use relative paths for the C<gitdir> and C<core.worktree>.

=item uint32 B<:$mode> - Can be used to explicitly set the file mode of
created files instead of using C<umask>.  See B<:$shared-group> and
:$shared-all>.

=item B<:shared-group> - Use C<--shared=group> behavior, chmod'ing the
new repo to be group writable and C<g+sx> for sticky group assignment.

=item B<:shared-all> - Use C<--shared=all> behavior, adding world
readability.

=item Str B<:$workdir-path> - The path to the working dir. IF THIS IS A
RELATIVE PATH, IT WILL BE EVALUATED RELATIVE TO THE REPO-PATH.  If
this is not the "natural" working directory, a .git gitlink file will
be created here linking to the repo-path.

=item Str B<:$description> - If set, this will be used to initialize the
"description" file in the repository, instead of using the template
content.

=item Str B<:$template-path> - When C<:external-template> is set, this
contains the path to use for the template directory.  If this isn't
set, the config or default directory options will be used instead.

=item Str B<:$initial-head> - The name of the head to point B<HEAD> at.
If not set, then this will be treated as C<master> and the B<HEAD> ref
will be set to C<refs/heads/master>.  If this begins with C<refs/> it
will be used verbatim; otherwise C<refs/heads/> will be prefixed.

=item Str B<:$origin-url> - If this is set, then after the rest of the
repository initialization is completed, an C<origin> remote will be
added pointing to this URL.

=end pod
