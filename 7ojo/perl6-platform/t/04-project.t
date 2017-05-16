use v6.c;
use lib 't/lib';
use Test;
use Template;
use nqp;

plan 5;

constant AUTHOR = ?%*ENV<AUTHOR_TESTING>;

if not AUTHOR {
     skip-rest "Skipping author test";
     exit;
}

my $tmpdir = '.tmp/test-platform-04-project'.IO.absolute;
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
    my $dockerfile = q:heredoc/END/;
        FROM nginx:latest
        END
    spurt "$project-dir/docker/Dockerfile", $dockerfile;
    my $project-yml = q:heredoc/END/;
        # command: nginx -g 'daemon off;'
        # volumes:
        #     - html:/usr/share/nginx/html:ro
        type: systemd
        command: /sbin/init
        environment:
          - GIT_BRANCH=$(GIT_BRANCH)
        build:
          - build-arg SYSTEMD=0
        volumes:
          # <from>:<to> if <from> is empty, defaults to root e.g. '.'
          - :/var/www/app
          - html:/usr/share/nginx/local:ro
        users:
          platorc:
            system: true
            home: /var/lib/auth/platorc
        dirs:
          /var/lib/auth/platorc/.ssh:
            owner: platorc
            group: nogroup
            mode: 0700
        files:
          /etc/sudoers.d/app-installer: |
            platorc ALL=(www-data:www-data) NOPASSWD: /var/www/app/bin/installer
          /var/lib/auth/platorc/.ssh/authorized_keys:
            content: ssh/id_rsa.pub
            owner: platorc
            group: nogroup
            mode: 0600
          # <target>: <content>
          /var/www/app/config:
            volume: true
            readonly: true
            content: |
              <?php
              $hello = "こんにちは!";
          /etc/install.ini: |
            foo
            bar
            kaa
          /etc/foo/bar/config.ini: |
            [default]
            host = project-honeybee.localhost
            
            [ui.project-honeybee.localhost]
            path = /var/www/app/ui
        END
    spurt "$project-dir/docker/project.yml", $project-yml;
    mkdir "$project-dir/html";
    spurt "$project-dir/html/index.html", html-welcome(%project);
    spurt "$project-dir/config", '<?php $hello = "Hello world!"';
    my $proc = run <git init>, $project-dir, :out;
    my $out = $proc.out.slurp-rest;
}

create-project('honeybee');

subtest 'platform create', {
    plan 2;
    my $proc = run <bin/platform>, "--data-path=$tmpdir/.platform", <create>, :out;
    my $out = $proc.out.slurp-rest;
    ok $out ~~ / DNS \s+ \[ \✓ \] /, 'service dns is up';
    ok $out ~~ / Proxy \s+ \[ \✓ \] /, 'service proxy is up';
}

subtest 'platform ssh keygen', {
    plan 3;
    run <bin/platform>, "--data-path=$tmpdir/.platform", <ssh keygen>;
    ok "$tmpdir/.platform/localhost/ssh".IO.e, '<data>/localhost/ssh exists';
    ok "$tmpdir/.platform/localhost/ssh/$_".IO.e, "<data>/localhost/ssh/$_ exists" for <id_rsa id_rsa.pub>;
}

subtest 'platform run', {
    plan 8;
    my $proc = run <bin/platform>, "--project=$tmpdir/project-honeybee", "--data-path=$tmpdir/.platform", <run>, :out;
    my $out = $proc.out.slurp-rest.Str;
    ok $out ~~ / honeybee \s+ \[ \✓ \] /, 'project honeybee is up';

    sleep 1.5; # wait project to start

    $proc = run <host project-honeybee.localhost localhost>, :out;
    $out = $proc.out.slurp-rest;
    my $found = $out.lines[*-1] ~~ / address \s $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] $$ /;
    ok $found, 'got ip-address ' ~ ($found ?? $/.hash<ip-address> !! '');

    $proc = run <docker exec -it project-honeybee cat /var/lib/auth/platorc/.ssh/authorized_keys>, :out;
    my $id_rsa_pub = "$tmpdir/.platform/localhost/ssh/id_rsa.pub".IO.slurp;
    is $proc.out.slurp-rest.Str.trim, $id_rsa_pub.Str.trim, 'id_rsa.pub contents';
    
    $proc = run <docker exec -it project-honeybee cat /etc/sudoers.d/app-installer>, :out;
    my Str $content = 'platorc ALL=(www-data:www-data) NOPASSWD: /var/www/app/bin/installer';
    is $proc.out.slurp-rest.Str.trim, $content.trim, 'file /etc/sudoers.d/app-installer';

    $proc = run <docker exec -it project-honeybee cat /var/www/app/config>, :out;
    $content = q:heredoc/END/;
        <?php
        $hello = "こんにちは!";
        END
    is $proc.out.slurp-rest.Str.trim, $content.trim, 'file /var/www/app/config';
    
    $proc = run <docker exec -it project-honeybee cat /etc/install.ini>, :out;
    $content = q:heredoc/END/;
        foo
        bar
        kaa
        END
    is $proc.out.slurp-rest.Str.trim, $content.trim, 'file /etc/install.ini';
    
    $proc = run <docker exec -it project-honeybee cat /etc/foo/bar/config.ini>, :out;
    $content = q:heredoc/END/;
        [default]
        host = project-honeybee.localhost
        
        [ui.project-honeybee.localhost]
        path = /var/www/app/ui
        END
    is $proc.out.slurp-rest.Str.trim, $content.trim, 'file /etc/install.ini';

    $proc = run <docker exec -it project-honeybee bash -c set>, :out;
    my %vars;
    $proc.out.lines.map({ my ($key, $val) = .split('='); %vars{$key} = $val });
    is %vars{'GIT_BRANCH'}, 'HEAD', 'env variable GIT_BRANCH=HEAD is set';
}


subtest 'platform stop|rm honeybee', {
    plan 1;
    for <honeybee> -> $project {
        run <bin/platform>, "--project=$tmpdir/project-$project", "--data-path=$tmpdir/.platform", <stop>;
        run <bin/platform>, "--project=$tmpdir/project-$project", "--data-path=$tmpdir/.platform", <rm>;
        ok 1, "stop+rm for project $project";
    }
}

run <bin/platform destroy>;

