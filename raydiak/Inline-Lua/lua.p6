#!/usr/bin/env perl6

# This script acts roughly like lua <file> or lua -e <code> and probably
# isn't very useful outside of testing during development

constant $root = $?FILE.IO.parent;
use lib $root.child('lib');
use lib $root.child('blib').child: 'lib';

use Inline::Lua;

sub MAIN (Str $file is copy, *@args, Bool :$jit, Bool :$e) {
    my $L = do given $jit { # JIT selection
        when $_ eqv True { Inline::Lua.new: :lua<JIT> } # yes
        when $_ eqv False { Inline::Lua.new: :!auto } # no
        Inline::Lua.new # detect
    };

    $file = $file.IO.slurp unless $e;

    my @results = $L.run: $file, @args;

    given +@results {
        when 0 { }
        when 1 {
            say "--- Returned @results[0].perl()";
        }
        default {
            say "--- Returned\n{ @results».perl.join("\n").indent(4) }";
        }
    }

    True;
}


