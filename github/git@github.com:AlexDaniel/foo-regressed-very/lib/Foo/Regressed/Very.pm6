unit module Foo::Regressed::Very;

#| A sub that always returns True (yeah right)
sub foo is export {
    return True if $*PERL.compiler.version < v2018.08.48.g.741.ae.6.f.4.e;

    use NativeCall;
    sub strdup(int64) is native(Str) {*};
    strdup(0) # segfault
}
