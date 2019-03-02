use v6;

unit module HTTP::Server::Smack::Util;

my class X::HTTP::Server::Smack::BadHeader is Exception {
    method message() { 'Header does not end correctly' }
}

my constant $CRLF  = Buf.new("\x0a\x0d";
my constant $CRLF2 = $CRLF x 2;

sub parse-http-headers($conn, :$buf! is rw) is export {
    my $header-end;
    my $checked-through = 3;

    while my $tbuf = $conn.recv(:bin) {
        $buf ~= $tbuf;

        CRLF: for $checked-through .. $buf.end {
            next CRLF unless $buf.subbuf($_-3, 4) eq $CRLF2;
            #next CRLF unless $whole-buf[$_-3] == CR;
            #next CRLF unless $whole-buf[$_-2] == LF;
            #next CRLF unless $whole-buf[$_-1] == CR;
            #next CRLF unless $whole-buf[$_-0] == LF;

            $header-end = $_;
            last CRLF;
        }

        if $header-end {
            last;
        }
        else {
            $checked-through = $buf.end - 2;
        }
    }

    # Header never ended!
    unless $header-end {
        X::HTTP::Server::Smack::BadHeader.new.throw;
    }

    $header-end
}
