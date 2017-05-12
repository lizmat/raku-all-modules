# Copyright 2017 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use NativeCall;
use TinyCC::Compiler;
use TinyCC::Typeof;

my role CSub[$bytes, $fp] is export {
    method bytes { $bytes }
    method funcptr { $fp }
}

sub C($body, &sub, $sig = &sub.signature, :$include) is export {
    PRE $sig.arity == $sig.params;

    my $prelude = $include ?? $include.map({ "#include \"$_\"\n" }).join !! '';
    my $name = &sub.name;
    my $rtype = typeof $sig.returns;
    my @params = $sig.params.map({ "{typeof .type} {.name}" });
    my $code = "$prelude$rtype $name\({@params.join(', ')}) \{$body}";

    my $bin := TCC.new.compile($code).relocate;
    LEAVE .close with $bin;

    my $fp := $bin.lookup($name);
    CALLER::MY::{"\&$name"} := nativecast($sig, $fp) does CSub[$bin.bytes, $fp];
}
