use NativeCall;
use Git::Error;
use Git::Oid;
use Git::Tree;
use Git::Strarray;

# git_index_add_option_t
enum Git::Index::Add::Option (
    GIT_INDEX_ADD_DEFAULT                => 0,
    GIT_INDEX_ADD_FORCE                  => 1 +< 0,
    GIT_INDEX_ADD_DISABLE_PATHSPEC_MATCH => 1 +< 1,
    GIT_INDEX_ADD_CHECK_PATHSPEC         => 1 +< 2,
);

enum Git::Index::Capabilities (
    GIT_INDEXCAP_IGNORE_CASE => 1,
    GIT_INDEXCAP_NO_FILEMODE => 2,
    GIT_INDEXCAP_NO_SYMLINKS => 4,
    GIT_INDEXCAP_FROM_OWNER  => -1,
);

class Git::Index::Time is repr('CStruct')
{
    has int32 $.seconds;
    has uint32 $.nanoseconds;
}

class Git::Index::Entry is repr('CStruct')
{
    HAS Git::Index::Time $.ctime;
    HAS Git::Index::Time $.mtime;
    has uint32 $.dev;
    has uint32 $.ino;
    has uint32 $.mode;
    has uint32 $.uid;
    has uint32 $.gid;
    has uint32 $.file-size;
    HAS Git::Oid $.id;
    has uint16 $.flags;
    has uint16 $.flags-extended;
    has Str $.path;
}

class Git::Index is repr('CPointer')
{
    sub git_index_free(Git::Index)
        is native('git2') {}

    sub git_index_new(Pointer is rw --> int32)
        is native('git2') {}

    sub git_index_open(Pointer is rw, Str --> int32)
        is native('git2') {}

    sub git_index_read(Git::Index, int32 --> int32)
        is native('git2') {}

    sub git_index_write(Git::Index --> int32)
        is native('git2') {}

    sub git_index_set_version(Git::Index, uint32 --> int32)
        is native('git2') {}

    method version(--> uint32)
        is native('git2') is symbol('git_index_version') {}

    method set-version(uint32 $version)
    {
        check(git_index_set_version(self, $version));
        self
    }

    method checksum(--> Git::Oid)
        is native('git2') is symbol('git_index_checksum') {}

    method new(--> Git::Index)
    {
        my Pointer $ptr .= new;
        check(git_index_new($ptr));
        nativecast(Git::Index, $ptr)
    }

    method open(Str $path)
    {
        my Pointer $ptr .= new;
        check(git_index_open($ptr, $path));
        nativecast(Git::Index, $ptr)
    }

    method read(Bool :$force = False)
    {
        check(git_index_read(self, $force ?? 1 !! 0));
        self
    }

    method write
    {
        check(git_index_write(self));
        self
    }

    method capabilities(--> int32)
        is native('git2') is symbol('git_index_caps') {}

    sub git_index_clear(Git::Index --> int32)
        is native('git2') {}

    method clear { check(git_index_clear(self)) }

    sub git_index_read_tree(Git::Index, Git::Tree --> int32)
        is native('git2') {}

    method read-tree(Git::Tree:D $tree)
    {
        check(git_index_read_tree(self, $tree))
    }

    sub git_index_write_tree(Git::Oid, Git::Index --> int32)
        is native('git2') {}

    sub git_index_write_tree_to(Git::Oid, Git::Index, Pointer --> int32)
        is native('git2') {}

    method write-tree($repo? --> Git::Oid)
    {
        my Git::Oid $oid .= new;
        if $repo
        {
            check(git_index_write_tree_to($oid, self,
                                          nativecast(Pointer, $repo)));
        }
        else
        {
            check(git_index_write_tree($oid, self));
        }
        $oid
    }

    method entrycount(--> size_t)
        is native('git2') is symbol('git_index_entrycount') {}

    method get-byindex(size_t $index --> Git::Index::Entry)
        is native('git2') is symbol('git_index_get_byindex') {}

    method get-bypath(Str $path, int32 $stage --> Git::Index::Entry)
        is native('git2') is symbol('git_index_get_bypath') {}

    sub git_index_add_bypath(Git::Index, Str --> int32)
        is native('git2') {}

    method add-bypath(Str:D $path)
    {
        check(git_index_add_bypath(self, $path));
        self
    }

    sub git_index_remove_bypath(Git::Index, Str --> int32)
        is native('git2') {}

    method remove-bypath(Str:D $path)
    {
        check(git_index_remove_bypath(self, $path));
        self
    }

    sub git_index_add_all(Git::Index, Git::Strarray, uint32, Pointer,
                          Pointer --> int32)
        is native('git2') {}

    method add-all(*@pathspec,
                   Bool :$force,
                   Bool :$disable-pathspec-match,
                   Bool :$check-pathspec)
    {
        my uint32 $flags =
           ($force                  ?? GIT_INDEX_ADD_FORCE                 !!0)
        +| ($disable-pathspec-match ?? GIT_INDEX_ADD_DISABLE_PATHSPEC_MATCH!!0)
        +| ($check-pathspec         ?? GIT_INDEX_ADD_CHECK_PATHSPEC        !!0);

        my Git::Strarray $pathspec;
        $pathspec .= new(@pathspec) if @pathspec;

        my $ret = git_index_add_all(self, $pathspec, $flags, Pointer, Pointer);
        check($ret);
        self
    }

    sub git_index_update_all(Git::Index, Git::Strarray, Pointer, Pointer
        --> int32)
        is native('git2') {}

    method update-all(*@pathspec)
    {
        my Git::Strarray $pathspec;
        $pathspec .= new(@pathspec) if @pathspec;

        my $ret = git_index_update_all(self, $pathspec, Pointer, Pointer);
        check($ret);
        self
    }

    sub git_index_remove_all(Git::Index, Git::Strarray, Pointer, Pointer
                             --> int32)
        is native('git2') {}

    method remove-all(*@pathspec)
    {
        my Git::Strarray $pathspec;
        $pathspec .= new(@pathspec) if @pathspec;

        my $ret = git_index_remove_all(self, $pathspec, Pointer, Pointer);
        return $ret if $ret <= 0;
        check($ret);
    }

    submethod DESTROY { git_index_free(self) }
}
