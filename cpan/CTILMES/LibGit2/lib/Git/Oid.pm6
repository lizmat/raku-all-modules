use NativeCall;
use Git::Error;

constant \GIT_OID_RAWSZ := 20;
constant \GIT_OID_HEXSZ := GIT_OID_RAWSZ * 2;

subset Git::Oidlike of Str where /^<xdigit>**{GIT_OID_HEXSZ}$/;

class Git::Oid is repr('CStruct')
{
    has int32 $.b0;
    has int32 $.b1;
    has int32 $.b3;
    has int32 $.b4;
    has int32 $.b5;

    sub git_oid_iszero(Git::Oid --> int32)
        is native('git2') {}

    sub git_oid_fromstr(Git::Oid, Str --> int32)
        is native('git2') {}

    method copy(Git::Oid)
        is native('git2') is symbol('git_oid_cpy') {}

    multi method new(Str:D $str --> Git::Oid)
    {
        my $oid = Git::Oid.new;
        check(git_oid_fromstr($oid, $str));
        $oid
    }

    multi method new(Pointer:D $ptr --> Git::Oid)
    {
        my $oid = Git::Oid.new;
        $oid.copy(nativecast(Git::Oid, $ptr));
        $oid
    }

    method is-zero { git_oid_iszero(self) == 1 }

    method Str(--> Str)
        is native('git2') is symbol('git_oid_tostr_s') {}

    method gist { ~self }
}

