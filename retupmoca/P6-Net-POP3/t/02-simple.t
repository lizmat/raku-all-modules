use v6;
use Test;

plan 6;

class POP3Socket {
    my @server-send =
        "+OK Greeting",
        "-ERR CAPA not supported in this test",
        "+OK USER",
        "+OK PASS",
        "+OK 1 message",
        "1 250",
        ".",
        "+OK 1 thisisauniqueid",
        "+OK message follows",
        "<message text here>",
        ".",
        "+OK QUIT"
    ;
    my @server-get =
        "CAPA",
        "USER bar",
        "PASS barpass",
        "LIST",
        "UIDL 1",
        "RETR 1",
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
        die "Bad client-send: $string" unless $string eq @server-get.shift;
    }
    method close { }
}

use Net::POP3;

my $client = Net::POP3.new(:server('foo.com'), :port(25), :socket(POP3Socket));

ok $client ~~ Net::POP3, "Client created";
ok $client.auth("bar", "barpass"), "Successful auth";
my @messages = $client.get-messages;
ok +@messages == 1, "One message in list";
ok @messages[0].size == 250, "Got correct message size";
ok @messages[0].uid eq 'thisisauniqueid', 'Got a unique ID';
ok @messages[0].data eq '<message text here>', 'Got message data';
$client.quit;

