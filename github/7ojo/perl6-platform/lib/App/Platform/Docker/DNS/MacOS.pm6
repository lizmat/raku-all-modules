use v6;
use JSON::Tiny;
use App::Platform::Docker::DNS;

class App::Platform::Docker::DNS::MacOS does App::Platform::Docker::DNS {
    
    method start {
        self.start-in;
        self.start-out;
    }
    
    method stop {
        my $proc = run <docker stop -t 0>, 'platform-' ~ self.name.lc ~ '-in', :out, :err;
        $proc.out.slurp-rest; # TODO: Is this needed still?
        $proc = run <docker stop -t 0>, 'platform-' ~ self.name.lc ~ '-out', :out, :err;
        self.last-result = self.result-as-hash($proc);
        self;
    }

    method start-in {
        my Str $name = $.name.lc ~ '-in';
        my Str $hostname = $name ~ ".{$.domain}";
        my $proc = run
            <docker run -d --rm --name>,
            'platform-' ~ $name,
            ([<--network>, $.network] if $.network-exists),
            <--dns>, '8.8.8.8',
            <--dns>, '8.8.4.4',
            <--env>, "VIRTUAL_HOST={$hostname}",
            <--env>, "DOMAIN_TLD={self.domain}",
            <--volume /var/run/docker.sock:/var/run/docker.sock:ro --label dns.tld=localhost>,
            <zetaron/docker-dns-gen>,
            :out, :err;
        self.last-result = self.result-as-hash($proc);
        sleep 0.1;
        $proc = run <docker inspect>, 'platform-' ~ $name, :out;
        my $json = from-json($proc.out.slurp-rest);
        my Str $dns-addr = $.network-exists 
            ?? $json[0]{'NetworkSettings'}{'Networks'}{$.network}{'IPAddress'}
            !! $json[0]{'NetworkSettings'}{'IPAddress'};
        my Str $file-resolv-conf = $.data-path ~ "/resolv.conf";
        spurt "$file-resolv-conf", "nameserver $dns-addr";
        self;
    }

    method start-out {
        my Str $name = $.name.lc ~ '-out';
        my Str $hostname = $name ~ ".{$.domain}";

        # Launch DNS service for the MacOS
        my Proc $proc = run
            <docker run -d --rm --name>,
            'platform-' ~ $name,
            ([<--network>, $.network] if $.network-exists),
            <--dns>, '8.8.8.8',
            <--dns>, '8.8.4.4',
            <--env>, "VIRTUAL_HOST={$hostname}",
            <--env>, "DOMAIN_TLD={self.domain}",
            <--publish>, "{$.dns-port}:53/udp",
            <--volume /var/run/docker.sock:/var/run/docker.sock:ro>,
            <--label dns.tld=localhost>,
            <zetaron/docker-dns-gen>,
            :out, :err;
        self.last-result = self.result-as-hash($proc);
       
        # Modify DNS service so it will return 127.0.0.1 address for all 
        sleep 0.1;
        run <docker exec>, "platform-$name", <ash -c>, Q[sed -i 's/{{ $network.IP *}}/127.0.0.1/' /etc/dnsmasq.tmpl];

        # If all went fine then check the name if its working
        if $proc.exitcode == 0 {
            my Proc $ping = run <ping -c 1 dns-in.localhost>, :out, :err;
            self.last-result = self.result-as-hash($ping);
            self.help-hint = q:heredoc/END/;
                dns is not configured properly. try this:
                
                    $ sudo sh -c 'echo "nameserver 127.0.0.1" > /etc/resolver/localhost'
                
                and try ping again to dns-in.localhost address like this:
                
                    $ ping dns-in.localhost
                
                END
        }
        
        self;
    }

}
