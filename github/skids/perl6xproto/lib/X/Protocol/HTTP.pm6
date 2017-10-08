use X::Protocol;
# Since we may end up used by some important stuff, be backward compatible
# for a while
#unit class X::Protocol::HTTP is X::Protocol;
class X::Protocol::HTTP is X::Protocol {

=NAME X::Protocol::HTTP - Perl6 Exception class for HTTP results

=begin SYNOPSIS
=begin code

    use X::Protocol::HTTP;

    $result = get_some_object_from_an_HTTP_library();

    # Assuming $result stringifies usefully, just hook it with :origin
    X::Protocol::HTTP.new(:code($result.status) :origin($result)).toss;

=end code
=end SYNOPSIS

=begin DESCRIPTION

The C<X::Protocol::HTTP> contains adjustments to X::Protocol for HTTP.
This includes standard human-readable strings, and some additional
"severity" levels that may be useful for flow control decisions.

Additional tweaks can be added easily by subclassing.  Suggestions
for better defaults are always welcome.

Codes between 400 and 499 are of severity "error" and C<.toss> will
throw them.  Codes 500 and above are of severity "failure" and
C<.toss> will result in a C<Failure>.

=end DESCRIPTION

has $.origin; # Place to hook URLs or such.  Will be stringified.

method protocol { 'HTTP' }

method codes {
    {
        100 => 'Continue',
        101 => 'Switching Protocols',
        102 => 'Processing',                      # RFC 2518 (WebDAV)
        200 => 'OK',
        201 => 'Created',
        202 => 'Accepted',
        203 => 'Non-Authoritative Information',
        204 => 'No Content',
        205 => 'Reset Content',
        206 => 'Partial Content',
        207 => 'Multi-Status',                    # RFC 2518 (WebDAV)
        208 => 'Already Reported',                # RFC 5842
        300 => 'Multiple Choices',
        301 => 'Moved Permanently',
        302 => 'Found',
        303 => 'See Other',
        304 => 'Not Modified',
        305 => 'Use Proxy',
        307 => 'Temporary Redirect',
        400 => 'Bad Request',
        401 => 'Unauthorized',
        402 => 'Payment Required',
        403 => 'Forbidden',
        404 => 'Not Found',
        405 => 'Method Not Allowed',
        406 => 'Not Acceptable',
        407 => 'Proxy Authentication Required',
        408 => 'Request Timeout',
        409 => 'Conflict',
        410 => 'Gone',
        411 => 'Length Required',
        412 => 'Precondition Failed',
        413 => 'Request Entity Too Large',
        414 => 'Request-URI Too Large',
        415 => 'Unsupported Media Type',
        416 => 'Request Range Not Satisfiable',
        417 => 'Expectation Failed',
        418 => 'I\'m a teapot',                   # RFC 2324
        422 => 'Unprocessable Entity',            # RFC 2518 (WebDAV)
        423 => 'Locked',                          # RFC 2518 (WebDAV)
        424 => 'Failed Dependency',               # RFC 2518 (WebDAV)
        425 => 'No code',                         # WebDAV Advanced Collections
        426 => 'Upgrade Required',                # RFC 2817
        428 => 'Precondition Required',
        429 => 'Too Many Requests',
        431 => 'Request Header Fields Too Large',
        449 => 'Retry with',                      # unofficial Microsoft
        451 => 'Unavailable For Legal Reasons',   # IESG Dec 18, 2015 RFC TBA
        500 => 'Internal Server Error',
        501 => 'Not Implemented',
        502 => 'Bad Gateway',
        503 => 'Service Unavailable',
        504 => 'Gateway Timeout',
        505 => 'HTTP Version Not Supported',
        506 => 'Variant Also Negotiates',         # RFC 2295
        507 => 'Insufficient Storage',            # RFC 2518 (WebDAV)
        509 => 'Bandwidth Limit Exceeded',        # unofficial
        510 => 'Not Extended',                    # RFC 2774
        511 => 'Network Authentication Required',
    }
}

method severity {
    given $.status {
        # Hopefully these will be useful.  Suggestions welcome.
        when 102 { "delay" }
        when 208|304 { "unchanged" }
        when 207 { "followup" }
        when { +$_ < 300 } { "success" }
        when { +$_ < 400 } { "followup" }
        when { +$_ < 500 } { "error" }
	default { "failure" }
    }
}

method gist {
    given $.origin {
        return callsame unless $_;
        callsame ~ "\n(From $_)";
    }
}

=AUTHOR Brian S. Julin

=begin COPYRIGHT

Copyright (c) 2015 Brian S. Julin. All rights reserved.

Codes and human-readable text were taken from HTTP::Message,
    Copyright (c) 1995-2008 Gisle Aas.

=end COPYRIGHT

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Exception::(pm3) HTTP::Status(pm3)>

# temporary backwards compatibility instead of "unit"
}