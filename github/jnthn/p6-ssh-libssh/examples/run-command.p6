use SSH::LibSSH;

sub MAIN(Str $host, Str $user, Int :$port = 22, Str :$password, Str :$private-key-file, *@command) {
    my $session = await SSH::LibSSH.connect(:$host, :$user, :$port, :$private-key-file, :$password);
    my $channel = await $session.execute(@command.join(' '));
    my $exit-code;
    react {
        unless $*IN.t {
            whenever $channel.print($*IN.slurp-rest) {
                $channel.close-stdin;
            }
        }
        whenever $channel.stdout(:enc<utf8>) -> $chars {
            $*OUT.print: $chars;
        }
        whenever $channel.stderr(:enc<utf8>) -> $chars {
            $*ERR.print: $chars;
        }
        whenever $channel.exit -> $code {
            $exit-code = $code;
        }
    }
    $channel.close;
    $session.close;
    exit $exit-code;

    CATCH {
        when X::SSH::LibSSH::Error {
            note .message;
            exit 1;
        }
    }
}
