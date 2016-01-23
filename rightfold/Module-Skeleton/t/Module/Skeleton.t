use v6.c;
use Module::Skeleton;
use File::Temp;
use Test;

sub can-diff {
    qx[diff t/fixtures/can-diff/{a,b}.txt] eq q:to/EOF/
    2c2
    < And that fool did not use a version control tool.
    ---
    > And that fool didn't use a version control tool.
    EOF
}

skip-rest 'cannot diff' unless can-diff;

my $skeleton = Module::Skeleton.new(name => 'Foolish::VCS::Git');

my $tree-dir = tempdir.IO;
$skeleton.spurt($tree-dir);
is(run('diff', 't/fixtures/tree', $tree-dir, :out).out, '');

done-testing;
