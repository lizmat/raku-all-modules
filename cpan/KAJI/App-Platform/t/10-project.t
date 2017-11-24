use v6.c;
use lib 'lib';
use lib '../lib';
use Test;
use App::Platform::Project;

plan 13;

{
    spurt '.test-10-project-my-project.yml', '';
    my $prj = App::Platform::Project.new(:project('.test-10-project-my-project.yml'));
    my $curr-path = ".".IO.absolute;

    is $curr-path, $prj.project-dir, "project dir";
    is "{$curr-path}/.test-10-project-my-project.yml".IO.absolute, $prj.project-file, "project file";

    '.test-10-project-my-project.yml'.IO.unlink;
}

{ # TEST: has files under docker dir
    my $tmpdir = '.tmp/test-platform-10-project/docker'.IO.absolute;
    mkdir $tmpdir;
    $tmpdir = $tmpdir.IO.dirname;

    ok $tmpdir.IO.e, "got $tmpdir";

    spurt "$tmpdir/docker/project.yml", 'command: ash';

    my $prj = App::Platform::Project.new(:project($tmpdir));

    is $tmpdir.IO.absolute, $prj.project-dir, "project dir {$prj.project-dir}";
    is $prj.project-file, "$tmpdir/docker/project.yml".IO.absolute, "project file {$prj.project-file}";

    unlink "$tmpdir/docker/project.yml";
    rmdir "$tmpdir/docker";
    rmdir "$tmpdir";
}

{ # TEST: Precedence with <project-root>/docker/project.yml, <project-root>/project.yml file
    my $tmpdir = '.tmp/test-platform-10-project/docker'.IO.absolute;
    mkdir $tmpdir;
    $tmpdir = $tmpdir.IO.dirname;

    ok $tmpdir.IO.e, "got $tmpdir";

    spurt "$tmpdir/docker/project.yml", 'command: ash';
    spurt "$tmpdir/project.yml", 'command: ash';

    my $prj = App::Platform::Project.new(:project($tmpdir));

    is $tmpdir.IO.absolute, $prj.project-dir, "project dir";
    is $prj.project-file, "$tmpdir/docker/project.yml".IO.absolute, "project file";

    unlink "$tmpdir/docker/project.yml";
    rmdir "$tmpdir/docker";
    unlink "$tmpdir/project.yml";
    rmdir "$tmpdir";
}

{ # TEST: No docker dirßs
    my $tmpdir = '.tmp/test-platform-10-project'.IO.absolute;
    mkdir $tmpdir;

    ok $tmpdir.IO.e, "got $tmpdir";

    spurt "$tmpdir/project.yml", 'command: ash';

    my $prj = App::Platform::Project.new(:project($tmpdir));

    is $tmpdir, $prj.project-dir, "project dir";
    is $prj.project-file, "$tmpdir/project.yml".IO.absolute, "project file";

    unlink "$tmpdir/project.yml";
    rmdir "$tmpdir";
}

{
    spurt $*HOME.IO.absolute ~ '/.test-10-project-my-project.yml', '';
    my $prj = App::Platform::Project.new(:project('~/.test-10-project-my-project.yml'));
    my $curr-path = $*HOME.IO.absolute;

    is $prj.project-dir, $curr-path, "project dir with ~";
    is $prj.project-file, "$curr-path/.test-10-project-my-project.yml".IO.absolute, "project file with ~";

    "{$*HOME.IO.absolute}/.test-10-project-my-project.yml".IO.unlink;
}
