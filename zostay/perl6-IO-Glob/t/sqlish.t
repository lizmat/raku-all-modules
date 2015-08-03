#!perl6

use v6;

use Test;
use IO::Glob;

my $star-foo = glob('%foo', :grammar(IO::Glob::SQL.new));
ok 'foo' ~~ $star-foo;
ok 'blahfoo' ~~ $star-foo;
ok 'fooblah' !~~ $star-foo;
ok 'bar' !~~ $star-foo;

my $dqs = glob('.__%', :grammar(IO::Glob::SQL.new));
ok 'foo' !~~ $dqs;
ok '.foo' ~~ $dqs;
ok '.f' !~~ $dqs;
ok '.bar.foo' ~~ $dqs;
ok '..' !~~ $dqs;
ok '...' ~~ $dqs;

my $star = glob(*, :grammar(IO::Glob::SQL.new));
ok 'foo' ~~ $star;
ok '.' ~~ $star;
ok '..' ~~ $star;
ok 'bsadhfwerowhefl;kasjdf' ~~ $star;
ok '' ~~ $star;

my $fixtures-foo = glob('t/fixtures/foo.%', :grammar(IO::Glob::SQL.new));
ok 't/fixtures/foo.md'.IO ~~ $fixtures-foo;
ok 't/fixtures/foo.txt'.IO ~~ $fixtures-foo;
ok 't/fixtures/bar.md'.IO !~~ $fixtures-foo;

done;
