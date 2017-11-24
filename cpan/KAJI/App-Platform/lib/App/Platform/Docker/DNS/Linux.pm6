use v6;
use JSON::Tiny;
use Terminal::ANSIColor;
use App::Platform::Docker::DNS;
use App::Platform::Output;

class App::Platform::Docker::DNS::Linux does App::Platform::Docker::DNS {

    method start {
        $.hostname = $.name.lc ~ ".{$.domain}";
        my $proc;
        loop (my $port = $.dns-port; $port <= ($.dns-port+10); $port++) {
            $proc = run
                <docker run -d --rm --name>,
                'platform-' ~ self.name.lc,
                ([<--network>, $.network] if $.network-exists),
                <--dns>, '8.8.8.8',
                <--dns>, '8.8.4.4',
                <--env>, "VIRTUAL_HOST={$.hostname}",
                <--env>, "DOMAIN_TLD={self.domain}",
                <--publish>, "$port:53/udp",
                <--volume /var/run/docker.sock:/var/run/docker.sock:ro>,
                <--label dns.tld=localhost>,
                <zetaron/docker-dns-gen>,
                :out, :err;
            self.last-result = self.result-as-hash($proc);
            if $port > 53 and self.last-result<err>.chars == 0 {
                put " {App::Platform::Output.after-prefix}" ~ BOLD, "notice: connected dns to port $port", RESET;
                last;
            } elsif self.last-result<err> ~~ / "address already in use" / {
                put " {App::Platform::Output.after-prefix}" ~ BOLD, "notice: dns port $port was already reserved", RESET;
            }
        }
        sleep 0.1;
        $proc = run <docker inspect>, 'platform-' ~ self.name.lc, :out, :err;
        if (my $err = $proc.err.slurp-rest.trim.lc).chars > 0 {
            put " {App::Platform::Output.after-prefix}" ~ color('red') ~ "docker: $err" ~ color('reset');
        } else {
            my $json = from-json($proc.out.slurp-rest);
            my Str $dns-addr = $.network-exists
                ?? $json[0]{'NetworkSettings'}{'Networks'}{$.network}{'IPAddress'}
                !! $json[0]{'NetworkSettings'}{'IPAddress'};
            my Str $file-resolv-conf = $.data-path ~ "/resolv.conf";
            spurt "$file-resolv-conf", "nameserver $dns-addr";
        }
        
        # If all went fine then check the name if its working
        if $proc.exitcode == 0 {
            my Proc $ping = run <ping -c 1 dns.localhost>, :out, :err;
            self.last-result = self.result-as-hash($ping);
            self.help-hint = q:heredoc/END/;
                dns is not configured properly. try this if you have NetworkManager:
                
                    $ sudo bash -c "echo 'address=/localhost/127.0.0.1' > /etc/NetworkManager/dnsmasq.d/localhost"

                    $ sudo service NetworkManager restart
                
                and try ping again to dns.localhost address like this:
                
                    $ ping dns.localhost
                
                END
        }
        self;
    }

}
