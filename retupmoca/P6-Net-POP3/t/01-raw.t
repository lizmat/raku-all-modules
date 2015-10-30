use v6;
use Test;

plan 10;

class POP3Socket {
    my @server-send =
        "+OK Greeting",
        "+OK USER",
        "+OK PASS",
        "+OK 1 message",
        "1 250",
        ".",
        "+OK QUIT"
    ;
    my @server-get =
        "USER bar",
        "PASS barpass",
        "LIST",
        "QUIT"
    ;

    has $.host;
    has $.port;
    has $.input-line-separator is rw = "\n";
    method new(:$host, :$port){
        self.bless(:$host, :$port);
    }
    method get {
        return @server-send.shift;
    }
    method print($string is copy) {
        $string .= substr(0, *-2); # strip \r\n
        die "Bad client-send" unless $string eq @server-get.shift;
    }
    method close { }
}

use Net::POP3;

ok True, "Module loaded";

my $client = Net::POP3.new(:server('foo.com'), :port(25), :raw, :socket(POP3Socket));

is $client.conn.host, 'foo.com', 'right server';
is $client.conn.port, '25', 'right port';
is $client.conn.input-line-separator, "\r\n", 'right line sep';

ok $client ~~ Net::POP3, "Created raw object";
ok $client.get-response.substr(0,3) eq '+OK', "greeting";
ok $client.user('bar').substr(0,3) eq '+OK', "USER";
ok $client.pass('barpass').substr(0,3) eq '+OK', "PASS";
ok $client.list.substr(0,3) eq '+OK', "LIST";
ok $client.quit.substr(0,3) eq '+OK', "QUIT";
