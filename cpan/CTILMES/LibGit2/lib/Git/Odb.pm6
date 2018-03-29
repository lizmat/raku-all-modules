use NativeCall;
use Git::Error;
use Git::Oid;
use Git::Object;
use Git::Channel;

class Git::Odb is repr('CPointer') {...}

class Git::Odb::Backend is repr('CStruct')
{
    has uint32 $.version = 1;
    has Git::Odb $.odb;
    has Pointer $.read;
    has Pointer $.read-prefix;
    has Pointer $.read-header;
    has Pointer $.write;
    has Pointer $.writestream;
    has Pointer $.readstream;
    has Pointer $.exists;
    has Pointer $.exists-prefix;
    has Pointer $.refresh;
    has Pointer $.foreach;
    has Pointer $.writepack;
    has Pointer $.freshen;
    has Pointer $.free;
}

class Git::Odb::Object is repr('CPointer')
{
    method id(--> Git::Oid)
        is native('git2') is symbol('git_odb_object_id') {}

    method size(--> size_t)
        is native('git2') is symbol('git_odb_object_size') {}

    sub git_odb_object_type(Git::Odb::Object --> int32)
        is native('git2') {}

    method type { Git::Type(git_odb_object_type(self)) }

    method gist { "$.type $.id" }

    method raw(--> CArray[uint8])
        is native('git2') is symbol('git_odb_object_data') {}

    method Buf { buf8.new($.raw[^$.size]) }

    method Str { $.Buf.decode }

    sub git_odb_object_free(Git::Odb::Object)
        is native('git2') {}

    submethod DESTROY { git_odb_object_free(self) }
}

sub odb-foreach(Git::Oid $oid, int64 $nonce --> int32)
{
    try Git::Channel.channel($nonce).send($oid);
    $! ?? 1 !! 0
}

class Git::Odb
{
    sub git_odb_new(Pointer is rw --> int32)
        is native('git2') {}

    multi method new
    {
        my Pointer $ptr .= new;
        check(git_odb_new($ptr));
        nativecast(Git::Odb, $ptr)
    }

    sub git_odb_open(Pointer is rw, Str --> int32)
        is native('git2') {}

    multi method new(Str $objects-dir)
    {
        my Pointer $ptr .= new;
        check(git_odb_open($ptr, $objects-dir));
        nativecast(Git::Odb, $ptr)
    }

    sub git_odb_free(Git::Odb)
        is native('git2') {}

    submethod DESTROY { git_odb_free(self) }

    method num-backends(--> size_t)
        is native('git2') is symbol('git_odb_num_backends') {}

    sub git_odb_get_backend(Pointer is rw, Git::Odb, size_t --> int32)
        is native('git2') {}

    method backend(size_t $index)
    {
        my Pointer $ptr .= new;
        check(git_odb_get_backend($ptr, self, $index));
        nativecast(Git::Odb::Backend, $ptr)
    }

    sub git_odb_hash(Git::Oid, Blob, size_t, int32 --> int32)
        is native('git2') {}

    multi method hash(Blob $buf, Str $type = 'blob')
    {
        my Git::Oid $oid .= new;
        check(git_odb_hash($oid, $buf, $buf.bytes, Git::Objectish.type($type)));
        $oid
    }

    multi method hash(Str $str, Str $type = 'blob')
    {
        self.hash($str.encode, $type)
    }

    sub git_odb_hashfile(Git::Oid, Str, int32 --> int32)
        is native('git2') {}

    method hashfile(Str:D $path, Str $type = 'blob')
    {
        my Git::Oid $oid .= new;
        check(git_odb_hashfile($oid, $path, Git::Objectish.type($type)));
        $oid
    }

    sub git_odb_add_disk_alternate(Git::Odb, Str --> int32)
        is native('git2') {}

    method add-disk-alternate(Str:D $path)
    {
        check(git_odb_add_disk_alternate(self, $path))
    }

    sub git_odb_exists(Git::Odb, Git::Oid --> int32)
        is native('git2') {}

    multi method exists(Git::Oid:D $oid)
    {
        git_odb_exists(self, $oid) == 1 ?? True !! False
    }

    multi method exists(Str:D $oid-str) { self.exists(Git::Oid.new($oid-str)) }

    sub git_odb_read(Pointer is rw, Git::Odb, Git::Oid --> int32)
        is native('git2') {}

    multi method read(Git::Oid:D $oid)
    {
        my Pointer $ptr .= new;
        check(git_odb_read($ptr, self, $oid));
        nativecast(Git::Odb::Object, $ptr)
    }

    multi method read(Str:D $oid-str) { self.read(Git::Oid.new($oid-str)) }

    sub git_odb_read_header(size_t is rw, int32 is rw, Git::Odb, Git::Oid
                            --> int32)
    is native('git2') {}

    multi method read-header(Git::Oid:D $oid)
    {
        my size_t $len = 0;
        my int32 $type = 0;
        check(git_odb_read_header($len, $type, self, $oid));
        [$len, Git::Type($type)]
    }

    multi method read-header(Str:D $oid-str)
    {
        $.read-header(Git::Oid.new($oid-str))
    }

    sub git_odb_foreach(Git::Odb, &callback (Git::Oid, int64 --> int32), int64
                        --> int32)
        is native('git2') {}

    method objects
    {
        my $channel = Git::Channel.new;

        start
        {
            my $ret = git_odb_foreach(self, &odb-foreach, $channel.Int);
            $channel.fail(X::Git.new(code => Git::ErrorCode($ret)))
                unless $ret == 0;
            Git::Channel.done($channel.Int)
        }

        $channel
    }

}
