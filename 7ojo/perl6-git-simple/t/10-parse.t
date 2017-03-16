use v6;
use lib 'lib';
use Test;
use Git::Simple;
use Git::Simple::Parse;

plan 2;

subtest 'Parse status output', {
    plan 10;

    my %res = Git::Simple::Parse.new.status(out => '## foo');
    is %res<local>, 'foo', "got local branch";

    %res = Git::Simple::Parse.new.status(out => '## foo...bar');
    is %res<local>, 'foo', "got local branch";
    is %res<remote>, 'bar', "got remote branch";

    %res = Git::Simple::Parse.new.status(out => '## foo...bar [ahead 3]');
    is %res<local>, 'foo', "got local branch";
    is %res<remote>, 'bar', "got remote branch";
    is %res<ahead>, '3', "got correct ahead";

    %res = Git::Simple::Parse.new.status(out => '## foo...bar [ahead 3, behind 5]');
    is %res<local>, 'foo', "got local branch";
    is %res<remote>, 'bar', "got remote branch";
    is %res<ahead>, '3', "got correct ahead";
    is %res<behind>, '5', "got correct behind";
}

subtest 'Anomalies', {
    plan 1;

    my $dir = '/tmp/.test-git-simple-10-basic';
    mkdir $dir;
    my %res = Git::Simple.new(cwd => $dir).branch-info;
    is %res.keys.elems, 0, 'not a git repository';
    rmdir $dir;
}
