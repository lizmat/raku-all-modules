use v6.c;
use lib 'lib';
use Test;
use Git::Simple;

plan 2;

my $dir = $*TMPDIR ~ '/test-git-simple-20-git-detached';
mkdir $dir;
my $proc = run <git -C>, $dir, <init>, :out;
$proc.out.close;

my %branch-info = Git::Simple.new(cwd => $dir).branch-info;
is %branch-info<local>, 'Big Bang', 'git init';

run <git -C>, $dir, <config user.email>, 'you@example.com';
run <git -C>, $dir, <config user.name>, 'Your Name';
run <touch>, "$dir/foo.txt";
run <git -C>, $dir, <add>, "$dir/foo.txt", :out;
$proc = run <git -C>, $dir, <commit -m>, "added foo.txt", :out;
$proc.out.close;

%branch-info = Git::Simple.new(cwd => $dir).branch-info;
is %branch-info<local>, 'master', 'git add + commit';

run <rm -rf>, $dir;
