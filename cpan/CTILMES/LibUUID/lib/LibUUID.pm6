use v6;

use NativeCall;

my constant LIBUUID = 'uuid'; # libuuid.so

class UUID
{
    has $.bytes;

    sub uuid_generate(Blob) is native(LIBUUID) {}
    sub uuid_unparse(Blob, Blob) is native(LIBUUID) {}
    sub uuid_parse(Blob, Blob) returns int32 is native(LIBUUID) {}

    proto method new(|) {*}

    multi method new()
    {
        my $bytes = buf8.allocate(16);
        uuid_generate($bytes);
        self.bless(:$bytes);
    }

    multi method new(Blob $bytes is copy where *.bytes == 16)
    {
        self.bless(:$bytes);
    }

    multi method new(Str $str)
    {
        my $bytes = buf8.allocate(16);
        uuid_parse(($str~"\0").encode, $bytes) == 0 or fail "Bad UUID $str";
        self.bless(:$bytes);
    }

    method Str
    {
        my $strbuf = buf8.allocate(37);
        uuid_unparse($!bytes, $strbuf);
        $strbuf.subbuf(0..^36).decode;
    }

    method Blob
    {
        $!bytes;
    }
}
