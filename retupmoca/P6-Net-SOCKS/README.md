P6-Net-SOCKS
============

A small SOCKS5 client. Currently only supports connection requests.

## Example Usage ##

    use Net::SOCKS;

    my $socket = Net::SOCKS.connect(:host('myhost'), :port(123), :proxy-server('proxy'));

## Methods ##

 -  `connect(:$host!, :$port!, :$proxy-server, :$proxy-port = 1080, :$socket = IO::Socket::INET)`

    Opens a connection to the `$host` via the `$proxy-server`. Returns a ready-to-use
    socket on success, and a Failure otherwise.

    The `$socket` parameter allows you to pass an already-connected handle (in
    which case `$proxy-server` and `$proxy-port` are ignored), or to define an
    alternate socket class to make the connection with.
