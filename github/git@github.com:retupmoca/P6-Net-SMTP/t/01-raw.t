use v6;
use Test;

plan 12;

class SMTPSocket {
    my @server-send = 
      "220 your.domain.here ESMTP Postfix",
      "250 Hello clientdomain.com",
      "250 Ok",
      "250 Ok",
      "354 End data with a single '.'",
      "250 Ok: queued",
      "221 Bye"
      ;
    my @server-get = 
      "HELO clientdomain.com",
      "MAIL FROM:foo\@bar.com",
      "RCPT TO:bar\@foo.com",
      "DATA",
      "Subject:test\r\nFrom:foo\@bar.com\r\nTo:bar\@foo.com\r\n\r\nTest\r\n.",
      "QUIT"
      ;

    has $.host;
    has $.port;
    has $.nl-in is rw = "\n";
    method new(:$host, :$port) {
        self.bless(:$host, :$port);
    }
    method get {
        return @server-send.shift;
    }
    method print($string is copy) {
        $string.subst-mutate(/\r\n$/,'');
        die "Bad client-send" unless $string eq @server-get.shift;
    }
}

use Net::SMTP;

ok True, "Module loaded";

my $client = Net::SMTP.new(:server('foo.com'), :port(25), :raw, :socket(SMTPSocket));

ok $client ~~ Net::SMTP, "Created raw class";
ok $client.conn.host eq 'foo.com', "with right host";
ok $client.conn.port eq '25', 'with right port';
ok $client.conn.nl-in eq "\r\n", 'with right line sep';

ok $client.get-response.substr(0,1) eq '2', 'Greeting';
ok $client.helo('clientdomain.com').substr(0,1) eq '2', 'HELO';
ok $client.mail-from('foo@bar.com').substr(0,1) eq '2', 'MAIL FROM';
ok $client.rcpt-to('bar@foo.com').substr(0,1) eq '2', 'RCPT TO';
ok $client.data.substr(0,1) eq '3', 'DATA';
ok $client.payload("Subject:test\r\nFrom:foo\@bar.com\r\nTo:bar\@foo.com\r\n\r\nTest").substr(0,1) eq '2', 'Message send';
ok $client.quit.substr(0,1) eq '2', 'QUIT';
