# -*- mode: perl6; -*-
use v6;

use Test;

my &normalize-path = -> $path {
    $*DISTRO.is-win ?? $path.subst( '\\', '/', :g ).IO.relative !! $path.IO.relative
};

my &to-module = -> $filename {
    normalize-path( $filename ).Str.subst( 'lib/', '' ).subst( '/', '::', :g ).subst( /\.pm6?$/, '' )
};

my &to-file = -> $module-name {
    my $path = $module-name.subst( '::', '/', :g ) ~ '.pm6';

    './lib/'.IO.add( $path ).Str
};

plan 3;

is 'hoge.txt'           , normalize-path( './hoge.txt' );

is 'Hoge::Piyo'         , to-module( './lib/Hoge/Piyo.pm6' );

is './lib/Hoge/Piyo.pm6', to-file( 'Hoge::Piyo' );

done-testing;
