use NativeCall;

class Git::Buffer is repr('CStruct')
{
    has CArray[uint8] $.ptr;
    has size_t $.asize;
    has size_t $.size;

    method buf
    {
        buf8.new($!ptr[^$!size])
    }

    method str
    {
        self.buf.decode
    }

    sub git_buf_free(Git::Buffer)
        is native('git2') {}

    submethod DESTROY { git_buf_free(self) }
}
