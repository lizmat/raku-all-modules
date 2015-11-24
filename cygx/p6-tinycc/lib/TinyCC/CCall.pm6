# Copyright 2015 cygx <cygx@cpan.org>
# Distributed under the Boost Software License, Version 1.0

use TinyCC;
use TinyCC::Types;

sub callee(Str $name, Signature $sig) {
    my $rtype := $sig.returns;
    if $rtype =:= Mu {
        my $csig = cparams($sig.params).join(', ');
        my \CODE = qq:to/__END__/;
            void ($name)($csig);
            int main(void) \{
                ($name)(ARGS);
                return 0;
            }
            __END__

        sub (*@args) {
            my \tcc = $*TINYCC // TinyCC.new;
            tcc.define(ARGS => cargs(@args).join(', '));
            tcc.compile(CODE);
            tcc.run;
            Nil;
        }
    }
    else {
        my $ctype := ctype($rtype);
        my $csig = cparams($sig.params).join(', ');
        my \CODE = qq:to/__END__/;
            $ctype ($name)($csig);
            extern $ctype rv;
            int main(void) \{
                rv = ($name)(ARGS);
                return 0;
            }
            __END__

        sub (*@args) {
            my \tcc = $*TINYCC // TinyCC.new;
            my $rv := cval($rtype);
            tcc.define(ARGS => cargs(@args).join(', '));
            tcc.declare(:$rv);
            tcc.compile(CODE);
            tcc.run;
            rv($rv);
        }
    }
}

multi trait_mod:<is>(Routine $r, :ccall($name)!) is export {
    $r.wrap: callee($name ~~ Bool ?? $r.name !! ~$name, $r.signature);
}
