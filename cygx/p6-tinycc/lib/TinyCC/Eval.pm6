# Copyright 2015 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use TinyCC;

multi EVAL(Cool $code, Str() :$lang! where 'c'|'C', :$tcc, :&init, :$args)
    is export {
    my \tcc := $tcc // $*TINYCC // TinyCC.new;

    my $error;
    tcc.catch(-> $, Str $msg { $error = X::AdHoc.new(payload => $msg) });

    .(tcc) with &init;

    do {
        CATCH { ($error // $_).fail }
        tcc.compile(~$code).run: @($args // ());
    }
}
