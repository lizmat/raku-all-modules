use v6;

use Smack::Handler;

unit class Smack::Handler::HTTP::Easy
does Smack::Handler;

use HTTP::Easy::PSGI;

has $.http = HTTP::Easy::PSGI.new(
    host => $!host,
    port => $!port,
);

method run(&app) {
    say "Starting on http://$!host:$!port/...";
    $!http.handle(&app)
}
