use NativeCall;
use Git::Error;
use Git::Oid;
use Git::Object;

class Git::Blob is repr('CPointer') does Git::Objectish
{
    method id(--> Git::Oid)
        is native('git2') is symbol('git_blob_id') {}

    method owner-ptr(--> Pointer)
        is native('git2') is symbol('git_blob_owner') {}

    method owner { nativecast(::('Git::Repository'), $.owner-ptr) }

    method rawcontent(--> CArray[uint8])
        is native('git2') is symbol('git_blob_rawcontent') {}

    method rawsize(--> int64)
        is native('git2') is symbol('git_blob_rawsize') {}

    sub git_blob_is_binary(Git::Blob --> int32)
        is native('git2') {}

    method is-binary { git_blob_is_binary(self) == 1 }

    method Buf { buf8.new($.rawcontent[^$.rawsize]) }

    method Str { $.Buf.decode }

    submethod DESTROY { self.free }
}
