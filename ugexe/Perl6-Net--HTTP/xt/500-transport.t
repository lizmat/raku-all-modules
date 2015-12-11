use Test;
plan 3;

use Net::HTTP::Transport;
use Net::HTTP::URL;
use Net::HTTP::Request;

subtest {
    my $url = Net::HTTP::URL.new('http://jigsaw.w3.org/HTTP/ChunkedScript');
    my $req = Net::HTTP::Request.new: :$url, :method<GET>,
        header => :Connection<keep-alive>, :User-Agent<perl6-net-http>;

    my $transport = Net::HTTP::Transport.new;
    my $res       = $transport.round-trip($req);
    my $decoded   = $res.body.decode;

    is $decoded.lines.grep(/^0/).elems, 1000;
    is $decoded.chars, 72200;
}, 'Transfer-Encoding: chunked [IO::Socket::INET]';

subtest {
    my $url = Net::HTTP::URL.new('http://jigsaw.w3.org/HTTP/ChunkedScript');
    my $req = Net::HTTP::Request.new: :$url, :method<GET>,
        header => :Connection<keep-alive>, :User-Agent<perl6-net-http>;

    my $transport = Net::HTTP::Transport.new;
    my $res       = await start { $transport.round-trip($req) };

    is $res.body.decode.lines.grep(/^0/).elems, 1000;
}, 'Threads: start { $transport.round-trip($req) }';


if Net::HTTP::Dialer.?can-ssl {
    subtest {
        my $url = Net::HTTP::URL.new('https://jigsaw.w3.org/HTTP/ChunkedScript');
        my $req = Net::HTTP::Request.new: :$url, :method<GET>,
            header => :Connection<close>, :User-Agent<perl6-net-http>;

        my $transport = Net::HTTP::Transport.new;
        my $res       = $transport.round-trip($req);
        my $decoded   = $res.body.decode;

        is $decoded.lines.grep(/^0/).elems, 1000;
        is $decoded.chars, 72200;
    }, 'Transfer-Encoding: chunked [IO::Socket::SSL]';
}
else {
    ok 1, "Skip: Can't do SSL. Is IO::Socket::SSL available?";
}
