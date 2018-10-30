unit role Net::SMTP::Raw;

use MIME::Base64;
use Digest;
use Digest::HMAC;
use IO::Socket::SSL;

has $.conn is rw;

method get-response() {
    my $line = $.conn.get;
    my $response = $line;
    while $line.substr(3,1) ne ' ' {
        $line = $.conn.get;
        $response ~= "\r\n"~$line;
    }
    return $response;
}

method send($stuff) {
    $.conn.print($stuff ~ "\r\n");
    return self.get-response;
}

method ehlo($hostname = gethostname()) {
    return self.send("EHLO $hostname");
}

method helo($hostname = gethostname()) {
    return self.send("HELO $hostname");
}

method starttls() {
    return self.send("STARTTLS");
}
method switch-to-ssl() {
    $!conn = IO::Socket::SSL.new(:client-socket($.conn));
    $!conn.input-line-separator = "\r\n";
}

method mail-from($address) {
    return self.send("MAIL FROM:$address");
}

method rcpt-to($address) {
    return self.send("RCPT TO:$address");
}

method data() {
    return self.send("DATA");
}

method payload($mail is copy) {

    # Dot-stuffing!
    # RFC 5321, section 4.5.2:
    # every line that begins with a dot has one additional dot prepended to it.
    my @lines = $mail.split("\r\n");
    for @lines -> $_ is rw {
        if $_.substr(0,1) eq '.' {
            $_ = '.' ~ $_;
        }
    }
    $mail = @lines.join("\r\n");

    if $mail.substr(*-2,2) ne "\r\n" {
        $mail ~= "\r\n";
    }
    return self.send($mail ~ ".");
}

method rset() {
    return self.send("RSET");
}

method quit() {
    return self.send("QUIT");
}

method auth-login($username, $password) {
    my $encoded = MIME::Base64.encode-str($username);
    my $resp = self.send("AUTH LOGIN $encoded");
    if $resp.substr(0,1) eq '3' {
        my $encoded = MIME::Base64.encode-str($password);
        return self.send($encoded);
    } else {
        return $resp;
    }
}

method auth-plain($username, $password) {
    my $encoded = MIME::Base64.encode-str("$username\0$username\0$password");
    return self.send("AUTH PLAIN $encoded");
}

method auth-cram-md5($username, $password) {
    my $resp = self.send("AUTH CRAM-MD5");
    my $data;
    if $resp.substr(0,1) eq '3' {
        $data = MIME::Base64.decode-str($resp.substr(4));
    } else {
        return $resp;
    }
    my $encoded = MIME::Base64.encode-str($username ~ " " ~ hmac-hex($password, $data, &md5));
    return self.send($encoded);
}
