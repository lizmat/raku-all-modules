unit role Net::POP3::Simple;

use Net::POP3::Message;

has $.raw is rw;
has $.authed = True;
has @.capabilities;

my class X::Net::POP3::BadGreeting is Exception { };
my class X::Net::POP3::BadAuth is Exception { };
my class X::Net::POP3::NoMessageCount is Exception { };
my class X::Net::POP3::NoMessageList is Exception { };

method start {
    $.raw = self.new(:server($.server), :port($.port), :raw, :debug($.debug), :socket($.socket));
    $.raw.switch-to-ssl() if $.ssl;

    my $greeting = $.raw.get-response;
    return fail(X::Net::POP3::BadGreeting.new) unless $greeting.substr(0,3) eq '+OK';

    self.get_capabilities;

    if @!capabilities.grep('STLS') {
        if !$.plain && !$.ssl {
            if $.raw.stls.substr(0,3) eq '+OK' {
                $.raw.switch-to-ssl;
                self.get_capabilities;
            }
            elsif $.tls {
                return fail("STARTTLS failed!");
            }
        }
    }
    elsif $.tls {
        return fail("Server does not support STARTTLS");
    }

    return True;
}

method get_capabilities {
    my $capa = $.raw.capa;
    if $capa.substr(0,3) eq '+OK' {
        my @lines = $capa.split("\r\n");
        @lines.shift; # remove the OK line
        @!capabilities = @lines;
    }
}

method auth($username, $password) {
    my $response;
    try {
        $response = $.raw.apop-login($username, $password);
    }
    if $! || $response.substr(0,3) ne '+OK' {
        my $response = $.raw.user($username);
        unless $response.substr(0,3) eq '+OK' {
            return fail(X::Net::POP3::BadAuth.new);
        }
        $response = $.raw.pass($password);
        return fail(X::Net::POP3::BadAuth.new) unless $response.substr(0,3) eq '+OK';
    }
    $!authed = True;
    return True;
}

method message-count() {
    my $stat = $.raw.stat;
    if $stat ~~ /^\+OK ' ' (\d+) ' ' (\d+) $/ {
        return $0;
    } else {
        return fail(X::Net::POP3::NoMessageCount.new);
    }
}

method get-messages() {
    my $list = $.raw.list;
    unless $list.substr(0,3) eq '+OK' {
        return fail(X::Net::POP3::NoMessageList.new);
    }

    my @return;

    my @messages = $list.split("\r\n");
    @messages = @messages[1..*]; # strip the +OK
    for @messages -> $msg-line {
        my @parts = $msg-line.split(' ');
        my $size = @parts[1];
        my $sid = @parts[0];

        @return.push(Net::POP3::Message.new(sid  => $sid,
                                            size => $size,
                                            pop  => self));
    }

    return @return;
}

multi method get-message(:$uid!) {
    die "NYI";
}

multi method get-message(:$sid!) {
    return Net::POP3::Message.new(sid => $sid, pop => self);
}

method quit {
    $.raw.quit;
    $.raw.conn.close;
    return True;
}
