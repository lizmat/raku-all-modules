# Copyright 2017 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use TinyCC::Compiler;
use TinyCC::Typeof;
use nqp;

multi EVAL(Str $code, Str :$lang! where 'c'|'C',
    Mu:U :$returns, :$include) is export {

    my $prelude = $include ?? $include.map({ "#include \"$_\"\n" }).join !! '';
    my $name = "p6_tcc_eval_{++$}";
    my $type = typeof $returns;
    my $unit = "$prelude$type $name\(void)\{$code\}";

    my $bin := TCC.new.compile($unit).relocate(:auto);
    LEAVE $bin andthen .close;

    my $sig := Signature.new;
    $sig.set_returns($returns);
    # make @!params a low-level list to prevent explosion at NativeCall.pm6:79
    nqp::bindattr($sig, Signature, '@!params', nqp::list);

    $bin.lookup($name, $sig).();
}
