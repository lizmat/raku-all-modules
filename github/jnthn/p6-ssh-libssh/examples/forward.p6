use SSH::LibSSH;

# To try this out, connect to an SSH server and put in a forwarding target and
# a local port to listen on:
#   perl6 examples/forward.p6 your.ssh.host youruser www.bash.org 80 8888
# You can then access it through the tunnel:
#   curl -v -H "Host: www.bash.org" http://127.0.0.1:8888/

sub MAIN(Str $host, Str $user, Str $remote-host, Int $remote-port, Int $local-port,
         Int :$port = 22, Str :$password, Str :$private-key-file) {
    my $session = await SSH::LibSSH.connect(:$host, :$user, :$port, :$private-key-file, :$password);
    react {
        whenever IO::Socket::Async.listen('127.0.0.1', $local-port) -> $connection {
            whenever $session.forward($remote-host, $remote-port,
                                      '127.0.0.1', $local-port) -> $channel {
                whenever $connection.Supply(:bin) {
                    $channel.write($_);
                    LAST $channel.close;
                }
                whenever $channel.Supply(:bin) {
                    $connection.write($_);
                    LAST $connection.close;
                }
            }
        }

        whenever signal(SIGINT) {
            say "Shutting down...";
            $session.close;
            done;
        }
    }
}
