use v6;
use Test;
use LWP::Simple;

plan 1;

my $sync = Channel.new;
start {
    my $server := IO::Socket::INET.new: :listen,
        :localhost<localhost>, :0localport;
    $sync.send: $server.localport;
    my $client := $server.accept;
    Nil while $client.get.chars;
    $client.print: q:to/END/.trans: ["\n" => "\r\n"];
    HTTP/1.1 200 OK
    Content-Type: text/html; charset=UTF-8

    Hello meows
    Test passed
    END
    $client.close;
    $server.close;
}

my $url := "http://localhost:{$sync.receive}";
is LWP::Simple.get($url), "Hello meows\r\nTest passed\r\n",
    "we pulled whole document without sizing from misbehaved server [$url]";
