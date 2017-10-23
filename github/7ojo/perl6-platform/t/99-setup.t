use v6.c;
use lib 't/lib';
use Test;
use Template;
use nqp;

plan 3;

constant DOCKER = ( ( run <docker --version>, :out, :err ).out.slurp ~~ / ^ Docker / ).Bool;

if not DOCKER {
     skip-rest "Skipping tests because docker is not available";
     exit;
}

my $data-dir = '.tmp/test-platform-99-setup'.IO.absolute;
run <rm -rf>, $data-dir if $data-dir.IO.e;
mkdir $data-dir;

ok $data-dir.IO.e, "got data-dir=$data-dir";

sub create-project(Str $animal) {
    my $project-dir = $data-dir ~ "/project-" ~ $animal.lc;
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
    plan 5;
    my ($proc, $out, $docker-ps, $docker-out, $versus, $dns-name, $found, %addr);

    $proc = run <bin/platform>, "--data-path=$data-dir/.platform", <create>, :out;
    $out = $proc.out.slurp-rest;

    require Platform::Util::OS;
    if 'linux' eq Platform::Util::OS.detect() {
        $versus = "platform-dns\nplatform-proxy";
        $dns-name = "dns.localhost";
    } else {
        $versus = "platform-dns-in\nplatform-dns-out\nplatform-proxy";
        $dns-name = "dns-in.localhost";
    }

    $out = ( shell Q:w{docker ps --format "table {{.Names}}"}, :out ).out.slurp.lines.skip(1).sort.join("\n");
    is $out, $versus, 'dns and proxy services are up';

    sleep 0.5;
    
    # Is proxy setup ok?
    $proc = run <docker exec -it platform-proxy getent hosts proxy.localhost>, :out;
    $out = $proc.out.slurp-rest;

    $found = $out ~~ / $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] /;
    ok $found, 'got proxy.localhost ip-address ' ~ ($found ?? $/.hash<ip-address> !! '');
    %addr<proxy> = $/.hash<ip-address>;

    # Is dns setup ok?
    $proc = run <docker exec -it platform-proxy getent hosts>, $dns-name, :out;
    $out = $proc.out.slurp-rest;
    $found = $out ~~ / $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] /;
    
    ok $found, "got $dns-name ip-address " ~ ($found ?? $/.hash<ip-address> !! '');
    %addr<dns> = $/.hash<ip-address>;

    # Is platform dns profile config ok?
    ok "$data-dir/.platform/resolv.conf".IO.e, '<data-dir>/resolv.conf exists';
    is "$data-dir/.platform/resolv.conf".IO.slurp.trim, "nameserver %addr<dns>", "<data-dir>/resolv.conf contents";
}

#`(

subtest 'platform ssl genrsa', {
    plan 4;
    my $proc = run <bin/platform>, "--data-path=$data-dir/.platform", <ssl genrsa>, :out, :err;
    my $out = $proc.out.slurp-rest;
    my $err = $proc.err.slurp-rest;

    ok "$data-dir/.platform/localhost".IO.e, '<data>/localhost exists';
    ok "$data-dir/.platform/localhost/ssl".IO.e, '<data>/localhost/ssl exists';
    for <server-key.key server-key.crt> -> $file {
        ok "$data-dir/.platform/localhost/ssl/$file".IO.e, "<data>/localhost/ssl/$file exists";
    }
}

subtest 'platform ssh keygen', {
    plan 3;
    run <bin/platform>, "--data-path=$data-dir/.platform", <ssh keygen>;
    ok "$data-dir/.platform/localhost/ssh".IO.e, '<data>/localhost/ssh exists';
    ok "$data-dir/.platform/localhost/ssh/$_".IO.e, "<data>/localhost/ssh/$_ exists" for <id_rsa id_rsa.pub>;
}

subtest 'platform run|stop|start|rm project-butterfly', {
    plan 4;
    my $proc = run <bin/platform>, "--project=$data-dir/project-butterfly", "--data-path=$data-dir/.platform", <run>, :out;
    ok $proc.out.slurp-rest.Str ~~ / butterfly \s+ \[ \✓ \] /, 'project butterfly is up';

    sleep 0.5; # wait project to start

    $proc = run <host project-butterfly.localhost localhost>, :out;
    my $out = $proc.out.slurp-rest;
    my $found = $out.lines[*-1] ~~ / address \s $<ip-address> = [ \d+\.\d+\.\d+\.\d+ ] $$ /;
    ok $found, 'got ip-address ' ~ ($found ?? $/.hash<ip-address> !! '');

    run <bin/platform>, "--project=$data-dir/project-butterfly", "--data-path=$data-dir/.platform", <stop>;

    $proc = run <bin/platform>, "--project=$data-dir/project-butterfly", "--data-path=$data-dir/.platform", <start>, :out;
    $out = $proc.out.slurp-rest;
    ok $out ~~ / butterfly \s+ \[ \✓ \] /, 'project butterfly is up';

    run <bin/platform>, "--project=$data-dir/project-butterfly", "--data-path=$data-dir/.platform", <stop>;

    run <bin/platform>, "--project=$data-dir/project-butterfly", "--data-path=$data-dir/.platform", <rm>;

    $proc = run <bin/platform>, "--project=$data-dir/project-butterfly", "--data-path=$data-dir/.platform", <rm>, :out;
    ok $proc.out.slurp-rest.Str ~~ / No \s such \s container /, 'got error message'
}

create-project('snail');

subtest 'platform run butterfly|snail', {
    plan 4;
    for <butterfly snail> -> $project {
        my $proc = run <bin/platform>, "--project=$data-dir/project-$project", "--data-path=$data-dir/.platform", <run>, :out;
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
        run <bin/platform>, "--project=$data-dir/project-$project", "--data-path=$data-dir/.platform", <stop>;
        run <bin/platform>, "--project=$data-dir/project-$project", "--data-path=$data-dir/.platform", <rm>;
        ok 1, "stop+rm for project $project";
    }
}

)#

subtest 'platform destroy', {
    plan 1;
    run <bin/platform destroy>;
    my $out = ( shell Q:w{docker ps --format "table {{.Names}}"}, :out ).out.slurp.lines.skip(1).sort.join("\n");
    is $out, '', 'dns and proxy services are down';
}

