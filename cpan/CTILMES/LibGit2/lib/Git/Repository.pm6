use NativeCall;
use Git::Error;
use Git::Init;
use Git::Open;
use Git::Clone;
use Git::Buffer;
use Git::Config;
use Git::Reference;
use Git::Oid;
use Git::Strarray;
use Git::Remote;
use Git::Commit;
use Git::Blob;
use Git::Tree;
use Git::TreeBuilder;
use Git::Signature;
use Git::Object;
use Git::Blame;
use Git::Message;
use Git::Index;
use Git::Status;
use Git::Revwalk;
use Git::Checkout;
use Git::Worktree;
use Git::Odb;
use Git::Annotated;
use Git::Describe;
use Git::Branch;

# git_repository_state_t
enum Git::Repository::State
<
    GIT_REPOSITORY_STATE_NONE
    GIT_REPOSITORY_STATE_MERGE
    GIT_REPOSITORY_STATE_REVERT
    GIT_REPOSITORY_STATE_REVERT_SEQUENCE
    GIT_REPOSITORY_STATE_CHERRYPICK
    GIT_REPOSITORY_STATE_CHERRYPICK_SEQUENCE
    GIT_REPOSITORY_STATE_BISECT
    GIT_REPOSITORY_STATE_REBASE
    GIT_REPOSITORY_STATE_REBASE_INTERACTIVE
    GIT_REPOSITORY_STATE_REBASE_MERGE
    GIT_REPOSITORY_STATE_APPLY_MAILBOX
    GIT_REPOSITORY_STATE_APPLY_MAILBOX_OR_REBASE
>;

# git_repository_item_t
enum Git::Repository::Item
<
    GIT_REPOSITORY_ITEM_GITDIR
    GIT_REPOSITORY_ITEM_WORKDIR
    GIT_REPOSITORY_ITEM_COMMONDIR
    GIT_REPOSITORY_ITEM_INDEX
    GIT_REPOSITORY_ITEM_OBJECTS
    GIT_REPOSITORY_ITEM_REFS
    GIT_REPOSITORY_ITEM_PACKED_REFS
    GIT_REPOSITORY_ITEM_REMOTES
    GIT_REPOSITORY_ITEM_CONFIG
    GIT_REPOSITORY_ITEM_INFO
    GIT_REPOSITORY_ITEM_HOOKS
    GIT_REPOSITORY_ITEM_LOGS
    GIT_REPOSITORY_ITEM_MODULES
    GIT_REPOSITORY_ITEM_WORKTREES
>;

class Git::Repository is repr('CPointer')
{
    sub git_repository_free(Git::Repository)
        is native('git2') {}

    sub git_repository_new(Pointer is rw)
        is native('git2') {}

    sub git_repository_init(Pointer is rw, Str, uint32 --> int32)
        is native('git2') {}

    sub git_repository_init_ext(Pointer is rw, Str, Git::Repository::InitOptions
                                --> int32)
        is native('git2') {}

    sub git_repository_open(Pointer is rw, Str --> int32)
        is native('git2') {}

    sub git_repository_open_bare(Pointer is rw, Str --> int32)
        is native('git2') {}

    sub git_repository_open_ext(Pointer is rw, Str, uint32, Str --> int32)
        is native('git2') {}

    sub git_repository_open_from_worktree(Pointer is rw, Git::Worktree --> int32)
        is native('git2') {}

    sub git_repository_is_bare(Git::Repository --> int32)
        is native('git2') {}

    sub git_repository_is_empty(Git::Repository --> int32)
        is native('git2') {}

    sub git_repository_is_shallow(Git::Repository --> int32)
        is native('git2') {}

    sub git_repository_discover(Git::Buffer, Str, int32, Str --> int32)
        is native('git2') {}

    sub git_clone(Pointer is rw, Str, Str, Git::Clone::Options --> int32)
        is native('git2') {}

    sub git_repository_config(Pointer is rw, Git::Repository --> int32)
        is native('git2') {}

    sub git_reference_lookup(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_reference_dwim(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_reference_name_to_id(Git::Oid, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_reference_list(Git::Strarray, Git::Repository --> int32)
        is native('git2') {}

    sub git_reference_create(Pointer is rw, Git::Repository, Str,
                             Git::Oid, int32, Str --> int32)
        is native('git2') {}

    sub git_tag_list(Git::Strarray, Git::Repository --> int32)
        is native('git2') {}

    sub git_tag_list_match(Git::Strarray, Str, Git::Repository --> int32)
        is native('git2') {}

    sub git_remote_create(Pointer is rw, Git::Repository, Str, Str --> int32)
        is native('git2') {}

    sub git_remote_create_anonymous(Pointer is rw, Git::Repository, Str
                                    --> int32)
        is native('git2') {}

    sub git_remote_create_with_fetchspec(Pointer is rw, Git::Repository, Str,
                                         Str, Str --> int32)
        is native('git2') {}

    sub git_remote_list(Git::Strarray, Git::Repository --> int32)
        is native('git2') {}

    sub git_remote_lookup(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_remote_add_fetch(Git::Repository, Str, Str --> int32)
        is native('git2') {}

    sub git_remote_add_push(Git::Repository, Str, Str --> int32)
        is native('git2') {}

    sub git_remote_set_autotag(Git::Repository, Str, int32 --> int32)
        is native('git2') {}

    sub git_remote_delete(Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_branch_create(Pointer is rw, Git::Repository, Str,
                          Git::Commit, int32 --> int32)
        is native('git2') {}

    sub git_branch_lookup(Pointer is rw, Git::Repository, Str, int32 --> int32)
        is native('git2') {}

    sub git_blob_create_frombuffer(Git::Oid, Git::Repository, Blob, size_t
                                   --> int32)
        is native('git2') {}

    sub git_blob_create_fromdisk(Git::Oid, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_blob_create_fromworkdir(Git::Oid, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_treebuilder_new(Pointer is rw, Git::Repository, Git::Tree --> int32)
        is native('git2') {}

    sub git_revparse_single(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_signature_default(Pointer is rw, Git::Repository --> int32)
        is native('git2') {}

    sub git_tag_create(Git::Oid, Git::Repository, Str, Pointer, Git::Signature,
                       Str, int32 --> int32)
        is native('git2') {}

    sub git_tag_delete(Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_object_lookup(Pointer is rw, Git::Repository, Git::Oid, int32
                          --> int32)
        is native('git2') {}

    sub git_blame_file(Pointer is rw, Git::Repository, Str, Git::Blame::Options
                   --> int32)
        is native('git2') {}

    sub git_tree_entry_to_object(Pointer is rw, Git::Repository,
                                 Git::Tree::Entry --> int32)
        is native('git2') {}

    sub git_commit_create(Git::Oid, Git::Repository, Str, Git::Signature,
                          Git::Signature, Str, Str, Git::Tree, size_t,
                          CArray[Git::Commit] --> int32)
        is native('git2') {}

    sub git_repository_index(Pointer is rw, Git::Repository --> int32)
        is native('git2') {}

    sub git_ignore_add_rule(Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_ignore_clear_internal_rules(Git::Repository --> int32)
        is native('git2') {}

    sub git_ignore_path_is_ignored(int32 is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_status_list_new(Pointer is rw, Git::Repository,
                            Git::Status::Options --> int32)
        is native('git2') {}

    sub git_status_file(uint32 is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_status_should_ignore(int32 is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_diff_index_to_workdir(Pointer is rw, Git::Repository, Git::Index,
                                  Git::Diff::Options --> int32)
        is native('git2') {}

    sub git_diff_tree_to_index(Pointer is rw, Git::Repository, Git::Tree,
                               Git::Index, Git::Diff::Options --> int32)
        is native('git2') {}

    sub git_diff_tree_to_workdir_with_index(Pointer is rw, Git::Repository,
                                   Git::Tree, Git::Diff::Options --> int32)
        is native('git2') {}

    sub git_diff_tree_to_tree(Pointer is rw, Git::Repository,
                              Git::Tree, Git::Tree, Git::Diff::Options
                              --> int32)
        is native('git2') {}

    sub git_revwalk_new(Pointer is rw, Git::Repository --> int32)
        is native('git2') {}

    sub git_worktree_list(Git::Strarray, Git::Repository --> int32)
        is native('git2') {}

    sub git_worktree_lookup(Pointer is rw, Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_worktree_add(Pointer is rw, Git::Repository, Str, Str,
                         Git::Worktree::Add::Options --> int32)
        is native('git2') {}

    sub git_worktree_open_from_repository(Pointer is rw, Git::Repository
                                          --> int32)
        is native('git2') {}

    sub git_repository_head_for_worktree(Pointer is rw, Git::Repository, Str
                                         --> int32)
        is native('git2') {}

    sub git_repository_is_worktree(Git::Repository --> int32)
        is native('git2') {}

    sub git_repository_odb(Pointer is rw, Git::Repository --> int32)
        is native('git2') {}

    sub git_annotated_commit_from_fetchhead(Pointer is rw, Git::Repository,
                                            Str, Str, Git::Oid --> int32)
        is native('git2') {}

    sub git_annotated_commit_from_ref(Pointer is rw, Git::Repository,
                                      Git::Reference --> int32)
        is native('git2') {}

    sub git_annotated_commit_from_revspec(Pointer is rw, Git::Repository,
                                          Str --> int32)
        is native('git2') {}

    sub git_annotated_commit_lookup(Pointer is rw, Git::Repository, Git::Oid
                                    --> int32)
        is native('git2') {}

    sub git_describe_workdir(Pointer is rw, Git::Repository,
                             Git::Describe::Options --> int32)
        is native('git2') {}

    sub git_repository_set_head(Git::Repository, Str --> int32)
        is native('git2') {}

    sub git_repository_head_detached(Git::Repository --> int32)
        is native('git2') {}

    sub git_repository_detach_head(Git::Repository --> int32)
        is native('git2') {}

    sub git_repository_head_unborn(Git::Repository --> int32)
        is native('git2') {}

    sub git_repository_state(Git::Repository --> int32)
        is native('git2') {}

    sub git_repository_state_cleanup(Git::Repository --> int32)
        is native('git2') {}

    sub git_repository_hashfile(Git::Oid, Git::Repository, Str, int32, Str
                                --> int32)
        is native('git2') {}

    method new()
    {
        my Pointer $ptr .= new;
        check(git_repository_new($ptr));
        nativecast(Git::Repository, $ptr)
    }

    method state { Git::Repository::State(git_repository_state(self)) }

    method state-cleanup { check(git_repository_state_cleanup(self)) }

    method init(Str:D $path, Bool :$bare, |opts --> Git::Repository)
    {
        my Pointer $ptr .= new;
        if opts
        {
            check(git_repository_init_ext($ptr, $path,
                Git::Repository::InitOptions.new(:$bare, |opts)))
        }
        else
        {
            check(git_repository_init($ptr, $path, $bare ?? 1 !! 0))
        }
        nativecast(Git::Repository, $ptr)
    }

    multi method open(Str $path?, Bool:D :$search, Str :$ceiling-dirs, *%opts)
    {
        my Pointer $ptr .= new;
        check(git_repository_open_ext($ptr, $path,
            Git::Repository::OpenOptions.flags(:$search, |%opts),
            $ceiling-dirs));
        nativecast(Git::Repository, $ptr)
    }

    multi method open(Str $path, Bool :$bare)
    {
        my Pointer $ptr .= new;
        check($bare ?? git_repository_open_bare($ptr, $path)
                    !! git_repository_open($ptr, $path));
        nativecast(Git::Repository, $ptr)
    }

    multi method open(Git::Worktree $worktree)
    {
        my Pointer $ptr .= new;
        check(git_repository_open_from_worktree($worktree));
        nativecast(Git::Repository, $ptr)
    }

    method discover(Str $start-path, Str $ceiling-dirs?,
                    Bool :$across-fs = False)
    {
        my Git::Buffer $buf .= new;
        check(git_repository_discover($buf, $start-path, $across-fs ?? 1 !! 0,
                                      $ceiling-dirs));
        $buf.str
    }

    method commondir(--> Str)
        is native('git2') is symbol('git_repository_commondir') {}

    method clone(Str:D $url, Str:D $local-path, |opts)
    {
        my Pointer $ptr .= new;
        my Git::Clone::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_clone($ptr, $url, $local-path, $opts));
        nativecast(Git::Repository, $ptr)
    }

    method config(--> Git::Config)
    {
        my Pointer $ptr .= new;
        check(git_repository_config($ptr, self));
        nativecast(Git::Config, $ptr)
    }

    method reference-lookup(Str $name)
    {
        my Pointer $ptr .= new;
        check(git_reference_lookup($ptr, self, $name));
        nativecast(Git::Reference, $ptr)
    }

    method ref(Str $shorthand)
    {
        my Pointer $ptr .= new;
        check(git_reference_dwim($ptr, self, $shorthand));
        nativecast(Git::Reference, $ptr)
    }

    method name-to-id(Str $name)
    {
        my Git::Oid $oid .= new;
        check(git_reference_name_to_id($oid, self, $name));
        $oid
    }

    method reference-list()
    {
        my Git::Strarray $array .= new;
        check(git_reference_list($array, self));
        $array.list(:free)
    }

    method references(Str $glob?)
    {
        Seq.new(Git::Reference::Iterator.new(self, $glob))
    }

    method reference-create(Str:D $name, Git::Oid:D $id, Bool :$force,
                            Str :$message)
    {
        my Pointer $ptr .= new;
        check(git_reference_create($ptr, self, $name, $id,
                                   $force ?? 1 !! 0,
                                   $message));
        nativecast(Git::Reference, $ptr)
    }

    method tag-list(Str $pattern?)
    {
        my Git::Strarray $array .= new;
        check($pattern ?? git_tag_list_match($array, $pattern, self)
                       !! git_tag_list($array, self));
        $array.list(:free)
    }

    method remote-create(Str:D :$url, Str :$name, Str :$fetch)
    {
        my Pointer $ptr .= new;
        check($name ??
              ($fetch ?? git_remote_create_with_fetchspec($ptr, self, $name,
                                                          $url, $fetch)
                      !! git_remote_create($ptr, self, $name, $url))
              !! git_remote_create_anonymous($ptr, self, $url));
        nativecast(Git::Remote, $ptr)
    }

    method remote-list()
    {
        my Git::Strarray $array .= new;
        check(git_remote_list($array, self));
        $array.list(:free)
    }

    method remote-lookup(Str $name)
    {
        my Pointer $ptr .= new;
        check(git_remote_lookup($ptr, self, $name));
        nativecast(Git::Remote, $ptr)
    }

    method remote-add-fetch(Str:D $remote, Str:D $refspec)
    {
        check(git_remote_add_fetch(self, $remote, $refspec))
    }

    method remote-add-push(Str:D $remote, Str:D $refspec)
    {
        check(git_remote_add_push(self, $remote, $refspec))
    }

    method remote-set-autotag(Str:D $remote, Str:D $tags = 'unspecified')
    {
        check(git_remote_set_autotag(self, $remote,
            Git::Fetch::Options.autotag-lookup($tags)))
    }

    method remote-delete(Str:D $name)
    {
        check(git_remote_delete(self, $name))
    }

    multi method blob-create(Blob $buf)
    {
        my Git::Oid $oid .= new;
        check(git_blob_create_frombuffer($oid, self, $buf, $buf.bytes));
        $oid
    }

    multi method blob-create(Str $str)
    {
        samewith($str.encode)
    }

    multi method blob-create(IO::Path $path)
    {
        my Git::Oid $oid .= new;
        check(git_blob_create_fromdisk($oid, self, ~$path));
        $oid
    }

    multi method blob-create(Str $path, :$workdir!)
    {
        my Git::Oid $oid .= new;
        check(git_blob_create_fromworkdir($oid, self, $path));
        $oid
    }

    method treebuilder(Git::Tree $tree = Git::Tree)
    {
        my Pointer $ptr .= new;
        check(git_treebuilder_new($ptr, self, $tree));
        nativecast(Git::TreeBuilder, $ptr)
    }

    method revparse-single(Str $spec)
    {
        my Pointer $ptr .= new;
        check(git_revparse_single($ptr, self, $spec));
        Git::Objectish.object($ptr)
    }

    method signature-default(--> Git::Signature)
    {
        my Pointer $ptr .= new;
        check(git_signature_default($ptr, self));
        nativecast(Git::Signature, $ptr)
    }

    method tag-create(Str:D $tag-name, Git::Objectish:D $target,
                      Git::Signature :$tagger = self.signature-default,
                      Str:D :$message = '', Bool :$force = False)
    {
        my Git::Oid $oid .= new;
        check(git_tag_create($oid, self, $tag-name,
                             nativecast(Pointer, $target),
                             $tagger, $message, $force ?? 1 !! 0));
        $oid
    }

    method tag-delete(Str $tag-name)
    {
        check(git_tag_delete(self, $tag-name))
    }

    method tag-lookup(Git::Oid $oid)
    {
        self.object-lookup($oid, GIT_OBJ_TAG)
    }

    method commit-lookup(Git::Oid $oid)
    {
        self.object-lookup($oid, GIT_OBJ_COMMIT)
    }

    method blob-lookup(Git::Oid $oid)
    {
        self.object-lookup($oid, GIT_OBJ_BLOB)
    }

    method tree-lookup(Git::Oid $oid)
    {
        self.object-lookup($oid, GIT_OBJ_TREE)
    }

    multi method object-lookup(Git::Oid:D $oid, Git::Type $type = GIT_OBJ_ANY)
    {
        my Pointer $ptr .= new;
        check(git_object_lookup($ptr, self, $oid, $type));
        Git::Objectish.object($ptr)
    }

    multi method object-lookup(Git::Oid:D $oid, Str:D $type)
    {
        samewith($oid, Git::Objectish.type($type))
    }

    multi method object-lookup(Str:D $oid-str, Git::Type $type = GIT_OBJ_ANY)
    {
        samewith(Git::Oid.new($oid-str), $type)
    }

    multi method object-lookup(Str:D $oid-str, Str:D $type)
    {
        samewith(Git::Oid.new($oid-str, Git::Objectish.type($type)))
    }

    method blame-file(Str $path, |opts)
    {
        my Pointer $ptr .= new;
        my Git::Blame::Options $opts .= new(|opts);
        check(git_blame_file($ptr, self, $path, $opts));
        nativecast(Git::Blame, $ptr)
    }

    multi method branch-create(Str $branch-name, Git::Commit $target,
                               Bool :$force = False, Bool :$set-head)
    {
        my Pointer $ptr .= new;
        check(git_branch_create($ptr, self, $branch-name, $target,
                                $force ?? 1 !! 0));
        my $ref = nativecast(Git::Reference, $ptr);
        $.set-head($ref.name) if $set-head;
        $ref
    }

    multi method branch-create(Str $branch-name, Git::Oid $target-id, |opts)
    {
        samewith($branch-name, $.commit-lookup($target-id), |opts)
    }

    method branch-lookup(Str $branch-name, Bool :$remote = False)
    {
        my Pointer $ptr .= new;
        check(git_branch_lookup($ptr, self, $branch-name,
              $remote ?? GIT_BRANCH_REMOTE !! GIT_BRANCH_LOCAL));
        nativecast(Git::Reference, $ptr)
    }

    method branch-list(|opts --> Seq)
    {
        Seq.new(Git::Branch::Iterator.new(self, |opts))
    }

    method object(Git::Tree::Entry $entry)
    {
        my Pointer $ptr .= new;
        check(git_tree_entry_to_object($ptr, self, $entry));
        Git::Objectish.object($ptr)
    }

    method commit(Str:D :$update-ref = 'HEAD',
                  Git::Signature:D :$author = $.signature-default,
                  Git::Signature:D :$committer = $author,
                  Str:D :$encoding =  'UTF-8',  # Should really encode message
                  Str:D :$message!,             # with specified encoding
                  Bool :$prettify = False,
                  Git::Tree:D :$tree = $.tree-lookup($.index.write-tree),
                  Bool :$root = False,
                  *@parents)
    {
        my Git::Oid $oid .= new;

        my CArray[Git::Commit] $parents-array;
        my size_t $parent-count;

        if $root
        {
            $parent-count = 0;
        }
        else
        {
            if @parents
            {
                $parent-count = @parents.elems;
                $parents-array .= new(@parents);
            }
            else
            {
                $parent-count = 1;
                $parents-array .= new($.commit-lookup($.name-to-id('HEAD')));
            }
        }

        check(git_commit_create($oid, self, $update-ref,
                                $author, $committer, $encoding,
                                $prettify ?? Git::Message.prettify($message)
                                          !! $message,
                                $tree ?? $tree !! $.lookup($.index.write-tree),
                                $parent-count, $parents-array));
        $oid
    }

    method index(--> Git::Index)
    {
        my Pointer $ptr .= new;
        check(git_repository_index($ptr, self));
        nativecast(Git::Index, $ptr)
    }

    method ignore-add(Str $rules)
    {
        check(git_ignore_add_rule(self, $rules));
    }

    method ignore-clear()
    {
        check(git_ignore_clear_internal_rules(self))
    }

    method is-ignored(Str $path)
    {
        my int32 $ignored = 0;
        check(git_ignore_path_is_ignored($ignored, self, $path));
        $ignored == 1
    }

    method status-list(*@pathspec, |opts)
    {
        my $opts = Git::Status::Options.new(
            :pathspec(Git::Strarray.new(|@pathspec)), |opts);

        my Pointer $ptr .= new;
        check(git_status_list_new($ptr, self, $opts));
        nativecast(Git::Status::List, $ptr)
    }

    method status-file(Str $path)
    {
        my uint32 $flags = 0;
        my $ret = git_status_file($flags, self, $path);
        return if $ret == GIT_ENOTFOUND;
        check($ret);
        Git::Status::File.new(:$flags, :$path)
    }

    method status-each(*@pathspec, |opts)
    {
        if @pathspec || opts
        {
            my $opts = Git::Status::Options.new(
                :pathspec(Git::Strarray.new(|@pathspec)), |opts);
            return Git::Status.foreach(nativecast(Pointer, self), $opts)
        }
        else
        {
            return Git::Status.foreach(nativecast(Pointer, self))
        }
    }

    method status-should-ignore(Str $path)
    {
        my int32 $ignored = 0;
        check(git_status_should_ignore($ignored, self, $path));
        $ignored == 1
    }

    method diff-index-to-workdir(Git::Index :$index = self.index, |opts)
    {
        my Pointer $ptr .= new;
        my Git::Diff::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_diff_index_to_workdir($ptr, self, $index, $opts));
        nativecast(Git::Diff, $ptr)
    }

    method diff-tree-to-index(
		Git::Tree :$tree = self.revparse-single('HEAD^{tree}'),
        Git::Index :$index = self.index,
        |opts)
    {
        my Pointer $ptr .= new;
        my Git::Diff::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_diff_tree_to_index($ptr, self, $tree, $index, $opts));
        nativecast(Git::Diff, $ptr)
    }

    method diff-tree-to-workdir-with-index(
		Git::Tree :$tree = self.revparse-single('HEAD^{tree}'), |opts)
    {
        my Pointer $ptr .= new;
        my Git::Diff::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_diff_tree_to_workdir_with_index($ptr, self, $tree, $opts));
        nativecast(Git::Diff, $ptr)
    }

    method diff-tree-to-tree(Git::Tree $old-tree,
                             Git::Tree $new-tree,
                             |opts)
    {
        my Pointer $ptr .= new;
        my Git::Diff::Options $opts;
        $opts .= new(|opts) if opts;
        check(git_diff_tree_to_tree($ptr, self, $old-tree, $new-tree, $opts));
        nativecast(Git::Diff, $ptr)
    }

    method revwalk
    {
        my Pointer $ptr .= new;
        check(git_revwalk_new($ptr, self));
        nativecast(Git::Revwalk, $ptr)
    }

    method checkout(|opts)
    {
        Git::Checkout.checkout(repo => self, |opts)
    }

    method worktree-list
    {
        my Git::Strarray $array .= new;
        check(git_worktree_list($array, self));
        $array.list
    }

    method worktree-lookup(Str:D $name)
    {
        my Pointer $ptr .= new;
        check(git_worktree_lookup($ptr, self, $name));
        nativecast(Git::Worktree, $ptr)
    }

    method worktree-add(Str:D $name, Str:D $path, |opts)
    {
        my Git::Worktree::Add::Options $opts;
        $opts .= new(|opts) if opts;
        my Pointer $ptr .= new;
        check(git_worktree_add($ptr, self, $name, $path, $opts));
        nativecast(Git::Worktree, $ptr)
    }

    method worktree-open
    {
        my Pointer $ptr .= new;
        check(git_worktree_open_from_repository($ptr, self));
        nativecast(Git::Worktree, $ptr)
    }

    method head-for-worktree(Str:D $name)
    {
        my Pointer $ptr .= new;
        check(git_repository_head_for_worktree($ptr, self, $name));
        nativecast(Git::Reference, $ptr)
    }

    method is-worktree { git_repository_is_worktree(self) == 1 }

    method odb
    {
        my Pointer $ptr .= new;
        check(git_repository_odb($ptr, self));
        nativecast(Git::Odb, $ptr)
    }

    method workdir(--> Str)
        is native('git2') is symbol('git_repository_workdir') {}

    multi method annotated-commit(Str:D $branch-name, Str:D $remote-url,
                                  Git::Oid:D $oid)
    {
        my Pointer $ptr .= new;
        check(git_annotated_commit_from_fetchhead($ptr, self, $branch-name,
                                                  $remote-url, $oid));
        nativecast(Git::Annotated::Commit, $ptr)
    }

    multi method annotated-commit(Git::Reference:D $ref)
    {
        my Pointer $ptr .= new;
        check(git_annotated_commit_from_ref($ptr, self, $ref));
        nativecast(Git::Annotated::Commit, $ptr)
    }

    multi method annotated-commit(Str:D $revspec)
    {
        my Pointer $ptr .= new;
        check(git_annotated_commit_from_revspec($ptr, self, $revspec));
        nativecast(Git::Annotated::Commit, $ptr)
    }

    multi method annotated-commit-lookup(Git::Oid:D $oid)
    {
        my Pointer $ptr .= new;
        check(git_annotated_commit_lookup($ptr, self, $oid));
        nativecast(Git::Annotated::Commit, $ptr)
    }

    multi method annotated-commit-lookup(Str:D $oid-str)
    {
        samewith(Git::Oid.new($oid-str))
    }

    method describe-workdir(|opts)
    {
        my Pointer $ptr .= new;
        my Git::Describe::Options $opts .= new(|opts);
        check(git_describe_workdir($ptr, self, $opts));
        nativecast(Git::Describe::Result, $ptr)
    }

    method is-bare(--> Bool)
    {
        git_repository_is_bare(self) == 1
    }

    method is-empty(--> Bool)
    {
        check(git_repository_is_empty(self)) == 1
    }

    method is-shallow(--> Bool)
    {
        git_repository_is_shallow(self) == 1
    }

    method set-head(Str:D $refname)
    {
        check(git_repository_set_head(self, $refname));
        self
    }

    method head-detached()
    {
        my $ret = git_repository_head_detached(self);
        $ret == 1 ?? True
                  !! $ret == 0 ?? False
                               !! check($ret)
    }

    method detach-head { check(git_repository_detach_head(self)) }

    method head-unborn()
    {
        my $ret = git_repository_head_unborn(self);
        $ret == 1 ?? True
                  !! $ret == 0 ?? False
                               !! check($ret)
    }

    method hashfile(Str:D $path, Str :$as-path,
                    Str :$type where 'commit'|'tree'|'blob'|'tag' = 'blob')
    {
        my Git::Oid $oid .= new;
        check(git_repository_hashfile($oid, self, $path,
                                      Git::Objectish.type($type), $as-path));
        $oid
    }

    method get-namespace(--> Str)
        is native('git2') is symbol('git_repository_get_namespace') {}

    sub git_repository_set_namespace(Git::Repository, Str --> int32)
        is native('git2') {}

    method set-namespace(Str:D $nmspace)
    {
        check(git_repository_set_namespace(self, $nmspace));
    }

    sub git_repository_set_ident(Git::Repository, Str, Str --> int32)
        is native('git2') {}

    method set-ident(Str $name, Str $email)
    {
        check(git_repository_set_ident(self, $name, $email));
        self
    }

    sub git_repository_item_path(Git::Buffer, Git::Repository, int32 --> int32)
        is native('git2') {}

    method item-path(Str:D $item)
    {
        my Git::Buffer $buf .= new;
        check(git_repository_item_path($buf, self,
            Git::Repository::Item::{"GIT_REPOSITORY_ITEM_$item.uc()"}));
        $buf.str
    }

    submethod DESTROY { git_repository_free(self) }
}

=begin pod

=head1 NAME

Git::Repository - LibGit2 Git Repository

=head1 SYNOPSIS

  use LibGit2;

  my $repo = Git::Repository.init('/my/dir');

  my $repo = Git::Repository.open('/my/dir');

=head1 DESCRIPTION

=head1 METHODS

=item B<.init>(Str:D $path, Bool :$bare, ... --> Git::Repository)

Initialize a directory as a Git repository and open it.

See Git::Repository::InitOptions for more information on options.

=item B<.open>(Str $path, Str :ceiling-dirs, ... --> Git::Repository)

Open an existing Git repository.

=item B<.clone>(Str:D $url, Str:D $localpath --> Git::Repository)

Clone a remote Git repository to the local disk.

=item B<.config>(--> Git::Config)

Access configuration information.

See Git::Config for more information.

=end pod
