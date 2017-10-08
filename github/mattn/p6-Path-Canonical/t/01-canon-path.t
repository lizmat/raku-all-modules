use v6;
use Test;
use Path::Canonical;

is canon-path('/var/tmp/./foo/../bar/..'), '/var/tmp/';
is canon-path('/var/tmp/./foo/../bar/../'), '/var/tmp/';
is canon-path('/var/tmp/./foo/../bar'), '/var/tmp/bar';
is canon-path('/../bar/..'), '/';
is canon-path('/../bar/../'), '/';
is canon-path('/../bar'), '/bar';
is canon-path('../bar/..'), '/';
is canon-path('../bar/../'), '/';
is canon-path('../bar'), '/bar';
is canon-path('./bar/..'), '/';
is canon-path('./bar/../'), '/';
is canon-path('./bar'), '/bar';
is canon-path('/var/tmp/./foo/../bar/'), '/var/tmp/bar/';
is canon-path('/var/tmp'), '/var/tmp';
is canon-path('/var//../../../foo/bar/baz'), '/foo/bar/baz';
is canon-path('/./././././././././.bashrc'), '/.bashrc';

done-testing;
