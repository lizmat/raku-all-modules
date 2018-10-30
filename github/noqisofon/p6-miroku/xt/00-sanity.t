# -*- mode: perl6; -*-
use v6;

use Test;
use File::Temp;

use lib "xt";
use FakeCommand;

plan 3;

subtest 'miroku --help tests' => sub {
    plan 1;

    my $result = miroku( '--help' );

    ok $result.success-p, 'success in `miroku --help`';
}

subtest 'miroku --version tests' => sub {
    plan 1;
    
    my $result = miroku( '--version' );

    ok $result.success-p, 'success in `miroku --version`';
}

my $temp-dir = tempdir;
subtest 'miroku new tests' => sub {
    plan 9;
    
    temp $*CWD = $temp-dir.IO;
    
    my $result = miroku( 'new', 'Foo::Bar' );

    ok 'p6-Foo-Bar'.IO.d, 'p6-Foo-Bar/ exist';

    chdir 'p6-Foo-Bar';
    ok $_.IO.e, "$_ exist" for <.git .gitignore .travis.yml LICENSE META6.json README.md lib>;

    ok $result.success-p, 'success in `miroku new Foo::Bar`';
}

done-testing;
