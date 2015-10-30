use v6;
use Test;

plan 4;

class SMTPSocket {
    my @server-send = 
      "220 your.domain.here ESMTP Postfix",
      "250 Hello clientdomain.com",
      "250 Ok",
      "250 Ok",
      "354 End data with a single '.'",
      "250 Ok: queued",
      "250 Ok",
      "250 Ok",
      "354 End data with a single '.'",
      "250 Ok: queued",
      "221 Bye"
      ;
    my @server-get = 
      "EHLO clientdomain.com",
      "MAIL FROM:foo\@bar.com",
      "RCPT TO:bar\@foo.com",
      "DATA",
      "Subject:test\r\nFrom:foo\@bar.com\r\nTo:bar\@foo.com\r\n\r\nTest\r\n.",
      "MAIL FROM:foo\@bar.com",
      "RCPT TO:bar\@foo.com",
      "DATA",
      "Subject: test\r\nFrom: foo\@bar.com\r\nTo: bar\@foo.com\r\n\r\nTest\r\n.", # Email::Simple adds spaces to headers
      "QUIT"
      ;

    has $.host;
    has $.port;
    has $.input-line-separator is rw = "\n";
    method new(:$host, :$port) {
        self.bless(:$host, :$port);
    }
    method get {
        return @server-send.shift;
    }
    method print($string is copy) {
        $string .= substr(0,*-2); # strip \r\n
        die "Bad client-send: $string" unless $string eq @server-get.shift;
    }
    method close { }
}

use Net::SMTP;

my $client = Net::SMTP.new(:server('foo.com'), :port(25), :hostname('clientdomain.com'), :socket(SMTPSocket));
ok $client ~~ Net::SMTP, "Created object";
ok $client.send('foo@bar.com', 'bar@foo.com', "Subject:test\r\nFrom:foo\@bar.com\r\nTo:bar\@foo.com\r\n\r\nTest"), "Send message";
ok $client.send("Subject:test\r\nFrom:foo\@bar.com\r\nTo:bar\@foo.com\r\n\r\nTest"), "Send message (extracting from/to lines)";
ok $client.quit, "QUIT";
