unit class Net::DNS;

use Net::DNS::Message;
use experimental :pack;

has $.server;
has $.socket;
has $.request-id is rw = 0;

method new($server, $socket = IO::Socket::INET) {
    self.bless(:$server, :$socket);
}

my %types = A     => 1,
            AAAA  => 28,
            CNAME => 5,
            MX    => 15,
            NS    => 2,
            PTR   => 12,
            SPF   => 99,
            SRV   => 33,
            TXT   => 16,
            SOA   => 6,
            AXFR  => 252;
method lookup($type is copy, $host is copy){
    $host ~~ s/\.$//;
    $type = $type.uc;
    my @host = $host.split('.');
    my $message = Net::DNS::Message.new;
    $message.header = Net::DNS::Message::Header.new;
    $message.header.id = (1..65535).pick;
    $message.header.rd = 1;
    $message.header.qdcount = 1;
    my $q = Net::DNS::Message::Question.new;
    $q.qname = @host;
    $q.qtype = %types{$type};
    $q.qclass = 1;
    $message.question.push($q);

    my $outgoing = $message.Buf;
    
    my $client = $.socket.new(:host($.server), :port(53));
    $client.write(pack('n', $outgoing.elems) ~ $outgoing);
    my $inc-size = $client.read(2);
    $inc-size = $inc-size.unpack('n');
    my $incoming = $client.read($inc-size);
    if $type eq 'AXFR' {
        my @responses = gather for Net::DNS::Message.new($incoming).answer.list {
            take $_.rdata-parsed;
        };
        unless @responses[0] ~~ Net::DNS::SOA {
            fail "Domain transfer failed.";
        }
        loop {
            if +@responses > 1 && @responses[*-1] ~~ Net::DNS::SOA {
                return @responses;
            }
            $inc-size = $client.read(2);
            $inc-size = $inc-size.unpack('n');
            $incoming = $client.read($inc-size);
            fail "Domain transfer failed." unless $incoming;
            my $obj = Net::DNS::Message.new($incoming);
            @responses.push(gather for Net::DNS::Message.new($incoming).answer.list { take $_.rdata-parsed; });
        }

        return gather for @responses -> $r {
            for $r.answer.list {
                take $_.rdata-parsed;
            }
        }
    } else {
        $client.close;

        my $inc-message = Net::DNS::Message.new($incoming);

        return gather for $inc-message.answer.list {
            take $_.rdata-parsed;
        }
    }
}

method lookup-ips($host, :$inet, :$inet6, :@loopcheck is copy) {
    my @result;

    die "CNAME loop detected" if @loopcheck.grep(* eq $host);
    die "Too many CNAME redirects" if @loopcheck > 10;
    @loopcheck.push: $host;

    if $inet6 || !$inet {
        my @raw = self.lookup('AAAA', $host);
        for @raw.grep(Net::DNS::AAAA) -> $res {
            unless @result.grep({ $_.owner-name eqv $res.owner-name
                               && $_.octets eqv $res.octets }) {
                @result.append: $res;
            }
        }
        for @raw.grep(Net::DNS::CNAME) -> $res {
            unless @result.grep({ $_.owner-name eqv $res.name}) {
                @result.append: self.lookup-ips($res.name.join('.'), :$inet, :$inet6, :@loopcheck);
            }
        }
    }

    if $inet || !$inet6 {
        my @raw = self.lookup('A', $host);
        for @raw.grep(Net::DNS::A) -> $res {
            unless @result.grep({ $_.owner-name eqv $res.owner-name
                               && $_.octets eqv $res.octets }) {
                @result.append: $res;
            }
        }
        for @raw.grep(Net::DNS::CNAME) -> $res {
            unless @result.grep({ $_.owner-name eqv $res.name}) {
                @result.append: self.lookup-ips($res.name.join('.'), :$inet, :$inet6, :@loopcheck);
            }
        }
    }

    @result;
}

method lookup-mx($host, :$inet, :$inet6) {
    my @result;

    my @raw = self.lookup('MX', $host);
    for @raw.grep(Net::DNS::MX).sort(*.priority) -> $res {
        @result.append: self.lookup-ips($res.name.join('.'), :$inet, :$inet6);
    }

    @result;
}
