unit role Net::SMTP::Simple;

use Email::Simple;

has $.smtp-raw is rw;
has $.hostname is rw;
has @.auth-methods is rw;
has $.auth-methods-raw is rw;
my @supported-auth = "CRAM-MD5", "PLAIN", "LOGIN";

class X::Net::SMTP is Exception {
    has $.server-response;
    has $.nicename;
    method message {
        return ($.nicename // self.^name) ~ " The server responded with\n" ~ $.server-response;
    }
    method new($response) {
        self.bless(:server-response($response));
    }
}
class X::Net::SMTP::Address is Exception {
    has $.server-response;
    has $.address;
    has $.nicename;
    method message {
        my $address = 'address';
        if $.address.list.elems > 1 {
            $address = 'addresses';
        }
        my $response = ($.nicename // self.^name) ~ " The following $address failed to send:\n"
                        ~ $.address.list.join("\n");
        if $.server-response {
            $response ~= "\nThe server responded with\n"
                          ~ $.server-response;
        }
        return $response;
    }
    method new($response, $address) {
        self.bless(:server-response($response), :$address);
    }
}

class X::Net::SMTP::BadGreeting is X::Net::SMTP { has $.nicename = 'Bad greeting from server: '; };
class X::Net::SMTP::BadHELO is X::Net::SMTP { has $.nicename = 'Unable to successfully HELO: '; };
class X::Net::SMTP::BadFrom is X::Net::SMTP::Address { has $.nicename = 'Bad from address: '; };
class X::Net::SMTP::BadTo is X::Net::SMTP::Address { has $.nicename = 'Bad to address: '; };
class X::Net::SMTP::NoValidTo is X::Net::SMTP::Address { has $.nicename = 'No valid to addresses: '; };
class X::Net::SMTP::BadData is X::Net::SMTP { has $.nicename = 'Unable to enter DATA mode: '; };
class X::Net::SMTP::BadPayload is X::Net::SMTP { has $.nicename = 'Unable to send message: '; };
class X::Net::SMTP::SomeBadTo is X::Net::SMTP::Address { has $.nicename = 'Some to addresses failed to send: '; };
class X::Net::SMTP::AuthFailed is X::Net::SMTP { has $.nicename = 'Authentication failed: '; };
class X::Net::SMTP::NoAuthMethods is X::Net::SMTP { has $.nicename = 'No valid authentication methods found.'; };

method start {
    $.smtp-raw = self.new(:server($.server), :port($.port), :raw, :debug($.debug), :socket($.socket), :ssl($.ssl), :starttls($.tls), :plain($.plain));
    $.smtp-raw.switch-to-ssl() if $.ssl;
    
    my $in-starttls = False;
    my $greeting = $.smtp-raw.get-response;
    return fail(X::Net::SMTP::BadGreeting.new($greeting)) unless self._check-response($greeting);
    
    loop {
        my $helo = $.smtp-raw.ehlo($.hostname);
        unless self._check-response($helo, :noquit) {
            # OK, either we can't EHLO, or something is screwy...
            # fall back to HELO
            $helo = $.smtp-raw.helo($.hostname);
            return fail(X::Net::SMTP::BadHELO.new($helo)) unless self._check-response($helo);
        }
        
        # do stuff with $helo here - get auth methods, *
        $.auth-methods-raw = '';
        @.auth-methods = [];
        $helo ~~ /250[\s|\-]AUTH (<-[\r]>+)/;
        if $0 {
            $.auth-methods-raw = $0.Str;
            my @list = $0.split(' ');
            for @list -> $val {
                if @supported-auth.grep(* eq $val) {
                    @.auth-methods.push($val);
                }
            }
        }
        
        last if $in-starttls;
        
        $helo ~~ /250[\s|\-](STARTTLS)/;
        if !$in-starttls && ($.tls || ($0 && !$.plain && !$.ssl)) {
            my $starttls = $.smtp-raw.starttls();
            if $starttls ~~ /^220/ {
                $.smtp-raw.switch-to-ssl();
                $in-starttls = True;
            } else {
                if $.tls {
                    return fail(X::Net::SMTP::BadHELO($starttls));
                }
            }
        }
        
        last unless $in-starttls;
    }

    return True;
}

method auth($username, $password, :$methods is copy, :$disallow, :$force) {
    $methods //= @.auth-methods;
    my @methods = $methods.list;
    my @disallow = $disallow.list;
    for @methods -> $method {
        # skip an auth method if we don't know how to implement it
        unless $force || @supported-auth.grep(* eq $method) {
            next;
        }
        # skip an auth method if it was explicitly disallowed
        if @disallow.grep(* eq $method) {
            next;
        }
        
        my $response = '';
        given $method {
            when "CRAM-MD5" { $response = $.smtp-raw.auth-cram-md5($username, $password); }
            when "PLAIN" { $response = $.smtp-raw.auth-plain($username, $password); }
            when "LOGIN" { $response = $.smtp-raw.auth-login($username, $password); }
        }
        unless $response {
            die "Code in Net::SMTP::Simple.auth doesn't handle all auth methods"
                ~ " it says it does.";
        }
        
        if $response.substr(0,1) eq '2' {
            return True;
        } else {
            return fail(X::Net::SMTP::AuthFailed.new($response));
        }
    }
    return fail(X::Net::SMTP::NoAuthMethods.new(''));
}

multi method send($from, $to, $message, :$keep-going) {
    my $response = $.smtp-raw.mail-from($from);
    return fail(X::Net::SMTP::BadFrom.new($response, $from)) unless self._check-response($response);
    my $to-count;
    my @bad-addresses;
    for $to.list {
        $response = $.smtp-raw.rcpt-to($_);
        if $keep-going {
            if self._check-response($response, :noquit) {
                $to-count++;
            } else {
                @bad-addresses.push($_);
            }
        } else {
            return fail(X::Net::SMTP::BadTo.new($response, $_)) unless self._check-response($response);
            $to-count++;
        }
    }
    unless $to-count {
        $.smtp-raw.rset;
        return fail(X::Net::SMTP::NoValidTo('', @bad-addresses));
    }
    $response = $.smtp-raw.data;
    return fail(X::Net::SMTP::BadData.new($response)) unless self._check-response($response);
    $response = $.smtp-raw.payload(~$message);
    return fail(X::Net::SMTP::BadPayload.new($response)) unless self._check-response($response);

    if $keep-going && +@bad-addresses {
        return fail(X::Net::SMTP::SomeBadTo.new('', @bad-addresses)) but True;
    } else {
        return True;
    }
}

multi method send($message, :$keep-going) {
    my $parsed;
    if ($message ~~ Email::Simple) {
        $parsed = $message;
    } else {
        $parsed = Email::Simple.new(~$message);
    }
    my $from = $parsed.header('From');
    my @to = $parsed.header('To');
    @to.push($parsed.header('CC').list);
    @to.push($parsed.header('BCC').list);
    $parsed.header-set('BCC'); # clear the BCC headers

    return self.send($from, @to, $parsed, :$keep-going);
}

method quit {
    $.smtp-raw.quit;
    $.smtp-raw.conn.close;
    return True;
}

method _check-response($response, :$noquit) {
    if $response.substr(0,1) ne '2'|'3' {
        $.smtp-raw.rset unless $noquit;
        return False;
    }
    return True;
}
