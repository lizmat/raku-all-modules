#!/usr/bin/env perl6

use v6.c;

#| Start daemon at port
sub MAIN(Int :$port = 3333) {
    my $listen = IO::Socket::INET.new(:listen, :localhost<localhost>, :localport($port));
    loop {
        my $conn = $listen.accept;
        while my $buf = $conn.recv(:bin) {
            my ($path, $exit) = $buf.decode('UTF-8').Str.chop.split(' ');
            require ::('Powerline::Prompt::Shell::Bash');
            my Str $prompt = ::('Powerline::Prompt::Shell::Bash').new(:$path, exit => $exit.Int).draw; 
            $conn.write: $prompt.encode('UTF-8');
            $conn.close;
        }
    }
}
