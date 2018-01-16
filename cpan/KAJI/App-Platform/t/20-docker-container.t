use v6;
use lib 'lib';
use lib '../lib';
use Test;
use App::Platform::Docker::Container;

plan 4;

{
    my $test-path = ($*TMPDIR ~ "/test-20-docker-container").IO.resolve.Str;
    mkdir $test-path;
    my %config-data = ();
    %config-data{'volumes'} = [ 'html:/usr/local/nginx/html' ];
    my $container = App::Platform::Docker::Container.new(
        :name('foo'),
        :domain('localhost'),
        :data-path('.'),
        :projectdir($test-path),
        :%config-data
        );
    ok $test-path.Str ne $*CWD.Str, "current working dir IS NOT project dir";
    is $container.volumes[1], "$test-path/html:/usr/local/nginx/html", "got correct volume path from:to";
    rmdir $test-path;
}

{
    my $test-path = ($*TMPDIR ~ "/test-20-docker-container").IO.resolve.Str;
    mkdir $test-path;
    chdir $test-path;
    my %config-data = ();
    %config-data{'volumes'} = [ 'html:/usr/local/nginx/html' ];
    my $container = App::Platform::Docker::Container.new(
        :name('foo'),
        :domain('localhost'),
        :data-path('.'),
        :projectdir($test-path),
        :%config-data
        );
    ok $test-path.Str eq $*CWD.Str, "current working dir IS project dir";
    is $container.volumes[1], "$test-path/html:/usr/local/nginx/html", "got correct volume path from:to";
    rmdir $test-path;
}
