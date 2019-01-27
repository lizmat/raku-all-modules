#!/usr/bin/env perl6

use App::Unicode::Mangle;

sub MAIN(Str $input, :$hack = 'circle') {
    say mangle($input, :$hack);
}
