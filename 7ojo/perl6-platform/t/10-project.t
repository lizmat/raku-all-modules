use v6.c;
use lib 'lib';
use lib '../lib';
use Test;
use Platform::Project;

plan 13;

{
    my $prj = Platform::Project.new(:project('my-project.yml'));
    my $curr-path = ".".IO.absolute;

    is $curr-path, $prj.project-dir, "project dir";
    is "$curr-path/my-project.yml", $prj.project-file, "project file";
}

{ # TEST: has files under docker dir
    my $tmpdir = '.tmp/test-platform-10-project/docker'.IO.absolute;
    run <rm -rf>, $tmpdir if $tmpdir.IO.e;
    mkdir $tmpdir;
    $tmpdir = $tmpdir.IO.dirname;

    ok $tmpdir.IO.e, "got $tmpdir";

    spurt "$tmpdir/docker/project.yml", 'command: ash';

    my $prj = Platform::Project.new(:project($tmpdir));

    is $tmpdir, $prj.project-dir, "project dir {$prj.project-dir}";
    is $prj.project-file, "$tmpdir/docker/project.yml", "project file {$prj.project-file}";
}

{ # TEST: Precedence with <project-root>/docker/project.yml, <project-root>/project.yml file
    my $tmpdir = '.tmp/test-platform-10-project/docker'.IO.absolute;
    run <rm -rf>, $tmpdir if $tmpdir.IO.e;
    mkdir $tmpdir;
    $tmpdir = $tmpdir.IO.dirname;

    ok $tmpdir.IO.e, "got $tmpdir";

    spurt "$tmpdir/docker/project.yml", 'command: ash';
    spurt "$tmpdir/project.yml", 'command: ash';

    my $prj = Platform::Project.new(:project($tmpdir));

    is $tmpdir, $prj.project-dir, "project dir";
    is $prj.project-file, "$tmpdir/docker/project.yml", "project file";
}

{ # TEST: No docker dir
    my $tmpdir = '.tmp/test-platform-10-project'.IO.absolute;
    run <rm -rf>, $tmpdir if $tmpdir.IO.e;
    mkdir $tmpdir;

    ok $tmpdir.IO.e, "got $tmpdir";

    spurt "$tmpdir/project.yml", 'command: ash';

    my $prj = Platform::Project.new(:project($tmpdir));

    is $tmpdir, $prj.project-dir, "project dir";
    is $prj.project-file, "$tmpdir/project.yml", "project file";
}

{
    my $prj = Platform::Project.new(:project('~/my-project.yml'));
    my $curr-path = $*HOME.IO.absolute;

    is $prj.project-dir, $curr-path, "project dir with ~";
    is $prj.project-file, "$curr-path/my-project.yml", "project file with ~";
}
