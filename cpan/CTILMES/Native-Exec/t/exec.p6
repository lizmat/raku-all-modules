#!/usr/bin/env perl6

use Native::Exec;

sub MAIN(Str $file, Bool :$nopath, *@args, *%env)
{
    exec $file, :$nopath, @args, |%env;
}
