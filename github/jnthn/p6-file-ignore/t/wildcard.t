use File::Ignore;
use Test;

my $ig = File::Ignore.parse(q:to/LIST/);
    *.swp
    dir*/
    /*.tmp
    result?.txt
    a/**/b
    **/c
    d/**
    LIST

nok $ig.ignore-file('alright'), 'Do not ignore files not in ignore list';
nok $ig.ignore-directory('alright'), 'Do not ignore directories not in ignore list';

ok $ig.ignore-file('foo.swp'), '"*.swp" ignores file foo.swp';
ok $ig.ignore-directory('foo.swp'), '"*.swp" ignores directory foo.swp';
ok $ig.ignore-file('.swp'), '"*.swp" ignores file .swp';
ok $ig.ignore-directory('.swp'), '"*.swp" ignores directory .swp';
ok $ig.ignore-file('bar/foo.swp'), '"*.swp" ignores file bar/foo.swp';
ok $ig.ignore-directory('bar/foo.swp'), '"*.swp" ignores directory bar/foo.swp';
ok $ig.ignore-file('bar/.swp'), '"*.swp" ignores file bar/.swp';
ok $ig.ignore-directory('bar/.swp'), '"*.swp" ignores directory bar/.swp';
nok $ig.ignore-file('x.swpe'), '"*.swp" does not ignore file x.swpe';
nok $ig.ignore-directory('x.swpe'), '"*.swp" does not ignore directory x.swpe';

nok $ig.ignore-file('dir21'), '"dir*/" does not ignore file dir21';
ok $ig.ignore-directory('dir21'), '"dir*/" ignores directory dir21';
nok $ig.ignore-file('foo/dir21'), '"dir*/" does not ignore file foo/dir21';
ok $ig.ignore-directory('foo/dir21'), '"dir*/" ignores directory foo/dir21';

ok $ig.ignore-file('x.tmp'), '"/*.tmp" ignores file x.tmp';
ok $ig.ignore-directory('x.tmp'), '"/*.tmp" ignores directory x.tmp';
nok $ig.ignore-file('subby/x.tmp'), '"/*.tmp" does not ignore file subby/x.tmp';
nok $ig.ignore-directory('subby/x.tmp'), '"/*.tmp" does not ignore directory subby/x.tmp';

nok $ig.ignore-file('result.txt'), '"result?.txt" does not ignore file result.txt';
nok $ig.ignore-directory('result.txt'), '"result?.txt" does not ignore directory result.txt';
ok $ig.ignore-file('result1.txt'), '"result?.txt" ignores file result1.txt';
ok $ig.ignore-directory('result1.txt'), '"result?.txt" ignores directory result1.txt';
nok $ig.ignore-file('result22.txt'), '"result?.txt" does not ignore file result22.txt';
nok $ig.ignore-directory('result22.txt'), '"result?.txt" does not ignore directory result22.txt';

ok $ig.ignore-file('a/b'), '"a/**/b" ignores file a/b';
ok $ig.ignore-directory('a/b'), '"a/**/b" ignores directory a/b';
ok $ig.ignore-file('a/x/b'), '"a/**/b" ignores file a/x/b';
ok $ig.ignore-directory('a/x/b'), '"a/**/b" ignores directory a/x/b';
ok $ig.ignore-file('a/x/y/b'), '"a/**/b" ignores file a/x/y/b';
ok $ig.ignore-directory('a/x/y/b'), '"a/**/b" ignores directory a/x/y/b';
nok $ig.ignore-file('a/x'), '"a/**/b" does not ignores file a/x';
nok $ig.ignore-directory('a/x'), '"a/**/b" does not ignore directory a/x';

ok $ig.ignore-file('c'), '"**/c" ignores file c';
ok $ig.ignore-directory('c'), '"**/c" ignores directory c';
ok $ig.ignore-file('x/c'), '"**/c" ignores file x/c';
ok $ig.ignore-directory('x/c'), '"**/c" ignores directory x/c';
ok $ig.ignore-file('x/y/c'), '"**/c" ignores file x/y/c';
ok $ig.ignore-directory('x/y/c'), '"**/c" ignores directory x/y/c';

ok $ig.ignore-file('d/x'), '"d/**" ignores file d/x';
ok $ig.ignore-directory('d/x'), '"d/**" ignores directory d/x';
ok $ig.ignore-file('d/x/yy'), '"d/**" ignores file d/x/yy';
ok $ig.ignore-directory('d/x/yy'), '"d/**" ignores directory d/x/yy';

done-testing;
