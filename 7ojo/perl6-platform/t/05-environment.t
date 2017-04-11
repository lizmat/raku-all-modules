use v6.c;
use lib 't/lib';
use Test;
use Template;
use nqp;

plan 8;

constant AUTHOR = ?%*ENV<AUTHOR_TESTING>;

if not AUTHOR {
     skip-rest "Skipping author test";
     exit;
}

my $tmpdir = '.tmp/test-platform-05-environment'.IO.abspath;
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
    $project-dir;
}

sub create-ssh-project(Str $animal) {
    my $project-dir = create-project($animal);
    my $new-dockerfile = q:heredoc/END/;
        FROM nginx:latest
        RUN apt-get update
        RUN apt-get -y install openssh-server
        END
    spurt "$project-dir/docker/Dockerfile", $new-dockerfile;
    my $new-projectyml = q:heredoc/END/;
        command: /bin/bash -c "/etc/init.d/ssh start && nginx -g 'daemon off;'"
        volumes:
            - html:/usr/share/nginx/html:ro
        END
    spurt "$project-dir/docker/project.yml", $new-projectyml;
    $project-dir;
}

my $domain-amazon = 'amazon';
my $domain-sahara = 'sahara';

#
# General setup
#
subtest 'platform create', {
    plan 2;
    my $proc = run <bin/platform>, "--data-path=$tmpdir/.platform", <create>, :out;
    my $out = $proc.out.slurp-rest;
    ok $out ~~ / DNS \s+ \[ \✓ \] /, 'service dns is up';
    ok $out ~~ / Proxy \s+ \[ \✓ \] /, 'service proxy is up';
}

subtest "platform --domain=$domain-sahara ssh keygen", {
    plan 3;
    run <bin/platform>, "--domain=$domain-sahara", "--data-path=$tmpdir/.platform", <ssh keygen>;
    ok "$tmpdir/.platform/$domain-sahara/ssh".IO.e, "<data>/$domain-sahara/ssh exists";
    ok "$tmpdir/.platform/$domain-sahara/ssh/$_".IO.e, "<data>/$domain-sahara/ssh/$_ exists" for <id_rsa id_rsa.pub>;
}

subtest "platform --domain=$domain-amazon ssh keygen", {
    plan 3;
    run <bin/platform>, "--domain=$domain-amazon", "--data-path=$tmpdir/.platform", <ssh keygen>;
    ok "$tmpdir/.platform/$domain-amazon/ssh".IO.e, "<data>/$domain-amazon/ssh exists";
    ok "$tmpdir/.platform/$domain-amazon/ssh/$_".IO.e, "<data>/$domain-amazon/ssh/$_ exists" for <id_rsa id_rsa.pub>;
}

#
# Start 2 projects under *.sahara domain with single command and project's 
# default settings
#
subtest "platform .. --environment=sahara.yml run", {
    plan 4;

    create-project('scorpion');
    create-project('ant');

    my $environment-yml = q:heredoc/END/;
        project-scorpion: true
        project-ant: true
        END

    spurt "$tmpdir/sahara.yml", $environment-yml;

    my $proc = run <bin/platform>, "--domain=sahara", "--environment=$tmpdir/sahara.yml", "--data-path=$tmpdir/.platform", <run>, :out;
    my $out = $proc.out.slurp-rest;
    ok $out ~~ / project\-scorpion \s+ \[ \✓ \] /, "project-scorpion run";
    ok $out ~~ / project\-ant \s+ \[ \✓ \] /, "project-ant run";

    sleep 1.5;

    for <scorpion ant> -> $project {
        $proc = run <docker exec -it platform-proxy getent hosts>, "project-{$project}.sahara", :out;
        $out = $proc.out.slurp-rest;
        my $found = $out.Str.trim ~~ / ^ $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] /;
        ok $found, "got project-$project.sahara ip-address " ~ ($found ?? $/.hash<ip-address> !! '');
    }
}

#
# Start 2 projects under *.amazon domain with single command and override
# project's default settings
#
subtest "platform .. --environment=amazon.yml run", {
    plan 6;

    create-ssh-project('octopus');
    create-ssh-project('blowfish');
    
    my $environment-yml = q:heredoc/END/;
        project-octopus:
            users:
              octonaut:
                system: true
                home: /var/lib/octonaut
                shell: /bin/bash
            dirs:
              /var/lib/octonaut/.ssh:
                owner: octonaut
                group: nogroup
                mode: 0700
            files:
              /var/lib/octonaut/.ssh/id_rsa:
                content: ssh/id_rsa
                owner: octonaut
                group: nogroup
                mode: 0600
        project-blowfish:
            users:
              kwazii:
                shell: /bin/bash
            dirs:
              /home/kwazii/.ssh:
                owner: kwazii
                group: kwazii
                mode: 0700
            files:
              /home/kwazii/.ssh/authorized_keys:
                content: ssh/id_rsa.pub
                owner: kwazii
                group: kwazii
                mode: 0600
        END

    spurt "$tmpdir/amazon.yml", $environment-yml;
    
    my $proc = run <bin/platform>, "--domain=amazon", "--environment=$tmpdir/amazon.yml", "--data-path=$tmpdir/.platform", <run>, :out;
    my $out = $proc.out.slurp-rest;
    ok $out ~~ / project\-octopus \s+ \[ \✓ \] /, "project-octopus run";
    ok $out ~~ / project\-blowfish \s+ \[ \✓ \] /, "project-blowfish run";

    sleep 1.5;

    my %addr;
    for <octopus blowfish> -> $project {
        $proc = run <docker exec -it platform-proxy getent hosts>, "project-{$project}.amazon", :out;
        $out = $proc.out.slurp-rest;
        my $found = $out.Str.trim ~~ / ^ $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] /;
        %addr{$project} = $/.hash<ip-address>;
        ok $found, "got project-$project.amazon ip-address " ~ ($found ?? $/.hash<ip-address> !! '');    
    }

    $proc = run <docker exec -it project-octopus su octonaut --command>, "ssh -o \"StrictHostKeyChecking no\" kwazii\@{%addr<blowfish>} ls /", :out;
    $out = $proc.out.slurp-rest;
    is $out.lines.elems, 21, 'got proper response from ssh connection';

    $proc = run <docker exec -it project-octopus getent hosts project-blowfish.amazon>, :out;
    $out = $proc.out.slurp-rest;
    is $out.trim, %addr<blowfish> ~ '      project-blowfish.amazon', 'got project-blowfish.amazon ip inside container';
}

subtest "platform .. --environment=shara.yml stop|rm", {
    plan 4;
    my $proc = run <bin/platform>, "--environment=$tmpdir/sahara.yml", "--data-path=$tmpdir/.platform", <stop>, :out;
    my $out = $proc.out.slurp-rest;
    ok $out ~~ / project\-scorpion \s+ \[ \✓ \] /, 'project-scorpion stop';
    ok $out ~~ / project\-ant \s+ \[ \✓ \] /, 'project-ant stop';
    $proc = run <bin/platform>, "--environment=$tmpdir/sahara.yml", "--data-path=$tmpdir/.platform", <rm>, :out;
    $out = $proc.out.slurp-rest;
    ok $out ~~ / project\-scorpion \s+ \[ \✓ \] /, 'project-scorpion rm';
    ok $out ~~ / project\-ant \s+ \[ \✓ \] /, 'project-ant rm';
}

subtest "platform .. --environment=amazon.yml stop|rm", {
    plan 4;
    my $proc = run <bin/platform>, "--environment=$tmpdir/amazon.yml", "--data-path=$tmpdir/.platform", <stop>, :out;
    my $out = $proc.out.slurp-rest;
    ok $out ~~ / project\-octopus \s+ \[ \✓ \] /, 'project-octopus stop';
    ok $out ~~ / project\-blowfish \s+ \[ \✓ \] /, 'project-blowfish stop';
    $proc = run <bin/platform>, "--environment=$tmpdir/amazon.yml", "--data-path=$tmpdir/.platform", <rm>, :out;
    $out = $proc.out.slurp-rest;
    ok $out ~~ / project\-octopus \s+ \[ \✓ \] /, 'project-octopus rm';
    ok $out ~~ / project\-blowfish \s+ \[ \✓ \] /, 'project-blowfish rm';
}

run <bin/platform destroy>;
