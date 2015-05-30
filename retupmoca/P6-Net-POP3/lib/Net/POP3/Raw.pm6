unit role Net::POP3::Raw;

use Digest;

has $.conn is rw;
has $!timestamp;
has $!first-received;

method get-response(:$multiline) {
    my $line = $.conn.get;

    # get the timestamp (if it exists) so we can do apop logins
    #
    # Should maybe not be doing this here, as it's the only place we actually
    # need state in this role
    unless $!first-received {
        $!first-received = 1;
        $line ~~ /(\<<-[>]>\>)/;
        if $0 {
            $!timestamp = $0.Str;
        }
    }

    unless $multiline {
        return $line;
    }
    if $line.substr(0,4) eq '-ERR' {
        # error responses are not multiline
        return $line;
    }

    # multiline: wait for a lonely dot
    my $response = $line;
    while $line ne '.' {
        if $line.substr(0,1) eq '.' {
            $line = $line.substr(1);
        }
        $line = $.conn.get;
        if $line ne '.' {
            $response ~= "\r\n"~$line;
        }
    }
    return $response;
}

method send($stuff, :$multiline-response) {
    $.conn.send($stuff ~ "\r\n");
    return self.get-response(:multiline($multiline-response));
}

method quit {
    return self.send("QUIT");
}

method stat {
    return self.send("STAT");
}

method list($msgnum?) {
    if $msgnum {
        return self.send("LIST $msgnum");
    } else {
        return self.send("LIST", :multiline-response);
    }
}

method retr($msgnum) {
    return self.send("RETR $msgnum", :multiline-response);
}

method dele($msgnum) {
    return self.send("DELE $msgnum");
}

method noop {
    return self.send("NOOP");
}

method rset {
    return self.send("RSET");
}

method top($msgnum, $lines) {
    return self.send("TOP $msgnum $lines", :multiline-response);
}

method uidl($msgnum?) {
    if $msgnum {
        return self.send("UIDL $msgnum");
    } else {
        return self.send("UIDL", :multiline-response);
    }
}

method user($username) {
    return self.send("USER $username");
}

method pass($pass) {
    return self.send("PASS $pass");
}

method apop($login, $digest) {
    return self.send("APOP $login $digest");
}
method apop-login($login, $pass) {
    unless $!timestamp {
        die "No timestamp found for APOP login - perhaps this server doesn't support APOP?";
    }
    my $digest = md5(($!timestamp ~ $pass).encode).list».fmt("%02x").join;
    return self.apop($login, $digest);
}
