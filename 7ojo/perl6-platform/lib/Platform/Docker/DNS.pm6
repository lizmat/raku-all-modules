use v6;
use Platform::Container;
use JSON::Tiny;

class Platform::Docker::DNS is Platform::Container {

    has Str $.name = 'DNS';

    method start {
        $.hostname = $.name.lc ~ ".{$.domain}";
        my $proc = run
            <docker run -d --rm --name>,
            'platform-' ~ self.name.lc,
            ([<--network>, $.network] if $.network-exists),
            <--dns>, '8.8.8.8',
            <--dns>, '8.8.4.4',
            <--env>, "VIRTUAL_HOST={$.hostname}",
            <--env>, "DOMAIN_TLD={self.domain}",
            <--publish 53:53/udp --volume /var/run/docker.sock:/var/run/docker.sock:ro --label dns.tld=localhost>,
            <zetaron/docker-dns-gen>,
            :out, :err;
        self.last-result = self.result-as-hash($proc);
        sleep 0.1;
        $proc = run <docker inspect>, 'platform-' ~ self.name.lc, :out;
        my $json = from-json($proc.out.slurp-rest);
        my Str $dns-addr = $.network-exists 
            ?? $json[0]{'NetworkSettings'}{'Networks'}{$.network}{'IPAddress'}
            !! $json[0]{'NetworkSettings'}{'IPAddress'};
        my Str $file-resolv-conf = $.data-path ~ "/resolv.conf";
        spurt "$file-resolv-conf", "nameserver $dns-addr";
        self;
    }

    method stop {
        my $proc = run <docker stop -t 0>, 'platform-' ~ self.name.lc, :out, :err;
        self.last-result = self.result-as-hash($proc);
        self;
    }

}
