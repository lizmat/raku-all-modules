use SSH::LibSSH;

# To try this out, run some local HTTP server on your machine. If it's on
# port 8080 then do:
#   perl6 examples/reverse-forward.p6 your.ssh.host youruser 8888 8080
# Now on that remote host, do:
#   curl http://127.0.0.1:8888/
# And it will tunnel the request to your local HTTP server.

sub MAIN(Str $host, Str $user, Int $remote-port, Int $local-port,
         Int :$port = 22, Str :$password, Str :$private-key-file) {
    my $session = await SSH::LibSSH.connect(:$host, :$user, :$port, :$private-key-file, :$password);
    react {
        whenever $session.reverse-forward($remote-port) -> $channel {
            whenever IO::Socket::Async.connect('localhost', $local-port) -> $connection {
                whenever $channel.Supply(:bin) {
                    $connection.write($_);
                    LAST $connection.close;
                }
                whenever $connection.Supply(:bin) {
                    $channel.write($_);
                    LAST $channel.close;
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
