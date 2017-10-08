use Cro;
use Cro::TLS;
use Cro::TCP;
use IO::Socket::Async::SSL;
use Test;

constant TEST_PORT = 31315;
constant %ca := { ca-file => 't/certs-and-keys/ca-crt.pem' };
constant %key-cert := {
    private-key-file => 't/certs-and-keys/server-key.pem',
    certificate-file => 't/certs-and-keys/server-crt.pem'
};

# Type relationships.
ok Cro::TLS::Listener ~~ Cro::Source, 'TLS listener is a source';
ok Cro::TLS::Listener.produces ~~ Cro::TLS::ServerConnection, 'TLS listener produces connections';
ok Cro::TLS::ServerConnection ~~ Cro::Connection, 'TLS connection is a connection';
ok Cro::TLS::ServerConnection ~~ Cro::Replyable, 'TLS connection is replyable';
ok Cro::TLS::ServerConnection.produces ~~ Cro::TCP::Message, 'TLS connection produces TCP messages';
ok Cro::TLS::Connector ~~ Cro::Connector, 'TLS connector is a connector';
ok Cro::TLS::Connector.consumes ~~ Cro::TCP::Message, 'TLS connector consumes TCP messages';
ok Cro::TLS::Connector.produces ~~ Cro::TCP::Message, 'TLS connector produces TCP messages';

# Cro::TLS::Listener
{
    my $lis = Cro::TLS::Listener.new(port => TEST_PORT, |%key-cert);
    is $lis.port, TEST_PORT, 'Listener has correct port';
    dies-ok { await IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca) },
        'Not listening simply by creating the object';

    my $incoming = $lis.incoming;
    ok $incoming ~~ Supply, 'incoming returns a Supply';
    dies-ok { await IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca) },
        'Still not listening as Supply not yet tapped';

    my $server-conns = Channel.new;
    my $tap = $incoming.tap({ $server-conns.send($_) });
    my $client-conn-a;
    lives-ok { $client-conn-a = await IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca) },
        'Listening for connections once the Supply is tapped';
    ok $server-conns.receive ~~ Cro::TLS::ServerConnection,
        'Listener emitted a TLS connection';
    nok $server-conns.poll, 'Only that one connection emitted';
    $client-conn-a.close;

    my $client-conn-b = await IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca);
    ok $server-conns.receive ~~ Cro::TLS::ServerConnection,
        'Listener emitted second connection';
    nok $server-conns.poll, 'Only that one connection emitted';
    $client-conn-b.close;

    $tap.close;
    dies-ok { await IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca) },
        'Not listening after Supply tap closed';
}

# Cro::TLS::ServerConnection and Cro::TCP::Message
{
    my $lis = Cro::TLS::Listener.new(port => TEST_PORT, |%key-cert);
    my $server-conns = Channel.new;
    my $tap = $lis.incoming.tap({ $server-conns.send($_) });
    my $client-conn = await IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca);
    my $client-received = Channel.new;
    $client-conn.Supply(:bin).tap({ $client-received.send($_) });
    my $server-conn = $server-conns.receive;

    my $rec-supply = $server-conn.incoming;
    ok $rec-supply ~~ Supply, 'Connection incoming method returns a Supply';

    my $received = Channel.new;
    $rec-supply.tap({ $received.send($_) });

    $client-conn.write('First packet'.encode('utf-8'));
    my $first-message = $received.receive;
    ok $first-message ~~ Cro::TCP::Message,
        'Received message is a Cro::TCP::Message';
    ok $first-message.data ~~ Blob,
        'Message data is in a Blob';
    is $first-message.data.decode('utf-8'), 'First packet',
        'Message data has correct value';

    $client-conn.write(Blob.new(0xFE, 0xED, 0xBE, 0xEF));
    my $second-message = $received.receive;
    ok $second-message ~~ Cro::TCP::Message,
        'Second received message is a Cro::TCP::Message';
    ok $second-message.data ~~ Blob,
        'Second message data is in a Blob';
    is $second-message.data.list, (0xFE, 0xED, 0xBE, 0xEF),
        'Second message data has correct value';

    my $replier = $server-conn.replier;
    ok $replier ~~ Cro::Sink, 'The TLS connection replier is a Cro::Sink';

    my $fake-replies = Supplier.new;
    my $sinker = $replier.sinker($fake-replies.Supply);
    ok $sinker ~~ Supply, 'Reply sinker returns a Supply';
    lives-ok { $sinker.tap }, 'Can tap that Supply';

    $fake-replies.emit(Cro::TCP::Message.new(data => 'First reply'.encode('utf-8')));
    is $client-received.receive.decode('utf-8'), 'First reply',
        'First TCP::Message reply sent successfully';

    $fake-replies.emit(Cro::TCP::Message.new(data => 'Second reply'.encode('utf-8')));
    is $client-received.receive.decode('utf-8'), 'Second reply',
        'Second TCP::Message reply sent successfully';

    $client-conn.close;
    $tap.close;
}

my class UppercaseTransform does Cro::Transform {
    method consumes() { Cro::TCP::Message }
    method produces() { Cro::TCP::Message }
    method transformer($incoming) {
        supply {
            whenever $incoming -> $message {
                $message.data = $message.data.decode('latin-1').uc.encode('latin-1');
                emit $message;
            }
        }
    }
}

{
    my $listener = Cro::TLS::Listener.new(port => TEST_PORT, |%key-cert);
    my $loud-service = Cro.compose($listener, UppercaseTransform);
    ok $loud-service ~~ Cro::Service,
        'Cro::TLS::Listener and a transform compose to make a service';
    lives-ok { $loud-service.start }, 'Can start the service';

    my $client-conn-a = await IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca);
    my $client-received-a = Channel.new;
    $client-conn-a.Supply(:bin).tap({ $client-received-a.send($_) });
    $client-conn-a.print("Can you hear me?");
    is $client-received-a.receive.decode('latin-1'), "CAN YOU HEAR ME?",
        'Service processes messages (first connection)';

    my $client-conn-b = await IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca);
    my $client-received-b = Channel.new;
    $client-conn-b.Supply(:bin).tap({ $client-received-b.send($_) });
    $client-conn-b.print("I'm over here!");
    is $client-received-b.receive.decode('latin-1'), "I'M OVER HERE!",
        'Service processes messages (second concurrent connection)';

    $client-conn-a.print("No, not there...");
    is $client-received-a.receive.decode('latin-1'), "NO, NOT THERE...",
        'Further messages on first connection processed';
    $client-conn-a.close;

    $client-conn-b.print("Bah, you suck at this");
    is $client-received-b.receive.decode('latin-1'), "BAH, YOU SUCK AT THIS",
        'Second connection fine after first closed';
    $client-conn-b.close;

    lives-ok { $loud-service.stop }, 'Can stop the service';
    dies-ok { await IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca) },
        'Cannot connect to service after it has been stopped';
}

{
    my $source = supply { emit Cro::TCP::Message.new( :data('bbq'.encode('ascii')) ) }
    dies-ok
        {
            react {
                whenever Cro::TLS::Connector.establish(port => TEST_PORT, |%ca, $source) {}
            }
        },
        'Establishing connection dies before service is started';

    my $listener = Cro::TLS::Listener.new(port => TEST_PORT, |%key-cert);
    my $loud-service = Cro.compose($listener, UppercaseTransform);
    $loud-service.start;

    my $responses = Cro::TLS::Connector.establish(port => TEST_PORT, |%ca, $source);
    ok $responses ~~ Supply, 'Connector establish method returns a Supply';
    react {
        whenever $responses -> $message {
            ok $message ~~ Cro::TCP::Message, 'Response supply emits a TCP message';
            is $message.data.decode('ascii'), 'BBQ', 'Response had correct data';
            done;
        }
    }

    $loud-service.stop;
    dies-ok
        {
            react {
                whenever Cro::TLS::Connector.establish(port => TEST_PORT, $source) {}
            }
        },
        'Establishing connection dies once service is stopped';
}

# ALPN
if supports-alpn() {
    my $lis = Cro::TLS::Listener.new(port => TEST_PORT, |%key-cert, alpn => <h2 http/1.1>);
    my $server-conns = Channel.new;
    my $incoming = $lis.incoming;
    my $tap = $incoming.tap({ $server-conns.send($_) });

    {
        my $c = IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca, alpn => <h2>);
        await Promise.anyof($c, Promise.in(5));
        is $c.status, Kept,
            'Can connect to a Cro::TLS::Listener with ALPN set up with ALPN from client';
        is $server-conns.receive.alpn-result, 'h2', 'ALPN negotiated result set on connection';
        $c.result.close;
    }

    {
        my $c = IO::Socket::Async::SSL.connect('localhost', TEST_PORT, |%ca);
        await Promise.anyof($c, Promise.in(5));
        is $c.status, Kept,
            'Can connect to a Cro::TLS::Listener with ALPN set up without ALPN from client';
        nok $server-conns.receive.alpn-result, 'No ALPN negotiation on this connection';
        $c.result.close;
    }

    $tap.close;
} else {
    skip "no alpn support in this TLS version", 4;
}

if supports-alpn() {
    my $listener = Cro::TLS::Listener.new(port => TEST_PORT, |%key-cert, alpn => <h2 http/1.1>);
    my $loud-service = Cro.compose($listener, UppercaseTransform);
    $loud-service.start;

    my class DoubleTransform does Cro::Transform {
        method consumes() { Cro::TCP::Message }
        method produces() { Cro::TCP::Message }
        method transformer($pipeline) {
            supply {
                whenever $pipeline {
                    emit Cro::TCP::Message.new(data => .data ~ .data);
                }
            }
        }
    }

    my $pipeline = Cro.compose(
        Cro::TLS::Connector,
        Cro::ConnectionConditional.new(
            { (.alpn-result // '') eq 'h2' } => [DoubleTransform, DoubleTransform],
            DoubleTransform
        )
    );
    my $source = supply { emit Cro::TCP::Message.new( :data('bbq'.encode('ascii')) ) }
    {
        my $responses = $pipeline.establish(port => TEST_PORT, |%ca, $source);
        react {
            whenever $responses -> $message {
                is $message.data.decode('ascii'), 'BBQBBQ',
                    'When no ALPN outcome, picked default transform';
                done;
            }
        }
    }
    {
        my $responses = $pipeline.establish(port => TEST_PORT, |%ca, alpn => <h2>, $source);
        react {
            whenever $responses -> $message {
                is $message.data.decode('ascii'), 'BBQBBQBBQBBQ',
                    'When correct ALPN outcome, picked conditioned tansform';
                done;
            }
        }
    }

    $loud-service.stop;
} else {
    skip "no alpn support in this TLS version", 2;
}

done-testing;
