use v6.c;
use lib 't/lib';
use Test;
use Template;
use nqp;

plan 7;

constant AUTHOR = ?%*ENV<AUTHOR_TESTING>;

if not AUTHOR {
     skip-rest "Skipping author test";
     exit;
}

my $tmpdir = '.tmp/test-platform-03-setup'.IO.absolute;
run <rm -rf>, $tmpdir if $tmpdir.IO.e;
mkdir $tmpdir;

ok $tmpdir.IO.e, "got $tmpdir";

sub create-project(Str $animal) {
    my $project-dir = $tmpdir ~ "/project-" ~ $animal.lc;
    my %project =
        title => "Project " ~ nqp::getstrfromname($animal.uc),
        name => "project-" ~ $animal.lc
    ;
    mkdir "$project-dir/docker";
    spurt "$project-dir/docker/Dockerfile", docker-dockerfile(%project);
    my $project-yml = q:heredoc/END/;
        command: nginx -g 'daemon off;'
        volumes:
            - html:/usr/share/nginx/html:ro
        END
    spurt "$project-dir/docker/project.yml", $project-yml;
    mkdir "$project-dir/html";
    spurt "$project-dir/html/index.html", html-welcome(%project);
}

create-project('butterfly');

subtest 'platform create', {
    plan 6;
    my $proc = run <bin/platform>, "--data-path=$tmpdir/.platform", <create>, :out;
    my $out = $proc.out.slurp-rest;

    ok $out ~~ / DNS \s+ \[ \✓ \] /, 'service dns is up';
    ok $out ~~ / Proxy \s+ \[ \✓ \] /, 'service proxy is up';

    sleep 0.5;

    $proc = run <host dns.localhost localhost>, :out;
    $out = $proc.out.slurp-rest;
    my %addr;
    my $found = $out.lines[*-1] ~~ / address \s $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] $$ /;
    ok $found, 'got dns.localhost ip-address ' ~ ($found ?? $/.hash<ip-address> !! '');
    %addr<dns> = $/.hash<ip-address>;

    $proc = run <host proxy.localhost localhost>, :out;
    $out = $proc.out.slurp-rest;
    $found = $out.lines[*-1] ~~ / address \s $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] $$ /;
    ok $found, 'got proxy.localhost ip-address ' ~ ($found ?? $/.hash<ip-address> !! '');
    %addr<proxy> = $/.hash<ip-address>;

    ok "$tmpdir/.platform/resolv.conf".IO.e, '<data-path>/resolv.conf exists';

    $proc = run <docker exec -it platform-proxy getent hosts dns.localhost>, :out;
    $out = $proc.out.slurp-rest;
    ok $out.trim ~~ / \d+\.\d+\.\d+\.\d+ \s+ dns.localhost /, 'got ip from dns inside container';
}

subtest 'platform ssl genrsa', {
    plan 4;
    my $proc = run <bin/platform>, "--data-path=$tmpdir/.platform", <ssl genrsa>, :out, :err;
    my $out = $proc.out.slurp-rest;
    my $err = $proc.err.slurp-rest;

    ok "$tmpdir/.platform/localhost".IO.e, '<data>/localhost exists';
    ok "$tmpdir/.platform/localhost/ssl".IO.e, '<data>/localhost/ssl exists';
    for <server-key.key server-key.crt> -> $file {
        ok "$tmpdir/.platform/localhost/ssl/$file".IO.e, "<data>/localhost/ssl/$file exists";
    }
}

subtest 'platform ssh keygen', {
    plan 3;
    run <bin/platform>, "--data-path=$tmpdir/.platform", <ssh keygen>;
    ok "$tmpdir/.platform/localhost/ssh".IO.e, '<data>/localhost/ssh exists';
    ok "$tmpdir/.platform/localhost/ssh/$_".IO.e, "<data>/localhost/ssh/$_ exists" for <id_rsa id_rsa.pub>;
}

subtest 'platform run|stop|start|rm project-butterfly', {
    plan 4;
    my $proc = run <bin/platform>, "--project=$tmpdir/project-butterfly", "--data-path=$tmpdir/.platform", <run>, :out;
    ok $proc.out.slurp-rest.Str ~~ / butterfly \s+ \[ \✓ \] /, 'project butterfly is up';

    sleep 0.5; # wait project to start

    $proc = run <host project-butterfly.localhost localhost>, :out;
    my $out = $proc.out.slurp-rest;
    my $found = $out.lines[*-1] ~~ / address \s $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] $$ /;
    ok $found, 'got ip-address ' ~ ($found ?? $/.hash<ip-address> !! '');

    run <bin/platform>, "--project=$tmpdir/project-butterfly", "--data-path=$tmpdir/.platform", <stop>;

    $proc = run <bin/platform>, "--project=$tmpdir/project-butterfly", "--data-path=$tmpdir/.platform", <start>, :out;
    $out = $proc.out.slurp-rest;
    ok $out ~~ / butterfly \s+ \[ \✓ \] /, 'project butterfly is up';

    run <bin/platform>, "--project=$tmpdir/project-butterfly", "--data-path=$tmpdir/.platform", <stop>;

    run <bin/platform>, "--project=$tmpdir/project-butterfly", "--data-path=$tmpdir/.platform", <rm>;

    $proc = run <bin/platform>, "--project=$tmpdir/project-butterfly", "--data-path=$tmpdir/.platform", <rm>, :out;
    ok $proc.out.slurp-rest.Str ~~ / No \s such \s container /, 'got error message'
}

create-project('snail');

subtest 'platform run butterfly|snail', {
    plan 4;
    for <butterfly snail> -> $project {
        my $proc = run <bin/platform>, "--project=$tmpdir/project-$project", "--data-path=$tmpdir/.platform", <run>, :out;
        ok $proc.out.slurp-rest.Str ~~ / $project \s+ \[ \✓ \] /, "project $project is up";
    }

    sleep 1.5; # wait projects to start

    for <butterfly snail> -> $project {
        my $proc = run <host>, 'project-' ~ $project ~ '.localhost', <localhost>, :out;
        my $out = $proc.out.slurp-rest;
        my $found = $out.lines[*-1] ~~ / address \s $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] $$ /;
        ok $found, 'got ip-address ' ~ ($found ?? $/.hash<ip-address> !! '') ~ " for $project";
    }
}

subtest 'platform stop|rm butterfly|snail', {
    plan 2;
    for <butterfly snail> -> $project {
        run <bin/platform>, "--project=$tmpdir/project-$project", "--data-path=$tmpdir/.platform", <stop>;
        run <bin/platform>, "--project=$tmpdir/project-$project", "--data-path=$tmpdir/.platform", <rm>;
        ok 1, "stop+rm for project $project";
    }
}

run <bin/platform destroy>;

