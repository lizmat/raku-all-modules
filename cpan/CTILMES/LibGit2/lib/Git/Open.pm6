use NativeCall;

enum Git::Repository::OpenFlag (
    GIT_REPOSITORY_OPEN_NO_SEARCH => 1 +< 0,
    GIT_REPOSITORY_OPEN_CROSS_FS  => 1 +< 1,
    GIT_REPOSITORY_OPEN_BARE      => 1 +< 2,
    GIT_REPOSITORY_OPEN_NO_DOTGIT => 1 +< 3,
    GIT_REPOSITORY_OPEN_FROM_ENV  => 1 +< 4,
);

class Git::Repository::OpenOptions
{
    method flags(Bool :$search,
                 Bool :$cross-fs,
                 Bool :$bare,
                 Bool :$no-dotgit,
                 Bool :$from-env)
    {
        my uint32 $flags =
               ($search    ?? 0 !! GIT_REPOSITORY_OPEN_NO_SEARCH)
            +| ($cross-fs  ?? GIT_REPOSITORY_OPEN_CROSS_FS  !! 0)
            +| ($bare      ?? GIT_REPOSITORY_OPEN_BARE      !! 0)
            +| ($no-dotgit ?? GIT_REPOSITORY_OPEN_NO_DOTGIT !! 0)
            +| ($from-env  ?? GIT_REPOSITORY_OPEN_FROM_ENV  !! 0)
    }

}

=begin pod

=head1 NAME

Git::Repository::OpenOptions -- Open Options

=head1 SYNOPSIS

  # Normal open
  my $repo = Git::Repository.open('/my/dir');

  # Bare repository
  my $repo = Git::Repository.open('/my/dir', :bare);

  # Search upward to find git directory
  # This is the default if other options are specified, use :!search to disable
  my $repo = Git::Repository.open('/my/dir/some/subdir', :search);

=head1 DESCRIPTION

Options for B<Git::Repository.open>.

=head2 OPTIONS

=item B<:bare> - Open repository as a bare repo regardless of core.bare
config, and defer loading config file for faster setup.

=item B<:search> - Walk up from the start path looking at parent
directories.  If other options are set, this is the default, use
C<:!search> to disable and only open the repository if it can be
immediately found in the start path.

=item B<:cross-fs> - Unless this flag is set, open will not continue
searching across filesystem boundaries (i.e. when C<st_dev> changes
from the <stat> system call).  (E.g. Searching in a user's home
directory C</home/user/source/> will not return </.git/> as the found
repo if C</> is a different filesystem than C</home>.)

=item B<:no-dotgit> - Do not check for a repository by appending /.git to
the start_path; only open the repository if start_path itself points
to the git directory.

=item B<:from-env> - Find and open a git repository, respecting the
environment variables used by the git command-line tools. If set,
ignore the other flags and the C<$ceiling_dirs> argument.  If $path is
not specified, this will use C<GIT_DIR> or search from the current
directory. The search for a repository will respect
C<GIT_CEILING_DIRECTORIES> and C<GIT_DISCOVERY_ACROSS_FILESYSTEM>.
The opened repository will respect C<GIT_INDEX_FILE>,
C<GIT_NAMESPACE>, C<GIT_OBJECT_DIRECTORY>, and
C<GIT_ALTERNATE_OBJECT_DIRECTORIES>.  In the future, this flag will
also respect C<GIT_WORK_TREE> and C<GIT_COMMON_DIR>; currently, this
flag will error out if either C<GIT_WORK_TREE> or C<GIT_COMMON_DIR> is
set.

=item Str B<$ceiling-dirs> - A ':' (';' on windows) delimited list of
path prefixes at which the search for a containing repository should
terminate.

=end pod
