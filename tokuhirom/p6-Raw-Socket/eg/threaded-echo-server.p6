use v6;
use NativeCall;

use Raw::Socket::INET;

# threaded echo server.

# -------------------------------------------------------------------------

sub info($msg as Str) {
    say "[{$*THREAD.id}] $msg";
}


# -------------------------------------------------------------------------

class Echod {
    has @!threads;
    has $!sock;
    has $!channel;

    method listen($port) {
        $!sock = Raw::Socket::INET.new(
            listen => 60,
            localport => $port,
            reuseaddr => True,
        );
    }

    method spawn-child() {
        while (1) {
            info "receive";
            my $csock = $!channel.receive;

            info "clientfd: $csock";
            # say inet_ntoa($client_addr.sin_addr);
            # say ntohs($client_addr.sin_port);

            my $buf = buf8.new;
            $buf[100-1] = 0; # extend buffer

            loop {
                my $readlen = $csock.recv($buf, 100, 0);
                if ($readlen <= 0) {
                    info("closed");
                    $csock.close();
                    last;
                }
                my $sent = $csock.send($buf.subbuf(0, $readlen), 0);
            }
        }
    }

    method run($n) {
        $!channel = Channel.new;

        for 1..$n {
            @!threads.push(start {
                self.spawn-child();
            });
        }

        while my $csock = $!sock.accept {
            $!channel.send($csock);
        }
    }
}

my $port = @*ARGS.elems > 0 ?? @*ARGS[0].Int !! 9800;

say "listening $port";

my $echod = Echod.new();
$echod.listen($port);
$echod.run(10);

