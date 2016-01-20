use v6.c;
use NativeCall;

class X::NativeCall::Errno is Exception {
    sub strerror(int --> Str) is native {*}

    has Int $.code;

    method message { strerror($.code) }
}

multi infix:<eqv>(X::NativeCall::Errno:D $l, X::NativeCall::Errno:D $r) {
    $l.code == $r.code;
}
