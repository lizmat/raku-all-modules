LibGit2 -- Direct access to Git via libgit2 library
===================================================

Note:

This is a WORK IN PROGRESS.  The tests are under construction and many
of them probably won't work on your computer..

This module provides Perl 6 access to [libgit2](https://libgit2.github.com/)

That library must be installed, and this module will be subject to the
features enabled during the build/install of that library.

This module is **EXPERIMENTAL**.  In particular, I'm still trying to refine
the Perl 6 API to be as friendly as possible, and also as Perl-ish as
possible.  I've converted some callbacks into Channels, and some options
into :pairs, etc.  If you see anything that could be done better, PLEASE
raise an issue.

There are also still some unimplemented corners, so if you see anything
you can't do, raise an issue and we can try to add more libgit2 bindings.
Also some functionality that looks like it should work doesn't seem to...
Debugging, test improvements, etc. are all appreciated -- feel free to
ask questions or offer patches!

For now, there are also some 64-bit assumptions.  If there is demand for
a 32-bit version, there are ways to adapt it I can work with someone who
wants to tackle that.  It also doesn't currently support Windows, but
could probably do so if someone wants to port it.  Patches welcome!

Global Initialization
---------------------

Always start with `use LibGit2` rather than using individual `Git::*`
modules.  That pulls in the rest of the modules, and also initializes
the library as a whole.

Query some global information about the library:

    use LibGit2;
    say LibGit2.version;
    say LibGit2.features;

    0.26.0
    (GIT_FEATURE_NSEC GIT_FEATURE_SSH GIT_FEATURE_HTTPS GIT_FEATURE_THREADS)

Tracing
-------

If libgit2 is compiled with tracing support, you can enable that tracing
from Perl6.

    LibGit2.trace('debug');  # none,fatal,error,warn,info,debug,trace

The default trace callback just prints the message and its level to
STDOUT.  You can also supply a callback:

    use NativeCall;
    sub my-trace($level, $message) { say "$level $message" }

    LibGit2.trace('info', &my-trace);

Init
----

    my $repo = Git::Repository.init('/my/dir');

    my $repo = Git::Repository.init('/my/dir', :bare);

    my $repo = Git::Repository.init('/my/dir', :mkpath,
    description => 'my description', ...);

See Git::Repository::InitOptions for the complete init option list.

Clone
-----

    my $repo = Git::Repository.clone('https://github.com/...', '/my/dir');

    my $repo = Git::Repository.clone('https://github.com/...', '/my/dir', :bare);

See Git::Clone::Options for the complete clone option list.

Open
----

    my $repo = Git::Repository.open('/my/dir');

    my $repo = Git::Repository.open('/my/dir', :bare);

    my $repo = Git::Repository.open('/my/dir/some/subdir', :search);

See Git::Repository::OpenOptions for the complete open options list.

Config
------

From a `Git::Repository`, you can use the `.config` method to access
configuration information.

    my $config = $repo.config;

Status
------

Get status for a specific file/path:

    my $status = $repo.status-file('afile');

    say $status.status;
    say $status.path;
    say "new in workdir" if $status.is-workdir-new;

Other queries on status: is-current is-index-new is-index-modified
is-index-deleted is-index-renamed is-index-typechange is-workdir-new
is-workdir-modified is-workdir-deleted is-workdir-typechange
is-workdir-renamed is-workdir-unreadable is-ignored is-conflicted

Query for status of everything, or specific pathes/globs:

    for $repo.status-each {
        say 'new' if .is-workdir-new;
    }

    say .path for $repo.status-each('*.p6', :include-untracked);

See `Git::Status::Options` for more information on status options.

Index
-----

Retrieve an object representing the repository's index with `.index`,
then you can add files to the index, either a specific file
`.add-bypath` or a group of files or all files with `.add-all`, or
just update with `.update-all`.

    my $repo.index;
    $index.add-bypath('afile.p6');  # Even works on ignored files
    $index.add-all('*.p6');         # Add any new files or update any changes
    $index.update-all('*.t');       # Just update, don't add new files

Remove from index with `.remove-bypath` or `.remove-all`.

The index is maintained in memory.  To persist the changes to disk,
always `$index.write` after completeing changes.  Use `.read(:force)`
to discard any changes and re-read index from disk.

See Git::Index for more information on options.

After adding new or changed files to the index, create a `Git::Tree`
representing the changes with `.write-tree` which returns a `Git::Oid`
for the new tree.

    my $tree-id = $index.write-tree;

Tree
----

    my $tree = $repo.tree-lookup($tree-id);

Signature
---------

    my $sig = $repo.signature-default;  # Fails if user.name, user.email not set
    my $sig = Git::Signature('Full Name <name@address.com');
    my $sig = Git::Signature('Full Name', 'name@address.com');
    my $sig = Git::Signature('Full Name', 'name@address.com',
       DateTime.new('...'));

Commit
------

A commit requires several components:

* **:update-ref** - Defaults to 'HEAD', the name of the reference that
    will be updated to point to this commit. If the reference is not
    direct, it will be resolved to a direct reference. Use "HEAD" to
    update the HEAD of the current branch and make it point to this
    commit. If the reference doesn't exist yet, it will be created. If
    it does exist, the first parent must be the tip of this branch.

* **:author** - Git::Signature of the commit author, defaults to
    $repo.signature-default.

* **:committer** - Git::Signature of the committer, defaults to the
    same as the author.

* **:messsage** - Commit message.  Add **:prettify** option to prettify it.

* **:tree** -- Git::Tree of the changes to add to the commit.  If not
    specified, $repo.tree-lookup($repo.index.write-tree) will be used, the
    tree of all changes to the index.

* **Git::Commit** - parents for this commit.  Specify **:root** for a
    root commit with no parents.  If no parents are specified, and
    **:root** is not included, the commit pointed to by 'HEAD' will be
    used as the only parent.

    $repo.commit(message => "This is my new commit.");

See ... for more information about commits.

References
----------

Look up references by name with:

     my $ref = $repo.reference-lookup('/refs/heads/master');

or by 'short name' (by git precedence rules) with:

    my $ref = $repo.ref('master');

They return Git::Reference.

You can get list of names references:

    .say for $repo.reference-list;

or a list of full references:

    .name.say for $repo.references;  # Say each full name

    refs/heads/master
    refs/remotes/origin/master
    refs/tags/0.1

    .short.say for $repo.references;  # Say each short name

    master
    origin/master
    0.1

or limit with a glob:

    .name.say for $repo.references('refs/tags/*')

You can also get the Oid from a reference name:

    my $oid = $repo.name-to-id('HEAD');

Tags
----

Branches
--------

Remotes
-------

Fetch
-----

Checkout
--------

Push
----

Worktree
--------

Diff
----
