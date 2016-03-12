use v6;
use lib $?FILE.IO.dirname;
use A;
use Test;

my %all = A.foo;
is %all<foo>, q:to/EOF/;
bar
baz
EOF

done-testing;

=finish

@@ foo
bar
baz
