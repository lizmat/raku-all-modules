use v6;

unit module HTTP::Parser;

grammar HTTPRequestHead {
    token TOP {
        (
            <.CRLF>* # pre-header blank lines are allowed (RFC 2616 4.1)
            <.request-line> <.CRLF>
            [ <.header-field> <.CRLF> ]*
            <.CRLF>
        )
        .* # body
    }
    token request-line { <method> <.SP> <request-target> <.SP> <HTTP-version> }
    token method { <.token> }
    token request-target { <path> [ '?' <query> ]? }
    token path { <-[?#\ ]>* }
    token query { <-[#\ ]>* }

    token CRLF { \x[0d] \x[0a] || \x[0a] }

    token HTTP-version {
        "HTTP/1." <[0..1]>
    }

    # See RFC 7230 3.2.  Header Fields
    # 3.2.6.  Field Value Components
    token header-field { <field-name> ':' <.OWS> <field-value> <.OWS> }
    token field-name { <.token> }
    token field-value { <field-content> [ <.obs-fold> <field-content> ]* }

    token field-content { \N* }

    token obs-fold { <.CRLF> [ <.SP> || <.HTAB> ]+ }

    # https://tools.ietf.org/html/rfc5234#appendix-B.1
    # visible (printing) characters
    token VCHAR { <[\x21 .. \x7E]> }

    token OWS { [ ' ' | "\t" ]* }

    token SP { "\x20" }
    token HTAB { "\x09" }

    token token {
        ["!" || "#" || '$' || "%" || "&" || "'" || "*"
                    || "+" || "-" || "." || "^" || "_" || "`" || "|" || "~"
                    || <[0..9]> || <[A..Z a..z]>]+ }
}

my class HTTPRequestHeadAction {
    has %.env;

    method TOP($/) {
        $/.make: $/[0].Str.encode('latin1').bytes;
    }

    method method($/) {
        %!env<REQUEST_METHOD> = ~$/;
    }
    method request-target($/) {
        %!env<REQUEST_URI> = ~$/;
        %!env<QUERY_STRING> //= '';
    }
    method path($/) {
        my $path = (~$/).subst(/'%' (<[0..9 A..F a..f]> ** 2)/, -> $/ {chr(:16(~$/[0]))}, :global);
        %!env<PATH_INFO> = $path;
    }
    method query($/) {
        %!env<QUERY_STRING> = ~$/;
    }
    method HTTP-version($/) {
        %!env<SERVER_PROTOCOL> = ~$/;
    }

    method header-field($/) {
        %!env{$/<field-name>.made} = ~$/<field-value>;
    }

    method field-value($/) {
        $/.make: $/<field-content>».made.join("");
    }

    method field-content($/) { $/.make: ~$/ }

    method field-name($/) {
        my $name = $/.Str.subst(/\-/, '_', :g).uc;
        if $name ne 'CONTENT_LENGTH' && $name ne 'CONTENT_TYPE' {
            $name = 'HTTP_' ~ $name;
        }
        $/.make: $name;
    }
}


# >0: header size
# -1: failed
# -2: request is partial
sub parse-http-request(Blob $req) is export {
    my $decoded = $req.decode('ascii');

    my $actions = HTTPRequestHeadAction.new();
    my $got = HTTPRequestHead.parse($decoded, :$actions);
    if $got {
        $actions.env<SCRIPT_NAME> = '';
        return $got.made, $actions.env;
    } else {
        # pre-header blank lines are allowed (RFC 2616 4.1)
        $decoded = $decoded.subst(/ [ \x0d\x0a || \x0a ]* /, '');
        return $decoded ~~ / [\x0d\x0a || \x0a]  [\x0d\x0a || \x0a] / ?? -1 !! -2;
    }
}

=begin pod

=head1 NAME

HTTP::Parser - HTTP parser.

=head1 SYNOPSIS

    use HTTP::Parser;

    my ($result, $env) = parse-http-request("GET / HTTP/1.0\x0d\x0acontent-type: text/html\x0d\x0a\x0d\x0a".encode("ascii"));
    # $result => 43
    # $env => ${:CONTENT_TYPE("text/html"), :PATH_INFO("/"), :QUERY_STRING(""), :REQUEST_METHOD("GET")}

=head1 DESCRIPTION

HTTP::Parser is tiny http request parser library for perl6.

=head1 FUNCTIONS

=item C<my ($result, $env) = sub parse-http-request(Blob[uint8] $req) is export>

parse http request.

C<$req> must be C<Blob[uint8]>. Not B<utf8>.

Tries to parse given request string, and if successful, inserts variables into C<$env>.  For the name of the variables inserted, please refer to the PSGI specification.  The return values are:

=item2 >=0

length of the request (request line and the request headers), in bytes

=item2 -1

given request is corrupt

=item2 -2

given request is incomplete

=head1 COPYRIGHT AND LICENSE

Copyright 2015 Tokuhiro Matsuno <tokuhirom@gmail.com>

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
