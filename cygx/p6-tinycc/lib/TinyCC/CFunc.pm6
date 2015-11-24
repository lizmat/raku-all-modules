# Copyright 2015 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use TinyCC;
use TinyCC::Invoke;

multi trait_mod:<is>(Routine $r, :$cfunc!) is export {
    given @$cfunc -> [ $arg where Stringy|Callable,
        TinyCC \tcc = $*TINYCC // TinyCC.new ] {

        tcc.compile($r, $_) given do given $arg {
            when Stringy { .Str }
            when Callable { .() }
        }

        my $handler := $r.wrap: sub (*@args, TinyCC :$tcc) {
            $r.unwrap($handler);
            $handler := Nil;
            $r.wrap: tccbind(tcc.lookup($r.name), $r.signature);
            $r.(@args, :$tcc);
        }
    }
}
