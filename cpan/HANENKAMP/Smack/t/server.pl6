#!perl6

use HTTP::Server::Smack;

sub MAIN(Int :$port, Str :$app) {
    my $server = HTTP::Server::Smack.new(
        host => 'localhost',
        port => $port,
    );

    my $psgi = $app.IO.slurp;
    my &app  = $psgi.EVAL;

    $server.start;
    say "Starting on http://localhost:$port/...";

    # Start a thread that will close the listener on QUIT/INT
    signal(SIGINT | SIGQUIT).tap: {
        $server.stop;
        exit 0;
    };

    $server.run(&app);
}
