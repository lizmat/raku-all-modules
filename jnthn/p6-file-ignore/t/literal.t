use File::Ignore;
use Test;

my $ig = File::Ignore.parse(q:to/LIST/);
    foo
    /bar
    baz/
    /whee/bang
    LIST

nok $ig.ignore-file('alright'), 'Do not ignore files not in ignore list';
nok $ig.ignore-directory('alright'), 'Do not ignore directories not in ignore list';

ok $ig.ignore-file('foo'), '"foo" ignores root file "foo"';
ok $ig.ignore-file('alright/foo'), '"foo" ignores file "alright/foo"';
ok $ig.ignore-directory('foo'), '"foo" ignores root directory "foo"';
ok $ig.ignore-directory('alright/foo'), '"foo" ignores directory "alright/foo"';
nok $ig.ignore-file('food'), '"foo" does not ignore file "food"';
nok $ig.ignore-directory('food'), '"foo" does not ignore directory "food"';

ok $ig.ignore-file('bar'), '"/bar" ignores root file "bar"';
nok $ig.ignore-file('alright/bar'), '"/bar" does not ignore file "alright/bar"';
ok $ig.ignore-directory('bar'), '"/bar" ignores root directory "bar"';
nok $ig.ignore-directory('alright/bar'), '"/bar" does not ignore directory "alright/bar"';
nok $ig.ignore-file('bard'), '"/bar" does not ignore file "bard"';
nok $ig.ignore-directory('bard'), '"/bar" does not ignore directory "bard"';

nok $ig.ignore-file('baz'), '"baz/" does not ignores root file "baz"';
nok $ig.ignore-file('alright/baz'), '"baz/" does not ignore file "alright/baz"';
ok $ig.ignore-directory('baz'), '"bar/" ignores root directory "bar"';
ok $ig.ignore-directory('alright/baz'), '"baz/" ignores directory "alright/baz"';

done-testing;
