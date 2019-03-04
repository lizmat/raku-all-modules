use v6;

unit class Smack::Request;

use HTTP::Headers;
use Hash::MultiValue;
use URI::Escape;

has %.env;

method new(%env) {
    return self.bless(:%env);
}

method protocol     is rw { return-rw %!env<SERVER_PROTOCOL> }
method method       is rw { return-rw %!env<REQUEST_METHOD> }
method host         is rw { return-rw %!env<SERVER_NAME> }
method port         is rw { return-rw %!env<SERVER_PORT> }
method user         is rw { return-rw %!env<REMOTE_USER> }
method request-uri  is rw { return-rw %!env<REQUEST_URI> }
method path-info    is rw { return-rw %!env<PATH_INFO> }
method path               { %!env<PATH_INFO> // '/' }
method query-string is rw { return-rw %!env<QUERY_STRING> }
method script-name  is rw { return-rw %!env<SCRIPT_NAME> }
method scheme       is rw { return-rw %!env<p6w.url_scheme> }
method secure             { self.scheme eq 'https' }
method body         is rw { return-rw %!env<p6w.input> }
method input        is rw { return-rw %!env<p6w.input> }

method session         is rw { return-rw %!env<p6wx.session> }
method session_options is rw { return-rw %!env<p6wx.session.options> }
method logger          is rw { return-rw %!env<p6wx.logger> }

method cookies returns Hash {
    return {} unless self.Cookie;

    my @cookies = self.Cookie.Str.comb(/<-[ ; , ]>+/).grep(/'='/);
    my %cookies = @cookies.map(*.trim.split('=', 2)).map({ uri-unescape($_) });
    return %cookies;
}

method query-parameters(Smack::Request:D: Str $s?) {
    unless %!env<smack.request.query>.defined {
        %!env<smack.request.query> := Hash::MultiValue.from-pairs(self!parse-query);
    }

    # Kinda dumb...
    if $s.defined {
        %!env<smack.request.query>($s);
    }
    else {
        %!env<smack.request.query>;
    }
}

method !parse-urlencoded-string($qs) {
    return [] unless $qs.defined;

    my @qs = do for $qs.comb(/<-[ & ; ]>+/) {
        when / '=' / {
            my ($key, $value) = .split(/ '=' /, 2).map({ uri-unescape( .subst(/ '+' /, ' ', :g)) });
            ~$key => ~$value
        }
        default {
            uri-unescape( .subst(/ '+' /, ' ', :g) ) => Str but True
        }
    }

    @qs;
}

method !parse-query {
    self!parse-urlencoded-string(%!env<QUERY_STRING>);
}

has $!_raw-content-cache;
method raw-content(--> Blob) {
    $!_raw-content-cache //= (await self.input.reduce(&infix:<~>)) // Blob.new
}

method content {
    warn "decoding content with non-text Content-Type and no defined charset"
        unless self.Content-Type.is-text
            || self.Content-Type.primary eq 'application/x-www-form-urlencoded' # this OK too
            || self.Content-Type.charset.defined;

    # RFC 2616 says ISO-8859-1 is assumed when no charset is given
    my $encoding = self.Content-Type.charset // 'ISO-8859-1';

    self.raw-content.decode($encoding);
}

has HTTP::Headers $.headers handles <header Content-Length Content-Type> = self!build-headers;

method !build-headers {
    my $headers = HTTP::Headers.new;
    for %!env.kv -> $k, $v {
        next unless $k ~~ /^ [ HTTP | CONTENT ] /;
        my $name = $k.subst(/^ HTTPS? _ /, '');
        $headers.header($name, :quiet) = $v;
    }

    return $headers;
}

method body-parameters(Smack::Request:D: Str $s?) {
    unless %!env<smack.request.body> {
        warn "reading parameters from body, but Content-Type is not application/x-www-form-urlencoded"
            unless self.Content-Type.primary eq 'application/x-www-form-urlencoded';


        %!env<smack.request.body> = Hash::MultiValue.from-pairs(self!parse-urlencoded-string(self.content));
    }

    if $s.defined {
        %!env<smack.request.body>($s);
    }
    else {
        %!env<smack.request.body>;
    }
}

method parameters(Smack::Request:D: Str $s?) {
    unless %!env<smack.request.merged> {
        %!env<smack.request.merged> = Hash::MultiValue.from-pairs(
            self.query-parameters.all-pairs,
            self.body-parameters.all-pairs,
        )
    }

    if $s.defined {
        %!env<smack.request.merged>($s);
    }
    else {
        %!env<smack.request.merged>;
    }
}

method param(Smack::Request:D: Str $s?) {
    if $s.defined {
        self.parameters($s)
    }
    else {
        self.parameters
    }
}
