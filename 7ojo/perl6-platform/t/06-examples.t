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

my $tmpdir = '.tmp/test-platform-06-examples'.IO.abspath;
run <rm -rf>, $tmpdir if $tmpdir.IO.e;
mkdir $tmpdir;

ok $tmpdir.IO.e, "got $tmpdir";

{
    my $proc = run <perl6 -Ilib bin/platform --project=examples/files-and-dirs run>, :out;
    my $out = $proc.out.slurp-rest;
    $proc = run <docker exec files-and-dirs ls -la /foo>, :out;
    $out = $proc.out.slurp-rest;
    for $out.lines -> $line {
        next if $line ~~ / ^total /;
        # drwxr-xr-x    1 root     root          4096 Apr 19 11:33 ..
        my @parts = $line.split(/ \s+ /);
        next if @parts[8] eq '..';
        is @parts[0], 'drwxr-xr-x', "/foo perm@'{@parts[8]}'";
        is @parts[2], 'root', "/foo uid@'{@parts[8]}'";
        is @parts[3], 'root', "/foo gid@'{@parts[8]}'";
    }
 
    $proc = run <docker exec files-and-dirs ls -la /bar>, :out;
    $out = $proc.out.slurp-rest;
    for $out.lines -> $line {
        next if $line ~~ / ^total /;
        my @parts = $line.split(/ \s+ /);
        next if @parts[8] eq '..';
        is @parts[0], 'drwxrwx---', "/bar perm@'{@parts[8]}'";
        is @parts[2], 'nobody', "/bar uid@'{@parts[8]}'";
        is @parts[3], 'nogroup', "/bar gid@'{@parts[8]}'";
    } 
    
    run <perl6 -Ilib bin/platform --project=examples/files-and-dirs stop>;
    run <perl6 -Ilib bin/platform --project=examples/files-and-dirs rm>;
}
