use NativeCall;
use Git::Error;

class Git::Time is repr('CStruct')
{
    has uint64 $.time;
    has int32 $.offset;
    has uint8 $.sign;
}

class Git::Signature is repr('CStruct')
{
    has Str $.name;
    has Str $.email;
    HAS Git::Time $.when;

    sub git_signature_free(Git::Signature)
        is native('git2') {}

    sub git_signature_new(Pointer is rw, Str, Str, int64, int32 --> int32)
        is native('git2') {}

    sub git_signature_now(Pointer is rw, Str, Str --> int32)
        is native('git2') {}

    sub git_signature_from_buffer(Pointer is rw, Str --> int32)
        is native('git2') {}

    multi method new(Str:D $name, Str:D $email, DateTime:D $time)
    {
        my Pointer $ptr .= new;
        check(git_signature_new($ptr, $name, $email,
                                $time.posix, $time.offset-in-minutes.Int));
        nativecast(Git::Signature, $ptr)
    }

    multi method new(Str:D $name, Str:D $email)
    {
        my Pointer $ptr .= new;
        check(git_signature_now($ptr, $name, $email));
        nativecast(Git::Signature, $ptr)
    }

    multi method new(Str:D $buf)
    {
        my Pointer $ptr .= new;
        check(git_signature_from_buffer($ptr, $buf));
        nativecast(Git::Signature, $ptr)
    }

    method when
    {
        DateTime.new($!when.time, timezone => $!when.offset*60)
    }

    submethod DESTROY { git_signature_free(self) }
}
