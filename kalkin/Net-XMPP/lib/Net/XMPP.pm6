unit class Net::XMPP;

use Net::XMPP::IQ;
use Net::XMPP::Presence;
use Net::XMPP::Message;

use Net::DNS;
use MIME::Base64;
use XML;

has $!socket;
has $.jid;
has $.jid-local;
has $.jid-domain;
has $.jid-resource;

method new(:$jid!, :$login, :$password, :$server, :$port = 5222, :$socket) {
    self.bless(:$jid, :$login, :$password, :$server, :$port, :$socket);
}

method get-stanza {
    my $xml = self!get-raw-stanza;
    if $xml.root.name eq 'iq' {
        return Net::XMPP::IQ.new(
            :from($xml.root.attribs<from>),
            :to($xml.root.attribs<to>),
            :id($xml.root.attribs<id>),
            :type($xml.root.attribs<type>),
            :body($xml.nodes));
    } elsif $xml.root.name eq 'message' {
        return Net::XMPP::Message.new(
            :from($xml.root.attribs<from>),
            :to($xml.root.attribs<to>),
            :id($xml.root.attribs<id>),
            :type($xml.root.attribs<type>),
            :body($xml.nodes));
    } elsif $xml.root.name eq 'presence' {
        return Net::XMPP::Presence.new(
            :from($xml.root.attribs<from>),
            :to($xml.root.attribs<to>),
            :id($xml.root.attribs<id>),
            :type($xml.root.attribs<type>),
            :body($xml.nodes));
    }
}

method send-stanza($stanza) {
    $!socket.print(~$stanza);
}

submethod BUILD(:$!jid, :$login is copy, :$password, :$server, :$port, :$!socket){
    ($!jid-local, $!jid-domain) = $!jid.split("@");
    $login = $!jid-local unless $login;
    unless $!socket {
        if $server {
            $!socket = IO::Socket::INET.new(:host($server), :$port);
        } else {
            my $resolver = Net::DNS.new("8.8.8.8");
            my @records = $resolver.lookup('SRV', $!jid-domain);
            if @records {
                @records = @records.sort(*.priority <=> *.priority);
                $!socket = IO::Socket::INET.new(:host(@records[0].Str),
                                                :port(@records[0].port));
            } else {
                $!socket = IO::Socket::INET.new(:host($!jid-domain), :$port);
            }
        }
    }
    self!do-negotiation($login, $password);
}

method !do-negotiation($login, $password) {
    my $done = False;
    until $done {
        self!start-streams;
        my $xml = self!get-raw-stanza;
        unless $xml.root.name eq 'stream:features' {
            die "confused";
        }

        my $action = False;
        for $xml.root.nodes -> $feature {
            if $feature.name eq 'mechanisms' {
                my $success = False;
                for $feature.nodes {
                    if .contents.join ~~ /^\s*PLAIN\s*$/ {
                        my $encoded = MIME::Base64.encode-str("\0$login\0$password");
                        $!socket.print("<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl'"
                                     ~" mechanism='PLAIN'>{$encoded}</auth>");
                        my $resp = self!get-raw-stanza;
                        unless $resp.root.name eq 'success' {
                            die "Auth failed.";
                        }
                        $success = True;
                    }
                }
                die "Can't do any server-supported mechanisms" unless $success;
                $action = True;
                last;
            } elsif $feature.name eq 'bind' {
                self.send-stanza(Net::XMPP::IQ.new(:type('set'),
                                                   :id(1),
                                                   :body("<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/>")));
                my $response = self.get-stanza;
                if $response ~~ Net::XMPP::IQ
                   && $response.body[0].name eq 'bind'
                   && $response.body[0].nodes[0].name eq 'jid' {
                    $!jid = $response.body[0].nodes[0].contents.join.trim;
                    ($!jid-local, $!jid-domain, $!jid-resource) = $!jid.split(/\@|\//);
                } else {
                    die "Bind failed."
                }

                $done = True;
                $action = True;
                last;
            } elsif $feature.nodes[0] && $feature.nodes[0].name eq 'required' {
                die "Can't do feature '{$feature.name}', yet it is required";
            }
        }
        last unless $action;
    }
}

method !start-streams {
    # send our stream open
    $!socket.print("<?xml version='1.0'?>\n");
    $!socket.print("<stream:stream\n"
                 ~" from='$!jid'\n"
                 ~" to='$!jid-domain'\n"
                 ~" version='1.0'\n"
                 ~" xml:lang='en'\n"
                 ~" xmlns='jabber:client'\n"
                 ~" xmlns:stream='http://etherx.jabber.org/streams'>\n");

    # get server stream startup
    my $check = "<?xml version='1.0'?>";
    my $check2 ="<?xml version=\"1.0\"?>";
    my $xmlv = $!socket.recv($check.chars);
    unless $xmlv eq $check|$check2 {
        die "...";
    }

    my $buffer;
    my $last = '';
    while $last ne '>' {
        $last = $!socket.recv(1);
        $buffer ~= $last;
    }

    my $xml = from-xml($buffer ~ "</stream:stream>");
    # check things...
}

method !get-raw-stanza {
    my $stanza;
    my $line;
    loop {
        $line = '';
        while $line ne '>' {
            $line = $!socket.recv(1);
            $stanza ~= $line;
        }

        if $stanza ~~ /^\s*\<\/stream\:stream\>/ {
            die "Connection closed";
        }

        try {
            my $xml = from-xml($stanza);
            return $xml;
        }
    }
}

=begin pod

=head1 NAME

Net::XMPP - an XMPP client module

=head1 SYNOPSIS

  use Net::XMPP;

=head1 DESCRIPTION

Currently does the initial connection for you, and then allows you to send and
receive stanzas.

=end pod
