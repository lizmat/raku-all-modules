use v6;
use Platform::Container;

class Platform::Docker::Proxy is Platform::Container {

    has Str $.name = 'Proxy';

    method start {
        $.hostname = $.name.lc ~ ".{$.domain}";
        my $proc = run
            <docker run -d --rm --name>,
            'platform-' ~ $.name.lc,
            ([<--network>, $.network] if $.network-exists),
            <--dns>, $.dns,
            <--env>, "VIRTUAL_HOST={$.hostname}",
            <--publish 80:80 --volume /var/run/docker.sock:/tmp/docker.sock:ro>,
            <jwilder/nginx-proxy>,
            :out, :err;
        self.last-result = self.result-as-hash($proc);
        self;
    }

    method stop {
        my $proc = run <docker stop -t 0>, 'platform-' ~ $.name.lc, :out, :err;
        self.result-as-hash($proc);
    }

}
