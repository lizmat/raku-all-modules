use v6.c;
use lib 't/lib';
use Test;
use Template;
use nqp;

plan 14;

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
    
    $proc = run <docker exec files-and-dirs cat /lorem-ipsum.txt>, :out;
    $out = $proc.out.slurp-rest;
    is $out.Str.trim, 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis blandit auctor mollis. Praesent volutpat, dolor quis iaculis sagittis, ex ante rhoncus est, ultricies auctor libero justo sit amet leo. Vestibulum vitae semper quam. Pellentesque feugiat in est non consequat. Sed iaculis eget ex ut cursus. Nam convallis ex tortor, vel vestibulum lectus aliquet sagittis. Aenean elementum odio ut orci elementum rutrum. Aenean id elementum augue, condimentum semper leo.', 'got content /lorem-ipsum.txt';

    $proc = run <docker exec files-and-dirs cat /b/words-from-file.p6>, :out;
    $out = $proc.out.slurp-rest;
    ok $out ~~ / word \s is \s a \s palindrome /, 'got content /b/words-from-file.p6';

    $proc = run <docker exec files-and-dirs cat /code/examples/perl6/hello-world.p6>, :out;
    $out = $proc.out.slurp-rest;
    ok $out ~~ / ^\# /, 'shebang found on /code/examples/perl6/hello-world.p6';
    ok $out ~~ / Hello \s Perl \s 6 \s World /, 'got content /code/examples/perl6/hello-world.p6';
    
    $proc = run <docker exec files-and-dirs ls -la /code/examples/perl6/hello-world.p6>, :out;
    $out = $proc.out.slurp-rest;

    for $out.lines -> $line {
        next if $line ~~ / ^total /;
        my @parts = $line.split(/ \s+ /);
        next if @parts[8] eq '..';
        is @parts[0], '-rwxr-x---', "../hello-world.p6 perm@'{@parts[8]}'";
        is @parts[2], 'nobody', "../hello-world.p6 uid@'{@parts[8]}'";
        is @parts[3], 'nogroup', "../hello-world.p6 gid@'{@parts[8]}'";
    } 

    run <perl6 -Ilib bin/platform --project=examples/files-and-dirs stop>;
    run <perl6 -Ilib bin/platform --project=examples/files-and-dirs rm>;
}
