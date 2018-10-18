use File::Ignore;
use Test;

plan 5;

ok File::Ignore.parse(q:to/LIST/);
    [._]*.s[a-w][a-z]
    [._]s[a-w][a-z]
    .X[a-z-]
    .X[--0]
    LIST

my $ig =  File::Ignore.parse(q:to/LIST/);
    [._]*.s[a-w][a-z]
    [._]s[a-w][a-z]
    .X[a-z-]
    .X[--0]
    LIST


ok $ig.ignore-path('foo.pm6.swp'), 'ignore-path ignores [._]s[a-w][a-z]';
nok $ig.ignore-path('foo.pm6.sxp'), 'ignore-path does not ignore *.sxp';
ok $ig.ignore-path('foo.X-'), 'range handles dangling “-”';
ok $ig.ignore-path('foo.X.'), 'range handles prepended “-”';
