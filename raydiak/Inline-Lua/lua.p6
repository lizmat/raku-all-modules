#!/usr/bin/env perl6

constant $root = $?FILE.IO.parent;
use lib $root.child('lib');
use lib $root.child('blib').child('lib');

my $lua-ver;
BEGIN {
    if
        @*ARGS &&
        defined my $i = (^@*ARGS).first: {
            my $v = @*ARGS[$_];
            $v ~~ /^ [ '-j' | '--jit' ] $/ &&
            (!$_ || @*ARGS[^$_].none eq '--')
        }
    {
        @*ARGS.splice: $i, 1;
        $lua-ver = 'JIT';
    }
}

use Lua::Raw $lua-ver;
use Inline::Lua;

sub MAIN (Str $file is copy, *@args, Bool :$e) {
    my $L = Inline::Lua.new;

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


