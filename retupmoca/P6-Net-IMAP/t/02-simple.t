use v6;
use Test;

plan 3;

class IMAPSocket {
    my @server-send =
        "* OK Ready",
        "* CAPABILITY TEST JUSTATEST",
        "aaaa OK CAPABILITY completed",
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
    method print($string is copy) {
        $string .= chomp; # strip \r\n
        die "Bad client-send" unless $string eq @server-get.shift;
    }
    method close { }
}

use Net::IMAP;

my $imap = Net::IMAP.new(:server('foo.com'), :socket(IMAPSocket));

ok $imap ~~ Net::IMAP::Simple, 'Is simple object';
ok $imap.capabilities ~~ ['TEST', 'JUSTATEST'], 'Got correct capabilities';
ok $imap.logout, 'Can log out';
