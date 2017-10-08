use File::Ignore;
use Test;

# These tests cover the difference between ignore-file and ignore-path:
# ignore-file assumes that you'll never feed it files found in a directory
# that ignore-directory already claimed should be ignored, while ignore-path
# will check the directories in the path also.

my $ig = File::Ignore.parse(q:to/LIST/);
    b*z/
    bang
    LIST

ok $ig.ignore-directory('baz'), 'ignore-directory ignores baz';
ok $ig.ignore-file('bang'), 'ignore-file ignores bang';
nok $ig.ignore-file('baz/fizz'),
    'ignore-file does not ignore baz/fizz; assumes it need not';
nok $ig.ignore-file('baz/fizz/wizz'),
    'ignore-file does not ignore baz/fizz/wizz; assumes it need not';

ok $ig.ignore-path('baz'), 'ignore-path ignores baz';
ok $ig.ignore-path('bang'), 'ignore-path ignores bang';
ok $ig.ignore-path('baz/fizz'), 'ignore-path ignores baz/fizz';
ok $ig.ignore-path('baz/fizz/wizz'), 'ignore-file ignores baz/fizz/wizz';
nok $ig.ignore-path('ba'), 'ignore-path does not ingore ba';

done-testing;
