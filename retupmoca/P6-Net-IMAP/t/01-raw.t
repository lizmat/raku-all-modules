use v6;
use Test;

plan 8;

class IMAPSocket {
    my @server-send =
        "* OK Ready",
        "* CAPABILITY IMAP4rev1 LOGINDISABLED",
        "aaaa OK Pre-login capabilities listed",
        "* BYE Logging out",
        "aaab OK Logout completed";
    my @server-get =
        "aaaa CAPABILITY",
        "aaab LOGOUT";
    has $.host;
    has $.port;
    has $.input-line-separator is rw = "\n";
    method new(:$host, :$port){
        self.bless(:$host, :$port);
    }
    method get {
        return @server-send.shift;
    }
    method send($string is copy) {
        $string .= substr(0, *-2); # strip \r\n
        die "Bad client-send" unless $string eq @server-get.shift;
    }
    method close { }
}

use Net::IMAP;

ok True, "Module loaded";

my $imap = Net::IMAP.new(:server('foo.com'), :raw, :socket(IMAPSocket));

is $imap.conn.host, 'foo.com', 'Correct server';
is $imap.conn.port, 143, 'Correct port';
is $imap.conn.input-line-separator, "\r\n", 'Good line sep';

ok $imap ~~ Net::IMAP::Raw, 'Is raw object';
ok $imap.get-response ~~ /^\*\sOK/, 'Got initial untagged response';
ok $imap.capability.split(/\r\n/).elems == 2, 'Got untagged data followed by tagged response';
ok $imap.logout ~~ /BYE/, 'Can log out';
