# Copyright 2017 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use nqp;
use NativeCall;

use TinyCC::Compiler;
use TinyCC::Typeof;

multi EVAL(Str $code, Str :$lang! where 'c'|'C',
    Mu:U :$returns, :$include, :$bind = Empty) is export {

    my $tcc := TCC.new;
    my $prelude = $include ?? $include.map({ "#include \"$_\"\n" }).join !! '';

    my @bindings;
    for $bind -> $ (:key($var), Mu:U :value($type)) {
        my $name := $var.key;
        my $blob := buf8.allocate(nativesizeof $type);
        my $ptr := nativecast Pointer[$type], $blob;
        nativecast(CArray[$type], $ptr).ASSIGN-POS(0, $_)
            with $var.value;

        $tcc.declare($name, $ptr);
        @bindings.push($var, $ptr);

        $prelude ~= qq:to/END/;
            #ifdef _WIN32
            __attribute__((dllimport))
            #endif
            extern {typeof $type} $name;
            END
    }

    my $name = "p6_tcc_eval_{++$}";
    my $type = typeof $returns;
    my $unit = "$prelude$type $name\(void)\{$code\}";

    my $bin := $tcc.compile($unit).relocate(:auto);
    LEAVE $bin andthen .close;

    my $sig := Signature.new;
    $sig.set_returns($returns);
    # make @!params a low-level list to prevent explosion at NativeCall.pm6:79
    nqp::bindattr($sig, Signature, '@!params', nqp::list);

    my $rv := $bin.lookup($name, $sig).();

    for @bindings -> $var, $ptr {
        $var.value = $ptr.deref;
    }

    $rv;
}
