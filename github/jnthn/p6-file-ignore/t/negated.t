use File::Ignore;
use Test;

my $ig = File::Ignore.parse(q:to/LIST/);
    .git/
    .svn/
    foo/bar/*
    !.git/
    !foo/bar/ok
    LIST

nok $ig.ignore-directory('.git'), 'Negated rule means .git directory not ignored';
ok $ig.ignore-directory('.svn'), 'Having negated rules does not break other directory checks';
nok $ig.ignore-path('.git/'), 'Negated rule means .git path not ignored';
ok $ig.ignore-path('.svn/'), 'Having negated rules does not break other path checks';

nok $ig.ignore-file('foo/bar/ok'), 'Negated rule means ok file not ignored';
ok $ig.ignore-file('foo/bar/nok'), 'Negated rule does not break ignoring of other files';
nok $ig.ignore-path('foo/bar/ok'), 'Negated rule means ok path not ignored';
ok $ig.ignore-path('foo/bar/nok'), 'Having negated rules does not break other path checks';

done-testing;
