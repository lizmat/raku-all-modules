use v6;
use Test;

plan 2;

class IMAPSocket {
    my @server-send =
        "* OK Ready",
        "* BYE Logging out",
        "aaaa OK Logout completed";
    my @server-get =
        "aaaa LOGOUT";
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

my $imap = Net::IMAP.new(:server('foo.com'), :socket(IMAPSocket));

ok $imap ~~ Net::IMAP::Simple, 'Is simple object';
ok $imap.logout, 'Can log out';
