use v6;
use App::Platform::Container;
use App::Platform::Docker::Command;

class App::Platform::Docker::Proxy is App::Platform::Container {

    has Str $.name = 'Proxy';
    has Str $.projectdir = 'service/proxy';

    method start {
        $.hostname = $.name.lc ~ ".{$.domain}";
        my $proc = App::Platform::Docker::Command.new(
            <docker run -d --rm --name>,
            'platform-' ~ $.name.lc,
            ([<--network>, $.network] if $.network-exists),
            <--dns>, $.dns,
            <--env>, "VIRTUAL_HOST={$.hostname}",
            <--publish 80:80 --volume /var/run/docker.sock:/tmp/docker.sock:ro>,
            <jwilder/nginx-proxy:alpine>)
            .run;
        self.last-result = self.result-as-hash($proc);
        self;
    }

    method stop {
        my $proc = run <docker stop -t 0>, 'platform-' ~ $.name.lc, :out, :err;
        self.result-as-hash($proc);
    }

}
