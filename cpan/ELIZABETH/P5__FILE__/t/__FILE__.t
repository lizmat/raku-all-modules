use v6.c;
use Test;
use P5__FILE__;

plan 8;

is __PACKAGE__, 'main',             'did we get "main" for package';
is __SUB__,     Nil,                'did we get Nil for sub';
is __FILE__,    $?FILE.IO.relative, 'did we get the right file';
is __LINE__,    $?LINE,             'did we get the right line';

module Foo {
    is __PACKAGE__, $?PACKAGE.^name,  'did we get the right package';
    is __SUB__,     Nil,              'did we get Nil for sub';

    sub foo() {
        is __SUB__, 'foo', 'did we get "foo" for sub';
    }
    foo;
}

sub bar() {
    is __SUB__, 'bar', 'did we get "bar" for sub';
}
bar;

# vim: ft=perl6 expandtab sw=4
