#!perl6

use v6;

use Test;
use IO::Glob;

isa-ok glob('*'), IO::Glob;

my $star-foo = glob('*foo');
ok 'foo' ~~ $star-foo;
ok 'blahfoo' ~~ $star-foo;
ok 'fooblah' !~~ $star-foo;
ok 'bar' !~~ $star-foo;

my $dqs = glob('.??*');
ok 'foo' !~~ $dqs;
ok '.foo' ~~ $dqs;
ok '.f' !~~ $dqs;
ok '.bar.foo' ~~ $dqs;
ok '..' !~~ $dqs;
ok '...' ~~ $dqs;

my $star = glob(*);
ok 'foo' ~~ $star;
ok '.' ~~ $star;
ok '..' ~~ $star;
ok 'bsadhfwerowhefl;kasjdf' ~~ $star;
ok '' ~~ $star;

my $fixtures-foo = glob('t/fixtures/foo.*');
ok 't/fixtures/foo.md'.IO ~~ $fixtures-foo;
ok 't/fixtures/foo.txt'.IO ~~ $fixtures-foo;
ok 't/fixtures/bar.md'.IO !~~ $fixtures-foo;

my $hyphen-foo = glob('some-other-bits/blah/*.json');
ok 'some-other-bits/blah/group.getStuff.json' ~~ $hyphen-foo;
ok 'some-other-bits/blah/group.getStuff.md' !~~ $hyphen-foo;

done-testing;
